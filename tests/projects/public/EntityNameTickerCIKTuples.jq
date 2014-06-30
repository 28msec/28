import module namespace entities ="http://xbrl.io/modules/bizql/entities";

declare function local:compute() as object* {
    for $entity in entities:entities()
    return {
        name: $entity.Profiles.SEC.CompanyName,
        tickers: $entity.Profiles.SEC.Tickers,
        cik: $entity.Profiles.SEC.CIK
    }
};
let $tuples:= local:compute()
return {
    entityNameTickerSymbolCikTuples:[$tuples]
}
