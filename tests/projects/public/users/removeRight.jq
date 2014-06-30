import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

session:validate("roles_change_permissions");

variable $role-id := api:required-parameter("role", $user:VALID_ROLEID);
variable $right-id := api:required-parameter("right", $user:VALID_RIGHTID);

user:disallow($role-id, $right-id);

api:success()
