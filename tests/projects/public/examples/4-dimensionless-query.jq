import module namespace hypercubes = "http://xbrl.io/modules/bizql/hypercubes";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";

hypercubes:facts(
    hypercubes:dimensionless-hypercube({
        Concepts: ["us-gaap:Assets"],
        Entities: [ companies:companies-for-tags("DOW30") ]
    })
)