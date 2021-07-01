/**
* Created by : Akhilesh
* Date : 31th May 2021
* Description: This is a helper class for UpdateGlobalUltimateParentBatch has implemented as per below logic
* a) If the Global Ultimate Parent is changed on a Top-Level Account or a Customer that serves as the immediate parent of a child account, then the child’s Global Ultimate Parent should match that of its immediate paren.
* b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
* and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
* Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
*/
public class UpdateGlobalUltimateParentBatchHelper {
    
    public static string updateGlobalParent(List<Account> accountList){
        List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
        list<sobject> finalUpdateList = new list<sobject>();
        map<id,Account> parentMap = new map<id,Account>();
        string csvBody  = '';
    //GlobalParentOwnerBatch_Helper call
            errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(accountList,false);
            for(GlobalParentOwnerBatch_Helper.CustomError err : errorList){
                csvBody += err.ID+ ',';
                csvBody += err.objectName + ','; 
                csvBody += err.message + ','; 
                csvBody += '\n';
            }
        // Order update List Creation 
        for(opportunity op : [select id,AccountId ,Account.Global_Ultimate_Parent__c,Global_Ultimate_Account__c   from opportunity Where AccountId  In: accountList ]){
            op.Global_Ultimate_Account__c = op.Account.Global_Ultimate_Parent__c;
            finalUpdateList.add(op); 
        }
        
        // Order update List Creation 
        for(Order ord : [select id,AccountId ,Account.Global_Ultimate_Parent__c,Global_Ultimate_Account__c   from Order Where AccountId  In:accountList ]){
            ord.Global_Ultimate_Account__c = ord.Account.Global_Ultimate_Parent__c;
            finalUpdateList.add(ord); 
        }
        
        
        // Quote update List Creation 
        for(Quote Qt : [select id,Account__c,Account__r.Global_Ultimate_Parent__c,Global_Ultimate_Account__c  from Quote Where Account__c In:accountList ]){
            Qt.Global_Ultimate_Account__c = Qt.Account__r.Global_Ultimate_Parent__c;
            finalUpdateList.add(Qt); 
        }
        
        //Update finalUpdateList
        try{
            if(finalUpdateList.size() > 0 && finalUpdateList != null ){
                list<list<Sobject>> soblistOfList = new list<list<Sobject>>();
                if(finalUpdateList.size()>10000){
                    soblistOfList.addAll(doSubList(finalUpdateList));
                } else{
                    soblistOfList.add(finalUpdateList);
                }
                if(!soblistOfList.isEmpty()){
                    for(list<Sobject> sl : soblistOfList){
                        Database.SaveResult[] srList = Database.Update(sl, false); 
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                            }
                            else {
                                String message='';
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    message+= err.getMessage();
                                }
                            }
                        }
                    } 
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        
     
        return csvBody;
        
    }
    public static string createCSVBody(string ObjName ,database.SaveResult[] updateResult){
        string body = '';
        
        for(Integer i=0; i < updateResult.size(); i++) {
            
            if(!updateResult.get(i).isSuccess() || Test.isRunningTest()) {
                body += updateResult.get(i).Id + ',';
                body += ObjName + ',';
                string errorMsg = '';
                for(Database.Error error : updateResult[i].getErrors()){
                    errorMsg += error.getMessage() + ',';
                }
                errorMsg = errorMsg.removeEnd(',');
                body += '"'+errorMsg + '"' + ','; 
                body += '\n';
            }
        }
        return body;
    }
    
    //create Sub List if list has more then 10000 record 
    public static list<list<Sobject>> doSubList(List<Sobject> recordList)
    {
        long secondInterval = recordList.size();
        list<list<Sobject>> sublistOfList = new list<list<Sobject>>();
        decimal listsize = recordList.size();
        decimal recordCount = listsize.divide(10000, 2);
        long interval = recordCount.round(System.RoundingMode.CEILING);
        if(interval != 0){
            decimal recordCount2 = listsize.divide(interval, 2);
            secondInterval = recordCount2.round(System.RoundingMode.CEILING);
        }
        List<Sobject> shareRecordList = new List<Sobject>();
        for(Sobject sh : recordList){
            if(shareRecordList.size() <=  secondInterval){
                shareRecordList.add(sh);
            }else{
                sublistOfList.add(shareRecordList);
                shareRecordList = new List<Sobject>();
                shareRecordList.add(sh);
            }
        }
        sublistOfList.add(shareRecordList);
        
        return sublistOfList;
    }
  
}