trigger UserTrigger on User (after insert, after update) {
    if(trigger.isInsert && trigger.isAfter){
        UserTriggerHelper.addUserInPubicGroup(trigger.new);
    } 
    if(trigger.isUpdate && Trigger.isAfter){
        UserTriggerHelper.updateGroupDetails(trigger.oldMap, trigger.new);
    }
}