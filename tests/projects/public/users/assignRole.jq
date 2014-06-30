import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

variable $assignedBy := session:validate("users_assign_role");

variable $user-id := api:required-parameter("userid", $user:VALID_USERID);
variable $role-id := api:required-parameter("role", $user:VALID_ROLEID);
variable $fromDateTime := dateTime(api:parameter("fromDateTime", $user:VALID_DATETIME, ()));
variable $toDateTime := dateTime(api:parameter("toDateTime", $user:VALID_DATETIME, ()));

user:assign-role($user-id, $role-id, $fromDateTime, $toDateTime, $assignedBy);

api:success()
