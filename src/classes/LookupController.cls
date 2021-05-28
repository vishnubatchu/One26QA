public without sharing class LookupController {
    
    @AuraEnabled
    public static List<sObject> searchRecord(String objectAPIName, String fieldAPIName, 
                                             List<String> moreFields, String searchText,
                                             Integer recordLimit)
    {
        List<sObject> objectList =  new List<sObject>();
        moreFields ='Party_Number__c,Type,Price_List__c'.split(',');
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        
        String soqlQuery = 'SELECT Id, Name';
        if(!moreFields.isEmpty()){
            soqlQuery = soqlQuery + ',' + String.join(moreFields, ',') ;
        }
        soqlQuery = soqlQuery + ' FROM ' + objectAPIName + ' WHERE ' +
            + fieldAPIName +' LIKE '+ searchText + 'AND Status__c =\'Active\' AND recordType.developername=\'Party_Account\''+' LIMIT '+ recordLimit;
        objectList = Database.query(soqlQuery);
        System.debug('objectList'+objectList);
        return objectList;
    }
    
    @AuraEnabled
    public static Quote saveQuote(String aAccountId){
        System.debug('qRec--> '+aAccountId);
        Quote newqRec = new Quote();
        newqRec.Account__c = aAccountId;        
        newqRec.name= '-Quote';
        newqRec.Fixed_Firm_Quote_Amount__c = 0;
        try{
            system.debug('newqRec=='+newqRec);
            upsert newqRec;
            system.debug('newqRec1=='+newqRec);
            return newqRec;  
        }catch(Exception e) {
            System.debug('Error'+e.getMessage());
             return null;
        }
        
       
    }
}