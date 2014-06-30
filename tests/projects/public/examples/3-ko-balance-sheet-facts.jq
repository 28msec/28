import module namespace fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace sec-networks = "http://xbrl.io/modules/bizql/profiles/sec/networks";
import module namespace csv = "http://zorba.io/modules/json-csv";

let $filing := fiscal:filings-for-entities-and-fiscal-periods-and-years( 21344, "FY", 2012 )
let $network := sec-networks:networks-for-filings-and-disclosures($filing, "BalanceSheet")
let $facts := sec-networks:facts($network)
return
    csv:serialize(
        for $f in $facts
        return {|
            $f.Aspects,
            { Value : $f.Value }
        |}
    )