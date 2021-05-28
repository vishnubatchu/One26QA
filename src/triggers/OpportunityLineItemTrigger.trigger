trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after delete) {
    if(trigger.isBefore && trigger.isupdate){
        OpportunityLineItemTriggerHelper.updateUnitPriceFromProductTier(trigger.new, trigger.oldMap);
    }
    if(trigger.isDelete && trigger.isAfter){
        OpportunityLineItemTriggerHelper.updateSortOrder(trigger.old);
    }
    if(trigger.isInsert && trigger.isBefore){
        OpportunityLineItemTriggerHelper.updateSortOrderonLines(trigger.new);
    }
}