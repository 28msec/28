jsoniq version "1.0";

module namespace user = "http://apps.28.io/user";

import module namespace random = "http://zorba.io/modules/random";
import module namespace hash = "http://zorba.io/modules/hash";

declare variable $user:collection as string := "Users";
declare variable $user:rights as string := "Rights";
declare variable $user:roles as string := "Roles";
declare variable $user:pictures as string := "UserPictures";

declare variable $user:STATUS_ACTIVE as string := "active";
declare variable $user:STATUS_SUSPENDED as string := "suspended";

declare variable $user:VALID_EMAIL as string := "[a-zA-Z0-9.!#$%&'*+/=?\\^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*";
declare variable $user:VALID_PASSWORD as string := "[^\\s]+";
declare variable $user:VALID_NAME as string := "[\\w]+";
declare variable $user:VALID_ROLEID as string := "[a-zA-Z0-9_]+";
declare variable $user:VALID_ROLENAME as string := "[\\w ]+";
declare variable $user:VALID_RIGHTID as string := "[a-zA-Z0-9_]+";
declare variable $user:VALID_RIGHTNAME as string := "[\\w ]+";
declare variable $user:VALID_USERID as string := "[a-z0-9\\-]+";
declare variable $user:VALID_DATETIME as string := "[TZ0-9\\-:\\.]+";

declare function user:get-by-email($email as string)
as object()?
{
  find($user:collection, { "email" : lower-case($email) })
};

declare function user:get-existing-by-email($email as string)
as object()
{
  let $user := user:get-by-email($email)
  return 
      if (empty($user))
      then fn:error(xs:QName("user:not-existing"),"User with email " || $email || " does not exist.")
      else $user
};

declare function user:get-by-id($id as string)
as object()?
{
  find($user:collection, { "_id" : $id })
};

declare function user:get-existing-by-id($id as string)
as object()
{
  let $user := user:get-by-id($id)
  return 
      if (empty($user))
      then fn:error(xs:QName("user:not-existing"),"User with id " || $id || " does not exist.")
      else $user
};

declare function user:login($email as string, $password as string)
as object()
{
  variable $user := user:get-by-email($email);
  
  if (empty($user))
  then fn:error(xs:QName("user:bad-login"),"Unknown user or bad password")
  else if ($user.hash eq user:compute-hash($user.salt, $password))
  then
     if ($user.status eq $user:STATUS_ACTIVE)
     then $user
     else fn:error(xs:QName("user:bad-login"),"Your account has been suspended.")
  else fn:error(xs:QName("user:bad-login"),"Unknown user or bad password")  
};

declare %an:sequential function user:new($email as string, $firstname as string, $lastname as string, $password as string, $extra as object())
as string
{
    if (exists(user:get-by-email($email)))
    then fn:error(xs:QName("user:exists"), "A user with this email already exists.");
    else ();

    variable $salt := random:uuid();

    variable $user :=
    {|
        {
          "_id"       : random:uuid(),
          firstname   : $firstname,
          lastname    : $lastname,
          email       : lower-case($email),
          hash        : user:compute-hash($salt, $password),
          status      : $user:STATUS_ACTIVE,
          salt        : $salt,      
          assignments : []
        },
        $extra
    |};
  
    db:insert($user:collection, $user);
    
    flush();
    
    user:get-existing-by-email($email).("_id")
};

declare function user:compute-hash($salt as xs:string, $password as xs:string) as xs:string
{
   lower-case(xs:string(xs:hexBinary(hash:hash($salt || $password, "sha256"))))
};

declare %an:sequential function user:set-password($user-id as string, $password as string)
as empty-sequence()
{
    variable $user := user:get-existing-by-id($user-id);
    
    variable $salt := random:uuid();
    variable $hash := user:compute-hash($salt, $password);
    
    replace value of json $user.hash with $hash;
    replace value of json $user.salt with $salt;

    if (exists($user.resetToken))
    then delete json $user("resetToken");
    else ();
    if (exists($user.resetDate))
    then delete json $user("resetDate");
    else ();
};


declare %an:sequential function user:upload-picture($user-id as string, $mime-type as string, $image-data as base64Binary)
as empty-sequence()
{
   variable $current-image := find($user:pictures, { "_id" : $user-id });
   variable $new-image :=
    {
      "_id"       : $user-id,
      "mime-type" : $mime-type,
      "image-data": $image-data
    };
   if (exists($current-image))
   then db:edit($current-image, $new-image);
   else db:insert($user:pictures, $new-image);
};

declare %an:sequential function user:remove-picture($user-id as string)
as empty-sequence()
{
   variable $current-image := find($user:pictures, { "_id" : $user-id });
   if (exists($current-image))
   then db:delete($current-image);
   else ();
};

declare function user:get-picture($user-id as string)
as object()?
{
   variable $current-image := find($user:pictures, { "_id" : $user-id });
   if (exists($current-image))
   then $current-image
   else find($user:pictures, { "_id" : "_default" })
};

declare %an:sequential function user:new-role($role-id as string, $role-name as string)
as empty-sequence()
{
    variable $role :=
      {
          "_id" : $role-id,
          "name" : $role-name
      };
    
    if (exists(find($user:roles, { "_id" : $role-id })))
    then fn:error(xs:QName("user:already-existing"), "A role with id '" || $role-id || "' already exists.");
    else if (find($user:roles, { "name" : $role-name }))
    then fn:error(xs:QName("user:already-existing"), "A role with name '" || $role-name || "' already exists.");
    else db:insert($user:roles, $role);
};

