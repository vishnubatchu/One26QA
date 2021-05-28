trigger QuoteShareTrigger on Quote (after insert,after update,before update) {
    if(!QuoteLinesHelper.isUpdatedQuoteSDEndDate){
        If(Trigger.isInsert && Trigger.isAfter){
            QuoteShareTriggerHelper.accessToInsideSales(Trigger.NewMap);
            QuoteShareTriggerHelper.provideAccesstoExternalUserInSameCompany(Trigger.NewMap);
        }
        
        If(Trigger.isUpdate && Trigger.isAfter){
            QuoteShareTriggerHelper.updateSalesChannelShare(Trigger.newMap,Trigger.oldMap);
        }
        // Moving PLM Dashboard Code from Line Item to header.Calculation of Gross Profit and Contribution Profit
        IF(Trigger.isUpdate && Trigger.isBefore){
            QuoteItemPLMDashboardTriggerHelper.UpdateQuotePLMDashboardDetails(trigger.OldMap,Trigger.NewMap);
        }
    }
}