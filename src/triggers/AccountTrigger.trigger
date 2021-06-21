trigger AccountTrigger on Account (after insert,after update,before insert,before update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountTriggerHelper.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            AccountTriggerHelper.afterUpdate(Trigger.oldMap, Trigger.newMap);
            AccountTriggerHelper.updateOrderLines(trigger.new, trigger.oldMap);
            //AccountTriggerHelper.updateSharing(trigger.newMap, trigger.oldMap);
            AccountTriggerHelper.updateGlblPrntPrevOwner(trigger.new, trigger.oldMap);
        } 
    }
}