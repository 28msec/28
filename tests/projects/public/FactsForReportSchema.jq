import module namespace report-schemas = "http://xbrl.io/modules/bizql/report-schemas";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace networks = "http://xbrl.io/modules/bizql/networks";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace facts = "http://xbrl.io/modules/bizql/facts";

import module namespace sec = "http://xbrl.io/modules/bizql/profiles/sec/core";

import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";

import module namespace seq = "http://zorba.io/modules/sequence";

session:audit-call();

let $format  := lower-case(request:param-values("format")[1])
let $aids     := request:param-values("aid")
let $report   := request:param-values("report")[1]
let $schema   := report-schemas:report-schemas($report)

let $archives := archives:archives(distinct-values($aids))
let $entities := entities:entities($archives.Entity)
return switch(true)
    case empty($archives) return {
        response:status-code(404);
        session:error("entities or archives not found (valid parameters: aid)", $format)
    }
    case not (session:only-dow30($entities) or session:valid()) return {
        response:status-code(401);
        session:error("accessing facts of an entity that is not in the DOW30", $format)
    }
    case empty($report) return {
        response:status-code(404);
        session:error("report does not exist", $report)
    }
    default return
        let $cached-archives := store:find("reportcache", { _id : { "$in" : [ $archives._id ! ($report || $$)]}})
        let $noncached-archives := seq:value-except($archives._id, $cached-archives._id ! substring-after($$, $report))
        return {
            let $network as object :=
                networks:networks-for-components-and-short-names($schema, "Presentation")
            let $facts := sec:facts-for-schema($schema, $noncached-archives)
            let $computed-archives :=
                    for $facts-by-archive in $facts
                    let $archive := $archives[$$._id eq $facts-by-archive.Archive]
                    group by $archive._id
                    return
                        copy $result := $network
                        modify (
                            insert json { Generator: $archive[1].Profiles.SEC.Generator } into $result,
                            for $concept in descendant-objects(values($result.Trees))[exists($$.Name)]
                            let $name := $concept.Name
                            return (
                                insert json {
                                    "Facts" : [ $facts-by-archive[$$.$facts:ASPECTS.$facts:CONCEPT eq $name] ]
                                } into $concept
                            ),
                            insert json { "_id" : $report || $archive[1]._id } into $result)
                        return
                            $result
            return  {
                if (exists($computed-archives))
                then db:insert("reportcache", $computed-archives);
                else ();
                [ $cached-archives, $computed-archives ] 
            }
        }
