jsoniq version "1.0";

import module namespace components = "http://xbrl.io/modules/bizql/components";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace filings = "http://xbrl.io/modules/bizql/profiles/sec/filings";
import module namespace fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";

import module namespace mongo = "http://www.28msec.com/modules/mongodb";
import module namespace credentials = "http://www.28msec.com/modules/credentials";

import module namespace sec-networks = "http://xbrl.io/modules/bizql/profiles/sec/networks";

import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace response = "http://www.28msec.com/modules/http-response";

import module namespace session = "http://apps.28.io/session";
import module namespace csv = "http://zorba.io/modules/json-csv";

declare function local:to-xml-rec($o as object*, $level as integer) as element()*
{
    for $o in $o
    return
        element { if ($o.Kind eq "Domain") then "Member" else $o.Kind } {
            attribute { "name" } { $o.Name },
            attribute { "label" } { $o.Label },
            if (exists($o.Balance)) then attribute { "balance" } { $o.Balance } else (),
            if (exists($o.DataType)) then attribute { "dataType" } { $o.DataType } else (),
            if (exists($o.BaseType)) then attribute { "baseDataType" } { $o.BaseType } else (), 
            if (exists($o.IsAbstract)) then attribute { "abstract" } { $o.IsAbstract } else (),
            if (exists($o.PeriodType)) then attribute { "periodType" } { $o.PeriodType } else (),
            attribute { "level" } { $level },
            local:to-xml-rec($o.Children[], $level + 1)
        }
};

declare function local:to-xml($model as object) as node()*
{
    ((session:comment("xml", {
                            TotalNumArchives: session:num-archives(),
                            TotalNumEntities: session:num-entities()
                        })),
    <Component>
        <Network entityRegistrantName="{$model.EntityRegistrantName}"
                 accessionNumber="{$model.AccessionNumber}"
                 tableName="{$model.TableName}"
                 cik="{$model.CIK}"
                 label="{$model.Label}"
                 networkIdentifier="{$model.NetworkIdentifier}"
                 formType="{$model.FormType}"
                 fiscalPeriod="{$model.FiscalPeriod}"
                 fiscalYear="{$model.FiscalYear}" 
                 acceptanceDatetime="{$model.AcceptanceDatetime}"
                 disclosure="{$model.Disclosure}"
                 >{
            local:to-xml-rec($model.ModelStructure, 0)
        }</Network>
    </Component>)
    
};

declare function local:to-csv-rec($objects as object*, $level as integer) as object*
{
    for $o in $objects
    let $object := {
        "Label" : $o.Label,
        "Name" : $o.Name,
        "ObjectClass" : if ($o.Kind eq "Domain") then "Member" else $o.Kind,
        "DataType" : $o.DataType,
        "BaseDataType" : $o.BaseType,
        "Balance" : $o.Balance,
        "Abstract" : $o.IsAbstract,
        "PeriodType" : $o.PeriodType,
        "Level" : $level
    }
    return (
        $object,
        local:to-csv-rec($o.Children[], $level + 1)
    )
};


declare function local:to-csv($model as object) as string
{
    let $lines := local:to-csv-rec($model.ModelStructure, 0) 
    return
        if (exists($lines))
        then string-join(csv:serialize($lines, { serialize-null-as : "" }))
        else ""
};


declare function local:enrich-json-rec($objects as object*, $level as integer) as object*
{
    for $object in $objects
    return
        copy $o := $object
        modify (
            if (exists($o.Children)) then delete json $o("Children") else (),
            insert json { Level : $level } into $o,
            if ($o.Kind eq "Domain") then replace value of json $o("Kind") with "Member" else ()
        ) 
        return {|
            $o,
            let $children := local:enrich-json-rec($object.Children[], $level + 1)
            return if (exists($children)) then { Children : [ $children ] } else ()
        |}
};


