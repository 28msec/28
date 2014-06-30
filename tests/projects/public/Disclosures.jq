import module namespace req = "http://www.28msec.com/modules/http/request";

declare function local:list($file as element()) as object*
{
    for $el in $file//node()
    where $el/@dataType/string() eq "dis:Disclosure"
    return {
        label: $el/@label/string(),
        name:
            let $name := $el/@name/string()
            let $prefix := $el/@prefix/string() || ":"
            return if (starts-with($name, $prefix)) then substring-after($name, $prefix) else $name,
        topic: $el/parent::Concept/@label/string()
    }
};

declare function local:tree($file as element(), $level as integer) as object*
{
    for $el in $file/node()
    return {
        level: $level,
        label: $el/@label/string(),
        name:
            let $name := $el/@name/string()
            let $prefix := $el/@prefix/string() || ":"
            return if (starts-with($name, $prefix)) then substring-after($name, $prefix) else $name,
        type:
            let $type := $el/@dataType/string()
            let $prefix := $el/@prefix/string() || ":"
            return if (starts-with($type, $prefix)) then substring-after($type, $prefix) else $type,
        children: [ local:tree($el, $level + 1) ]
    }
};

let $file := 
<Component>
<Network label='US GAAP' identifier='http://www.xbrlsite.com/us-gaap/US-GAAP'>
   <Concept label='Financial Report' name='asc:FinancialReport' abstract='true' dataType='asc:Topic' prefix='asc'>
      <Concept label='Primary Financial Statements' name='asc:PrimaryFinancialStatements' abstract='true' dataType='asc:Topic' prefix='asc'>
         <Concept label='Balance Sheet' name='asc:BalanceSheet' abstract='true' dataType='asc:Topic' prefix='asc'>
               <Concept label='Balance Sheet' name='dis:BalanceSheet' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Balance Sheet, Parenthetical' name='dis:BalanceSheetParenthetical' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Temporary Equity, by class' name='dis:TemporaryEquityByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Preferred Stock, by class' name='dis:PreferredStockByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Common Stock, by class' name='dis:CommonStockByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Treasury Stock, by class' name='dis:TreasuryStockByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Assets [Roll Up]' name='dis:AssetsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Liabilities and Equity [Roll Up]' name='dis:LiabilitiesAndEquityRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
         </Concept>
         <Concept label='Statement of Income and Comprehensive Income' name='asc:StatementOfIncomeAndComprehensiveIncome' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Income Statement' name='asc:IncomeStatement' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Income Statement' name='dis:IncomeStatement' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Income Breakdown' name='dis:NetIncomeBreakdown' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earning Per Share' name='dis:EarningPerShare' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Statement, Parenthetical' name='dis:IncomeStatementParenthetical' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Income (Loss) Available to Common Stockholders, Basic [Roll Up]' name='dis:NetIncomeLossAvailableToCommonStockholdersBasicRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Statement of Income and Comprehensive Income' name='dis:StatementOfIncomeAndComprehensiveIncome' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Comprehensive Income' name='asc:ComprehensiveIncome' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Statement of Comprehensive Income' name='dis:StatementOfComprehensiveIncome' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Comprehensive Income (Loss), Net of Tax, Attributable to Parent [Roll Up]' name='dis:ComprehensiveIncomeLossNetOfTaxAttributableToParentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
         </Concept>
         <Concept label='Cash Flow Statement' name='asc:CashFlowStatement' abstract='true' dataType='asc:Topic' prefix='asc'>
               <Concept label='Cash Flow Statement' name='dis:CashFlowStatement' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Cash Flow, Supplemental Disclosures' name='dis:CashFlowSupplementalDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Cash Flow, Operating Capital [Text Block]' name='dis:CashFlowOperatingCapital' abstract='true' dataType='dis:Disclosure' prefix='dis' />
               <Concept label='Cash Flow, Supplemental Disclosures (Duplicate) [Text Block]' name='dis:CashFlowSupplementalDisclosuresDuplicate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
         </Concept>
         <Concept label='Statement of Changes in Equity' name='asc:StatementOfChangesInEquity' abstract='true' dataType='asc:Topic' prefix='asc'>
         </Concept>
      </Concept>
      <Concept label='Disclosures' name='asc:Disclosures' abstract='true' dataType='asc:Topic' prefix='asc'>
         <Concept label='Nature of Business' name='asc:NatureOfBusiness' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Organization' name='asc:Organization' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Organization, Consolidation and Presentation of Financial Statements Disclosure and Significant Accounting Policies [Text Block]' name='dis:OrganizationConsolidationAndPresentationOfFinancialStatementsDisclosureAndSignificantAccountingPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Organization, Consolidation and Presentation of Financial Statements Disclosure' name='dis:OrganizationConsolidationAndPresentationOfFinancialStatementsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nature of Operations' name='dis:NatureOfOperations' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Additional Financial Information Disclosure [Text Block]' name='dis:AdditionalFinancialInformationDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Supplemental Balance Sheet Disclosures [Text Block]' name='dis:SupplementalBalanceSheetDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property Management Fee' name='dis:PropertyManagementFee' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Valuation And Qualifying Accounts Disclosure' name='dis:ValuationAndQualifyingAccountsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Going Concern' name='dis:GoingConcern' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Principles of Consolidation' name='asc:PrinciplesOfConsolidation' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Consolidation, Variable Interest Entity, Policy [Policy Text Block]' name='dis:ConsolidationVariableInterestEntityPolicyPolicyTextBlock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Variable Interest Entities' name='dis:VariableInterestEntities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
         </Concept>
         <Concept label='Basis of Financial Statement Presentation' name='asc:BasisOfFinancialStatementPresentation' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Basis of Reporting' name='asc:BasisOfReporting' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Basis of Reporting' name='dis:BasisOfReporting' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Accounting Changes' name='asc:AccountingChanges' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Accounting Changes and Error Corrections Disclosures' name='dis:AccountingChangesAndErrorCorrectionsDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income (Loss), Effect of Change in Accounting Principle, Net of Taxes [Roll Up]' name='dis:OtherComprehensiveIncomeLossEffectOfChangeInAccountingPrincipleNetOfTaxesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounting Changes and Error Corrections [Hierarchy]' name='dis:AccountingChangesAndErrorCorrectionsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Use of Estimates' name='asc:UseOfEstimates' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Change in Accounting Estimate' name='dis:ChangeInAccountingEstimate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Prior Period Adjustments' name='asc:PriorPeriodAdjustments' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Misstatement of Prior Year Statement Corrected in Current Year Financial Statements' name='dis:MisstatementPriorYearCorrectedInCurrentYearFinancialStatements' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Error Corrections and Prior Period Adjustments [Hierarchy]' name='dis:ErrorCorrectionsAndPriorPeriodAdjustmentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Misstatement in Current Year Financial Statements [Hierarchy]' name='dis:MisstatementInCurrentYearFinancialStatementsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Changing Prices (Hyperinflation)' name='asc:ChangingPricesHyperinflation' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Earnings Per Share' name='asc:EarningsPerShare' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Earnings Per Share Disclosures' name='dis:EarningsPerShareDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share Calculation [Text Block]' name='dis:EarningsPerShareCalculation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Weighted Average Number of Shares [Text Block]' name='dis:WeightedAverageNumberOfShares' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic, by Common Class, Including Two Class Method' name='dis:EarningsPerShareBasicByCommonClassIncludingTwoClassMethod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Diluted, by Common Class, Including Two Class Method' name='dis:EarningsPerShareDilutedByCommonClassIncludingTwoClassMethod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Antidilutive Securities Excluded from Computation of Earnings Per Share' name='dis:AntidilutiveSecuritiesExcludedfromComputationOfEarningsPerShare' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Income (Loss) Available to Common Stockholders, Diluted [Roll Up]' name='dis:NetIncomeLossAvailableToCommonStockholdersDilutedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Weighted Average Number of Shares Outstanding, Diluted [Roll Up]' name='dis:WeightedAverageNumberOfSharesOutstandingDilutedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic [Roll Up]' name='dis:EarningsPerShareBasicRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Participating Securities, Distributed and Undistributed Earnings [Roll Up]' name='dis:ParticipatingSecuritiesDistributedAndUndistributedEarningsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Undistributed Earnings, Basic [Roll Up]' name='dis:UndistributedEarningsBasicRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Diluted [Roll Up]' name='dis:EarningsPerShareDilutedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Undistributed Earnings, Diluted [Roll Up]' name='dis:UndistributedEarningsDilutedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share Disclosures [Hierarchy]' name='dis:EarningsPerShareDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Pro Forma [Hierarchy]' name='dis:EarningsPerShareProFormaHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impact of Restatement on Earnings Per Share [Hierarchy]' name='dis:ImpactOfRestatementonEarningsPerShareHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic, Two Class Method [Hierarchy]' name='dis:EarningsPerShareBasicTwoClassMethodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Nonrecurring Common Control Intra-Entity Transactions, Per Basic Share [Hierarchy]' name='dis:EarningsPerShareNonrecurringCommonControlIntraEntityTransactionsPerBasicShareHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Diluted, Two Class Method [Hierarchy]' name='dis:EarningsPerShareDilutedTwoClassMethodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Nonrecurring Common Control IntraEntity Transactions, Per Diluted Share [Hierarchy]' name='dis:EarningsPerShareNonrecurringCommonControlIntraEntityTransactionsPerDilutedShareHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Financial Instruments' name='asc:FinancialInstruments' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Interim Reporting' name='asc:InterimReporting' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Quarterly Financial Information' name='dis:QuarterlyFinancialInformation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Quarterly Financial Information (Duplicate) [Text Block]' name='dis:QuarterlyFinancialInformationDuplicate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effect of Fourth Quarter Events' name='dis:EffectOfFourthQuarterEvents' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Interim Period, Costs Not Allocable' name='dis:InterimPeriodCostsNotAllocable' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Quarterly Financial Information, Explanatory Disclosure [Hierarchy]' name='dis:QuarterlyFinancialInformationExplanatoryDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Selected Quarterly Financial Information [Hierarchy]' name='dis:SelectedQuarterlyFinancialInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Risks Uncertainties' name='asc:RisksUncertainties' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Concentration Risk Disclosure [Text Block]' name='dis:ConcentrationRiskDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Concentration of Risk, by Risk Factor' name='dis:ConcentrationOfRiskByRiskFactor' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Concentration Risks, Types, No Concentration Percentage' name='dis:ConcentrationRisksTypesNoConcentrationPercentage' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unusual Risks and Uncertainties' name='dis:UnusualRisksAndUncertainties' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Segment Reporting' name='asc:SegmentReporting' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Segment Reporting, Disclosure' name='dis:SegmentReportingDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting Information, by Segment' name='dis:SegmentReportingInformationBySegment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Reconciliation of Operating Profit (Loss) from Segments to Consolidated' name='dis:ReconciliationOfOperatingProfitLossfromSegmentsToConsolidated' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Reconciliation of Revenue from Segments to Consolidated' name='dis:ReconciliationOfRevenuefromSegmentsToConsolidated' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Reconciliation of Assets from Segment to Consolidated' name='dis:ReconciliationOfAssetsfromSegmentToConsolidated' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Reconciliation of Other Significant Reconciling Items from Segments to Consolidated' name='dis:ReconciliationOfOtherSignificantReconcilingItemsfromSegmentsToConsolidated' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Depreciation, Depletion and Amortization [Roll Up]' name='dis:DepreciationDepletionAndAmortizationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting Information, Revenue for Reportable Segment [Roll Up]' name='dis:SegmentReportingInformationRevenueForReportableSegmentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Entity&quot;s Reportable Segments Information [Hierarchy]' name='dis:SegmentReportingEntitysReportableSegmentsInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Disclosure of Other Information about Entity&quot;s Reportable Segments [Hierarchy]' name='dis:SegmentReportingDisclosureOfOtherInformationaboutEntitysReportableSegmentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Measurement Disclosures [Hierarchy]' name='dis:SegmentReportingMeasurementDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Other Disclosures [Hierarchy]' name='dis:SegmentReportingOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting Information, Additional Information [Hierarchy]' name='dis:SegmentReportingInformationAdditionalInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting Information, Other Information [Hierarchy]' name='dis:SegmentReportingInformationOtherInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting Information, Profit (Loss) [Hierarchy]' name='dis:SegmentReportingInformationProfitLossHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Reconciling Item for Operating Profit (Loss) from Segment to Consolidated [Hierarchy]' name='dis:SegmentReportingReconcilingItemForOperatingProfitLossfromSegmentToConsolidatedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Revenue Reconciling Item [Hierarchy]' name='dis:SegmentReportingRevenueReconcilingItemHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Asset Reconciling Item [Hierarchy]' name='dis:SegmentReportingAssetReconcilingItemHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Segment Reporting, Other Significant Reconciling Item, Consolidated [Hierarchy]' name='dis:SegmentReportingOtherSignificantReconcilingItemConsolidatedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Geographic Areas, Long-Lived Assets [Hierarchy]' name='dis:GeographicAreasLongLivedAssetsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Geographic Areas, Long-Lived Assets in Individual Foreign Countries by Country Disclosure [Text Block]' name='dis:GeographicAreasLongLivedAssetsInIndividualForeignCountriesByCountryDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Geographic Areas, Revenues from External Customers' name='dis:GeographicAreasRevenuesfromExternalCustomers' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue from Major Customers, by Reporting Segments' name='dis:RevenueFromMajorCustomersByReportingSegments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue from External Customers and Long-Lived Assets, by Geographical Areas' name='dis:RevenuefromExternalCustomersAndLongLivedAssetsByGeographicalAreas' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue from External Customers Attributed to Foreign Countries by Geographic Area [Text Block]' name='dis:RevenuefromExternalCustomersAttributedToForeignCountriesByGeographicArea' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue from External Customers by Products and Services' name='dis:RevenuefromExternalCustomersByProductsAndServices' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Specialized Activities' name='asc:SpecializedActivities' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Discontinued Operations' name='asc:DiscontinuedOperations' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Disposal Groups, Including Discontinued Operations, Income Statement, Balance Sheet and Additional Disclosures, by Disposal Group' name='dis:DisposalGroupsIncludingDiscontinuedOperationsIncomeStatementBalanceSheetAndAdditionalDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Groups, Including Discontinued Operations, Disclosure [Text Block]' name='dis:DisposalGroupsIncludingDiscontinuedOperationsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income (Loss) from Discontinued Operations, Net of Tax, Including Portion Attributable to Noncontrolling Interest [Roll Up]' name='dis:IncomeLossfromDiscontinuedOperationsNetOfTaxIncludingPortionAttributableToNoncontrollingInterestRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Discontinued Operation, Additional Disclosures [Hierarchy]' name='dis:DiscontinuedOperationAdditionalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Discontinued Operation, Income (Loss) from Discontinued Operation Disclosures [Hierarchy]' name='dis:DiscontinuedOperationIncomeLossfromDiscontinuedOperationDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Including Discontinued Operation, Additional Disclosures [Hierarchy]' name='dis:DisposalGroupIncludingDiscontinuedOperationAdditionalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Including Discontinued Operation, Balance Sheet Disclosures [Hierarchy]' name='dis:DisposalGroupIncludingDiscontinuedOperationBalanceSheetDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Including Discontinued Operation, Classified Balance Sheet Disclosures [Hierarchy]' name='dis:DisposalGroupIncludingDiscontinuedOperationClassifiedBalanceSheetDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Including Discontinued Operation, Unclassified Balance Sheet Disclosures [Hierarchy]' name='dis:DisposalGroupIncludingDiscontinuedOperationUnclassifiedBalanceSheetDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Not Discontinued Operation, Disposal Disclosures [Hierarchy]' name='dis:DisposalGroupNotDiscontinuedOperationDisposalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Not Discontinued Operation, Income Statement Disclosures [Hierarchy]' name='dis:DisposalGroupNotDiscontinuedOperationIncomeStatementDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Group, Special Transaction Classifications [Hierarchy]' name='dis:DisposalGroupSpecialTransactionClassificationsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Disposal Groups, Including Discontinued Operations, Disclosure [Hierarchy]' name='dis:DisposalGroupsIncludingDiscontinuedOperationsDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
         </Concept>
         <Concept label='Significant Accounting Policies' name='asc:SignificantAccountingPolicies' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Accounting Policies' name='asc:AccountingPolicies' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Significant accounting policies' name='dis:SignificantAccountingPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue Recognition Policy' name='dis:RevenueRecognitionPolicy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment Useful Lives' name='dis:PropertyPlantAndEquipmentUsefulLives' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Industry Specific Policies [Hierarchy]' name='dis:IndustrySpecificPoliciesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
         </Concept>
         <Concept label='Financial Statement Accounts' name='asc:FinancialStatementAccounts' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Cash and Cash Equivalents' name='asc:CashAndCashEquivalents' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Cash and Cash Equivalents and Short-term Investments Disclosure' name='dis:CashCashEquivalentsAndShortTermInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cash and Cash Equivalents Disclosure' name='dis:CashAndCashEquivalentsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cash and Cash Equivalents Details [Roll up]' name='dis:CashAndCashEquivalentsDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Cash Related Disclosures [Hierarchy]' name='dis:OtherCashRelatedDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cash and Cash Equivalents [Text Block]' name='dis:CashAndCashEquivalents' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restricted Cash and Cash Equivalents' name='dis:RestrictedCashAndCashEquivalents' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cash, Insured and Uninsured [Hierarchy]' name='dis:CashInsuredAndUninsuredHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensating Balances' name='dis:CompensatingBalances' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Receivables' name='asc:Receivables' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Receivables Disclosures' name='dis:ReceivablesDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Receivable Additional Disclosures [Hierarchy]' name='dis:AccountsReceivableAdditionalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Receivable, Net [Roll Up]' name='dis:AccountsReceivableNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts, Notes, Loans and Financing Receivable' name='dis:AccountsNotesLoansAndFinancingReceivable' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts, Notes, Loans and Financing Receivable, Current [Roll Up]' name='dis:AccountsNotesLoansAndFinancingReceivableCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts, Notes, Loans and Financing Receivable, Noncurrent [Roll Up]' name='dis:AccountsNotesLoansAndFinancingReceivableNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Allowance for Credit Losses [Text Block]' name='dis:AllowanceForCreditLosses' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Allowance for Credit Losses on Financing Receivables [Text Block]' name='dis:AllowanceForCreditLossesonFinancingReceivables' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Allowance for Doubtful Accounts Receivable [Roll Forward]' name='dis:AllowanceForDoubtfulAccountsReceivableRollforward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Allowance for Loan and Lease Losses [Roll Forward]' name='dis:AllowanceForLoanAndLeaseLossesRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans Acquired in Transfer Not Accounted for as Debt Securities [Hierarchy]' name='dis:CertainLoansAcquiredInTransferNotAccountedForasDebtSecuritiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans Acquired in Transfer Not Accounted for as Debt Securities Provision and Allowance [Hierarchy]' name='dis:CertainLoansAcquiredInTransferNotAccountedForasDebtSecuritiesProvisionAndAllowanceHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans Acquired in Transfer Not Accounted for as Debt Securities, Accretable Yield Movement [Roll Forward]' name='dis:CertainLoansAcquiredInTransferNotAccountedForasDebtSecuritiesAccretableYieldMovementRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans Acquired in Transfer Not Accounted for as Debt Securities, Acquired During Period [Hierarchy]' name='dis:CertainLoansAcquiredInTransferNotAccountedForasDebtSecuritiesAcquiredDuringPeriodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans Acquired in Transfer Not Accounted for as Debt Securities, Not Accounted for Using Income Recognition Model [Hierarchy]' name='dis:CertainLoansAcquiredInTransferNotAccountedForasDebtSecuritiesNotAccountedForUsingIncomeRecognitionModelHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Certain Loans and Debt Securities Acquired in Transfer, Subsequent Impairment [Hierarchy]' name='dis:CertainLoansAndDebtSecuritiesAcquiredInTransferSubsequentImpairmentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contract Receivable Retainage [Roll Up]' name='dis:ContractReceivableRetainageRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contracts Receivable [Roll Up]' name='dis:ContractsReceivableRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contracts Receivable, Claims and Uncertain Amounts [Roll Up]' name='dis:ContractsReceivableClaimsAndUncertainAmountsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Credit Losses for Financing Receivables, Current [Text Block]' name='dis:CreditLossesForFinancingReceivablesCurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Credit Losses Related to Financing Receivables, Current and Noncurrent [Text Block]' name='dis:CreditLossesRelatedToFinancingReceivablesCurrentAndNoncurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Credit Losses Related to Financing Receivables, Noncurrent [Text Block]' name='dis:CreditLossesRelatedToFinancingReceivablesNoncurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deteriorated Loans Transferred in' name='dis:DeterioratedLoansTransferredin' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deteriorated Loans Transferred in, Debt Securities, Accreditable Yield, Net Increase (Decrease) [Hierarchy]' name='dis:DeterioratedLoansTransferredinDebtSecuritiesAccreditableYieldNetIncreaseDecreaseHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from Related Parties, Current [Roll Up]' name='dis:DueFromRelatedPartiesCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from Related Parties, Noncurrent [Roll Up]' name='dis:DueFromRelatedPartiesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from Related Parties, Unclassified [Roll Up]' name='dis:DueFromRelatedPartiesUnclassifiedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable Credit Quality Indicators [Text Block]' name='dis:FinancingReceivableCreditQualityIndicators' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Allowance for Credit Loss, Additional Information [Hierarchy]' name='dis:FinancingReceivableAllowanceForCreditLossAdditionalInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Allowance for Credit Losses' name='dis:FinancingReceivableAllowanceForCreditLosses' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Impaired [Hierarchy]' name='dis:FinancingReceivableImpairedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Modifications [Hierarchy]' name='dis:FinancingReceivableModificationsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Recorded Investment [Hierarchy]' name='dis:FinancingReceivableRecordedInvestmentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Recorded Investment, Aging [Hierarchy]' name='dis:FinancingReceivableRecordedInvestmentAgingHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Recorded Investment, Credit Quality Indicator' name='dis:FinancingReceivableRecordedInvestmentCreditQualityIndicator' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Recorded Investment, Past Due [Roll Up]' name='dis:FinancingReceivableRecordedInvestmentPastDueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivable, Troubled Debt Restructurings' name='dis:FinancingReceivableTroubledDebtRestructurings' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivables' name='dis:FinancingReceivables' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivables, Minimum Payments [Text Block]' name='dis:FinancingReceivablesMinimumPayments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivables, Non Accrual Status [Text Block]' name='dis:FinancingReceivablesNonAccrualStatus' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financing Receivables, Past Due' name='dis:FinancingReceivablesPastDue' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impaired Financing Receivables' name='dis:ImpairedFinancingReceivables' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loan and Lease Receivables, Impaired [Hierarchy]' name='dis:LoanAndLeaseReceivablesImpairedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable Disclosure' name='dis:LoansAndLeasesReceivableDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Allowance [Roll Up]' name='dis:LoansAndLeasesReceivableAllowanceRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Deferred Income [Roll Up]' name='dis:LoansAndLeasesReceivableDeferredIncomeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Gross, Carrying Amount, by Category Alternative [Roll Up]' name='dis:LoansAndLeasesReceivableGrossCarryingAmountByCategoryAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Loans in Process [Roll Up]' name='dis:LoansAndLeasesReceivableLoansInProcessRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Net of Deferred Income [Roll Up]' name='dis:LoansAndLeasesReceivableNetOfDeferredIncomeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Net Reported Amount [Roll Up]' name='dis:LoansAndLeasesReceivableNetReportedAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Net Reported Amount, by Category Alternative [Roll Up]' name='dis:LoansAndLeasesReceivableNetReportedAmountByCategoryAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Other Information [Hierarchy]' name='dis:LoansAndLeasesReceivableOtherInformationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Related Parties [Roll Forward]' name='dis:LoansAndLeasesReceivableRelatedPartiesRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans and Leases Receivable, Related Parties Disclosure [Hierarchy]' name='dis:LoansAndLeasesReceivableRelatedPartiesDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Receivable Held-for-sale, Net [Roll Up]' name='dis:LoansReceivableHeldForsaleNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Receivable Held-for-sale, Net, Reconciliation to Cash Flow [Roll Forward]' name='dis:LoansReceivableHeldForsaleNetReconciliationToCashFlowRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Receivable, Net [Roll Up]' name='dis:LoansReceivableNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Mortgage Loans on Real Estate, Commercial and Consumer, Net [Roll Up]' name='dis:MortgageLoansonRealEstateCommercialAndConsumerNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nontrade Receivables, Current [Roll Up]' name='dis:NontradeReceivablesCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nontrade Receivables, Noncurrent [Roll Up]' name='dis:NontradeReceivablesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nontrade Receivables, Unclassified [Roll Up]' name='dis:NontradeReceivablesUnclassifiedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Notes, Loans and Financing Receivable, Net [Roll Up]' name='dis:NotesLoansAndFinancingReceivableNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Receivables, Net, Current [Roll Up]' name='dis:OtherReceivablesNetCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivable with Imputed Interest, Net Amount [Roll Up]' name='dis:ReceivableWithImputedInterestNetAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivables Held-for-sale' name='dis:ReceivablesHeldForsale' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivables Held-for-sale, Amount [Roll Up]' name='dis:ReceivablesHeldForSaleAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivables Held-for-sale, Net Amount [Roll Up]' name='dis:ReceivablesHeldForSaleNetAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivables with Imputed Interest' name='dis:ReceivablesWithImputedInterest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restricted Assets Disclosure [Text Block]' name='dis:RestrictedAssetsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Trade Receivables Held-for-sale, Net, Reconciliation to Cash Flow [Roll Forward]' name='dis:TradeReceivablesHeldForsaleNetReconciliationToCashFlowRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unamortized Loan Commitment and Origination Fees and Unamortized Discounts or Premiums [Roll Up]' name='dis:UnamortizedLoanCommitmentAndOriginationFeesAndUnamortizedDiscountsOrPremiumsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Debt and Equity Securities' name='asc:DebtAndEquitySecurities' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Cost and Equity Method Investments Disclosure [Text Block]' name='dis:CostAndEquityMethodInvestmentsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities' name='dis:AvailableForsaleSecurities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities [Hierarchy]' name='dis:AvailableForsaleSecuritiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities [Roll Up]' name='dis:AvailableForsaleSecuritiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities Reconciliation [Text Block]' name='dis:AvailableForsaleSecuritiesReconciliation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Amortized Cost Basis [Roll Up]' name='dis:AvailableForsaleSecuritiesAmortizedCostBasisRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Change in Net Unrealized Holding Gain (Loss), Net of Tax [Roll Up]' name='dis:AvailableForsaleSecuritiesChangeInNetUnrealizedHoldingGainLossNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Continuous Unrealized Loss Position [Hierarchy]' name='dis:AvailableForsaleSecuritiesContinuousUnrealizedLossPositionHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Current [Roll Up]' name='dis:AvailableForsaleSecuritiesCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Debt Maturities [Hierarchy]' name='dis:AvailableForsaleSecuritiesDebtMaturitiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Debt Maturities, Amortized Cost Basis [Roll Up]' name='dis:AvailableForsaleSecuritiesDebtMaturitiesAmortizedCostBasisRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Debt Maturities, Fair Value [Hierarchy]' name='dis:AvailableForsaleSecuritiesDebtMaturitiesFairValueHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Gross Gains (Losses), Derivatives [Roll Up]' name='dis:AvailableForsaleSecuritiesGrossGainsLossesDerivativesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Gross Realized Gain (Loss) [Roll Up]' name='dis:AvailableForsaleSecuritiesGrossRealizedGainLossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Gross Realized Gain (Loss), Disclosures [Hierarchy]' name='dis:AvailableForsaleSecuritiesGrossRealizedGainLossDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Gross Realized Gain (Loss), Excluding Other than Temporary Impairments [Roll Up]' name='dis:AvailableForsaleSecuritiesGrossRealizedGainLossExcludingOtherThanTemporaryImpairmentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Gross Unrealized Gain (Loss) [Roll Up]' name='dis:AvailableForsaleSecuritiesGrossUnrealizedGainLossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Noncurrent [Roll Up]' name='dis:AvailableForsaleSecuritiesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Other Disclosure Items [Hierarchy]' name='dis:AvailableForsaleSecuritiesOtherDisclosureItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Restricted [Roll Up]' name='dis:AvailableForsaleSecuritiesRestrictedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Restricted, Disclosure [Hierarchy]' name='dis:AvailableForsaleSecuritiesRestrictedDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Transfers to Trading [Hierarchy]' name='dis:AvailableForsaleSecuritiesTransfersToTradingHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Available-for-sale Securities, Transfers to Trading, Gains (Losses) [Roll Up]' name='dis:AvailableForsaleSecuritiesTransfersToTradingGainsLossesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities' name='dis:HeldTomaturitySecurities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Balance Sheet, Reported Amounts [Hierarchy]' name='dis:HeldTomaturitySecuritiesBalanceSheetReportedAmountsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Continuous Unrealized Loss Position, Aggregate Losses [Roll Up]' name='dis:HeldTomaturitySecuritiesContinuousUnrealizedLossPositionAggregateLossesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Continuous Unrealized Loss Position, Fair Value [Roll Up]' name='dis:HeldTomaturitySecuritiesContinuousUnrealizedLossPositionFairValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Continuous Unrealized Loss Position, Qualitative Disclosure [Hierarchy]' name='dis:HeldTomaturitySecuritiesContinuousUnrealizedLossPositionQualitativeDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Contracts to Acquire Securities to be Accounted for as Held-to-maturity [Hierarchy]' name='dis:HeldTomaturitySecuritiesContractsToAcquireSecuritiesTobeAccountedForasHeldTomaturityHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Debt Maturities [Hierarchy]' name='dis:HeldTomaturitySecuritiesDebtMaturitiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Debt Maturities, Fair Value [Roll Up]' name='dis:HeldTomaturitySecuritiesDebtMaturitiesFairValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Debt Maturities, Net Carrying Amount [Roll Up]' name='dis:HeldTomaturitySecuritiesDebtMaturitiesNetCarryingAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Gross Gains (Losses), Derivatives [Roll Up]' name='dis:HeldTomaturitySecuritiesGrossGainsLossesDerivativesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Other Disclosure Items [Hierarchy]' name='dis:HeldTomaturitySecuritiesOtherDisclosureItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Parenthetical Disclosure [Hierarchy]' name='dis:HeldTomaturitySecuritiesParentheticalDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Restricted [Roll Up]' name='dis:HeldTomaturitySecuritiesRestrictedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Restricted, Disclosure [Hierarchy]' name='dis:HeldTomaturitySecuritiesRestrictedDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Sales or Transfers of Investments [Hierarchy]' name='dis:HeldTomaturitySecuritiesSalesOrTransfersOfInvestmentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Sales, Excluding Other than Temporary Impairments [Hierarchy]' name='dis:HeldTomaturitySecuritiesSalesExcludingOtherThanTemporaryImpairmentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Transferred Security, Unrealized Gain (Loss) [Roll Up]' name='dis:HeldTomaturitySecuritiesTransferredSecurityUnrealizedGainLossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Held-to-maturity Securities, Transfers [Hierarchy]' name='dis:HeldTomaturitySecuritiesTransfersHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Marketable Securities [Text Block]' name='dis:MarketableSecurities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Marketable Securities, Alternative [Roll Up]' name='dis:MarketableSecuritiesAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Marketable Securities, Restricted [Roll Up]' name='dis:MarketableSecuritiesRestrictedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Realized and Unrealized Gain (Loss) on Trading Securities [Roll Up]' name='dis:NetRealizedAndUnrealizedGainLossonTradingSecuritiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Investment Income' name='dis:InvestmentIncome' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Investments Classified by Contractual Maturity Date [Text Block]' name='dis:InvestmentsClassifiedByContractualMaturityDate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Investments in Debt and Marketable Equity Securities Disclosures' name='dis:InvestmentsInDebtAndMarketableEquitySecuritiesDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Realized Gain (Loss) [Text Block]' name='dis:RealizedGainLoss' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Realized Gain (Loss) on Investments [Text Block]' name='dis:RealizedGainLossonInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Temporary Impairment Losses, Investments [Text Block]' name='dis:TemporaryImpairmentLossesInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Trading Securities and Other Trading Assets' name='dis:TradingSecuritiesAndOtherTradingAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrealized Gain (Loss) on Investments [Text Block]' name='dis:UnrealizedGainLossonInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrealized Loss on Investments [Text Block]' name='dis:UnrealizedLossonInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Acquired, Accounted for as Debt Securities, Available-for-sale Category [Hierarchy]' name='dis:LoansAcquiredAccountedForasDebtSecuritiesAvailableForsaleCategoryHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Acquired, Accounted for as Debt Securities, Disclosure [Hierarchy]' name='dis:LoansAcquiredAccountedForasDebtSecuritiesDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Acquired, Accounted for as Debt Securities, General Items [Hierarchy]' name='dis:LoansAcquiredAccountedForasDebtSecuritiesGeneralItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Acquired, Accounted for as Debt Securities, Held-to-maturity Category [Hierarchy]' name='dis:LoansAcquiredAccountedForasDebtSecuritiesHeldTomaturityCategoryHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment Losses, Investments [Roll Up]' name='dis:OtherThanTemporaryImpairmentLossesInvestmentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment Losses, Investments, Available-for-sale Securities [Roll Up]' name='dis:OtherThanTemporaryImpairmentLossesInvestmentsAvailableForsaleSecuritiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment Losses, Investments, Available-for-sale Securities, Portion Recognized in Earnings, Net, Qualitative Disclosures [Hierarchy]' name='dis:OtherThanTemporaryImpairmentLossesInvestmentsAvailableForsaleSecuritiesPortionRecognizedInEarningsNetQualitativeDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment Losses, Investments, Held-to-maturity Securities [Roll Up]' name='dis:OtherThanTemporaryImpairmentLossesInvestmentsHeldTomaturitySecuritiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment Losses, Investments, Held-to-maturity Securities, Portion Recognized in Earnings, Net, Qualitative Disclosures [Hierarchy]' name='dis:OtherThanTemporaryImpairmentLossesInvestmentsHeldTomaturitySecuritiesPortionRecognizedInEarningsNetQualitativeDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other than Temporary Impairment, Credit Losses Recognized in Earnings' name='dis:OtherThanTemporaryImpairmentCreditLossesRecognizedInEarnings' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Equity Method Joint Ventures' name='asc:EquityMethodJointVentures' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Equity Method Investments' name='dis:EquityMethodInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Equity Method Investments Disclosure [Text Block]' name='dis:EquityMethodInvestmentsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Investments - Other' name='asc:InvestmentsOther' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Investments, All Other Investments Disclosures' name='dis:InvestmentsAllOtherInvestmentsDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Investments and Other Noncurrent Assets [Text Block]' name='dis:InvestmentsAndOtherNoncurrentAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cost-method Investments' name='dis:CostMethodInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cost-method Investments, Description [Text Block]' name='dis:CostMethodInvestmentsDescription' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cost-method Investments, Realized Gain (Loss), Alternative [Roll Up]' name='dis:CostMethodInvestmentsRealizedGainLossAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cost-method Investments, Realized Gain (Loss), Excluding Other than Temporary Impairments [Roll Up]' name='dis:CostMethodInvestmentsRealizedGainLossExcludingOtherThanTemporaryImpairmentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financial Instruments Disclosure [Text Block]' name='dis:FinancialInstrumentsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Investments' name='dis:GainLossOnInvestments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Investments [Roll Up]' name='dis:GainLossonInvestmentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Investments, Excluding Other than Temporary Impairments [Roll Up]' name='dis:GainLossonInvestmentsExcludingOtherThanTemporaryImpairmentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Investments, Excluding Other than Temporary Impairments, Realized and Unrealized Alternative [Roll Up]' name='dis:GainLossonInvestmentsExcludingOtherThanTemporaryImpairmentsRealizedAndUnrealizedAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Investments, Realized and Unrealized Alternative [Roll Up]' name='dis:GainLossonInvestmentsRealizedAndUnrealizedAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Insurance, Corporate or Bank Owned' name='dis:LifeInsuranceCorporateOrBankOwned' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Disclosure [Text Block]' name='dis:LifeSettlementContractsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Fair Value Method [Hierarchy]' name='dis:LifeSettlementContractsFairValueMethodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Fair Value Method [Text Block]' name='dis:LifeSettlementContractsFairValueMethod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Fair Value Method, Disclosure Items [Hierarchy]' name='dis:LifeSettlementContractsFairValueMethodDisclosureItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Investment Method [Hierarchy]' name='dis:LifeSettlementContractsInvestmentMethodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Investment Method [Text Block]' name='dis:LifeSettlementContractsInvestmentMethod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Life Settlement Contracts, Investment Method, Disclosure Items [Hierarchy]' name='dis:LifeSettlementContractsInvestmentMethodDisclosureItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Inventory' name='asc:Inventory' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Inventory Disclosure' name='dis:InventoryDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory Details' name='dis:InventoryDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Current [Text Block]' name='dis:InventoryCurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Noncurrent [Text Block]' name='dis:InventoryNoncurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, LIFO Reserve, Effect on Income, Net [Roll Up]' name='dis:InventoryLIFOReserveEffectonIncomeNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Net [Roll Up]' name='dis:InventoryNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Net, Classification by Industry Alternative [Roll Up]' name='dis:InventoryNetClassificationByIndustryAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Net, Combining Work in Process and Raw Materials Alternative [Roll Up]' name='dis:InventoryNetCombiningWorkInProcessAndRawMaterialsAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Net, Items Net of Reserve Alternative [Roll Up]' name='dis:InventoryNetItemsNetOfReserveAlternativeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory, Noncurrent [Roll Up]' name='dis:InventoryNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='General and Administrative Costs in Inventory [Hierarchy]' name='dis:GeneralAndAdministrativeCostsInInventoryHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='LIFO Method Related Items [Hierarchy]' name='dis:LIFOMethodRelatedItemsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Deferred Costs' name='asc:DeferredCosts' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Deferred Costs, Capitalized, Prepaid, and Other Assets Disclosure' name='dis:DeferredCostsCapitalizedPrepaidAndOtherAssetsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Costs, Leasing, Net [Roll Up]' name='dis:DeferredCostsLeasingNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs [Hierarchy]' name='dis:DeferredFinanceCostsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Current, Net [Roll Up]' name='dis:DeferredFinanceCostsCurrentNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Net [Roll Up]' name='dis:DeferredFinanceCostsNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Noncurrent, Net [Roll Up]' name='dis:DeferredFinanceCostsNoncurrentNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Income Taxes [Hierarchy]' name='dis:DeferredIncomeTaxesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Deferred Costs [Hierarchy]' name='dis:OtherDeferredCostsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Deferred Costs, Net [Roll Up]' name='dis:OtherDeferredCostsNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Prepaid Expense and Other Assets, Current [Roll Up]' name='dis:PrepaidExpenseAndOtherAssetsCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Prepaid Expense and Other Assets, Noncurrent [Roll Up]' name='dis:PrepaidExpenseAndOtherAssetsNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preproduction Costs Related to Long-term Supply Arrangements [Hierarchy]' name='dis:PreproductionCostsRelatedToLongTermSupplyArrangementsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deposit Assets [Roll Up]' name='dis:DepositAssetsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Assets Held-in-trust [Roll Up]' name='dis:AssetsHeldintrustRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Credit Card Origination Costs [Hierarchy]' name='dis:CreditCardOriginationCostsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets [Roll Up]' name='dis:OtherAssetsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets [Text Block]' name='dis:OtherAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets and Other Liabilities [Text Block]' name='dis:OtherAssetsAndOtherLiabilities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets Disclosure [Text Block]' name='dis:OtherAssetsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets, Miscellaneous [Roll Up]' name='dis:OtherAssetsMiscellaneousRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets, Noncurrent [Hierarchy]' name='dis:OtherAssetsNoncurrentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets, Noncurrent [Text Block]' name='dis:OtherAssetsNoncurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets, Significant Additions or Reductions [Hierarchy]' name='dis:OtherAssetsSignificantAdditionsOrReductionsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Assets, Unclassified [Hierarchy]' name='dis:OtherAssetsUnclassifiedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Property, Plant, and Equipment' name='asc:PropertyPlantAndEquipment' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Property, Plant and Equipment Disclosure' name='dis:PropertyPlantAndEquipmentDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment' name='dis:PropertyPlantAndEquipment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment Income Statement Disclosures [Hierarchy]' name='dis:PropertyPlantAndEquipmentIncomeStatementDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment, Net, by Type [Roll Up]' name='dis:PropertyPlantAndEquipmentNetByTypeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment [Roll Forward]' name='dis:PropertyPlantAndEquipmentRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accumulated Depreciation, Depletion and Amortization of Property, Plant and Equipment [Roll Forward]' name='dis:AccumulatedDepreciationDepletionAndAmortizationPropertyPlantAndEquipmentRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment, Significant Acquisitions and Disposals' name='dis:PropertyPlantAndEquipmentSignificantAcquisitionsAndDisposals' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain (Loss) on Sale of Property Plant Equipment [Roll Up]' name='dis:GainLossonSaleOfPropertyPlantEquipmentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property, Plant and Equipment Impairment or Disposal [Hierarchy]' name='dis:PropertyPlantAndEquipmentImpairmentOrDisposal' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impaired Assets to be Disposed of by Method Other than Sale' name='dis:ImpairedAssetsTobeDisposedOfByMethodOtherThanSale' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impaired Long-Lived Assets Held and Used' name='dis:ImpairedLongLivedAssetsHeldAndUsed' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impairment or Disposal of Tangible Assets Disclosure [Hierarchy]' name='dis:ImpairmentOrDisposalOfTangibleAssetsDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Tangible Asset Impairment Charges [Roll Up]' name='dis:TangibleAssetImpairmentChargesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long Lived Assets Held-for-sale' name='dis:LongLivedAssetsHeldForsale' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-Lived Assets to be Abandoned' name='dis:LongLivedAssetsTobeAbandoned' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Assets Disposed of by Method Other than Sale, in Period of Disposition' name='dis:AssetsDisposedOfByMethodOtherThanSaleInPeriodOfDisposition' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Assets Held-for-sale, Reason for Changing Plan to Sell [Hierarchy]' name='dis:AssetsHeldForsaleReasonForChangingPlanToSellHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cost of Goods and Services Sold, Depreciation and Amortization [Roll Up]' name='dis:CostOfGoodsAndServicesSoldDepreciationAndAmortizationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Intangible Assets, Goodwill and Other' name='asc:IntangibleAssetsGoodwillAndOther' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Goodwill Disclosure [Text Block]' name='dis:GoodwillDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill' name='dis:Goodwill' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill [Roll Forward]' name='dis:GoodwillRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill, Impaired [Hierarchy]' name='dis:GoodwillImpairedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill, Impaired, Accumulated Impairment Loss [Roll Up]' name='dis:GoodwillImpairedAccumulatedImpairmentLossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill, Not Allocated [Hierarchy]' name='dis:GoodwillNotAllocatedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Goodwill and Intangible Assets Disclosure' name='dis:GoodwillAndIntangibleAssetsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Intangible Assets and Goodwill [Text Block]' name='dis:IntangibleAssetsAndGoodwill' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impaired Intangible Assets' name='dis:ImpairedIntangibleAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Impairment of Intangible Assets (Excluding Goodwill) [Roll Up]' name='dis:ImpairmentOfIntangibleAssetsExcludingGoodwillRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Intangible Assets Disclosure [Text Block]' name='dis:IntangibleAssetsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Intangible Assets, Net (Excluding Goodwill) [Roll Up]' name='dis:IntangibleAssetsNetExcludingGoodwillRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Indefinite-lived Intangible Assets' name='dis:IndefinitelivedIntangibleAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Indefinite-lived Intangible Assets [Roll Forward]' name='dis:IndefinitelivedIntangibleAssetsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Indefinite-lived Intangible Assets by Major Class [Hierarchy]' name='dis:IndefinitelivedIntangibleAssetsByMajorClassHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Acquired Finite-Lived Intangible Asset, by Major Class' name='dis:AcquiredFiniteLivedIntangibleAssetByMajorClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Acquired Indefinite-Lived Intangible Asset, by Major Class' name='dis:AcquiredIndefinitelivedIntangibleAssetsByMajorClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Finite-Lived Intangible Assets, Estimated Useful Lives [Hierarchy]' name='dis:FiniteLivedIntangibleAssetsEstimatedUsefulLives' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Finite-Lived Intangible Assets, Future Amortization Expense [Roll Up]' name='dis:FiniteLivedIntangibleAssetsFutureAmortizationExpenseRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Finite-Lived Intangible Assets, Future Amortization Expense, Current and Five Succeeding Fiscal Years [Hierarchy]' name='dis:FiniteLivedIntangibleAssetsFutureAmortizationExpenseCurrentAndFiveSucceedingFiscalYearsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Finite-Lived Intangible Assets, Net [Roll Up]' name='dis:FiniteLivedIntangibleAssetsNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Research and Development Assets Acquired Other than Through Business Combination' name='dis:ResearchAndDevelopmentAssetsAcquiredOtherThanThroughBusinessCombination' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Asset Impairment Charges [Text Block]' name='dis:AssetImpairmentCharges' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Payables and Accruals' name='asc:PayablesAccruals' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Accounts Payable Disclosures' name='dis:AccountsPayableDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities Disclosure [Text Block]' name='dis:AccountsPayableAndAccruedLiabilitiesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities [Text Block]' name='dis:AccountsPayableAndAccruedLiabilities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accrued Liabilities [Text Block]' name='dis:AccruedLiabilities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable Details' name='dis:AccountsPayableDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities, Current [Roll Up]' name='dis:AccountsPayableAndAccruedLiabilitiesCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities [Roll Up]' name='dis:AccountsPayableAndAccruedLiabilitiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities, Noncurrent [Roll Up]' name='dis:AccountsPayableAndAccruedLiabilitiesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accrued Income Taxes [Roll Up]' name='dis:AccruedIncomeTaxesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due to Related Parties [Roll Up]' name='dis:DueToRelatedPartiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due to Related Parties, Current [Roll Up]' name='dis:DueToRelatedPartiesCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due to Related Parties, Noncurrent [Roll Up]' name='dis:DueToRelatedPartiesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities Disclosure, Current [Text Block]' name='dis:AccountsPayableAccruedLiabilitiesAndOtherLiabilitiesDisclosureCurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accounts Payable and Accrued Liabilities Disclosure, Noncurrent [Text Block]' name='dis:AccountsPayableAccruedLiabilitiesAndOtherLiabilitiesDisclosureNoncurrent' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Asset Retirement Obligations' name='asc:AssetRetirementObligations' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Asset Retirement Obligation Disclosure [Text Block]' name='dis:AssetRetirementObligationDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Asset Retirement Obligation [Roll Up]' name='dis:AssetRetirementObligationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Asset Retirement Obligation, Roll Forward [Roll Forward]' name='dis:AssetRetirementObligationRollForwardAnalysisRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Exit Cost' name='dis:EnvironmentalExitCost' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Exit or Disposal Cost Obligations' name='asc:ExitOrDisposalCostObligations' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Restructuring and Related Activities Disclosure' name='dis:RestructuringAndRelatedActivitiesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring, Impairment, and Other Activities Disclosure [Text Block]' name='dis:RestructuringImpairmentAndOtherActivitiesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Reserve by Type of Cost [Text Block]' name='dis:RestructuringReserveByTypeOfCost' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring and Related Costs' name='dis:RestructuringAndRelatedCosts' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effects on Future Earnings and Cash Flows Resulting from Exit Plan' name='dis:EffectsonFutureEarningsAndCashFlowsResultingfromExitPlan' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Charges [Roll Up]' name='dis:RestructuringChargesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Reserve [Roll Up]' name='dis:RestructuringReserveRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Reserve [Roll Forward]' name='dis:RestructuringReserveRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring and Related Activities Disclosure [Hierarchy]' name='dis:RestructuringAndRelatedActivitiesDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring and Related Cost [Hierarchy]' name='dis:RestructuringAndRelatedCostHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring and Related Cost, Positions Eliminated [Hierarchy]' name='dis:RestructuringAndRelatedCostPositionsEliminatedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Cost and Reserve [Hierarchy]' name='dis:RestructuringCostAndReserveHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restructuring Reserve Disclosures [Hierarchy]' name='dis:RestructuringReserveDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effects on Future Earnings and Cash Flows Resulting from Exit Plan [Hierarchy]' name='dis:EffectsonFutureEarningsAndCashFlowsResultingfromExitPlanHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Deferred Revenue' name='asc:DeferredRevenue' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Deferred Revenue Disclosure' name='dis:DeferredRevenueDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Revenue [Roll Up]' name='dis:DeferredRevenueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Revenue [Roll Forward]' name='dis:DeferredRevenueRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Revenue Arrangement [Hierarchy]' name='dis:DeferredRevenueArrangementHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Revenue Arrangement, by Type' name='dis:DeferredRevenueArrangementByType' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Customer Refundable Fees [Roll Forward]' name='dis:CustomerRefundableFeesRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Contingencies' name='asc:Contingencies' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Commitments and Contingencies Disclosure' name='dis:CommitmentsAndContingenciesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Commitments Disclosure [Text Block]' name='dis:CommitmentsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contingencies Disclosure [Text Block]' name='dis:ContingenciesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Commitments Contingencies and Guarantees [Text Block]' name='dis:CommitmentsContingenciesAndGuarantees' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Accrual Components [Hierarchy]' name='dis:EnvironmentalLossAccrualComponentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies Accrual [Roll Forward]' name='dis:AccrualForEnvironmentalLossContingenciesRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies Accrual [Roll Up]' name='dis:AccrualForEnvironmentalLossContingenciesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies Accrual Disclosure [Hierarchy]' name='dis:AccrualForEnvironmentalLossContingenciesDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies Accrual, Balance Sheet Classification [Hierarchy]' name='dis:AccrualForEnvironmentalLossContingenciesBalanceSheetClassificationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies Accrual, Reconciliation of Undiscounted Amount to Recorded Balance [Hierarchy]' name='dis:AccrualForEnvironmentalLossContingenciesReconciliationOfUndiscountedAmountToRecordedBalanceHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies by Site' name='dis:EnvironmentalLossContingenciesBySite' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingencies, Applicability, Impact and Conclusion of [Hierarchy]' name='dis:ApplicabilityImpactAndConclusionOfEnvironmentalLossContingenciesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Loss Contingency Disclosure' name='dis:EnvironmentalLossContingencyDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Property Sale, Disposal or Abandonment Costs [Hierarchy]' name='dis:EnvironmentalPropertySaleDisposalOrAbandonmentCostsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Remediation Costs Recognized [Hierarchy]' name='dis:EnvironmentalRemediationCostsRecognizedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Environmental Site Contingency [Hierarchy]' name='dis:SiteContingencyHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Extended Product Warranty Accrual [Roll Forward]' name='dis:ExtendedProductWarrantyAccrualMovementRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Extended Product Warranty Accrual, Balance Sheet Classification [Roll Up]' name='dis:ExtendedProductWarrantyAccrualBalanceSheetClassificationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Extended Product Warranty Disclosure [Hierarchy]' name='dis:ExtendedProductWarrantyDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Gain Contingencies' name='dis:GainContingenciesByContingency' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Legal Matters and Contingencies [Text Block]' name='dis:LegalMattersAndContingencies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Litigation Settlement Gain (Loss) [Roll Up]' name='dis:GainLossRelatedToLitigationSettlementRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingencies' name='dis:LossContingencies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency Accrual [Roll Forward]' name='dis:LossContingencyAccrualRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency Accrual, Product Liability, Gross [Roll Up]' name='dis:LossContingencyAccrualProductLiabilityGrossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency Accrual, Product Liability, Material Components [Hierarchy]' name='dis:LossContingencyAccrualProductLiabilityMaterialComponentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency Accrual, Product Liability, Net [Hierarchy]' name='dis:LossContingencyAccrualProductLiabilityNetHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency Related Receivable [Roll Forward]' name='dis:LossContingencyRelatedReceivableRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Claims Quantities [Hierarchy]' name='dis:LossContingencyClaimsQuantitiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Classification of Accrual [Hierarchy]' name='dis:LossContingencyClassificationOfAccrualHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Estimate [Hierarchy]' name='dis:LossContingencyEstimateHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Information about Litigation Matters [Hierarchy]' name='dis:LossContingencyInformationaboutLitigationMattersHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Insurance-related Assessment [Hierarchy]' name='dis:LossContingencyInsurancerelatedAssessmentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Related Receivable [Hierarchy]' name='dis:LossContingencyRelatedReceivableHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Related Receivable Carrying Value [Roll Up]' name='dis:LossContingencyRelatedReceivableCarryingValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loss Contingency, Settlement [Hierarchy]' name='dis:LossContingencySettlementHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Product Liability Contingencies' name='dis:ProductLiabilityContingencies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Product Warranty Disclosure [Text Block]' name='dis:ProductWarrantyDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Product Warranty Liability [Text Block]' name='dis:ProductWarrantyLiability' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Purchase and Supply Commitment, Excluding Long-term Commitment [Text Block]' name='dis:PurchaseAndSupplyCommitmentExcludingLongTermCommitment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Third-Party Environmental Recoveries, Balance Sheet Classification [Hierarchy]' name='dis:RecordedThirdPartyEnvironmentalRecoveriesBalanceSheetClassificationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Third-Party Environmental Recoveries, Material Components of [Hierarchy]' name='dis:MaterialComponentsOfRecordedThirdPartyEnvironmentalRecoveriesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Third-Party Environmental Recoveries, Net [Roll Up]' name='dis:RecordedThirdPartyEnvironmentalRecoveriesNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Third-Party Recoveries Related to Environmental Remediation Obligations [Hierarchy]' name='dis:RecordedThirdPartyRecoveriesRelatedToEnvironmentalRemediationObligationsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Standard and Extended Product Warranty Accrual [Roll Forward]' name='dis:StandardAndExtendedProductWarrantyMovementRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Standard and Extended Product Warranty Accrual, Balance Sheet Classification [Roll Up]' name='dis:ProductWarrantyAccrualBalanceSheetClassificationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Standard Product Warranty Accrual [Roll Forward]' name='dis:StandardProductWarrantyAccrualMovementRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Standard Product Warranty Accrual, Balance Sheet Classification [Roll Up]' name='dis:StandardProductWarrantyAccrualBalanceSheetClassificationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Standard Product Warranty Disclosure [Hierarchy]' name='dis:StandardProductWarrantyDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Commitments' name='asc:Commitments' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Purchase Commitment, Excluding Long-term Commitment' name='dis:PurchaseCommitmentExcludingLongTermCommitment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Supply Commitment' name='dis:SupplyCommitment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Purchase Commitment' name='dis:LongTermPurchaseCommitment' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Unconditional Purchase Obligation' name='dis:RecordedUnconditionalPurchaseObligation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecorded Unconditional Purchase Obligation' name='dis:UnrecordedUnconditionalPurchaseObligation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Registration Payment Arrangement' name='dis:RegistrationPaymentArrangement' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Unconditional Purchase Obligation Payment Schedule [Roll Up]' name='dis:RecordedUnconditionalPurchaseObligationPaymentScheduleRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecorded Unconditional Purchase Obligation [Roll Up]' name='dis:UnrecordedUnconditionalPurchaseObligationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Recorded Unconditional Purchase Obligation [Hierarchy]' name='dis:RecordedUnconditionalPurchaseObligationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecorded Unconditional Purchase Obligation [Hierarchy]' name='dis:UnrecordedUnconditionalPurchaseObligationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Guarantees' name='asc:Guarantees' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Guarantor Obligations' name='dis:GuarantorObligations' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Guarantees [Text Block]' name='dis:Guarantees' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Debt' name='asc:Debt' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Debt Disclosure' name='dis:DebtDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt [Text Block]' name='dis:Debt' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Short-term Debt' name='dis:ShortTermDebt' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Short-term Debt (Duplicate) [Text Block]' name='dis:ShortTermDebtDuplicate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Short-term Debt Default [Hierarchy]' name='dis:ShortTermDebtDefaultHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Loans Payable, Current and Noncurrent [Roll Up]' name='dis:LoansPayableCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Line of Credit Facility' name='dis:LineOfCreditFacility' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt [Text Block]' name='dis:LongTermDebt' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt and Capital Leases Disclosures [Text Block]' name='dis:DebtAndCapitalLeasesDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Interest Costs Incurred' name='dis:InterestCostsIncurred' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Own-share Lending Arrangement, Issuance Costs' name='dis:DeferredFinanceCostsOwnShareLendingArrangementIssuanceCosts' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Extinguishment of Debt' name='dis:ExtinguishmentOfDebt' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt Conversion' name='dis:DebtConversion' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt Details' name='dis:LongTermDebtDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt Instruments' name='dis:LongTermDebtInstruments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt Maturities' name='dis:LongTermDebtMaturities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt, by Current and Noncurrent [Roll Up]' name='dis:LongTermDebtByCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt, by Type, Current and Noncurrent [Roll Up]' name='dis:LongTermDebtByTypeCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt, Current and Noncurrent [Roll Up]' name='dis:LongTermDebtCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Long-term Debt, Other Disclosures [Hierarchy]' name='dis:LongTermDebtOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Own-share Lending Arrangement, Issuance Costs, Net [Roll Up]' name='dis:DeferredFinanceCostsOwnShareLendingArrangementIssuanceCostsNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt Instrument, Unamortized Discount (Premium), Net [Roll Up]' name='dis:DebtInstrumentUnamortizedDiscountPremiumNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt, Long-term and Short-term, Combined Amount [Roll Up]' name='dis:DebtLongTermAndShortTermCombinedAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Troubled Debt Restructuring Summary Note, Debtor [Text Block]' name='dis:TroubledDebtRestructuringSummaryNoteDebtor' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Troubled Debt Restructuring, Debtor, Current Period' name='dis:TroubledDebtRestructuringDebtorCurrentPeriod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Troubled Debt Restructuring, Debtor, Current Period [Hierarchy]' name='dis:TroubledDebtRestructuringDebtorCurrentPeriodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Troubled Debt Restructuring, Debtor, Current Period, Gain (Loss) on Restructuring, Net of Tax [Roll Up]' name='dis:TroubledDebtRestructuringDebtorCurrentPeriodGainLossonRestructuringNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Troubled Debt Restructuring, Debtor, Subsequent Periods' name='dis:TroubledDebtRestructuringDebtorSubsequentPeriods' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Finance Costs, Own-share Lending Arrangement, Issuance Costs, Accumulated Amortization [Roll Forward]' name='dis:DeferredFinanceCostsOwnShareLendingArrangementIssuanceCostsAccumulatedAmortizationRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Mortgage Notes Payable Disclosure [Text Block]' name='dis:MortgageNotesPayableDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Notes and Loans Payable, Current and Noncurrent [Roll Up]' name='dis:NotesAndLoansPayableCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Notes Payable, Current and Noncurrent [Roll Up]' name='dis:NotesPayableCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Own-share Lending Arrangement [Hierarchy]' name='dis:OwnShareLendingArrangementHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Own-share Lending Arrangement, Counterparty Default [Hierarchy]' name='dis:OwnShareLendingArrangementCounterpartyDefaultHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Participating Mortgage Loans' name='dis:ParticipatingMortgageLoans' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Debt Instrument, Debt Default [Hierarchy]' name='dis:DebtInstrumentDebtDefault' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Distinguishing Liabilities from Equity' name='asc:DistinguishingLiabilitiesFromEquity' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Other Liabilities Disclosure' name='dis:OtherLiabilitiesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accelerated Share Repurchases' name='dis:AcceleratedShareRepurchases' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Option Indexed to Issuer&quot;s Equity' name='dis:OptionIndexedToIssuersEquity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Option Indexed to Issuer&quot;s Equity, Description' name='dis:OptionIndexedToIssuersEquityDescription' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Forward Contract Indexed to Issuer&quot;s Equity' name='dis:ForwardContractIndexedToIssuersEquity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financial Instruments Subject to Mandatory Redemption' name='dis:FinancialInstrumentsSubjectToMandatoryRedemption' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Noncontrolling Interest Disclosure' name='dis:NoncontrollingInterestDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Consolidation, Less than Wholly Owned Subsidiary, Parent Ownership Interest, Effects of Changes, Net' name='dis:ConsolidationLessThanWhollyOwnedSubsidiaryParentOwnershipInterestEffectsOfChangesNet' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Noncontrolling Interest' name='dis:NoncontrollingInterest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Redeemable Noncontrolling Interest' name='dis:RedeemableNoncontrollingInterest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Customer Advances and Deposits, Current [Roll Up]' name='dis:CustomerAdvancesAndDepositsCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Revenue and Credits [Roll Up]' name='dis:DeferredRevenueAndCreditsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Liabilities [Roll Up]' name='dis:OtherLiabilitiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Sundry Liabilities [Roll Up]' name='dis:OtherSundryLiabilitiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension and Other Postretirement and Postemployment Benefit Plans, Liabilities [Roll Up]' name='dis:PensionAndOtherPostretirementAndPostemploymentBenefitPlansLiabilitiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension and Other Postretirement and Postemployment Benefit Plans, Liabilities, Noncurrent [Roll Up]' name='dis:PensionAndOtherPostretirementAndPostemploymentBenefitPlansLiabilitiesNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stockholders&quot; Equity Attributable to Noncontrolling Interest [Roll Up]' name='dis:StockholdersEquityAttributableToNoncontrollingInterestRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Redeemable Noncontrolling Interest, Equity, Carrying Amount [Roll Up]' name='dis:RedeemableNoncontrollingInterestEquityCarryingAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Redeemable Noncontrolling Interest, Equity, Fair Value [Roll Up]' name='dis:RedeemableNoncontrollingInterestEquityFairValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stockholders&quot; Equity Attributable to Noncontrolling Interest [Roll Forward]' name='dis:StockholdersEquityAttributableToNoncontrollingInterestRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Credits and Other Liabilities [Hierarchy]' name='dis:DeferredCreditsAndOtherLiabilitiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Liabilities, Current [Hierarchy]' name='dis:OtherLiabilitiesCurrentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Liabilities, Noncurrent [Hierarchy]' name='dis:OtherLiabilitiesNoncurrentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Liabilities, Unclassified [Hierarchy]' name='dis:OtherLiabilitiesUnclassifiedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financial Instruments Subject to Mandatory Redemption by Settlement Terms [Hierarchy]' name='dis:FinancialInstrumentsSubjectToMandatoryRedemptionBySettlementTermsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deconsolidation, Gain (Loss) with Related Disclosures [Hierarchy]' name='dis:DeconsolidationGainLossWithRelatedDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Amounts Attributable to Noncontrolling Interest, Disclosures [Hierarchy]' name='dis:IncomeAmountsAttributableToNoncontrollingInterestDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Noncontrolling Interest Represented by Preferred Stock [Hierarchy]' name='dis:NoncontrollingInterestRepresentedByPreferredStockHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Redeemable Noncontrolling Interest, Range of Estimated Fair Value [Hierarchy]' name='dis:RedeemableNoncontrollingInterestRangeOfEstimatedFairValueHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Equity' name='asc:Equity' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Stockholders&quot; Equity Disclosures' name='dis:StockholdersEquityDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities Disclosure [Text Block]' name='dis:AuctionMarketPreferredSecuritiesDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Comprehensive Income (Loss) Note [Text Block]' name='dis:ComprehensiveIncomeLossNote' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income, Noncontrolling Interest [Text Block]' name='dis:OtherComprehensiveIncomeNoncontrollingInterest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Stock [Text Block]' name='dis:PreferredStock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accumulated Other Comprehensive Income (Loss) [Text Block]' name='dis:AccumulatedOtherComprehensiveIncomeLoss' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Comprehensive Income (Loss) [Text Block]' name='dis:ComprehensiveIncomeLoss' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Derivative Financial Instruments Indexed to, and Potentially Settled in, Entity&quot;s Own Stock, Equity [Text Block]' name='dis:DerivativeFinancialInstrumentsIndexedtoAndPotentiallySettledinEntitysOwnStockEquity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stockholders Equity [Text Block]' name='dis:StockholdersEquity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stockholders&quot; Equity Note Disclosure [Text Block]' name='dis:StockholdersEquityNoteDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Treasury Stock [Text Block]' name='dis:TreasuryStock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stock by Class' name='dis:StockByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Treasury Stock, by Class' name='dis:ClassOfTreasuryStock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Retained Earnings Adjustments' name='dis:RetainedEarningsAdjustments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Subsidiary or Equity Method Investee' name='dis:SubsidiaryOrEquityMethodInvestee' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities by Stock Series' name='dis:AuctionMarketPreferredSecuritiesByStockSeries' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Targeted or Tracking Stock' name='dis:TargetedOrTrackingStock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Dividends Payable' name='dis:DividendsPayable' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Conversion of Stock' name='dis:ConversionOfStock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Class of Warrant or Right' name='dis:ClassOfWarrantOrRight' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Stockholders&quot; Equity Note, Warrants or Rights [Text Block]' name='dis:StockholdersEquityNoteWarrantsOrRights' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Subsidiary or Equity Method Investee, Sale of Stock by Subsidiary or Equity Investee' name='dis:SubsidiaryOrEquityMethodInvesteeSaleOfStockBySubsidiaryOrEquityInvestee' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restrictions on Dividends, Loans and Advances' name='dis:RestrictionsonDividendsLoansAndAdvances' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Dividend Payment Restrictions [Text Block]' name='dis:DividendPaymentRestrictions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Partners&quot; Capital Disclosures' name='dis:PartnersCapitalDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Reclassification Amount Disclosure [Text Block]' name='dis:ReclassificationAmountDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Incentive Distribution Policy, Managing Member or General Partner, Description [Policy Text Block]' name='dis:IncentiveDistributionPolicyManagingMemberOrGeneralPartnerDescriptionPolicyTextBlock' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Units' name='dis:CapitalUnits' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Incentive Distribution Made to Managing Member or General Partner' name='dis:IncentiveDistributionMadeToManagingMemberOrGeneralPartner' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Units' name='dis:PreferredUnits' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Ownership Interests' name='dis:OtherOwnershipInterests' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Limited Partners&quot; Capital Account by Class' name='dis:LimitedPartnersCapitalAccountByClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Dividends, Share-based Compensation [Roll Up]' name='dis:DividendsSharebasedCompensationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effect on Retained Earnings (Accumulated Deficit) Due to Change in Measurement Date, Net of Tax [Roll Up]' name='dis:EffectonRetainedEarningsAccumulatedDeficitDueToChangeInMeasurementDateNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income (Loss), before Tax [Roll Up]' name='dis:OtherComprehensiveIncomeLossbeforeTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restatement of Prior Year Income, Net of Tax [Roll Up]' name='dis:RestatementOfPriorYearIncomeNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Common Stock, Including Additional Paid in Capital, Net of Discount [Roll Up]' name='dis:CommonStockIncludingAdditionalPaidInCapitalNetOfDiscountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Dividends, Common Stock [Roll Up]' name='dis:DividendsCommonStockRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Dividends, Preferred Stock [Roll Up]' name='dis:DividendsPreferredStockRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic and Diluted [Roll Up]' name='dis:EarningsPerShareBasicAndDilutedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Stock, Including Additional Paid in Capital, Net of Discount [Roll Up]' name='dis:PreferredStockIncludingAdditionalPaidInCapitalNetOfDiscountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cumulative Effect on Retained Earnings, Net of Tax [Roll Up]' name='dis:CumulativeEffectonRetainedEarningsNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities, Dividend, Paid from Earnings and Capital [Roll Up]' name='dis:AuctionMarketPreferredSecuritiesDividendPaidfromEarningsAndCapitalRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income (Loss), Net of Tax [Roll Up]' name='dis:OtherComprehensiveIncomeLossNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income (Loss), Tax [Roll Up]' name='dis:OtherComprehensiveIncomeLossTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Partners&quot; Capital [Roll Up]' name='dis:PartnersCapitalRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Units, Preferred Partners&quot; Capital Accounts [Roll Up]' name='dis:PreferredUnitsPreferredPartnersCapitalAccountsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Ownership Interests, Capital Account [Roll Up]' name='dis:OtherOwnershipInterestsCapitalAccountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Limited Partners&quot; Capital Account, Value [Roll Up]' name='dis:LimitedPartnersCapitalAccountValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities Shares Outstanding [Roll Forward]' name='dis:AuctionMarketPreferredSecuritiesSharesOutstandingRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Trust [Hierarchy]' name='dis:EmployeeTrustHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Deposit Securities [Hierarchy]' name='dis:IncomeDepositSecuritiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restatement of Prior Year Income [Hierarchy]' name='dis:RestatementOfPriorYearIncome' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restrictions for Consolidated and Unconsolidated Subsidiaries [Hierarchy]' name='dis:RestrictionsForConsolidatedAndUnconsolidatedSubsidiariesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Retained Earnings Disclosure [Hierarchy]' name='dis:RetainedEarningsDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Shares Held in Employee Stock Ownership Plan [Hierarchy]' name='dis:SharesHeldInEmployeeStockOwnershipPlanHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Class of Common Stock [Hierarchy]' name='dis:ClassOfCommonStockHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic and Diluted, Other Disclosures [Hierarchy]' name='dis:EarningsPerShareBasicAndDilutedOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Basic, Other Disclosures [Hierarchy]' name='dis:EarningsPerShareBasicOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Earnings Per Share, Diluted, Other Disclosures [Hierarchy]' name='dis:EarningsPerShareDilutedOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Convertible Preferred Stock Features [Hierarchy]' name='dis:ConvertiblePreferredStockFeaturesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Class of Preferred Stock [Hierarchy]' name='dis:ClassOfPreferredStockHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Stock, Shares Subscribed but Unissued, Value [Hierarchy]' name='dis:PreferredStockSharesSubscribedbutUnissuedValueHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities, Stock Series [Hierarchy]' name='dis:AuctionMarketPreferredSecuritiesStockSeriesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Auction Market Preferred Securities, Dividend Distributions [Hierarchy]' name='dis:AuctionMarketPreferredSecuritiesDividendDistributionsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restrictions on Dividends [Hierarchy]' name='dis:RestrictionsonDividendsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Restrictions on Loans and Other Fund Transfers [Hierarchy]' name='dis:RestrictionsonLoansAndOtherFundTransfersHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Incentive Distribution, Managing Member or General Partner [Hierarchy]' name='dis:IncentiveDistributionManagingMemberOrGeneralPartnerHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Distribution Made to Member or Limited Partner [Hierarchy]' name='dis:DistributionMadeToMemberOrLimitedPartnerHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Preferred Units Description and Other Disclosures [Hierarchy]' name='dis:PreferredUnitsDescriptionAndOtherDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Limited Partners&quot; Capital Account [Hierarchy]' name='dis:LimitedPartnersCapitalAccountHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Distributions Made to Limited Partner' name='dis:DistributionsMadeToLimitedPartner' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Distributions Made to Limited Liability Company (LLC) Member' name='dis:DistributionsMadeToLimitedLiabilityCompanyLLCMember' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Revenue Recognition' name='asc:RevenueRecognition' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Revenue Recognition, Multiple-deliverable Arrangements' name='dis:RevenueRecognitionMultipledeliverableArrangements' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue Recognition, Milestone Method' name='dis:RevenueRecognitionMilestoneMethod' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue Recognition, Multiple-deliverable Arrangements, by Type of Arrangement and Product' name='dis:RevenueRecognitionMultipledeliverableArrangementsByTypeOfArrangementAndProduct' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Revenue Recognition, Multiple-deliverable Arrangements, Description [Policy Text Block]' name='dis:RevenueRecognitionMultipledeliverableArrangementsDescriptionPolicy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Cost of Sales, Services' name='asc:CostOfSalesServices' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Compensation Related Costs, General' name='asc:CompensationRelatedCostsGeneral' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Compensation Related Costs, General' name='dis:CompensationRelatedCostsGeneral' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Arrangement with Individual, Excluding Share-based Payments and Postretirement Benefits, by Title of Individual and by Type of Deferred Compensation' name='dis:DeferredCompensationArrangementWithIndividual100' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensated Absences Liability [Roll Up]' name='dis:CompensatedAbsencesLiabilityRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Liability, Current [Roll Up]' name='dis:DeferredCompensationLiabilityCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Liability, Current and Noncurrent [Roll Up]' name='dis:DeferredCompensationLiabilityCurrentAndNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Labor and Related Expense [Roll Up]' name='dis:LaborAndRelatedExpenseRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensated Absences [Hierarchy]' name='dis:CompensatedAbsencesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Arrangements [Hierarchy]' name='dis:DeferredCompensationArrangementsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Stock Compensation' name='asc:StockCompensation' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Compensation Related Costs and Share-based Payments Disclosures' name='dis:CompensationRelatedCostsAndSharebasedPaymentsDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Shareholders&quot; Equity and Share-based Payments [Text Block]' name='dis:ShareholdersEquityAndSharebasedPayments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensation Related Costs and Share-based Payments Details' name='dis:CompensationRelatedCostsAndSharebasedPaymentsDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensation Related Costs and Share-based Payments Details, Other Disclosures' name='dis:CompensationRelatedCostsAndSharebasedPaymentsDetailsOtherDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cash Proceeds Received from Share-based Payment Awards [Text Block]' name='dis:CashProceedsReceivedfromSharebasedPaymentAwards' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensation Cost for Share-based Payment Arrangements, Allocation of Share-based Compensation Costs by Plan [Text Block]' name='dis:CompensationCostForSharebasedPaymentArrangementsAllocationOfSharebasedCompensationCostsByPlan' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nonvested Performance-based Units Activity [Text Block]' name='dis:NonvestedPerformancebasedUnitsActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nonvested Restricted Stock Units Activity [Text Block]' name='dis:NonvestedRestrictedStockUnitsActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Nonvested Share Activity [Text Block]' name='dis:NonvestedShareActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Share-based Compensation, Activity [Text Block]' name='dis:OtherSharebasedCompensationActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Grants in Period, Grant Date Intrinsic Value [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsGrantsInPeriodGrantDateIntrinsicValue' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Vested and Expected to Vest, Outstanding [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsVestedAndExpectedToVestOutstanding' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Performance-Based Units, Vested and Expected to Vest [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardPerformanceBasedUnitsVestedAndExpectedToVest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Restricted Stock Units, Vested and Expected to Vest [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardRestrictedStockUnitsVestedAndExpectedToVest' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Activity [Text Block]' name='dis:SharebasedCompensationActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Employee Stock Purchase Plan, Activity [Text Block]' name='dis:SharebasedCompensationEmployeeStockPurchasePlanActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Nonemployee Director Stock Award Plan, Activity [Text Block]' name='dis:SharebasedCompensationNonemployeeDirectorStockAwardPlanActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Restricted Stock and Restricted Stock Units Activity [Text Block]' name='dis:SharebasedCompensationRestrictedStockAndRestrictedStockUnitsActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Restricted Stock Units Award Activity [Text Block]' name='dis:SharebasedCompensationRestrictedStockUnitsAwardActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Stock Appreciation Rights Award Activity [Text Block]' name='dis:SharebasedCompensationStockAppreciationRightsAwardActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Stock Options and Stock Appreciation Rights Award Activity [Text Block]' name='dis:SharebasedCompensationStockOptionsAndStockAppreciationRightsAwardActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Stock Options, Activity [Text Block]' name='dis:SharebasedCompensationStockOptionsActivity' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Payment Award, Employee Stock Purchase Plan, Valuation Assumptions [Text Block]' name='dis:SharebasedPaymentAwardEmployeeStockPurchasePlanValuationAssumptions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Payment Award, Stock Options, Valuation Assumptions [Text Block]' name='dis:SharebasedPaymentAwardStockOptionsValuationAssumptions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecognized Compensation Cost, Nonvested Awards [Text Block]' name='dis:UnrecognizedCompensationCostNonvestedAwards' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Grants in Period, Weighted Average Grant Date Fair Value [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsGrantsInPeriodWeightedAverageGrantDateFairValue' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Vested and Expected to Vest, Exercisable [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsVestedAndExpectedToVestExercisable' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Vested and Expected to Vest, Outstanding and Exercisable [Text Block]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsVestedAndExpectedToVestOutstandingAndExercisable' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangements by Share-based Payment Award' name='dis:SharebasedCompensationArrangementsBySharebasedPaymentAward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Shares Authorized under Stock Option Plans, by Exercise Price Range' name='dis:SharebasedCompensationSharesAuthorizedunderStockOptionPlansByExercisePriceRange' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Goods and Nonemployee Services Transaction by Supplier' name='dis:SharebasedGoodsAndNonemployeeServicesTransactionBySupplier' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Stock Ownership Plan (ESOP) Disclosures' name='dis:EmployeeStockOwnershipPlanESOPDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Service Share-based Compensation, Allocation of Recognized Period Costs' name='dis:EmployeeServiceSharebasedCompensationAllocationOfRecognizedPeriodCosts' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Arrangement with Individual, Share-based Payments' name='dis:DeferredCompensationArrangementWithIndividualSharebasedPayments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Liability, Classified, Noncurrent [Roll Up]' name='dis:DeferredCompensationLiabilityClassifiedNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Stock Ownership Plan (ESOP), Shares in ESOP [Roll Up]' name='dis:EmployeeStockOwnershipPlanESOPSharesInESOPRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Equity Instruments Other than Options, Nonvested [Roll Forward]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardEquityInstrumentsOtherThanOptionsNonvestedRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Outstanding [Roll Forward]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsOutstandingRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Service Share-based Compensation Disclosures [Hierarchy]' name='dis:EmployeeServiceSharebasedCompensationDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Additional General Disclosures [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardAdditionalGeneralDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Equity Instruments Other than Options, Additional Disclosures [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardEquityInstrumentsOtherThanOptionsAdditionalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Fair Value Assumptions and Methodology [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardFairValueAssumptionsAndMethodologyHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Additional Disclosures [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsAdditionalDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation Arrangement by Share-based Payment Award, Options, Vested and Expected to Vest [Hierarchy]' name='dis:SharebasedCompensationArrangementBySharebasedPaymentAwardOptionsVestedAndExpectedToVestHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Shares Authorized under Stock Option Plans, Exercise Price Range [Hierarchy]' name='dis:SharebasedCompensationSharesAuthorizedunderStockOptionPlansExercisePriceRangeHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Shares Authorized under Stock Option Plans, Exercise Price Range, Beginning of Period [Hierarchy]' name='dis:SharebasedCompensationSharesAuthorizedunderStockOptionPlansExercisePriceRangeBeginningOfPeriodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Share-based Compensation, Shares Authorized under Stock Option Plans, Exercise Price Range, End of Period [Hierarchy]' name='dis:SharebasedCompensationSharesAuthorizedunderStockOptionPlansExercisePriceRangeEndOfPeriodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Stock Ownership Plan (ESOP) Disclosures [Hierarchy]' name='dis:EmployeeStockOwnershipPlanESOPDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Stock Ownership Plan (ESOP), Debt Structure [Hierarchy]' name='dis:EmployeeStockOwnershipPlanESOPDebtStructureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Grandfathered ESOP Expense Recognition [Hierarchy]' name='dis:GrandfatheredESOPExpenseRecognitionHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Employee Service Share-based Compensation, Allocation of Recognized Period Costs [Hierarchy]' name='dis:EmployeeServiceSharebasedCompensationAllocationOfRecognizedPeriodCostsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Post-employment But Pre-retirement Costs' name='asc:PostEmploymentButPreRetirementCosts' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Pension and Other Postretirement Benefits Disclosure' name='dis:PensionAndOtherPostretirementBenefitsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Compensation and Employee Benefit Plans [Text Block]' name='dis:CompensationAndEmployeeBenefitPlans' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plans Disclosures' name='dis:DefinedBenefitPlansDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Incremental Effects on Balance Sheet, Application of FAS 158 Recognition Provisions' name='dis:IncrementalEffectsonBalanceSheetApplicationOfFAS158RecognitionProvisions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Compensation Arrangement with Individual, Postretirement Benefits' name='dis:DeferredCompensationArrangementWithIndividualPostretirementBenefits' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plans and Other Postretirement Benefit Plans Disclosures' name='dis:DefinedBenefitPlansAndOtherPostretirementBenefitPlansDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accumulated and Projected Benefit Obligations [Text Block]' name='dis:AccumulatedAndProjectedBenefitObligations' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Accumulated Benefit Obligations in Excess of Fair Value of Plan Assets [Text Block]' name='dis:AccumulatedBenefitObligationsInExcessOfFairValueOfPlanAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Allocation of Plan Assets [Text Block]' name='dis:AllocationOfPlanAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Amounts in Accumulated Other Comprehensive Income (Loss) to be Recognized over Next Fiscal Year [Text Block]' name='dis:AmountsInAccumulatedOtherComprehensiveIncomeLossTobeRecognizedoverNextFiscalYear' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension Plans or Other Employee Benefit Plans, Amounts Recognized in Balance Sheet [Text Block]' name='dis:AmountsRecognizedInBalanceSheet' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension Plans or Other Employee Benefit Plans, Amounts Recognized in Other Comprehensive Income (Loss) [Text Block]' name='dis:AmountsRecognizedInOtherComprehensiveIncomeLoss' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension Plans or Other Employee Benefit Plans, Assumptions Used [Text Block]' name='dis:AssumptionsUsed' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Benefit Obligations in Excess of Fair Value of Plan Assets [Text Block]' name='dis:BenefitObligationsInExcessOfFairValueOfPlanAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Changes in Accumulated Postemployment Benefit Obligations [Text Block]' name='dis:ChangesInAccumulatedPostemploymentBenefitObligations' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Changes in Fair Value of Plan Assets [Text Block]' name='dis:ChangesInFairValueOfPlanAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Changes in Projected Benefit Obligations [Text Block]' name='dis:ChangesInProjectedBenefitObligations' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Costs of Retirement Plans [Text Block]' name='dis:CostsOfRetirementPlans' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan Amounts Recognized in Other Comprehensive Income (Loss) [Text Block]' name='dis:DefinedBenefitPlanAmountsRecognizedInOtherComprehensiveIncomeLoss' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effect of One-Percentage-Point Change in Assumed Health Care Cost Trend Rates [Text Block]' name='dis:EffectOfOnePercentagePointChangeInAssumedHealthCareCostTrendRates' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effect of Significant Unobservable Inputs, Changes in Plan Assets [Text Block]' name='dis:EffectOfSignificantUnobservableInputsChangesInPlanAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Expected Benefit Payments [Text Block]' name='dis:ExpectedBenefitPayments' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Health Care Cost Trend Rates [Text Block]' name='dis:HealthCareCostTrendRates' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Benefit Costs [Text Block]' name='dis:NetBenefitCosts' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Funded Status [Text Block]' name='dis:NetFundedStatus' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Periodic Benefit Cost Not yet Recognized [Text Block]' name='dis:NetPeriodicBenefitCostNotyetRecognized' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effect on Accumulated Other Comprehensive Income (Loss) Due to Change in Measurement Date, Net of Tax [Roll Up]' name='dis:EffectonAccumulatedOtherComprehensiveIncomeLossDueToChangeInMeasurementDateNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Amounts Recognized in Balance Sheet [Roll Up]' name='dis:DefinedBenefitPlanAmountsRecognizedInBalanceSheetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Funded Status of Plan [Roll Up]' name='dis:DefinedBenefitPlanFundedStatusOfPlanRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Net Periodic Benefit Cost [Roll Up]' name='dis:DefinedBenefitPlanNetPeriodicBenefitCostRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension and Other Postretirement Benefit Plans, Accumulated Other Comprehensive Income (Loss), before Tax [Roll Up]' name='dis:PensionAndOtherPostretirementBenefitPlansAccumulatedOtherComprehensiveIncomeLossbeforeTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Pension and Other Postretirement Benefit Plans, Amounts that Will be Amortized from Accumulated Other Comprehensive Income (Loss) in Next Fiscal Year [Roll Up]' name='dis:PensionAndOtherPostretirementBenefitPlansAmounts400' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan Benefit Obligation [Roll Forward]' name='dis:DefinedBenefitPlanBenefitObligationRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan Fair Value of Plan Assets [Roll Forward]' name='dis:DefinedBenefitPlanFairValueOfPlanAssetsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Asset Line Item Changes Due to Application of FAS 158 Recognition Provisions [Roll Forward]' name='dis:AssetLineItemChangesDueToApplicationOfFAS158RecognitionProvisionsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Liability or Equity Line Item Changes Due to Application of FAS 158 Recognition Provisions [Roll Forward]' name='dis:LiabilityOrEquityLineItemChangesDueToApplicationOfFAS158RecognitionProvisionsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Asset Line Item Changes Due to Additional Minimum Pension Liability (AML) Adjustment and Application of FAS 158 Recognition Provisions [Roll Forward]' name='dis:AssetLineItemChangesDueToAdditionalMinimumPensionLiabilityAMLAdjustmentAndApplicationOfFAS158RecognitionProvisionsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Liability or Equity Line Item Changes Due to AML Adjustment and Application of FAS 158 Recognition Provisions [Roll Forward]' name='dis:LiabilityOrEquityLineItemChangesDueToAMLAdjustmentAndApplicationOfFAS158RecognitionProvisionsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Application of Recognition Provisions of FAS 158, Incremental Effects on Balance Sheet [Hierarchy]' name='dis:ApplicationOfRecognitionProvisionsOfFAS158IncrementalEffectsonBalanceSheetHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Coal Industry Retiree Health Benefit Act of 1992 [Hierarchy]' name='dis:CoalIndustryRetireeHealthBenefitActOf1992Hierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Pension Plans and Defined Benefit Postretirement Plans Disclosure [Hierarchy]' name='dis:DefinedBenefitPensionPlansAndDefinedBenefitPostretirementPlansDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Contribution Pension and Other Postretirement Plans Disclosure [Hierarchy]' name='dis:DefinedContributionPensionAndOtherPostretirementPlansDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Expected Gross Prescription Drug Subsidy Receipts Disclosure [Hierarchy]' name='dis:ExpectedGrossPrescriptionDrugSubsidyReceiptsDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='General Discussion of Pension and Other Postretirement Benefits [Hierarchy]' name='dis:GeneralDiscussionOfPensionAndOtherPostretirementBenefitsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Japanese Welfare Pension Insurance Law [Hierarchy]' name='dis:JapaneseWelfarePensionInsuranceLawHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Multiemployer Pension or Postretirement Benefit Plan [Hierarchy]' name='dis:MultiemployerPensionOrPostretirementBenefitPlanHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Postretirement Medical Plans with Prescription Drug Benefits [Hierarchy]' name='dis:PostretirementMedicalPlansWithPrescriptionDrugBenefitsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan Disclosure [Hierarchy]' name='dis:DefinedBenefitPlanDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Amounts Recognized in Other Comprehensive Income (Loss) [Hierarchy]' name='dis:DefinedBenefitPlanAmountsRecognizedInOtherComprehensiveIncomeLossHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Assumed Health Care Cost Trend Rates [Hierarchy]' name='dis:DefinedBenefitPlanAssumedHealthCareCostTrendRatesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Assumptions Used in Calculations [Hierarchy]' name='dis:DefinedBenefitPlanAssumptionsUsedInCalculationsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, before Adoption of FAS 158 Recognition Provisions, Disclosures [Hierarchy]' name='dis:DefinedBenefitPlanbeforeAdoptionOfFAS158RecognitionProvisionsDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Estimated Future Benefit Payments [Hierarchy]' name='dis:DefinedBenefitPlanEstimatedFutureBenefitPaymentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Estimated Future Employer Contributions in Current Fiscal Year [Hierarchy]' name='dis:DefinedBenefitPlanEstimatedFutureEmployerContributionsInCurrentFiscalYearHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Information about Plan Assets [Hierarchy]' name='dis:DefinedBenefitPlanInformationaboutPlanAssetsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Pension Plans with Accumulated Benefit Obligations in Excess of Plan Assets [Hierarchy]' name='dis:DefinedBenefitPlanPensionPlansWithAccumulatedBenefitObligationsInExcessOfPlanAssetsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Plan Amendment [Hierarchy]' name='dis:DefinedBenefitPlanPlanAmendmentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Plans with Benefit Obligations in Excess of Plan Assets [Hierarchy]' name='dis:DefinedBenefitPlanPlansWithBenefitObligationsInExcessOfPlanAssetsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Settlements and Curtailments [Hierarchy]' name='dis:DefinedBenefitPlanSettlementsAndCurtailmentsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Defined Benefit Plan, Special or Contractual Termination Benefits During Period [Hierarchy]' name='dis:DefinedBenefitPlanSpecialOrContractualTerminationBenefitsDuringPeriodHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Postretirement Pension Costs' name='asc:PostretirementPensionCosts' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Postemployment Benefits' name='dis:PostemploymentBenefits' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Supplemental Unemployment Benefits [Roll Up]' name='dis:SupplementalUnemploymentBenefitsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Other Expenses' name='asc:OtherExpenses' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Other Income and Expenses Disclosures' name='dis:OtherIncomeAndExpensesDisclosures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Income and Other Expense Disclosure [Text Block]' name='dis:OtherIncomeAndOtherExpenseDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Nonoperating Income (Expense)' name='dis:OtherNonoperatingIncomeExpense' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Income [Roll Up]' name='dis:OtherIncomeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Expense, Nonoperating Disclosure [Hierarchy]' name='dis:OtherExpenseNonoperatingDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Income, Nonoperating Disclosure [Hierarchy]' name='dis:OtherIncomeNonoperatingDisclosureHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Expense, Nonoperating Details [Hierarchy]' name='dis:OtherExpenseNonoperatingDetailsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Income, Nonoperating Details [Hierarchy]' name='dis:OtherIncomeNonoperatingDetailsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Cost and Expense, Operating  Details [Hierarchy]' name='dis:OtherCostAndExpenseOperatingDetailsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Research and Development Costs' name='asc:ResearchAndDevelopmentCosts' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Research, Development, and Computer Software' name='dis:ResearchDevelopmentAndComputerSoftware' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Research and Development Arrangement, Contract to Perform for Others' name='dis:ResearchAndDevelopmentArrangementContractToPerformForOthers' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capitalized Computer Software, Net [Roll Up]' name='dis:CapitalizedComputerSoftwareNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Research and Development Expense [Roll Up]' name='dis:ResearchAndDevelopmentExpenseRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capitalized Computer Software, Net, Movement [Roll Forward]' name='dis:CapitalizedComputerSoftwareNetMovementRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Research and Development Arrangement with Federal Government [Hierarchy]' name='dis:ResearchAndDevelopmentArrangementWithFederalGovernmentHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Research and Development Arrangement, Contract to Perform for Others [Hierarchy]' name='dis:ResearchAndDevelopmentArrangementContractToPerformForOthersHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Income Taxes' name='asc:IncomeTaxes' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Income Tax Disclosure' name='dis:IncomeTaxDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Expense (Benefit) Details [Text Block]' name='dis:IncomeTaxExpenseBenefitDetails' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Assets and Liabilities [Text Block]' name='dis:DeferredTaxAssetsAndLiabilities' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effective Income Tax Rate Reconciliation [Text Block]' name='dis:EffectiveIncomeTaxRateReconciliation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income before Income Tax, Domestic and Foreign [Text Block]' name='dis:IncomebeforeIncomeTaxDomesticAndForeign' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Loss Carryforwards' name='dis:OperatingLossCarryforwards' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Tax Credit Carryforward' name='dis:TaxCreditCarryforward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Holiday' name='dis:IncomeTaxHoliday' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Valuation Allowance' name='dis:ValuationAllowance' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Contingency' name='dis:IncomeTaxContingency' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Significant Change in Unrecognized Tax Benefits is Reasonably Possible' name='dis:SignificantChangeInUnrecognizedTaxBenefitsisReasonablyPossible' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Examination' name='dis:IncomeTaxExamination' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Assets (Liabilities), Net [Roll Up]' name='dis:DeferredTaxAssetsLiabilitiesNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Assets, Net [Roll Up]' name='dis:DeferredTaxAssetsNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Assets, Net, Classification Current and Noncurrent [Roll Up]' name='dis:DeferredTaxAssetsNetClassificationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Liabilities [Roll Up]' name='dis:DeferredTaxLiabilitiesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Liabilities, Classification Current and Noncurrent [Roll Up]' name='dis:DeferredTaxLiabilitiesClassificationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Effective Income Tax Rate, Continuing Operations, Tax Rate Reconciliation [Roll Up]' name='dis:EffectiveIncomeTaxRateContinuingOperationsTaxRateReconciliationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income (Loss) from Continuing Operations before Equity Method Investments, Income Taxes, Extraordinary Items, Noncontrolling Interest [Roll Up]' name='dis:IncomeLossfromContinuingOperationsbeforeEquityMethodInvestmentsIncomeTaxesExtraordinaryItemsNoncontrollingInterestRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Examination, Penalties and Interest Accrued [Roll Up]' name='dis:IncomeTaxExaminationPenaltiesAndInterestAccruedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Examination, Penalties and Interest Expense [Roll Up]' name='dis:IncomeTaxExaminationPenaltiesAndInterestExpenseRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Expense (Benefit), Continuing Operations [Roll Up]' name='dis:IncomeTaxExpenseBenefitContinuingOperationsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Expense (Benefit), Continuing Operations, by Jurisdiction [Roll Up]' name='dis:IncomeTaxExpenseBenefitContinuingOperationsByJurisdictionRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Expense (Benefit), Continuing Operations, Income Tax Reconciliation [Roll Up]' name='dis:IncomeTaxExpenseBenefitContinuingOperationsIncomeTaxReconciliationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Expense (Benefit), Intraperiod Tax Allocation [Roll Up]' name='dis:IncomeTaxExpenseBenefitIntraperiodTaxAllocationRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecognized Tax Benefits, Income Tax Penalties and Interest Accrued [Roll Up]' name='dis:UnrecognizedTaxBenefitsIncomeTaxPenaltiesAndInterestAccruedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecognized Tax Benefits, Income Tax Penalties and Interest Expense [Roll Up]' name='dis:UnrecognizedTaxBenefitsIncomeTaxPenaltiesAndInterestExpenseRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unrecognized Tax Benefits, Excluding Amounts Pertaining to Examined Tax Returns, Reconcilation [Roll Forward]' name='dis:UnrecognizedTaxBenefitsExcludingAmountsPertainingToExaminedTaxReturnsRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Taxes, Business Combination, Valuation Allowance [Hierarchy]' name='dis:DeferredTaxesBusinessCombinationValuationAllowanceHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Uncertainties [Hierarchy]' name='dis:IncomeTaxUncertaintiesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Tax Carryforward [Hierarchy]' name='dis:OtherTaxCarryforwardHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Deferred Tax Liability Not Recognized [Hierarchy]' name='dis:DeferredTaxLiabilityNotRecognizedHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Income Tax Contingency, Other [Hierarchy]' name='dis:IncomeTaxContingencyOtherHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
         </Concept>
         <Concept label='Broad Transactional Categories' name='asc:BroadTransactionalCategories' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Business Combinations and Reorganizations' name='asc:BusinessCombinationsAndReorganizations' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Derivative Instruments and Hedging Activities' name='asc:DerivativeInstrumentsAndHedgingActivities' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Derivative' name='dis:Derivative' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Consolidation' name='asc:Consolidation' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Noncash or Part Noncash Divestitures' name='dis:NoncashOrPartNoncashDivestitures' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Noncash or Part Noncash Acquisitions' name='dis:NoncashOrPartNoncashAcquisitions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Consolidation, Less than Wholly Owned Subsidiary, Parent Ownership Interest, Change Due to Net Income Attributable to Parent and Effects of Changes, Net' name='dis:ConsolidationLessThanWhollyOwnedSubsidiaryParentOwnershipInterestChangeDueToNetIncomeAttributableToParentAndEffectsOfChangesNet' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Noncash or Part Noncash Acquisition, Net Nonmonetary Assets Acquired (Liabilities Assumed) [Roll Up]' name='dis:NoncashOrPartNoncashAcquisitionNetNonmonetaryAssetsAcquiredLiabilitiesAssumedRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Financial Instruments Disclosure' name='asc:FinancialInstrumentsDisclosure' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Foreign Operations and Currency Translation' name='asc:ForeignOperationsAndCurrencyTranslation' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Foreign Currency Transaction Disclosure' name='dis:ForeignCurrencyTransactionDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Foreign Currency Translation' name='dis:ForeignCurrencyTranslation' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Intercompany Foreign Currency Balance' name='dis:IntercompanyForeignCurrencyBalance' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Differences between Reported Amount and Reporting Currency Denominated Amount' name='dis:DifferencesbetweenReportedAmountAndReportingCurrencyDenominatedAmount' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Foreign Currency Transaction Gain (Loss), before Tax [Roll Up]' name='dis:ForeignCurrencyTransactionGainLossbeforeTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Adjustment for Long-term Intercompany Transactions, Net of Tax [Roll Up]' name='dis:AdjustmentForLongTermIntercompanyTransactionsNetOfTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Comprehensive Income (Loss), Foreign Currency Transaction and Translation Adjustment, before Tax [Roll Up]' name='dis:OtherComprehensiveIncomeLossForeignCurrencyTransactionAndTranslationAdjustmentbeforeTaxRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Cumulative Translation Adjustment [Roll Forward]' name='dis:CumulativeTranslationAdjustmentRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Derivatives used in Net Investment Hedge, Net of Tax [Roll Forward]' name='dis:DerivativesusedInNetInvestmentHedgeNetOfTaxRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Translation Adjustment Functional to Reporting Currency [Roll Forward]' name='dis:TranslationAdjustmentFunctionalToReportingCurrencyRollForward' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Foreign Currency Transaction [Hierarchy]' name='dis:ForeignCurrencyTransactionHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Foreign Currency Translation [Hierarchy]' name='dis:ForeignCurrencyTranslationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Multiple Foreign Currency Exchange Rates [Hierarchy]' name='dis:MultipleForeignCurrencyExchangeRatesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Financial Statement Line Items with Differences in Reported Amount and Reporting Currency Denominated Amounts [Hierarchy]' name='dis:FinancialStatementLineItemsWithDifferencesInReportedAmountAndReportingCurrencyDenominatedAmountsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Interest' name='asc:Interest' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Interest and Other Income [Text Block]' name='dis:InterestAndOtherIncome' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Interest and Other Income [Roll Up]' name='dis:InterestAndOtherIncomeRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Leases, Operating' name='asc:LeasesOperating' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Leases of Lessee Disclosure' name='dis:LeasesOfLesseeDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leases of Lessor, Disclosure (Summary)' name='dis:LeasesOfLessorDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases of Lessor, Disclosure [Text Block]' name='dis:OperatingLeasesOfLessorDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Rental Payments for Operating Leases [Text Block]' name='dis:FutureMinimumRentalPaymentsForOperatingLeases' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases of Leasor, Property Subject to or Available for Operating Lease, by Major Property Class' name='dis:PropertySubjectToOrAvailableForOperatingLeaseByMajorPropertyClass' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leased Assets, Details by Contractual Arrangement and Asset Type' name='dis:OperatingLeasedAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leveraged Leases, Balance Sheet, Investment in Leveraged Leases, Net [Roll Up]' name='dis:LeveragedLeasesBalanceSheetInvestmentInLeveragedLeasesNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leveraged Leases, Income (Loss) [Roll Up]' name='dis:LeveragedLeasesIncomeLossRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leveraged Leases, Net Investment in Leveraged Leases [Roll Up]' name='dis:LeveragedLeasesNetInvestmentInLeveragedLeasesDisclosureInvestmentInLeveragedLeasesNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Net Investment in Direct Financing and Sales Type Leases [Roll Up]' name='dis:NetInvestmentInDirectFinancingAndSalesTypeLeasesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Payments Receivable of Operating Leases of Lessor [Roll Up]' name='dis:OperatingLeasesFutureMinimumPaymentsReceivableRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases, Income Statement, Lease Revenue [Roll Up]' name='dis:OperatingLeasesIncomeStatementLeaseRevenueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Property Subject to or Available for Operating Lease, Net [Roll Up]' name='dis:PropertySubjectToOrAvailableForOperatingLeaseNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Payments Due under Operating Leases of Lessee [Roll Up]' name='dis:OperatingLeasesFutureMinimumPaymentsDueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases, Rent Expense, Net [Roll Up]' name='dis:OperatingLeasesRentExpenseNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leveraged Leases [Hierarchy]' name='dis:LeveragedLeasesHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases of Lessor Disclosures [Hierarchy]' name='dis:OperatingLeasesOfLessorDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Operating Leases, Income Statement [Hierarchy]' name='dis:OperatingLeasesIncomeStatementHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Leases, Capital' name='asc:LeasesCapital' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Capital Leases in Financial Statements of Lessee Disclosure [Text Block]' name='dis:CapitalLeasesInFinancialStatementsOfLesseeDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases of Lessor in Financial Statements Disclosure [Text Block]' name='dis:CapitalLeasesInFinancialStatementsOfLessorDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leased Assets, Details by Asset Type' name='dis:CapitalLeasedAssets' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Lease Obligations [Roll Up]' name='dis:CapitalLeaseObligationsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Payments, Present Value of Net Minimum Payments, Noncancelable Capital Leases, Lessor [Roll Up]' name='dis:CapitalLeasesFutureMinimumPaymentsPresentValueOfNetMinimumPaymentsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Payments Receivable of Capital Leases, Lessor [Roll Up]' name='dis:CapitalLeasesFutureMinimumPaymentsReceivableRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases, Income Statement, Lease Revenue, Income Statement of Lessor [Roll Up]' name='dis:CapitalLeasesIncomeStatementLeaseRevenueIncomeStatementOfLessorRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases, Net Investment in Direct Financing and Sales Type Leases [Roll Up]' name='dis:CapitalLeasesNetInvestmentInDirectFinancingAndSalesTypeLeasesRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases, Balance Sheet, Assets by Major Class, Net [Roll Up]' name='dis:CapitalLeasesBalanceSheetAssetsByMajorClassNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases of Lessee [Hierarchy]' name='dis:CapitalLeasesOfLesseeHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Capital Leases, Income Statement of Lessee [Hierarchy]' name='dis:CapitalLeasesIncomeStatementOfLesseeHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Leases, Capital [Hierarchy]' name='dis:LeasesCapitalHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Leases, Sale and Leaseback' name='asc:LeasesSaleAndLeaseback' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Sale Leaseback Transaction, Disclosure' name='dis:SaleLeasebackTransactionDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Sale Leaseback Transaction, Details by Transaction' name='dis:SaleLeasebackTransaction' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Sublease Rentals, Sales Leaseback Transactions, Seller-Lessee [Roll Up]' name='dis:FutureMinimumSubleaseRentalsSaleLeasebackTransactionsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Future Minimum Payments, Present Value of Net Minimum Payments, Sale Leaseback Transactions [Roll Up]' name='dis:PresentValueOfFutureMinimumLeasePaymentsSaleLeasebackTransactionsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Sale Leaseback Transaction, Deferred Gain, Net [Roll Up]' name='dis:SaleLeasebackTransactionDeferredGainNetRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Sale Leaseback Transaction, Net Book Value [Roll Up]' name='dis:SaleLeasebackTransactionNetBookValueRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Nonmonetary Transactions' name='asc:NonmonetaryTransactions' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Nonmonetary Transactions' name='dis:NonmonetaryTransactions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Other Significant Noncash Transactions' name='dis:OtherSignificantNoncashTransactions' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Related Party Disclosures' name='asc:RelatedPartyDisclosures' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Related Party Transactions, by Related Party' name='dis:RelatedPartyTransactionsByRelatedParty' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from (to) Related Party [Roll Up]' name='dis:DuefromtoRelatedPartyRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from (to) Related Party, Current [Roll Up]' name='dis:DuefromtoRelatedPartyCurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Due from (to) Related Party, Noncurrent [Roll Up]' name='dis:DuefromtoRelatedPartyNoncurrentRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Related Party Disclosures [Hierarchy]' name='dis:RelatedPartyDisclosuresHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Related Party Tax Expense [Hierarchy]' name='dis:RelatedPartyTaxExpenseHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Subsequent Events' name='asc:SubsequentEvents' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Subsequent Events' name='dis:SubsequentEvents' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Subsequent Events, Schedule of (Duplicate) [Text Block]' name='dis:SubsequentEventsScheduleOfDuplicate' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Subsequent Event [Hierarchy]' name='dis:SubsequentEventHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Unusual or Infrequent Items' name='asc:UnusualOrInfrequentItems' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Unusual or Infrequent Item' name='dis:UnusualOrInfrequentItem' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unusual or Infrequent Items Disclosure [Text Block]' name='dis:UnusualOrInfrequentItemsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Extraordinary Items' name='asc:ExtraordinaryItems' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Extraordinary Items' name='dis:ExtraordinaryItems' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Business Insurance Recoveries' name='dis:BusinessInsuranceRecoveries' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Transfers and Servicing' name='asc:TransfersAndServicing' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
         </Concept>
         <Concept label='Industry Specific Disclosures' name='asc:IndustrySpecificDisclosures' abstract='true' dataType='asc:Topic' prefix='asc'>
            <Concept label='Agriculture' name='asc:Agriculture' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Agriculture Policies' name='dis:AgriculturePolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Airlines' name='asc:Airlines' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Contractors-Construction' name='asc:ContractorsConstruction' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Long-term Contracts or Programs Disclosure' name='dis:LongTermContractsOrProgramsDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unapproved Contract Claims receivable, Amount [Roll Up]' name='dis:UnapprovedContractClaimsAmountRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Billings in Excess of Cost [Roll Up]' name='dis:BillingsInExcessOfCostRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contract Receivable [Roll Up]' name='dis:ContractReceivableRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Costs in Excess of Billings on Uncompleted Contracts or Programs [Roll Up]' name='dis:CostsInExcessOfBillingsonUncompletedContractsOrProgramsRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Retention Payable [Roll Up]' name='dis:RetentionPayableRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unbilled Change Orders [Roll Up]' name='dis:UnbilledChangeOrdersRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Unbilled Receivables, Not Billable at Balance Sheet Date [Roll Up]' name='dis:UnbilledReceivablesNotBillableatBalanceSheetDateRollUp' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Billed and Unbilled Contract Claims Subject to Uncertainty [Hierarchy]' name='dis:BilledAndUnbilledContractClaimsSubjectToUncertaintyHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Contract Termination Claims and Loans [Hierarchy]' name='dis:ContractTerminationClaimsAndLoansHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Governmental Contracts Subject to Renegotiation [Hierarchy]' name='dis:GovernmentalContractsSubjectToRenegotiationHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Inventory for Long-term Contracts or Programs [Hierarchy]' name='dis:InventoryForLongTermContractsOrProgramsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Liabilities for Long-term Contracts or Programs [Hierarchy]' name='dis:LiabilitiesForLongTermContractsOrProgramsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Receivables, Long-term Contracts or Programs [Hierarchy]' name='dis:ReceivablesLongTermContractsOrProgramsHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Construction Contractors Policies' name='dis:ConstructionContractorsPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Development Stage Entities' name='asc:DevelopmentStageEntities' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Development Stage Enterprise General Disclosure' name='dis:DevelopmentStageEnterpriseGeneralDisclosure' abstract='true' dataType='dis:Disclosure' prefix='dis' />
                  <Concept label='Equity Issuance Since Inception [Hierarchy]' name='dis:EquityIssuanceSinceInceptionHierarchy' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Broadcasting' name='asc:Broadcasting' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Cable Television' name='asc:CableTelevision' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Motion Pictures' name='asc:MotionPictures' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Records and Music Industry' name='asc:RecordsAndMusicIndustry' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Entertainment Policies' name='dis:EntertainmentPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Casinos' name='asc:Casinos' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Extractive Activities-Mining' name='asc:ExtractiveActivitiesMining' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Extractive Activities-Oil and Gas' name='asc:ExtractiveActivitiesOilAndGas' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Oil and Gas Accounting Policies' name='dis:OilAndGasPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Franchisor Accounting' name='asc:FranchisorAccounting' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Depository and Lending' name='asc:DepositoryAndLending' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Brokers and Dealers' name='asc:BrokersAndDealers' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Insurance' name='asc:Insurance' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Investment Companies' name='asc:InvestmentCompanies' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Mortgage Banking' name='asc:MortgageBanking' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Financial Services - Title Plant' name='asc:FinancialServicesTitlePlant' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Health Care Entities' name='asc:HealthCareEntities' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Health Care Entities Policies' name='dis:HealthCareEntitiesPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Not-for-Profit Entities' name='asc:NotForProfitEntities' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Plan Accounting-Defined Benefit Pension Plans' name='asc:PlanAccountingDefinedBenefitPensionPlans' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Real Estate Operations' name='asc:RealEstateOperations' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Real Estate Policies' name='dis:RealEstatePolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Regulated Operations' name='asc:RegulatedOperations' abstract='true' dataType='asc:Topic' prefix='asc'>
                  <Concept label='Public Utilities Policies' name='dis:PublicUtilitiesPolicies' abstract='true' dataType='dis:Disclosure' prefix='dis' />
            </Concept>
            <Concept label='Software' name='asc:Software' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
            <Concept label='Commercial and Industrial' name='asc:CommercialAndIndustrial' abstract='true' dataType='asc:Topic' prefix='asc'>
            </Concept>
         </Concept>
      </Concept>
   </Concept>
</Network>
</Component>

return 
if (lower-case(req:parameter-values("output", "list")[1]) eq "tree") then
    [ local:tree($file, 0) ]
else
    [ local:list($file) ]
