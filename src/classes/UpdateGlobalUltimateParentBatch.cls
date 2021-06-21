/**
     * Created by : Akhilesh
     * Date : 31th May 2021
     * Description: This Batch class has implemented as per below logic
     * a) If the Global Ultimate Parent is changed on a Top-Level Account or a Customer that serves as the immediate parent of a child account, then the child’s Global Ultimate Parent should match that of its immediate paren.
     * b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
     * and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
     * Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
     */
global class UpdateGlobalUltimateParentBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    global String query;
    global map<id,Account> globalMap = new map<id,Account>();
    global List<Id> topAcclist = new list<Id>();
    global set<id> allAccSuccessId=new set<id>();
    global string csvBody;
    global string headerValue;
    global  List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
    //Header and body for faild record CSV file.
     global UpdateGlobalUltimateParentBatch(){
        csvBody = '';
        headerValue = 'Id,object, Error Message \n';
    }
    
    // Start Method : In start method we are fatching all the account and related child account where Global_Parent_Updated__c is true 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        globalMap = new Map<Id, Account>([select id, Global_Parent_Updated__c,Global_Ultimate_Parent__c,Changed_Global_Parent_Old_Owner__c   from Account where Global_Parent_Updated__c  = True]);
        topAcclist.addAll(globalMap.keySet());
        query = 'select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c ,Parent.Id,Parent.parent.Id,Parent.parent.parent.Id,Parent.parent.parent.parent.Id ' +
            'from Account where Parent.Id In: topAcclist Or Parent.Parent.Id In: topAcclist Or Parent.Parent.Parent.Id In: topAcclist Or Parent.parent.parent.parent.Id In: topAcclist Or Id In: topAcclist';
        system.debug('Quesry ' + query);
        return Database.getQueryLocator(query);
    }
    //Execute Method : Updating all the child account , and related Quote,order,Opportunity "Global_Ultimate_Account__c" and calling "GlobalParentOwnerBatch_Helper" with list of account. 
    global void execute(Database.BatchableContext BC,List<sObject> batch)
    {
      csvBody += UpdateGlobalUltimateParentBatchHelper.UpdateGlobalParent(batch,globalMap).csvBody;
        allAccSuccessId.addAll(UpdateGlobalUltimateParentBatchHelper.UpdateGlobalParent(batch,globalMap).allAccSuccessId);
    }
    
    //Finish Method : Sending faild record to admin and reset "Global_Parent_Updated__c" flag
    global void finish(Database.BatchableContext BC) {
        //send Email
        String finalCsv = '';
                    if(csvBody != null && csvBody != ''){
                        finalCsv = headerValue + csvBody;
                    }
                    if( finalCsv != null && finalCsv != ''){
                        String csvname= 'GlobalParentAccount_Update_Errors.csv';
                        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                        csvAttc.setFileName(csvname);
                        csvAttc.setBody(Blob.valueOf(finalCsv));
                        list<string> toAddresses = new list<string>();
                        Profile sys_adm_profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
                        for(user u : [SELECT id, Email FROM User WHERE ProfileId =:sys_adm_profile.Id]){
                           toAddresses.add(u.Email); 
                        }
                        String subject ='Account Update Error:';    
                        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                        email.setSubject(subject);
                        email.setToAddresses(toAddresses );
                        email.setPlainTextBody('PFA error file attached.');
                        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                        try{
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        }catch(Exception e){
                            
                        }
                    }   
        list<Account> finaAccllist = [select id,Global_Parent_Updated__c from Account where id in:allAccSuccessId];
        list<Account> ResetFlaglist = new list<Account>();
        if(finaAccllist.size() > 0 && finaAccllist != null){
            for(Account reset : finaAccllist){
                reset.Global_Parent_Updated__c = false;
                reset.Changed_Global_Parent_Old_Owner__c = null;
                ResetFlaglist.add(reset); 
            }
            try{
            update ResetFlaglist;
            }catch(Exception e){
                system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
            }
        }
    }
}