declare %an:sequential function user:new-right($right-id as string, $right-name as string, $parent-right-id as string?, $order as integer)
as empty-sequence()
{
    variable $right :=
    {|
      {
        "_id"  : $right-id,
        name : $right-name,
        "order" : $order,
        roles : []
      },
      if ($parent-right-id)
      then { parent : $parent-right-id }
      else ()
    |};
    
    db:insert($user:rights, $right);
};

declare %an:sequential function user:allow($role-id as string, $right-id as string)
as empty-sequence()
{
    variable $right := find($user:rights, { "_id" : $right-id });
    if (empty($right))
    then fn:error(xs:QName("user:not-existing"), "The requested right '" || $right-id || "' is not existing");
    else 
        if ($right.roles[] = $role-id)
        then ();
        else append json $role-id into $right.roles;
};

declare %an:sequential function user:disallow($role-id as string, $right-id as string)
as empty-sequence()
{
    if ($role-id eq "admin" and $right-id eq "rights")
    then fn:error(xs:QName("user:not-allowed"),"Admin group must have all rights.");
    else ();
    
    variable $right := find($user:rights, { "_id" : $right-id });
    if (empty($right))
    then fn:error(xs:QName("user:not-existing"), "The requested right '" || $right-id || "' is not existing");
    else 
        for $role at $idx in members($right.roles)
        where $role eq $role-id
        return delete json $right.roles($idx);        
};


declare %an:sequential function user:assign-role($user-id as string, $role-id as string, $fromDateTime as dateTime?, $toDateTime as dateTime?, $assignedBy-id as string)
as empty-sequence()
{
    variable $user := user:get-existing-by-id($user-id);
    
    variable $assignment := 
    {
        role         : $role-id,
        from-dateTime : $fromDateTime,
        to-dateTime   : $toDateTime,
        assigned-by   : $assignedBy-id,
        assigned-on   : current-dateTime()
    };
    
    append json $assignment into $user.assignments;
};

declare %an:sequential function user:close-assignment($user-id as string, $role-id as string, $fromDateTime as dateTime?)
as empty-sequence()
{
    if ($role-id eq "admin")
    then 
        if (exists(find($user:collection, { assignments : { "$elemMatch" : { "role" : "admin", "from-dateTime":null, "to-dateTime":null } } })[not($$._id eq $user-id)]))
        then ();
        else fn:error(xs:QName("user:not-allowed"),"At least one user must have the admin role.");
    else ();
    
    variable $user := user:get-existing-by-id($user-id);
    
    if (empty($fromDateTime))
    then 
        for $assignment at $idx in $user.assignments
        where $assignment.role eq $role-id
        return delete json $user.assignments($idx);
    else 
    {
        for $assignment at $idx in $user.assignments
        where $assignment.role = $role-id and $assignment.from-dateTime ge $fromDateTime
        return delete json $user.assignments($idx);        
        for $assignment in $user.assigments
        where $assignment.role eq $role-id
        return replace value of json $assignment.to-dateTime with $fromDateTime;
    }
};

declare function user:is-authorized($user-id as string, $right as string)
as boolean
{
  let $check-dateTime := fn:current-dateTime()
  let $user := user:get-existing-by-id($user-id)
  let $role-ids := ($user.assignments[]
                 [($$.from-dateTime eq null or $$.from-dateTime le $check-dateTime) and
                  ($$.to-dateTime eq null or $$.to-dateTime ge $check-dateTime)].role, "anybody")
  return user:is-role-id-authorized($role-ids, $right)
};

declare function user:is-role-id-authorized($role as string*, $right as string)
as boolean
{
  let $right := collection($user:rights)[$$._id = $right]
  return
    if ($right.roles[] = $role)
    then true
    else if ($right.parent)
    then user:is-role-id-authorized($role, $right.parent)
    else false
};

declare %an:sequential function user:suspend($user-id as string)
as empty-sequence()
{
 variable $user := user:get-existing-by-id($user-id);

 if ($user.assignments[].role = "admin")
 then
    if (exists(find($user:collection, { assignments : { "$elemMatch" : { "role" : "admin", "from-dateTime":null, "to-dateTime":null } } })[not($$._id eq $user-id)]))
    then ();
    else fn:error(xs:QName("user:not-allowed"),"At least one user must have the admin role.");
 else ();
 
 if ($user.status eq $user:STATUS_SUSPENDED)
 then fn:error(xs:QName("user:already-suspended"),"User is already suspended.");
 else ();

 replace value of json $user.status with $user:STATUS_SUSPENDED;

};

declare function user:resolve($user-id)
as string
{
    if (empty($user-id) or $user-id eq null)
    then ""
    else
    let $user := user:get-by-id($user-id)
    return
        if (empty($user))
        then "Missing user " || $user-id
        else $user.firstname || " " || $user.lastname
};

declare function user:get-by-reset-token($email as string, $reset-token as string)
as object()?
{
  let $user := user:get-by-email($email)
  return 
      if (empty($user))
      then fn:error(xs:QName("user:not-existing"),"User with email " || $email || " does not exist.")
      else if ($reset-token ne $user.resetToken)
      then fn:error(xs:QName("user:invalid-token"),"Token " || $reset-token || " is invalid.")
      else if (typeswitch($user.resetDate)
               case xs:dateTime return $user.resetDate le current-dateTime() - dayTimeDuration("P1D")
               default return true)
      then fn:error(xs:QName("user:expired-token"),"Token " || $reset-token || " has expired.")
      else $user
};