jsoniq version "1.0";

import module namespace user = "http://apps.28.io/user";
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
    <result success="{$o.success}">{
        if (exists($o.description))
        then <description>{$o.description}</description>
        else ()
    }</result>
};

variable $user-id := session:validate();

variable $firstname := api:required-parameter("firstname", $user:VALID_NAME);
variable $lastname := api:required-parameter("lastname", $user:VALID_NAME);
variable $newemail := request:param-values("newemail");
variable $format  := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1]);

variable $res := ();
variable $status := ();
if (not(empty($newemail))) 
then {
    variable $email := api:required-parameter("email", $user:VALID_EMAIL);
    variable $password := api:required-parameter("password", $user:VALID_PASSWORD);

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
        if ($user._id != $user-id) 
        then {
            $status := 403;
            $res :=
            {
                success : false,
                description : "unauthorized operation"
            };
        } else {
            variable $other-same-mail := user:get-by-email($newemail);

            if (not(empty($other-same-mail)) and $other-same-mail._id != $user-id)
            then
            {
                $status := 403;
                $res := 
                {
                    success: false,
                    description: "A different user with same email address already exists."
                };
            }
            else 
            {
                replace value of json $user.firstname with $firstname;
                replace value of json $user.lastname with $lastname;
                replace value of json $user.email with $newemail;

                $status := 200;
                $res :=
                {
                  success : true
                };
            }
        }
    }
} else {
    variable $user := user:get-existing-by-id($user-id);

    replace value of json $user.firstname with $firstname;
    replace value of json $user.lastname with $lastname;

    $status := 200;
    $res :=
    {
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
        response:header("Content-Disposition", "attachment; filename=edit.csv");
        local:to-csv($res)
    }
    default return {
        response:content-type("application/json");
        response:serialization-parameters({"indent" : true});
        $res
    }