import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";

variable $userid := api:required-parameter("userid", $user:VALID_USERID);

session:validate(
     if (session:validate() eq $userid)
     then "users_remove_picture_self"
     else "users_remove_picture"
);

user:get-existing-by-id($userid);

user:remove-picture($userid);

api:success()
