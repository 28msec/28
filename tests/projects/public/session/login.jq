jsoniq version "1.0";

import module namespace user = "http://apps.28.io/user";
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
    <result success="{$o.success}">{
        if (exists($o.description))
        then <description>{$o.description}</description>
        else (),
        
        if (exists($o.token))
        then <token>{$o.token}</token>
        else (),
        
        if (exists($o._id))
        then <id>{$o._id}</id>
        else (),
        
        if (exists($o.firstname))
        then <firstname>{$o.firstname}</firstname>
        else (),
        
        if (exists($o.lastname))
        then <lastname>{$o.lastname}</lastname>
        else ()
    }</result>
};

variable $res := ();
variable $status := ();

variable $email := request:param-values("email");
variable $password := request:param-values("password");
variable $format  := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1]);

if (empty($email) or empty($password))
then {
    $status := 400;
    $res :=
        { 
            success : false, 
            description : (if (empty($email)) 
                          then "email"
                          else "password")
                            || ": parameter missing"
        };
} else {
    variable $user := try { user:login($email, $password) } catch * { () };
    variable $expiration := fn:current-dateTime() +
                            (if ($email eq "charlie@prudena.com")
                             then xs:yearMonthDuration("P10Y")
                             else xs:dayTimeDuration("P1D"));
    
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
              success : true,
              _id: $user._id,
              firstname: $user.firstname,
              lastname: $user.lastname
            };
    }
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
