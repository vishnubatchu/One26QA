/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This Batch class has implemented for updating all the opportunity order and quote's,case, order line sharing 

*/
public class InsertSharedRecordOneTimeBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    // Start method : Quering all the opportunity , order and quote if Global_Ultimate_Account__c is null
    public Iterable<Sobject>  start(Database.BatchableContext BC)
    {
         return new InsertSharedRecordIterable();
    }
    // Execute method : update Global_Ultimate_Account__c field with parent Acccount Global_Ultimate_Account__c field value 
    public void execute(Database.BatchableContext BC,List<sObject> scope)
    {
     Database.SaveResult[] sList = Database.insert(scope, false); 
    }
    
    public void finish(Database.BatchableContext BC) {
        
        
    }
}