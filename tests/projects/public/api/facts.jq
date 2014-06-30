import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace sec-fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";

import module namespace hypercubes = "http://xbrl.io/modules/bizql/hypercubes";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";
import module namespace csv = "http://zorba.io/modules/json-csv";

declare function local:to-csv($o as object*) as string?
{
    if (exists($o)) (: bug in csv:serialize :)
    then
    string-join(
        csv:serialize(
            for $o in $o
            let $a := $o.Aspects
            return {|
                for $k in keys($a)
                return { $k : $a.$k },
                { "Value" : $o.Value },
                if (exists($o."Unit"))
                then { "Unit" :  $o."Unit" }
                else (),
                if (exists($o.Decimals))
                then { "Decimals" : $o.Decimals }
                else(),
                { "EntityRegistrantName" : $o.EntityRegistrantName },
                if (exists($o.ReportedConcept))
                then { "ReportedConcept" : $o.ReportedConcept }
                else ()
            |},
            { serialize-null-as : "" }
        )
    )
    else ()
};

declare function local:audittrail-to-xml($audit as item) as element()
{
    <AuditTrails>{
        for $a in flatten($audit)
        return (
            <Type>{$a.Type}</Type>,
            <Label>{$a.Label}</Label>,
            <Message>{$a.Message}</Message>,
            <Data>{
                if (exists($a.Data.OriginalConcept))
                then <OriginalConcept>{$a.Data.OriginalConcept}</OriginalConcept>
                else (),
                if (exists($a.Data.OutputConcept))
                then <OutputConcept>{$a.Data.OutputConcept}</OutputConcept>
                else (),
                if (exists($a.Data.AuditTrails))
                then local:audittrail-to-xml($a.Data.AuditTrails)
                else ()
            }</Data>
        )
    }</AuditTrails>
};


declare function local:to-xml($o as object*) as node()*
{
    (session:comment("xml", {
        NumFacts: count($o),
        TotalNumFacts: session:num-facts(),
        TotalNumArchives: session:num-archives(),
        TotalNumEntities: session:num-entities()
    }),
    <FactTable NetworkIdentifier="http://bizql.io/facts"
            TableName="xbrl:Facts">{
        for $o in $o
        let $a := $o.Aspects
        return
            <Fact>{
                <Aspects>{
                    for $k in keys($a)
                    return
                        <Aspect>
                            <Name>{$k}</Name>
                            <Value>{$a.$k}</Value>
                        </Aspect>
                }</Aspects>,
                <Value>{$o.Value}</Value>,
                <Type>{$o.Type}</Type>,
                if (exists($o.Unit))
                then <Unit>{$o.Unit}</Unit>
                else(),
                if (exists($o.Decimals))
                then <Decimals>{$o.Decimals}</Decimals>
                else (),
                <EntityRegistrantName>{$o.EntityRegistrantName}</EntityRegistrantName>,
                if (exists($o.AuditTrails))
                then local:audittrail-to-xml($o."AuditTrails")
                else ()
            }</Fact>
    }</FactTable>)
};

declare function local:hypercube() as object
{
    hypercubes:user-defined-hypercube({|
        let $concepts := (request:param-values("concept"), request:param-values("xbrl:Concept"))
        return
            if (exists($concepts))
            then { "xbrl:Concept" : { Domain : [ $concepts ] } }
            else (),
        
        if (not(request:param-names() = "dei:LegalEntityAxis"))
        then { 
                "dei:LegalEntityAxis" : { 
                    "Domain" : [ "sec:DefaultLegalEntity" ],
                    "Default" : "sec:DefaultLegalEntity"
                }
        } else (),
        
        for $p in request:param-names()
        where contains($p, ":") and not(starts-with($p, "xbrl:Concept"))
        group by $dimension-name := if (ends-with(lower-case($p), "::default"))
                                    then substring-before($p, "::default")
                                    else if (ends-with(lower-case($p), ":default"))
                                    then substring-before($p, ":default")
                                    else $p
        let $all := (request:param-values($dimension-name) ! upper-case($$)) = "ALL"
        return
        { 
            $dimension-name : {|
                let $v := request:param-values($dimension-name)
                return
                    if (exists($v) and not($all))
                    then { "Domain" : [ $v ] }
                    else (),
            
            let $predefined-default := collection("defaultaxis")[$$.axis eq $dimension-name]
            let $is-default := ($p = $dimension-name || "::default") or ($p = $dimension-name || ":default")
            return 
                if (exists($predefined-default) and not($is-default))
                then { "Default" : $predefined-default.default }
                else if ($is-default)
                then { 
                        "Default" : (
                                request:param-values($dimension-name || "::default"),
                                request:param-values($dimension-name || ":default")
                            )[1]
                    }
                else ()
            |}
        }
    |})
};

