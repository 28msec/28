import module namespace concept-maps = "http://xbrl.io/modules/bizql/concept-maps";

import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";

import module namespace csv = "http://zorba.io/modules/json-csv";


declare function local:to-xml($c as object) as node()*
{
    (
        session:comment("xml"),
        <ConceptMap name="{$c.ShortName}" linkrole="{$c.LinkRole}">{
            for $k in keys($c.Trees)
            return
                <Mapping>{
                     (
                         <Concept>{$k}</Concept>,
                         for $t in keys($c.Trees.$k.To)
                         return
                             <MappedTo>{$t}</MappedTo>
                     )
                }
                </Mapping>
        }</ConceptMap>
    )
};

declare function local:to-csv($c as object) as string
{
    string-join(
        csv:serialize(
            for $k in keys($c.Trees)
            for $v at $y in keys($c."Trees".$k.To)
            return {
                "Concept" : $k,
                "MappedTo" : $v,
                "TryOrder" : $y
            }
        )
    )
};

session:audit-call();

let $format  := lower-case(request:param-values("format"))[1]
let $map-name := request:param-values("name")
let $map := concept-maps:concept-maps($map-name)
return
    if (exists($map))
    then
        switch ($format)
        case "xml" return {
            response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
            local:to-xml($map)
        }
        case "text" case "csv" return {
            response:content-type("text/csv");
            response:header("Content-Disposition", "attachment; filename=map.csv");
            local:to-csv($map)
        }
        case "excel" return {
            response:content-type("application/vnd.ms-excel");
            response:header("Content-Disposition", "attachment; filename=map.csv");
            local:to-csv($map)
        }
        default return {
            response:content-type("application/json");
            response:serialization-parameters({"indent" : true});
            {|
                $map,
                session:comment("json")
            |}
        }
    else {
        response:status-code(404);
        session:error("concept map not found", "json")
    }
