import module namespace mongo = "http://www.28msec.com/modules/mongodb";

let $c := mongo:connect("xbrl", {})
return [
    for $s in mongo:find($c, "sics")
    return {
        ID: $s.ID,
        Description: $s.Description,
        Sector: $s.Sector
    }
]
