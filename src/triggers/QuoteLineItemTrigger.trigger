trigger QuoteLineItemTrigger on Quote_Item__c (before insert, before update) {
  if(trigger.isBefore && trigger.isInsert){
        QuoteLineItemTriggerHelper.updateConverionValue(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        QuoteLineItemTriggerHelper.updateConverionValue(trigger.newMap, trigger.oldMap);
        QuoteLineItemTriggerHelper.updateunitPrice(trigger.new, trigger.oldMap);
    }
}