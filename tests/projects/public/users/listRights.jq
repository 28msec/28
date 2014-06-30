import module namespace user = "http://apps.28.io/user";
import module namespace session = "http://apps.28.io/session";
import module namespace api = "http://apps.28.io/api";

session:validate("roles_list");

variable $role := api:required-parameter("role", $user:VALID_ROLEID);

variable $results := 
  for $right in collection($user:rights)
  return 
      {
          "_id"     : $right._id,
          "name"    : $right.name,
          "parent"  : $right.parent,
          "allowed" : user:is-role-id-authorized($role, $right._id)
      };
  
api:success({ results : [ $results ]})
