import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace filings = "http://xbrl.io/modules/bizql/profiles/sec/filings";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";

import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace session = "http://apps.28.io/session";


declare function local:filings(
    $ciks as string*,
    $tags as string*,
    $tickers as string*,
    $sics as string*,
    $fp as string*,
    $fy as string*) as object*
{
    let $entities := if ($tags = "ALL") then companies:companies()
                                        else (
                                            companies:companies($ciks),
                                            companies:companies-for-tags($tags),
                                            companies:companies-for-tickers($tickers),
                                            companies:companies-for-SIC($sics)
                                        )
    for $entity in $entities
    for $fy in distinct-values(
                for $fy in $fy
                return
                    switch ($fy)
                    case "LATEST" return
                        for $p in $fp
                        return
                            if ($p eq "FY")
                            then fiscal:latest-reported-fiscal-period($entity, "10-K").year 
                            else fiscal:latest-reported-fiscal-period($entity, "10-Q").year
                        case "ALL" return  $fiscal:ALL_FISCAL_YEARS
                    default return $fy cast as integer
                )
    for $fp in $fp 
    return fiscal:filings-for-entities-and-fiscal-periods-and-years($entity, $fp, $fy)
};

session:audit-call();

let $format      := lower-case((request:param-values("format"), substring-after(request:path(), ".jq."))[1])
let $ciks        := distinct-values(companies:eid(request:param-values("cik")))
let $tags        := distinct-values(request:param-values("tag") ! upper-case($$))
let $tickers     := distinct-values(request:param-values("ticker"))
let $sics        := distinct-values(request:param-values("sic"))
let $fiscalYears := distinct-values(
                        for $y in request:param-values("fiscalYear", "LATEST")
                        return
                            if ($y eq "LATEST" or $y eq "ALL")
                            then $y
                            else if ($y castable as integer)
                            then $y
                            else  ()
                    )
let $fiscalPeriods := distinct-values(let $fp := request:param-values("fiscalPeriod", "FY")
                      return
                        if (($fp ! lower-case($$)) = "all")
                        then $fiscal:ALL_FISCAL_PERIODS
                        else $fp)
let $aids        := archives:aid(request:param-values("aid"))
let $archives    := (
                        local:filings($ciks, $tags, $tickers, $sics, $fiscalPeriods, $fiscalYears),
                        archives:archives($aids)
                    )
let $companies   := companies:companies($archives.Entity)
return
    if (session:only-dow30($companies) or session:valid())
    then {
        let $summaries := filings:summaries($archives) 
        return
            switch ($format)
            case "xml"  return {
                response:serialization-parameters({"omit-xml-declaration" : false, indent : true });
                ( session:comment("xml", {
                    NumArchives: count($summaries),
                    TotalNumArchives: session:num-archives(),
                    TotalNumEntities: session:num-entities()
                }),
                <Filings>{
                    filings:summaries-to-xml($summaries)   
                }</Filings>)
            }
            case "csv" case "text" return {
                response:content-type("text/csv");
                response:header("Content-Disposition", "attachment; filename=filings.csv");
                string-join(filings:summaries-to-csv($summaries), "")
            }
            case "excel" return {
                response:content-type("application/vnd.ms-excel");
                response:header("Content-Disposition", "attachment; filename=filings.csv");
                string-join(filings:summaries-to-csv($summaries))
            }
            default return {
                response:content-type("application/json");
                response:serialization-parameters({"indent" : true});
                {|
                    { "Archives" : [ $summaries ] },
                    session:comment("json", {
                        NumArchives: count($summaries),
                        TotalNumArchives: session:num-archives(),
                        TotalNumEntities: session:num-entities()
                    })
                |}
            }
    } else {
        response:status-code(401);
        session:error("accessing filings of an entity that is not in the DOW30", $format)
    }
