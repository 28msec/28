
import module namespace sec = "http://xbrl.io/modules/bizql/profiles/sec/core";
import module namespace archives = "http://xbrl.io/modules/bizql/archives";
import module namespace entities = "http://xbrl.io/modules/bizql/entities";
import module namespace sec-fiscal = "http://xbrl.io/modules/bizql/profiles/sec/fiscal/core";
import module namespace companies = "http://xbrl.io/modules/bizql/profiles/sec/companies";
import module namespace response = "http://www.28msec.com/modules/http-response";
import module namespace request = "http://www.28msec.com/modules/http-request";
import module namespace session = "http://apps.28.io/session";

declare %an:sequential function local:filingPeriodInfo($archives as object*) as object*{
    for $archive in $archives
    return {
        fiscalPeriod: sec-fiscal:fiscal-period($archive),
        fiscalYear: sec-fiscal:fiscal-year($archive),
        endDate:  sec:end-date($archive)
    }
};

variable $cik := let $cik := request:param-values("cik","0000354950")
                 return if (empty($cik))
                        then error(QName("local:INVALID-REQUEST"), "cik: mandatory parameter not found")
                        else if (empty(entities:entities(companies:eid($cik))))
                             then error(QName("local:INVALID-REQUEST"), "Given CIK:"||$cik|| " not found")
                             else $cik;
                             
let $entity := entities:entities(companies:eid($cik))
let $archives :=  archives:archives-for-entities($entity)
let $format  := lower-case(substring-after(request:path(), ".jq.")) (: text, xml, or json (default) :)
return  if(session:only-dow30($entity) or session:valid()) 
        then {
            cik: $cik,
            companyName: $entity.Profiles.SEC.CompanyName,
            filings: [local:filingPeriodInfo($archives)]
        } else {
            response:status-code(401);
            session:error("accessing filings of an entity that is not in the DOW30", $format) 
        }

(: entities:entities(seccore:normalize-cik($cik)) can be simplified to secprofilefilings:filings($cik) :)
