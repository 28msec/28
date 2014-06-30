jsoniq version "1.0";

module namespace api = "http://apps.28.io/api";

import module namespace req = "http://www.28msec.com/modules/http-request";

declare function api:parameter($name as string, $regexp as string, $default as string?)
as string?
{
  variable $param := req:param-values($name);
  if (exists($param) and not($param eq ""))
  then  
    if (matches($param, "^" || $regexp || "$"))
    then $param
    else fn:error(xs:QName("api:bad-parameter"), "Provided parameter " || $name || " with value " || $param || " does not match reg. expression " || $regexp || ".")
  else $default 
};

declare function api:parameter-enum($name as string, $enum as string*, $default as string?)
as string?
{
  variable $param := req:param-values($name);
  if (exists($param) and not($param eq ""))
  then 
    if ($param = $enum)
    then $param
    else fn:error(xs:QName("api:bad-parameter"), "Provided parameter " || $name || " with value " || $param || " is not one of these: " || string-join($enum,", ") || ".")
  else $default 
};

declare function api:required-parameter-enum($name as string, $enum as string*)
as string
{
  variable $param := api:parameter-enum($name, $enum, ());
  if (exists($param))
  then $param
  else fn:error(xs:QName("api:missing-parameter"), "Missing required parameter " || $name)
};

declare function api:parameter-boolean($name as string, $default as boolean)
as boolean
{
  boolean(api:parameter-enum($name, ("true","false"), if($default) then "true" else "false") eq "true")
};


declare function api:required-parameter($name as string, $regexp as string)
as string
{
  variable $param := api:parameter($name, $regexp, ());
  if (exists($param))
  then $param
  else fn:error(xs:QName("api:missing-parameter"), "Missing required parameter " || $name)
};

declare %private function api:sgpl($count as integer, $singular as string, $plural as string)
as string
{ 
    if ($count eq 1)
    then $count || " " || $singular
    else $count || " " || $plural
};

declare function api:passed($timestamp)
as string
{
    if (empty($timestamp) or $timestamp eq null)
    then "Never"
    else
        let $now := current-dateTime()
        let $difference := $now - $timestamp
        let $years := years-from-duration($difference)
        let $month := months-from-duration($difference)
        let $days := days-from-duration($difference)
        let $hours := hours-from-duration($difference)
        let $minutes := minutes-from-duration($difference)
        return
            if ($years gt 0) then api:sgpl($years,"year ago","years ago")
            else if ($month gt 0) then api:sgpl($month,"month ago","month ago")
            else if ($days gt 0) then api:sgpl($days, "day ago", "days ago")
            else if ($hours gt 0) then api:sgpl($hours, "hour ago", "hours ago")
            else if ($minutes gt 0) then api:sgpl($minutes, "minute ago", "minutes ago")
            else if ($difference div xs:dayTimeDuration("PT1S") lt 0) then "future"
            else "Just Now"        
};

declare function api:success()
{
  { "success" : true }
};

declare function api:success($data as object())
{
  {| 
     {"success" : true },
     $data
  |}
};
