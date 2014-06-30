import module namespace user = "http://apps.28.io/user";
import module namespace api = "http://apps.28.io/api";
import module namespace session = "http://apps.28.io/session";
import module namespace req = "http://www.28msec.com/modules/http-request";

variable $userid := api:required-parameter("userid", $user:VALID_USERID);

session:validate(
     if (session:validate() eq $userid)
     then "users_upload_picture_self"
     else "users_upload_picture"
);

user:get-existing-by-id($userid);

variable $mime-type :=
   let $part := req:parts().parts[][$$.name eq "image"]
  return
      if (exists($part))
      then $part.headers.Content-Type
      else req:content-type();

variable $image-data := 
  let $part := req:parts().parts[][$$.name eq "image"]
  return
      if (exists($part))
      then req:binary-part($part.src)
      else req:binary-content();

user:upload-picture($userid, $mime-type, $image-data);

api:success()

