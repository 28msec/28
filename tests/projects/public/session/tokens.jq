jsoniq version "1.0";

import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace csv = "http://zorba.io/modules/json-csv";

declare function local:to-csv($o as object*) as string
{
    string-join(csv:serialize($o))
};

declare function local:to-xml($o as object*) as element()
{
    <results success="{$o.success}">{
        for $r in $o.results
        return (
            if (exists($r.token))
            then <token>{$r.token}</token>
            else (),
            if (exists($r.expiration))
            then <expiration>{$r.expiration}</expiration>
            else ()
        )
    }</results>
};

variable $res := ();
variable $status := ();

variable $token := request:param-values("token");
variable $format  := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1]);

variable $user-id := session:get($token);

if (empty($user-id))
then {
      $status := 400;
      $res :=
        {
            success : false,
            description : "invalid or missing token"
        };
} else {
    $status := 200;

    variable $results :=
        for $session in collection($session:tokens)
            where $session.user-id eq $user-id and $session.expiration-date gt current-dateTime()
            return 
            {
                token: $session._id,
                expiration: $session.expiration-date
            };
    $res := api:success({ results : [ $results ]});
}

response:status-code($status);

switch ($format)
    case "xml" return {
        response:content-type("application/xml");
        response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
        local:to-xml($res)
    }
    case "text" case "csv" case "excel" return {
        response:content-type("text/csv");
        response:header("Content-Disposition", "attachment; filename=login.csv");
        local:to-csv($res)
    }
    default return {
        response:content-type("application/json");
        response:serialization-parameters({"indent" : true});
        $res
    }
