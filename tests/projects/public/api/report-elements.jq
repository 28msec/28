import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace sec-fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace hypercubes = "http://xbrl.io/modules/bizql/hypercubes";
import module namespace components = "http://xbrl.io/modules/bizql/components";

import module namespace mongo = "http://www.28msec.com/modules/mongodb";
import module namespace credentials = "http://www.28msec.com/modules/credentials";
 
import module namespace csv = "http://zorba.io/modules/json-csv";

declare namespace concepts = "http://www.28msec.com/modules/bizql/concepts";

declare function local:to-csv($concepts as item*, $onlyNames as boolean) as string
{
    if ($onlyNames)
    then
        string-join(("Name", $concepts), "
")
    else
        string-join(csv:serialize($concepts, { serialize-null-as : "" }))
};

declare function local:to-xml($concepts as item*, $onlyNames as boolean) as element()*
{
    for $c in $concepts
    return
        <ReportElement>{
             if ($onlyNames)
             then
                <Name>{$c}</Name>
             else (
                <Name>{$c.Name}</Name>,
                <Label>{$c.Label}</Label>,
                <IsNillable>{$c.IsNillable}</IsNillable>,
                <IsAbstract>{$c.IsAbstract}</IsAbstract>,
                <PeriodType>{$c.PeriodType}</PeriodType>,
                <Balance>{$c.Balance}</Balance>,
                <SubstitutionGroup>{$c.SubstitutionGroup}</SubstitutionGroup>,
                <DataType>{$c.DataType}</DataType>,
                <BaseType>{$c.BaseType}</BaseType>,
                <ClosestSchemaBuiltinType>{$c.ClosestSchemaBuiltinType}</ClosestSchemaBuiltinType>,
                <IsTextBlock>{$c.IsTextBlock}</IsTextBlock>,
                <ComponentRole>{$c.ComponentRole}</ComponentRole>,  
                <ComponentLabel>{$c.ComponentLabel}</ComponentLabel>,
                <AccessionNumber>{$c.AccessionNumber}</AccessionNumber>,
                <CIK>{$c.CIK}</CIK>,
                <EntityRegistrantName>{$c.EntityRegistrantName}</EntityRegistrantName>,
                <FiscalYear>{$c.FiscalYear}</FiscalYear>,
                <FiscalPeriod>{$c.FiscalPeriod}</FiscalPeriod>
             )
        }</ReportElement>
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
                            then sec-fiscal:latest-reported-fiscal-period($entity, "10-K").year 
                            else sec-fiscal:latest-reported-fiscal-period($entity, "10-Q").year
                    case "ALL" return (2010 to 2015) (: temporary solution until next release :)
                    default return $fy
                )
    for $fp in $fp 
    return sec-fiscal:filings-for-entities-and-fiscal-periods-and-years($entity, $fp, $fy ! ($$ cast as integer))
};

declare function local:concepts-for-archives($aids as string*) as object*
{
    let $conn :=   
      let $credentials := credentials:credentials("MongoDB", "xbrl")
      return
        try {
            mongo:connect($credentials)
        } catch mongo:* {
            error(QName("concepts:CONNECTION-FAILED"), $err:description)
        }
    return
        mongo:find($conn, "concepts", 
        {
            "Archive": { "$in" : [ $aids ] }
        })
};

declare function local:concepts-for-archives($aids as string*, $names as string*) as object*
{
    let $conn :=   
      let $credentials := credentials:credentials("MongoDB", "xbrl")
      return
        try {
            mongo:connect($credentials)
        } catch mongo:* {
            error(QName("concepts:CONNECTION-FAILED"), $err:description)
        }
    return
        mongo:find($conn, "concepts", 
        {
            "Name" : { "$in" : [ $names ] },
            "Archive": { "$in" : [ $aids ] }
        })
};

