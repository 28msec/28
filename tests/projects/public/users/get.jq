import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

variable $my-user-id := session:validate();

variable $email := api:parameter("email", $user:VALID_EMAIL, ());
variable $id    := api:parameter("userid", $user:VALID_USERID, ());

if (exists($email)) then 
{
    session:validate("users_get");
    api:success({ user : project(user:get-existing-by-email($email), ("firstname","lastname","status","email","_id","assignments")) })
}
else if (exists($id)) then 
{
    session:validate("users_get");
    api:success({ user : project(user:get-existing-by-id($id), ("firstname","lastname","status","email","_id","assignments")) })
}
else
{
    session:validate("users_get_self");
    api:success({ user : project(user:get-existing-by-id($my-user-id), ("firstname","lastname","status","email","_id","assignments")) })
}