declare function local:enrich-json($component as object) as object
{
    {
        ModelStructure : [ local:enrich-json-rec($component.ModelStructure, 0) ] ,
        CIK : $component.CIK,
        EntityRegistrantName : $component.EntityRegistrantName,
        Label : $component.Label,
        AccessionNumber : $component.AccessionNumber,
        TableName : $component.TableName,
        FormType : $component.FormType, 
        FiscalPeriod : $component.FiscalPeriod,
        FiscalYear : $component.FiscalYear,
        AcceptanceDatetime : $component.AcceptanceDatetime,
        NetworkIdentifier: $component.NetworkIdentifier,
        Disclosure : $component.Disclosure
    }
};
declare function local:components-by-disclosures($disclosures as string*, $aids as string*) as object*
{
    let $conn :=   
      let $credentials := credentials:credentials("MongoDB", "xbrl")
      return
        try {
            mongo:connect($credentials)
        } catch mongo:* {
            error(QName("components:CONNECTION-FAILED"), $err:description)
        }
    for $aid in $aids
    return
        mongo:find($conn, "components", 
        {
            $components:ARCHIVE: $aid,
            "Profiles.SEC.Disclosure": { "$in" : [ $disclosures ] }
        })
};

declare function local:components-by-roles($roles as string*, $aids as string*) as object*
{
    let $conn :=   
      let $credentials := credentials:credentials("MongoDB", "xbrl")
      return
        try {
            mongo:connect($credentials)
        } catch mongo:* {
            error(QName("components:CONNECTION-FAILED"), $err:description)
        }
    return
        mongo:find($conn, "components", 
        {
            $components:ARCHIVE: { "$in" : [ $aids ] },
            "Role": { "$in" : [ $roles ] }
        })
};

declare function local:components-by-concepts($concepts as object*, $aids as string*) as object*
{
    let $conn :=   
      let $credentials := credentials:credentials("MongoDB", "xbrl")
      return
        try {
            mongo:connect($credentials)
        } catch mongo:* {
            error(QName("components:CONNECTION-FAILED"), $err:description)
        }
    let $ids := mongo:find($conn, "concepts", 
        {| 
            (
                { "Name" : { "$in" : [ $concepts ] } },
                { "Archive" : { "$in" : [ $aids ] } }
            )
        |}).Component
    return components:components($ids)
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
                        case "ALL" return $fiscal:ALL_FISCAL_YEARS
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
                            else ()
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
let $concepts    := distinct-values(request:param-values("concept"))
let $disclosures := request:param-values("disclosure")
let $components  := (if (exists($cid))
                    then components:components($cid)
                    else (),
                    if (exists($concepts))
                    then local:components-by-concepts($concepts, $archives._id)
                    else if (exists($disclosures))
                    then local:components-by-disclosures($disclosures, $archives._id)
                    else if (exists($roles))
                    then local:components-by-roles($roles, $archives._id)
                    else components:components-for-archives($archives._id))
let $component := $components[1] (: only one for know :)
let $archive   := archives:archives($component.Archive)
let $entity    := entities:entities($archive.Entity)
return
     if (session:only-dow30($entity) or session:valid())
     then {
        let $model := {|
                    { CIK : $entity._id },
                    { EntityRegistrantName : $entity.Profiles.SEC.CompanyName },
                    { ModelStructure : sec-networks:model-structures($component) },
                    { TableName : sec-networks:tables($component, {IncludeImpliedTable: true}).Name },
                    { Label : $component.Label },
                    { AccessionNumber : $component.Archive },
                    { FormType : $archive.Profiles.SEC.FormType },
                    { FiscalPeriod : $archive.Profiles.SEC.Fiscal.DocumentFiscalPeriodFocus },
                    { FiscalYear : $archive.Profiles.SEC.Fiscal.DocumentFiscalYearFocus },
                    { AcceptanceDatetime : filings:acceptance-dateTimes($archive) },
                    { NetworkIdentifier: $component.Role },
                    { Disclosure : $component.Profiles.SEC.Disclosure }
        |}
        return 
            switch ($format)
            case "xml" return {
                response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
                local:to-xml($model)
            }
            case "text" case "csv" return {
                response:content-type("text/csv");
                response:header("Content-Disposition", "attachment; filename=modelstructure-" || $cid || ".csv");
                local:to-csv($model)
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=modelstructure-" || $cid || ".csv");
                local:to-csv($model)
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    local:enrich-json($model), 
                    session:comment("json", {
                            TotalNumArchives: session:num-archives(),
                            TotalNumEntities: session:num-entities()
                        })
                |}
            }
     } else {
        response:status-code(401);
        session:error("accessing fact table for an entity that is not in the DOW30", $format)
     }
