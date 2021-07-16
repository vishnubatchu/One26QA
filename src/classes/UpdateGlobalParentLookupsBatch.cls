/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This Batch class has implemented as a "one time Activity" and "daily schedule batch" for   updateing all the opportunity order and quote's Global Parent 
* a) if opportunity order and quote's dont have global 
* b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
* and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
* Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
* when IsOneTimeBatch custom label value True then it will run for one time activity and when value is fall it will run for daily schedule
*/
public class UpdateGlobalParentLookupsBatch implements Database.Batchable <sObject>,Database.Stateful,Schedulable{ 
    public Database.SaveResult[] finalsaveResult ; 
    List<GlobalParentOwnerBatch_Helper.CustomError> errorList= new List<GlobalParentOwnerBatch_Helper.CustomError>();
    string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    string mainContent = csvHeader;
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
        set<sobject> updateSet = new set<sObject>();
        for(sObject obj : scope)
        {
            switch on obj
            {
                when Opportunity opp
                {
                    opp.Global_Ultimate_Account__c = opp.Account.Global_Ultimate_Parent__c ;
                    updateSet.add(opp);
                    acSharing.add(opp.Account);
                }
                when Order ord
                {
                    ord.Global_Ultimate_Account__c = ord.Account.Global_Ultimate_Parent__c ;
                    updateSet.add(ord);
                    acSharing.add(ord.Account);
                }
                when Quote qt
                {
                    qt.Global_Ultimate_Account__c = qt.Account.Global_Ultimate_Parent__c ;
                    updateSet.add(qt);
                    acSharing.add(qt.Account);
                }
            }
        }
        finalUpdateList.addAll(updateSet);
        Database.SaveResult[] srList = Database.update(finalUpdateList, false); 
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                String message='';
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    message+= err.getMessage();
                }
                errorList.add(new GlobalParentOwnerBatch_Helper.CustomError('','ShareObj','Insert',message));
            }
        }
        set<Account> accSet = new set<Account>();
        accSet.addAll(acSharing);
        list<Account> updateOnetimebatchFlag = new list<Account>();
        if(acSharing != null && acSharing.size() > 0){ 
            if(System.Label.IsOneTimeBatch  == 'False'){
                // calling deleteAndInsertShareRecords method for deleting and insert sharing 
                errorList.addAll(GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(acSharing,false));
            }
            for(Account ac : accSet){
                    ac.Global_Parent_Updated__c = false;
                    ac.Changed_Global_Parent_Old_Owner__c = null;
                updateOnetimebatchFlag.add(ac);
            }
            Database.SaveResult[] acs = Database.update(updateOnetimebatchFlag, false); 
              
        }
    }
    public void finish(Database.BatchableContext BC) {
        if(errorList!=null && !errorList.isEmpty()){
            for(GlobalParentOwnerBatch_Helper.CustomError eachError:errorList){
                string errStr = eachError.id+','+eachError.objectName+','+eachError.operation+','+eachError.message +'\n';
                mainContent += errStr;
            }
            EmailUtil.sendEmailWithAttachment(mainContent,'ErrorList.csv',System.Label.Global_Parent_Owner_Account_Update_Batch_Notification_EmaildId,'UpdateGlobalParentLookupsBatch Errors','PFA error file attached.');
        }  
        // calling "InsertSharedRecordOneTimeBatch" batch for inserting share record            
        if(System.Label.IsOneTimeBatch  == 'True'){
            InsertSharedRecordOneTimeBatch ex = new InsertSharedRecordOneTimeBatch();
            database.executeBatch(ex,200);
        }
    }
    
     //This method schedules the batch to run everyday
    public void execute(SchedulableContext sc) 
    {
            UpdateGlobalParentLookupsBatch batchObj = new UpdateGlobalParentLookupsBatch();
            Database.executeBatch(batchObj);
    }
}