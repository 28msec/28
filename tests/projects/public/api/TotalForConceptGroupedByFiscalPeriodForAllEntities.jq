import module namespace facts = "http://xbrl.io/modules/bizql/facts";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace sec-fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace csv = "http://zorba.io/modules/json-csv";
import module namespace session = "http://apps.28.io/session";

declare function local:to-csv($o as object*) as string
{
    string-join(
        csv:serialize(
            for $o in $o
            let $a := $o.Aspects
            return {|
                for $k in keys($a)
                return { $k : $a.$k },
                { "Unit" :  $o."Unit" },
                { "Value" : $o.Value },
                { "Decimals" : "INF" },
                { "NumReports" : $o.NumReports }
            |},
            { serialize-null-as : "" }
        )
    )
};

declare function local:to-xml($o as object*) as node()*
{
    (
    session:comment("xml"),
    <FactTable NetworkIdentifier="http://xbrl.io/TotalForConceptGroupedByFiscalPeriodForAllEntities"
            TableName="xbrl:TotalForConceptGroupedByFiscalPeriodForAllEntities">{

        for $o in $o
        let $a := $o.Aspects
        return
            <Fact>{
                (<Aspects>{
                    for $k in keys($a)
                    return
                        <Aspect>
                            <Name>{$k}</Name>
                            <Value>{$a.$k}</Value>
                        </Aspect>
                }</Aspects>,
                <Unit>{$o.Unit}</Unit>,
                <Type>{$o.Value}</Type>,
                <Value>{$o.Value}</Value>,
                <Decimals>INF</Decimals>,
                <NumReports>{$o.NumReports}</NumReports>,
                if (exists($o.Debug))
                then
                    <Debug>{
                        for $a in $o.Debug[]
                        return <InstanceURL value="{$a.Value}">{$a.InstanceURL}</InstanceURL>
                    }</Debug>
                else ()
                )
            }</Fact>
    }</FactTable>)
};
 
session:audit-call(); 
 
let $format  := lower-case(request:param-values("format")[1])
let $periods := let $period := upper-case(request:param-values("fiscalPeriod", "FY"))
                return 
                    if ($period = ("Q1", "Q2", "Q3", "FY", "ALL"))
                    then distinct-values($period)
                    else error(xs:QName("local:INVALID-PERIOD"),
                               $period || ": fiscalPeriod value must be one of Q1, Q2, Q3, FY")
let $years   := let $years := request:param-values("fiscalYear", "ALL")
                return
                    if ($years = "ALL")
                    then $sec-fiscal:ALL_FISCAL_YEARS
                    else $years ! $$ cast as integer
let $concept := request:param-values("concept", "us-gaap:Assets")[1]
let $map     := request:param-values("map")[1]
let $tags    := request:param-values("tag")
let $debug   := request:param-values("debug")
                
let $json-result := 
    let $facts :=
        for $fact in sec-fiscal:facts-for-entities-and-concepts-and-fiscal-periods-and-years(
            (if (exists($tags))
                then companies:companies-for-tags(upper-case($tags))
                else entities:entities()
            )[$$.Profiles.SEC.IsTrust eq false],
            $concept,
            if ($periods = "ALL") then ("Q1", "Q2", "Q3", "FY") else $periods,
            $years,
            {|
                if (exists($map))
                then { "concept-maps" : $map }
                else ()
            |}
        )
        group by $fyf := sec-fiscal:fiscal-year($fact),
                 $fpf := sec-fiscal:fiscal-period($fact),
                 $entity:= facts:entity-for-fact($fact)
        return ($fact[$$.Aspects."xbrl:Unit" eq "iso4217:USD"], $fact)[1]
    for $fact in $facts
    group by $fyf := sec-fiscal:fiscal-year($fact),
             $fpf := sec-fiscal:fiscal-period($fact),
             $unit := $fact.Aspects."xbrl:Unit"
    order by $fyf
    return {|
        {
            Aspects : {
                "xbrl:Entity" : "bizql:AllReportingEntitiesMember",
                "dei:LegalEntityAxis" : "sec:DefaultLegalEntity",
                "xbrl:Concept" : $concept,
                "bizql:FiscalYear" : $fyf,
                "bizql:FiscalPeriod" : $fpf
            }
        },
        { "Value" : sum($fact.Value[$$ ne null]) },
        { "Type"  : "NumericValue" },
        { "Unit" : $unit },
        { "Decimals"  : "INF" },
        { "NumReports" : count(distinct-values($fact.Archive)) },

        if (exists($debug) and $debug)
        then
            {
                "Debug" : [ $fact ! 
                            {
                                "InstanceURL" : archives:archives(distinct-values($$.Archive)).InstanceURL,
                                "Value" : $$.Value,
                                "Decimals" : $$.Decimals
                            } ]
            }
        else ()
    |}
return
    switch ($format)
    case "xml" return {
        response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
        local:to-xml($json-result)
    }
    case "text" case "csv" return {
        response:content-type("text/csv");
        response:header("Content-Disposition", "attachment; filename=Total-" || $concept || ".csv");
        local:to-csv($json-result)
    }
    case "excel" return {
        response:content-type("application/vnd.ms-excel");
        response:header("Content-Disposition", "attachment; filename=Total-" || $concept || ".csv");
        local:to-csv($json-result)
    }
    default return {
        response:content-type("application/json");
        response:serialization-parameters({"indent" : true});
        {|
            { NetworkIdentifier : "http://xbrl.io/TotalForConceptGroupedByFiscalPeriodForAllEntities" },
            { TableName : "xbrl:TotalForConceptGroupedByFiscalPeriodForAllEntities" },
            { FactTable : [ $json-result ] },
            session:comment("json")
        |}
    }
