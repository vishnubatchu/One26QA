trigger AccountGDPRTrigger on Account (after update) {
/*
    Account newAcc;
    Account oldAcc;
    Set<Id> accountId = new Set<Id>();
    if( trigger.isAfter){
        if( trigger.isUpdate){
            for(Account acc:Trigger.new) {
                newAcc= Trigger.newMap.get(acc.id);
                oldAcc = Trigger.oldMap.get(acc.id);
                 system.debug('newAcc==='+newAcc.Type);
                 system.debug('oldAcc==='+oldAcc.Type);
                if(oldAcc.Type != newAcc.Type) {
                    accountId.add(newAcc.id);
                }
             }
            ContactForGDPR.updateAccountContact(accountId);
        }
    }
*/
}