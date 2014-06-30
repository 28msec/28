import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

session:validate("users_activate");

variable $userid := api:required-parameter("userid", $user:VALID_USERID);
variable $user := user:get-existing-by-id($userid);

if ($user.status eq $user:STATUS_ACTIVE)
then fn:error(xs:QName("user:already-active"),"User is already active.");
else ();

replace value of json $user.status with $user:STATUS_ACTIVE;

api:success()
