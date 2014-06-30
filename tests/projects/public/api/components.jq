import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";

import module namespace components = "http://xbrl.io/modules/bizql/components";
import module namespace sec-networks = "http://xbrl.io/modules/bizql/profiles/sec/networks";

import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace csv = "http://zorba.io/modules/json-csv";
import module namespace session = "http://apps.28.io/session";

declare function local:to-csv($res as object*) as string*
{
    csv:serialize(
        for $a in flatten($res.Archives)
        for $c in flatten($a.Components)
        return { 
            AcessionNumber : $a.AccessionNumber,
            EntityRegistrantName : $a.EntityRegistrantName,
            CIK : $a.CIK,
            FiscalYear : $a.FiscalYear,
            FiscalPeriod : $a.FiscalPeriod,
            AcceptanceDateTime : $a.AcceptanceDatetime,
            FormType : $a.FormType,
            NetworkLabel : $c.NetworkLabel,
            NetworkIdentifier : $c.NetworkRole,
            Category : $c.Category,
            SubCategory : $c.SubCategory,
            Table : flatten($c.Table),
            Disclosure : $c.Disclosure,
            ReportElements : $c.ReportElements,
            Tables : $c.Tables,
            Axis : $c.Axis,
            Members : $c.Members,
            LineItems : $c.LineItems,
            Concepts : $c.Concepts,
            Abstracts : $c.Abstracts
        },
    { serialize-null-as : "" }) 
};


declare function local:filings(
    $ciks as string*,
    $tags as string*,
    $tickers as string*,
    $sics as string*,
    $fp as string*,
    $fy as string*) as object*
{
    let $entities := if ($tags = "ALL") then companies:companies()
                                        else (
                                            companies:companies($ciks),
                                            companies:companies-for-tags($tags),
                                            companies:companies-for-tickers($tickers),
                                            companies:companies-for-SIC($sics)
                                        )
    for $entity in $entities
    for $fy in distinct-values(
                for $fy in $fy
                return
                    switch ($fy)
                    case "LATEST" return
                        for $p in $fp
                        return
                            if ($p eq "FY")
                            then fiscal:latest-reported-fiscal-period($entity, "10-K").year 
                            else fiscal:latest-reported-fiscal-period($entity, "10-Q").year
                    case "ALL" return  $fiscal:ALL_FISCAL_YEARS
                    default return $fy cast as integer
                )
    for $fp in $fp 
    return fiscal:filings-for-entities-and-fiscal-periods-and-years($entity, $fp, $fy)
};

session:audit-call();

let $format      := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1])
let $ciks        := distinct-values(companies:eid(request:param-values("cik")))
let $tags        := distinct-values(request:param-values("tag") ! upper-case($$))
let $tickers     := distinct-values(request:param-values("ticker"))
let $sics        := distinct-values(request:param-values("sic"))
let $fiscalYears := distinct-values(
                        for $y in request:param-values("fiscalYear", "LATEST")
                        return
                            if ($y eq "LATEST" or $y eq "ALL")
                            then $y
                            else if ($y castable as integer)
                            then $y
                            else  ()
                    )
let $fiscalPeriods := distinct-values(let $fp := request:param-values("fiscalPeriod", "FY")
                      return
                        if (($fp ! lower-case($$)) = "all")
                        then $fiscal:ALL_FISCAL_PERIODS
                        else $fp)
let $aids        := archives:aid(request:param-values("aid"))
let $roles       := request:param-values("networkIdentifier")
let $archives    := (
                        local:filings($ciks, $tags, $tickers, $sics, $fiscalPeriods, $fiscalYears),
                        archives:archives($aids)
                    )
let $cid         := request:param-values("cid")
let $reportElements    := distinct-values(request:param-values("reportElement"))
let $disclosures := request:param-values("disclosure")
let $search := request:param-values("label")
let $components  := (if (exists($cid))
                    then components:components($cid)
                    else (),
                    if (exists($reportElements))
                    then sec-networks:networks-for-filings-and-reportElements($archives, $reportElements) 
                    else if (exists($disclosures))
                    then sec-networks:networks-for-filings-and-disclosures($archives, $disclosures) 
                    else if (exists($roles))
                    then sec-networks:networks-for-filings-and-roles($archives, $roles) 
                    else if (exists($search))
                    then sec-networks:networks-for-filings-and-label($archives, $search) 
                    else sec-networks:networks-for-filings($archives))
let $entities    := entities:entities($archives.Entity)
let $res         :=  { "Archives" : [
                        for $r in $components
                        let $disclosure := sec-networks:disclosures($r)
                        where $disclosure ne "DefaultComponent" and
                            exists(sec-networks:model-structures($r))
                        order by $r.Label
                        group by $archive := $r.Archive
                        let $archive := archives:archives($archive)
                        let $e := entities:entities($archive.Entity)
                        return
                        {
                          AccessionNumber : $archive._id,
                          EntityRegistrantName : $e.Profiles.SEC.CompanyName,
                          CIK : $e._id,
                          FiscalYear :$archive.Profiles.SEC.Fiscal.DocumentFiscalYearFocus,
                          FiscalPeriod :$archive.Profiles.SEC.Fiscal.DocumentFiscalPeriodFocus,
                          AcceptanceDatetime : $archive.Profiles.SEC.AcceptanceDatetime,
                          FormType : $archive.Profiles.SEC.FormType,
                          Components : [ 
                            $r ! sec-networks:summaries($$)
                          ]
                        }
                    ]}
return 
    if (session:only-dow30($entities) or session:valid())
    then {
        switch ($format)
        case "xml" return {
            response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
            (session:comment("xml", {
                    NumComponents : count($components),
                    TotalNumComponents: session:num-components(),
                    TotalNumArchives: session:num-archives()
                }),
             <Archives>{
                 for $r in flatten($res.Archives)
                 return
                     <Archive id="{$r.AccessionNumber}">
                        <EntityRegistrantName>{$r.EntityRegistrantName}</EntityRegistrantName>
                        <CIK>{$r.CIK}</CIK>
                        <FiscalYear>{$r.FiscalYear}</FiscalYear>
                        <FiscalPeriod>{$r.FiscalPeriod}</FiscalPeriod>
                        <AcceptanceDatetime>{$r.AcceptanceDatetime}</AcceptanceDatetime>
                        <FormType>{$r.FormType}</FormType>
                        <Components>{
                            sec-networks:summaries-to-xml(flatten($r.Components))
                        }</Components>
                    </Archive>
            }</Archives>)
        } 
            case "text" case "csv" return {
                response:content-type("text/csv");
                response:header("Content-Disposition", "attachment; filename=components.csv");
                string-join(local:to-csv($res), "")
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=components.csv");
                string-join(local:to-csv($res), "")
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    session:comment("json", {
                        NumComponents : count($components),
                        TotalNumComponents: session:num-components(),
                        TotalNumArchives: session:num-archives()
                    }), $res
                |}
            }
    } else {
        response:status-code(401);
        let $res := session:error("accessing components of an entity that is not in the DOW30", $format)
        return
            switch ($format)
            case "xml" return {
                response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
                (session:comment("xml"), $res)
            }
            case "text" case "csv" return {
                response:content-type("text/plain");
                $res
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=components.csv");
                $res
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    session:comment("json"),
                    $res
                |}
            }
    }
