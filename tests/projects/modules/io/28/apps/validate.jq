jsoniq version "1.0";

module namespace validation = "http://apps.28.io/validation";


(:~
 : <p>Validates a JSON object.</p>
 :
 : @error validation:VALIDATION if the object is not valid
 :)
declare function validation:validate($object as object, $schema as object, 
  $allow-extra-fields as boolean)
as object
{
  if ($allow-extra-fields)
  then ();
  else 
    for $key in jn:keys($object)
    where not($key=jn:keys($schema))
    return fn:error(QName("validation:VALIDATION"), "Unknown field specified: " ||  $key);
  
  
  copy $validated-object := $object
  modify
  (
    for $key in jn:keys($schema)
    return
      let $field := $validated-object($key)      
      let $schema-type := $schema($key)  
      let $type := fn:replace($schema-type, "\\?", "")
      let $is-optional := fn:ends-with($schema-type, "?")
      return
        if (not($is-optional) and (empty($field) or $field eq null))
        then fn:error(QName("validation:VALIDATION"), "Missing field: " || $key)
        else if (empty($field) or $field eq null)
             then ()
             else validation:validate-field($type, $validated-object, $key) 
  )
  return $validated-object
};

declare %private updating function validation:validate-field($type as string, 
  $object as object, $key as string)
{
  switch ($type)
    case "boolean" return
    (
      if ($object instance of boolean)
      then ()
      else if ($object($key) castable as boolean) 
           then replace value of json $object($key) with ($object($key) cast as boolean)
           else fn:error(QName("validation:VALIDATION"), "Boolean required: " || $key)
    )
    case "string" return
    (
      if ($object($key) instance of string) 
      then () 
      else fn:error(QName("validation:VALIDATION"), "String required: " || $key)
    )
    case "integer" return
    (
      if ($object($key) instance of integer)
      then ()
      else if ($object($key) castable as integer) 
           then replace value of json $object($key) with ($object($key) cast as integer)
           else fn:error(QName("validation:VALIDATION"), "Integer required: " || $key)
    )
    case "double" return
    (
      if ($object($key) instance of double)
      then ()
      else if ($object($key) castable as double) 
           then replace value of json $object($key) with ($object($key) cast as double)
           else fn:error(QName("validation:VALIDATION"), "Double required: " || $key)
    )
    case "dateTime" return
    (
      if ($object($key) instance of dateTime)
      then ()
      else if ($object($key) castable as dateTime) 
           then replace value of json $object($key) with ($object($key) cast as dateTime)
           else fn:error(QName("validation:VALIDATION"), "DateTime required: " || $key || " found:" || $object($key) )
    )
    case "object" return
    (
      if ($object($key) instance of object) 
      then ()
      else fn:error(QName("validation:VALIDATION"), "Object required: " || $key)
    ) 
    case "item" return 
    ()
    default return fn:error(QName("validation:VALIDATION"), "Internal error: " || $type ||
      " unsupported validation option")
};          