declare function local:concepts-for-archives-and-labels($aids as string*, $labels as string) as object*
{
    let $conn :=
        let $credentials := credentials:credentials("MongoDB", "xbrl")
        return
            try {
                mongo:connect($credentials)
            } catch mongo:* {
                error(QName("components:CONNECTION-FAILED"), $err:description)
            }
    return mongo:run-cmd-deterministic(
        $conn,
        {
            "text" : "concepts",
            "filter" : { "Archive" : { "$in" : [ $aids ] } },
            "search" : $labels,
            "limit" : 100,
            "score" : { "$meta" : "textScore" },
            "sort" : { score: { "$meta" : "textScore" } }
        }).results[].obj
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
                            else ()
                    )
let $fiscalPeriods := distinct-values(let $fp := request:param-values("fiscalPeriod", "FY")
                      return
                        if (($fp ! lower-case($$)) = "all")
                        then ("Q1", "Q2", "Q3", "Q4", "FY")
                        else $fp)
let $aids        := archives:aid(request:param-values("aid"))
let $archives    := (
                        local:filings($ciks, $tags, $tickers, $sics, $fiscalPeriods, $fiscalYears),
                        archives:archives($aids)
                    )
let $entities    := entities:entities($archives.Entity)
let $names       := distinct-values(request:param-values("name"))
let $labels      := distinct-values(request:param-values("label"))
let $onlyNames   := let $o := request:param-values("onlyNames")[1] return if (exists($o)) then ($o cast as boolean) else false
return
    if (session:only-dow30($entities) or session:valid()) 
        then {
            let $concepts := let $concepts := if (exists($names))
                                              then local:concepts-for-archives($archives._id, $names)
                                              else if (exists($labels))
                                              then local:concepts-for-archives-and-labels($archives._id, $labels[1])
                                              else local:concepts-for-archives($archives._id)
                             return if ($onlyNames) 
                                    then distinct-values($concepts.Name)
                                    else for $c in $concepts
                                         group by $component := $c.Component
                                         let $component := components:components($component)
                                         let $default-hc := hypercubes:hypercubes-for-components($component, "xbrl:DefaultHypercube")
                                         let $members := $default-hc.Aspects."xbrl:Concept".Domains."xbrl:ConceptDomain".Members
                                         let $archive := archives:archives($c[1].Archive)
                                         let $entity := entities:entities($archive.Entity)
                                         return
                                             for $name in $c.Name
                                             return
                                                 copy $res := $members.$name
                                                 modify (
                                                    insert json { ComponentRole : $component.Role } into $res,
                                                    insert json { ComponentLabel : $component.Label } into $res,
                                                    insert json { AccessionNumber : $archive._id } into $res,
                                                    insert json { CIK : $entity._id } into $res,
                                                    insert json { EntityRegistrantName : $entity.Profiles.SEC.CompanyName } into $res,
                                                    insert json { FiscalYear : $archive.Profiles.SEC.Fiscal.DocumentFiscalYearFocus } into $res,
                                                    insert json { FiscalPeriod : $archive.Profiles.SEC.Fiscal.DocumentFiscalPeriodFocus } into $res
                                                 )
                                                 return $res
            return
            switch ($format)
            case "xml" return {
                response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
                (session:comment("xml"),
                <ReportElements>{
                    local:to-xml($concepts, $onlyNames)
                }</ReportElements>)
            }
            case "text" case "csv" return {
                response:content-type("text/csv");
                response:header("Content-Disposition", "attachment; filename=facts.csv");
                local:to-csv($concepts, $onlyNames)
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=fact.csv");
                local:to-csv($concepts, $onlyNames)
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    { ReportElements : [ $concepts ] },
                    session:comment("json", {
                        NumConcepts: count($concepts),
                        TotalNumConcepts: session:num-concepts()
                    })
                |}
            }
        }
        else {
            response:status-code(401);
            session:error("accessing filings of an entity that is not in the DOW30", $format)
        }
