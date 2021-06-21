/**
     * Created by : Akhilesh
     * Date : 2nd June 2021
     * Description: This Batch class has implemented for updateing all the opportunity order and quote's Global Parent 
     * a) if opportunity order and quote's dont have global 
     * b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
     * and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
     * Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
     */
global class UpdateGlobalParentLookupsBatch implements Database.Batchable <sObject>,Database.Stateful{ 
// Start method : Quering all the opportunity , order and quote if Global_Ultimate_Account__c is null
    global List<sObject>  start(Database.BatchableContext BC)
    {
        List<sObject> scope = new List<sObject>();
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,AccountId  from Opportunity where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null limit 40000]);
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,AccountId  from Order where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null limit 40000]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,AccountId from Quote  where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null limit 40000]);
        return scope;
    }
    // Execute method : update Global_Ultimate_Account__c field with parent Acccount Global_Ultimate_Account__c field value 
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        list<Opportunity> updateOppList = new list<Opportunity>();
         list<Order> updateOrdList = new list<Order>();
         list<Quote> updateQtList = new list<Quote>();
     for(sObject obj : scope)
        {
            switch on obj
            {
                when Opportunity opp
                {
                    opp.Global_Ultimate_Account__c = opp.Account.Global_Ultimate_Parent__c ;
                    updateOppList.add(opp);
                }
                when Order ord
                {
                    ord.Global_Ultimate_Account__c = ord.Account.Global_Ultimate_Parent__c ;
                     updateOrdList.add(ord);
                }
                 when Quote qt
                {
                    qt.Global_Ultimate_Account__c = qt.Account.Global_Ultimate_Parent__c ;
                    updateQtList.add(qt);
                }
             }
         }
        system.debug('updateOppList ' + updateOppList);
        if(updateOppList.size() > 0 && updateOppList != null ){
                database.SaveResult[] oppResult=database.update(updateOppList,true);
                          system.debug('updateOrdList ' + oppResult);

        }
        if(updateOrdList.size() > 0 && updateOrdList != null ){
                database.SaveResult[] oppResult=database.update(updateOrdList,true);
        }
         system.debug('updateQtList ' + updateQtList);
         if(updateQtList.size() > 0 && updateQtList != null ){
                database.SaveResult[] oppResult=database.update(updateQtList,true);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
       
    }
}