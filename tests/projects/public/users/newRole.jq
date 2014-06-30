import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

session:validate("roles_new");

variable $role-id := api:required-parameter("id", $user:VALID_ROLEID);
variable $role-name := api:required-parameter("name", $user:VALID_ROLENAME);

user:new-role($role-id, $role-name);

api:success()
