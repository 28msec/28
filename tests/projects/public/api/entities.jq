import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace session = "http://apps.28.io/session";

session:audit-call();

let $format  := lower-case(request:param-values("format")[1])
let $ciks    := request:param-values("cik")
let $tags    := request:param-values("tag") ! upper-case($$) (: DOW30, SP500, FORTUNE100 :)
let $tickers := request:param-values("ticker")
let $sics    := request:param-values("sic")
let $entities := 
    for $entity in 
        if (exists(($ciks, $tags, $tickers, $sics)))
        then companies:companies-for({
                ciks : [ $ciks ],
                tags : [ $tags ],
                tickers : [ $tickers ],
                sics : [ $sics ]
            })
        else
            companies:companies()
    order by $entity.Profiles.SEC.CompanyName (: companies:name() ? :)
    return $entity
return
    switch ($format)
        case "xml"  return { 
            response:content-type("application/xml");
            response:serialization-parameters({"omit-xml-declaration" : false});
            (session:comment("xml", {
                NumEntities: count($entities),
                TotalNumEntities: session:num-entities() 
            }),
            <Entities>{
                companies:to-xml($entities)
            }</Entities>)
        }
        case "text" case "csv" return {
            response:content-type("application/csv");
            string-join(companies:to-csv($entities))
        }
        case "excel" return {
            response:content-type("application/vnd.ms-excel");
            response:header("Content-Disposition", "attachment; filename=entities.csv");
            string-join(companies:to-csv($entities))
        }
        default return {
            response:content-type("application/json");
            response:serialization-parameters({"indent" : false});
            {|
                { "Entities" : [ $entities ] },
                session:comment("json", {
                        NumEntities: count($entities),
                        TotalNumEntities: session:num-entities() 
                    }) 
            |} 
        } 
