/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This Batch class has implemented for updateing all the opportunity order and quote's Global Parent 
* a) if opportunity order and quote's dont have global 
* b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
* and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
* Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
*/
public class UpdateGlobalParentLookupsBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    // Start method : Quering all the opportunity , order and quote if Global_Ultimate_Account__c is null
    public Iterable<Sobject>  start(Database.BatchableContext BC)
    {
        List<sObject> scope = new List<sObject>();
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Order where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity where Global_Ultimate_Account__c = null and AccountId != null and  Account.Global_Ultimate_Parent__c != null ]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId from Quote  where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null  ]);
        return scope;
    }
    // Execute method : update Global_Ultimate_Account__c field with parent Acccount Global_Ultimate_Account__c field value 
    public void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        list<Account> acSharing = new list<Account>();
        list<sobject> finalUpdateList = new list<sObject>();
        for(sObject obj : scope)
        {
            switch on obj
            {
                when Opportunity opp
                {
                    opp.Global_Ultimate_Account__c = opp.Account.Global_Ultimate_Parent__c ;
                    finalUpdateList.add(opp);
                    acSharing.add(opp.Account);
                }
                when Order ord
                {
                    ord.Global_Ultimate_Account__c = ord.Account.Global_Ultimate_Parent__c ;
                    finalUpdateList.add(ord);
                    acSharing.add(ord.Account);
                }
                when Quote qt
                {
                    qt.Global_Ultimate_Account__c = qt.Account.Global_Ultimate_Parent__c ;
                    finalUpdateList.add(qt);
                    acSharing.add(qt.Account);
                }
            }
        }
        if(finalUpdateList.size() > 0 && finalUpdateList != null ){
            list<list<Sobject>> soblistOfList = new list<list<Sobject>>();
            if(finalUpdateList.size()>10000 || Test.isRunningTest()){
                soblistOfList.addAll(UpdateGlobalParentLookupsBatchHelper.doSubList(finalUpdateList));
            } else{
                soblistOfList.add(finalUpdateList);
            }
            if(!soblistOfList.isEmpty()){
                
                for(list<Sobject> sl : soblistOfList){
                    system.debug('sl@@@ =' + sl);
                    Database.SaveResult[] srList = Database.update(sl, True); 
                }
            }
        }
        if(acSharing != null && acSharing.size() > 0){
            UpdateGlobalParentLookupsBatchHelper.deleteAndInsertShareRecords(acSharing); 
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
        
    }
}