jsoniq version "1.0";

import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";
import module namespace dt = "http://zorba.io/modules/datetime";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace csv = "http://zorba.io/modules/json-csv";

declare function local:to-csv($o as object*) as string
{
    string-join(csv:serialize($o))
};

declare function local:to-xml($o as object*) as element()
{
    <result success="{$o.success}">{
        if (exists($o.token))
        then <token>{$o.token}</token>
        else ()
    }</result>
};

variable $res := ();
variable $status := ();

variable $email := api:required-parameter("email", $user:VALID_EMAIL);
variable $password := api:required-parameter("password", $user:VALID_PASSWORD);
variable $expiration := dt:parse-dateTime(request:param-values("expiration"), "%Y-%m-%dT%H:%M:%S");
variable $format  := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1]);

variable $user := try { user:login($email, $password) } catch * { () };

if (empty($user)) 
then {
      $status := 403;
      $res :=
        {
            success : false,
            description : "invalid email or password"
        };
} else {
    variable $token := session:start($user._id, $expiration);
    
    $status := 200;
    
    $res :=
        { 
          token : $token, 
          success : true
        };
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
