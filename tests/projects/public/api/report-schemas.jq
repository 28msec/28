import module namespace report-schemas = "http://xbrl.io/modules/bizql/report-schemas";

import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";

session:audit-call();

let $name := request:param-values("name")
let $schema := report-schemas:report-schemas($name)
return 
    if (exists($schema))
    then {
        response:content-type("application/json");
        response:serialization-parameters({"indent" : true});
        $schema
    }
    else {
        response:status-code(404);
        session:error($name || "schema not found", "json")
    }