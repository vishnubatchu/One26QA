trigger QuoteItemPLMDashboardTrigger on Quote_Item__c (before Insert, after insert, after update, before update, after delete) {
    //Added by Surendar
    if(Trigger.isUpdate && Trigger.isAfter ){
        QuoteLinesHelper.updatedQuoteSDEnddate(trigger.new, trigger.oldMap);
    } 
    if(trigger.isInsert && trigger.isBefore){
        system.debug('in trigger');
        QuoteLinesHelper.getPLMApprover(trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isBefore ){
        List<Quote_Item__c> items = new List<Quote_Item__c>();
        for(Quote_Item__c qtitem : trigger.new){
            if(qtitem.product__c != trigger.oldMap.get(qtitem.id).Product__c){
                items.add(qtitem);
            }
        }
        if(items != null && !items.isEmpty())
            QuoteLinesHelper.getPLMApprover(items);
    } 
    if(trigger.isDelete && trigger.isAfter){
        QuoteLinesHelper.updateBuonQuote(trigger.old);
    }
}