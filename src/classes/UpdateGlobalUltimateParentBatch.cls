/**
     * Created by : Akhilesh
     * Date : 31th May 2021
     * Description: This Batch class has implemented as per below logic
     * a) If the Global Ultimate Parent is changed on a Top-Level Account or a Customer that serves as the immediate parent of a child account, then the child’s Global Ultimate Parent should match that of its immediate paren.
     * b) When the Global_Ultimate_Parent__c is changed on an Account that is populated in Opportunity.AccountId, Quote.AccountId, 
     * and Order.AccountId, a batch class properly updates Opportunity.Global_Ultimate_Account__c, 
     * Quote.Global_Ultimate_Account__c, and Order.Global_Ultimate_Account__c to reflect the Account’s Global_Ultimate_Parent__c
     */
public class UpdateGlobalUltimateParentBatch implements Database.Batchable <sObject>,Database.Stateful{ 
    public String query;
    public string csvBody;
    public string headerValue;
    public  List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
    //Header and body for faild record CSV file.
     public UpdateGlobalUltimateParentBatch(){
        csvBody = '';
        headerValue = 'Id,object, Error Message \n';
    }
    
    // Start Method : In start method we are fatching all the account and related child account where Global_Parent_Updated__c is true 
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        query = 'select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c  from Account where Global_Parent_Updated__c  = True';
        return Database.getQueryLocator(query);
    }
    //Execute Method : Updating all the child account , and related Quote,order,Opportunity "Global_Ultimate_Account__c" and calling "GlobalParentOwnerBatch_Helper" with list of account. 
    public void execute(Database.BatchableContext BC,List<Account> batch)
    {
      csvBody += UpdateGlobalUltimateParentBatchHelper.updateGlobalParent(batch);
      list<Account> resetFlaglist = new list<Account>();
            for(Account reset : batch){
                reset.Global_Parent_Updated__c = false;
                reset.Changed_Global_Parent_Old_Owner__c = null;
                resetFlaglist.add(reset); 
            }
            try{
                      Database.SaveResult[] srList = Database.Update(resetFlaglist, false);   
            }catch(Exception e){
                system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
            }
        
    }
    
    //Finish Method : Sending faild record to admin and reset "Global_Parent_Updated__c" flag
    public void finish(Database.BatchableContext BC) {
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
                        List<String> toEmailIdList=new List<String>();
        String toEmailIdStr=System.Label.Global_Parent_Owner_Account_Update_Batch_Notification_EmaildId;
        if(toEmailIdStr!=null && toEmailIdStr.trim()!=''){
            if(toEmailIdStr.contains(',')){
                toEmailIdList=toEmailIdStr.split(',');
            }else{
                toEmailIdList.add(toEmailIdStr);
            }
        }
        String[] toAddresses = toEmailIdList; 
                        String subject ='Account Update Error:';    
                        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                        email.setSubject(subject);
                        email.setToAddresses(toEmailIdList );
                        email.setPlainTextBody('PFA error file attached.');
                        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                        try{
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        }catch(Exception e){
                            
                        }
                    }   
    }
}