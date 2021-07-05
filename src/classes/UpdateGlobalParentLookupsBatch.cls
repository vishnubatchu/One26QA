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
         return new updateGlobalParentCustomIterable();
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
                         Database.SaveResult[] srList = Database.update(finalUpdateList, false); 
        set<Account> accSet = new set<Account>();
        accSet.addAll(acSharing);
list<Account> updateOnetimebatchFlag = new list<Account>();
        if(acSharing != null && acSharing.size() > 0){
            //UpdateGlobalParentLookupsBatchHelper.deleteAndInsertShareRecords(acSharing); 
            for(Account ac : accSet){
                ac.oneTimeBatchFlag__c = True;
                updateOnetimebatchFlag.add(ac);
            }
            Database.SaveResult[] acs = Database.update(updateOnetimebatchFlag, false); 
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        InsertSharedRecordOneTimeBatch ex = new InsertSharedRecordOneTimeBatch();
database.executeBatch(ex,200);
        
    }
}