import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

session:validate("users_close_assignment");

variable $user-id := api:required-parameter("userid", $user:VALID_USERID);
variable $role-id := api:required-parameter("role", $user:VALID_ROLEID);
variable $fromDateTime := dateTime(api:parameter("fromDateTime", $user:VALID_DATETIME, ()));

user:close-assignment($user-id, $role-id, $fromDateTime);

api:success()
