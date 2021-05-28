/**
 * Name : LoanerLineTrigger
 * Description : Updates Bu on Loaner when Line is deleted
**/
trigger LoanerLineTrigger on Loaner_Line__c (after delete) {
    if(trigger.isDelete && trigger.isAfter){
        LoanerShareTriggerHelper.updateBuonLoaner(trigger.old);
    }
}