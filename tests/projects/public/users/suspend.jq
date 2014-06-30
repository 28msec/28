import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

session:validate("users_suspend");

variable $userid := api:required-parameter("userid", $user:VALID_USERID);

user:suspend($userid);

api:success()
