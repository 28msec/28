import module namespace fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace sec-networks = "http://xbrl.io/modules/bizql/profiles/sec/networks";

let $filing := fiscal:filings-for-entities-and-fiscal-periods-and-years( 21344, "FY", 2012 )
return sec-networks:networks-for-filings-and-disclosures($filing, "BalanceSheet")