declare function local:facts(
    $archives as object*,
    $map as string?,
    $rules as string?) as object*
{
    for $fact in
        for $f in hypercubes:facts-for-hypercube(local:hypercube(), $archives,
            {|
                { Filter : {
                        "Profiles.SEC.Fiscal": { "$exists" : true }
                    }
                },
                if (exists($map)) then { "concept-maps" : $map } else (),
                if (exists($rules)) then { "Rules" : $rules } else ()
            |}
        )
        group by $f.Aspects."xbrl:Entity",
                 $f.Profiles.SEC.Fiscal.Year,
                 $f.Profiles.SEC.Fiscal.Period,
                 $f.Aspects."xbrl:Concept"
        let $latest-accepted := max(distinct-values($f.Profiles.SEC.Accepted))
        return if (empty($latest-accepted))
               then $f
               else $f[$$.Profiles.SEC.Accepted eq $latest-accepted]
    return {|
        { Aspects : {|
            for $a in keys($fact.Aspects)
            where $a ne "xbrl:Unit"
            return { $a : $fact.Aspects.$a },
            { "bizql:FiscalPeriod" : $fact.Profiles.SEC.Fiscal.Period },
            { "bizql:FiscalYear" : $fact.Profiles.SEC.Fiscal.Year }
        |} },
        { Type: $fact.Type },
        if (exists($fact.Aspects."xbrl:Unit"))
        then { Unit: $fact.Aspects."xbrl:Unit" }
        else  (),
        if (exists($fact.Decimals))
        then { Decimals: $fact.Decimals }
        else (), 
        { Value: $fact.Value },
        { "EntityRegistrantName" : companies:companies($fact.Aspects."xbrl:Entity").Profiles.SEC.CompanyName},
        if (exists(flatten($fact.AuditTrails[])))
        then { "AuditTrails" : $fact.AuditTrails }
        else ()
    |} 
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
                        case "ALL" return  $sec-fiscal:ALL_FISCAL_YEARS
                    default return $fy
                )
    for $fp in $fp
    return sec-fiscal:filings-for-entities-and-fiscal-periods-and-years($entity, $fp, $fy cast as integer)
};

session:audit-call();

let $format      := lower-case(request:param-values("format")[1])

(: choose 
    1. entities (using ciks, tags, tickers, sics), FY, and FP ) or
    2. accession numbers
:)
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
                        then $sec-fiscal:ALL_FISCAL_PERIODS
                        else $fp)
let $aids     := request:param-values("aid")
let $map      := request:param-values("map")[1]
let $rules    := request:param-values("rules")[1]
let $archives := (
                    local:filings($ciks, $tags, $tickers, $sics, $fiscalPeriods, $fiscalYears),
                    archives:archives($aids)
                 )
let $entities := companies:companies($archives.Entity)
return 
    switch(true)
    case empty($archives) return {
        response:status-code(400);
        session:error("entities or archives not found (valid parameters: cik, ticker, tag, sic, aid)", $format)
    }
    case not (session:only-dow30($entities) or session:valid()) return {
        response:status-code(401);
        session:error("accessing facts of an entity that is not in the DOW30", $format)
    }
    default return 
        let $facts := local:facts($archives, $map, $rules)
        return
            switch ($format)
            case "xml" return {
                response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
                local:to-xml($facts)
            }
            case "text" case "csv" return {
                response:content-type("text/csv");
                response:header("Content-Disposition", "attachment; filename=facts.csv");
                local:to-csv($facts)
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=fact.csv");
                local:to-csv($facts)
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    { NetworkIdentifier : "http://bizql.io/facts" },
                    { TableName : "xbrl:Facts" },
                    { FactTable : [ $facts ] },
                    session:comment("json", {
                            NumFacts: count($facts),
                            TotalNumFacts: session:num-facts(),
                            TotalNumArchives: session:num-archives(),
                            TotalNumEntities: session:num-entities()
                        })
                |}
            }
