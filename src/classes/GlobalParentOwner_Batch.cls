/*
     * Created by : Pooja U
     * Date : 26th May 2021
     * Description: When Account owner on Global Parent is changed, batch class inserts share record for the new Global Account owner for all related private records within the global hierarchy including Contacts, 
     * Opportunities, Quotes, Orders, Order Lines and Cases. And deletes share records for the previous owner of the Global Parent 
     * from all Private records within the global hierarchy.
     */
public class GlobalParentOwner_Batch implements Database.Batchable<sObject>,Database.Stateful{
    List<GlobalParentOwnerBatch_Helper.CustomError> finalErrorList=new List<GlobalParentOwnerBatch_Helper.CustomError>();
	string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    string mainContent = csvHeader;
    
    //This method queries all Accounts for which Global Parent Owner are changed i.e.,Global_Parent_Previous_Owner__c!=null
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String accountQueryStr='Select Id,Global_Parent_Previous_Owner__c,Global_Ultimate_Parent__r.OwnerId from Account where Global_Parent_Previous_Owner__c!=null';
        return Database.getQueryLocator(accountQueryStr);
    }
    
    /*This method inserts share record for the new Global Account owner for all related private records including Contacts, 
     * Opportunities, Quotes, Orders, Order Lines and Cases. Also deletes share records for the previous owner of the Global Parent.
     * and reset "Global_Parent_Previous_Owner__c"
     */
    public void execute(Database.BatchableContext bc, List<Account> accountList){
        // process each batch of records
        if(accountList!=null && !accountList.isEmpty()){
            List<GlobalParentOwnerBatch_Helper.CustomError> errorList=new List<GlobalParentOwnerBatch_Helper.CustomError>();
            try{
                errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(accountList,true);
                List<Account> accountListToUpdate=new List<Account>();
                for(Account eachAcc:accountList){
                    eachAcc.Global_Parent_Previous_Owner__c=null;
                    accountListToUpdate.add(eachAcc);
                }
                if(!accountListToUpdate.isEmpty()){
                    // Update the records
                    Database.SaveResult[] srList = Database.update(accountListToUpdate, false);
                    Integer lstIndex=0;
                    // Iterate through each returned result
                    for(Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            String message='';
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                message+= err.getMessage();
                            }
                            errorList.add(GlobalParentOwnerBatch_Helper.getCustomErrorObj(accountListToUpdate[lstIndex].Id,'Account','Update',message));
                        }
                        lstIndex++;
                    }
                    
                }
                
                if(errorList!=null && !errorList.isEmpty()){
                    finalErrorList.addAll(errorList);
                    for(GlobalParentOwnerBatch_Helper.CustomError eachError:errorList){
                        string errStr = eachError.id+','+eachError.objectName+','+eachError.operation+','+eachError.message +'\n';
                        mainContent += errStr;
                    }
                }
            }catch(Exception excpn){
                errorList.add(GlobalParentOwnerBatch_Helper.getCustomErrorObj('','','','Exception occured in execute()==>At line:'+excpn.getLineNumber()+',Message:'+excpn.getMessage()));
            }
        }
    }
    
    /*This method sends failed record details to configured emailId if any 
	*/
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(finalErrorList!=null && !finalErrorList.isEmpty()){
             GlobalParentOwnerBatch_Helper.sendEmail(mainContent);
        }
    }
    
}