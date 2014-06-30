import module namespace hypercubes = "http://xbrl.io/modules/bizql/hypercubes";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace sec = "http://xbrl.io/modules/bizql/profiles/sec/core";
import module namespace csv = "http://zorba.io/modules/json-csv";

declare function local:to-csv($facts as object*) as string*
{
    csv:serialize(
        for $f in $facts
        return {|
            $f.Aspects,
            { Value : $f.Value }
        |}
    )
};

local:to-csv(
    hypercubes:facts(
            sec:user-defined-hypercube({
                "xbrl:Concept" : { Domain: [ "us-gaap:Assets"] },
                "xbrl:Entity"  : { Domain: [ companies:companies-for-tags("DOW30")._id ] },
                "us-gaap:StatementBusinessSegmentsAxis" : { Default: "us-gaap:SegmentDomain" }
            }
        )
    )
)