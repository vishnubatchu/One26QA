public class OpportunityBUUpdateBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC ){
        if(!Test.isRunningTest()){
            //return Database.getQueryLocator([select id,name,business_Unit__c from opportunity where id= '0062f00000C0ejPAAR']);  
            return Database.getQueryLocator([select id,name,business_Unit__c from opportunity where business_Unit__c = null]);  
        } else {
            return Database.getQueryLocator([select id,name,business_Unit__c from opportunity where business_Unit__c = null LIMIT 200]);
        }
        
    }
    public void execute(Database.BatchableContext BC, List<opportunity> scope) {
        Map<Id, String> opptyMap = new Map<Id, String>();
        List<Opportunity> optList = new List<Opportunity>();
        for(OpportunityLineItem line : [SELECT Id,OpportunityId, Product2id, Product2.BU_Code__c, Product2.Product_Family__c
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId IN : scope]){
                                            if(line.Product2.BU_Code__c == '0040' &&
                                               line.Product2.Product_Family__c != 'WSS-OCM' &&
                                               line.Product2.Product_Family__c != 'WSS-OIG'){
                                                   opptyMap.put(line.OpportunityId, 'WSS');
                                                   
                                               } else if(!opptyMap.containsKey(line.OpportunityId)) {
                                                   opptyMap.put(line.OpportunityId, 'non WSS');
                                               }
                                        }
        for(Id oppId : opptyMap.KeySet()){
            optList.add(new Opportunity(Id = oppId, business_Unit__c = opptyMap.get(oppId)));
        }
        if(optList != null && !optList.isEmpty()){
            database.update(optList, false) ;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}