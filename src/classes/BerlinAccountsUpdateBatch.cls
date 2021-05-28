/*
Class Name : BerlinAccountsUpdateBatch
Version : 1.0
Created  :Surendar, 25th June 2019
last Modified By:
Description : Batch to update berlin accounts.
*/
public class BerlinAccountsUpdateBatch implements Database.Batchable<sObject>{
    public final string USECODE ='SHIP_TO';
    public final string ORGNAME ='Finisar Berlin';
    public String query= 'SELECT id,ParentId,Site_Use_Code__c from account where Site_Use_Code__c =:USECODE AND Org_Name__c = :ORGNAME';
    public Date batchLastRun; 
    /*
Method Name : BerlinAccountsUpdateBatch
Input Parameters : NA 
Outupt Parameters : NA
Description : BerlinAccountsUpdateBatch class constructor
*/
    public BerlinAccountsUpdateBatch(){
        GlobalVariable__c var = GlobalVariable__c.getValues('BerlinAccountsUpdateBatch');
        if(var.Value__c != null){
            batchLastRun = Date.valueOf(var.Value__c);
            system.debug('batchLastRun'+batchLastRun);
            query = query+ ' AND LastModifiedDate >= :batchLastRun';
        }
        
    }
    /*
Method Name : Start
Input Parameters : Database.BatchableContext BC 
Outupt Parameters : Database.QueryLocator
Description : Queries accounts to update Parent accounts
*/
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('query + '+query);
        system.debug('batchLastRun'+batchLastRun);
        return Database.getQueryLocator(query);
    }
    /*
Method Name : execute
Input Parameters : Database.BatchableContext BC, List<sObject> scope 
Outupt Parameters : NA
Description : Execute mothod
*/
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('scope'+scope);
        AccountTriggerHelper.checkBerlinAccount(scope);
    }
    /*
Method Name : finish
Input Parameters : Database.BatchableContext BC 
Outupt Parameters : NA
Description : Updates custom setting with last batch run date.
*/  
    public void finish(Database.BatchableContext BC){
        GlobalVariable__c var = GlobalVariable__c.getValues('BerlinAccountsUpdateBatch');
        var.Value__c = String.valueOf(Date.today());
        update var;
    }
    
}