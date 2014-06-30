import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";

variable $firstname := api:required-parameter("firstname", $user:VALID_NAME);
variable $lastname := api:required-parameter("lastname", $user:VALID_NAME);
variable $email := api:required-parameter("email", $user:VALID_EMAIL);
variable $password := api:required-parameter("password", $user:VALID_PASSWORD);

variable $user-id := user:new($email, $firstname, $lastname, $password, {| |});

api:success( { user-id : $user-id } )
