public class ForecastdataUpdateBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC ){
        if(!Test.isRunningTest()){
            return Database.getQueryLocator([SELECT id,BusinessUnit__c,Item__c,Item__r.BU_Code__c, Item__r.Product_Family__c FROM Forecast__c where BusinessUnit__c = null]);
        } else {
            return Database.getQueryLocator([SELECT id,BusinessUnit__c,Item__c,Item__r.BU_Code__c, Item__r.Product_Family__c FROM Forecast__c where BusinessUnit__c = null LIMIT 200]);
        }
        
    }
    public void execute(Database.BatchableContext BC, List<Forecast__c> scope) {
        List<Forecast__c> fList = new List<Forecast__c>();
        for(Forecast__c fCast : scope){
            if(fCast.Item__r.BU_Code__c =='0040' && 
               fCast.Item__r.Product_Family__c != 'WSS-OCM' &&
               fCast.Item__r.Product_Family__c != 'WSS-OIG'){
                   fCast.BusinessUnit__c = 'WSS';
               } else {
                   fCast.BusinessUnit__c = 'Non WSS';
               }
            fList.add(fCast);
        }
        update fList;
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}