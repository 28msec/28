
import module namespace concept-maps = "http://xbrl.io/modules/bizql/concept-maps";
import module namespace req = "http://www.28msec.com/modules/http-request";

variable $mapName := let $mapName := req:param-values("mapName","FundamentalAccountingConcepts")
                     return if (empty($mapName))
                            then error(QName("local:INVALID-REQUEST"), "mapName: mandatory parameter not found")
                            else $mapName;
                         
variable $map := let $map := concept-maps:concept-maps($mapName)
                 return if (empty($map))
                        then error(QName("local:INVALID-REQUEST"), $mapName ||": no map defined with name ")
                        else $map;
                        
let $keys := keys($map.Trees)

return 
{
   mapName :  $mapName,
   mapKeys : [$keys],
   raw : [concept-maps:concept-maps($mapName)]

}

(: access the map with concept-maps:concept-maps($mapName) :)

(: concept maps will evolve in the future, to match XBRL networks. But for now, this query is stable. :)
