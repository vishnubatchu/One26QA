trigger LoanerShareTrigger on Loaner__c (after insert,after update, before insert, before update, after delete) {
    if(trigger.isBefore && trigger.isInsert){
        LoanerShareTriggerHelper.updateVPSVP(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        List<Loaner__c> rsmUpdateLoaner = new List<Loaner__c>();
        for(Loaner__c loaner : trigger.new){
            if(loaner.RSM_PLM_Approval__c != null && 
               loaner.RSM_PLM_Approval__c != trigger.oldMap.get(loaner.Id).RSM_PLM_Approval__c){
                   rsmUpdateLoaner.add(loaner);
               }
        }
        if(rsmUpdateLoaner != null && !rsmUpdateLoaner.isEmpty()){
            system.debug('rsmUpdateLoaner'+rsmUpdateLoaner);
            LoanerShareTriggerHelper.updateVPSVP(rsmUpdateLoaner);
        }
        
    }
    If(Trigger.isInsert && Trigger.isAfter){
        LoanerShareTriggerHelper.accessToSalesOrDistributor(Trigger.NewMap);
        LoanerShareTriggerHelper.accessToinsideSalesAndRSM(Trigger.New);
    }
    
    If(Trigger.isUpdate && Trigger.isAfter){
        LoanerShareTriggerHelper.updateSalesRepAndDistributorShare(Trigger.newMap,Trigger.oldMap);
        LoanerShareTriggerHelper.accessToinsideSalesAndRSM(Trigger.oldMap,Trigger.newMap);
    }
}