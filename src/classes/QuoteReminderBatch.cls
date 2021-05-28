public class QuoteReminderBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select id,targetobjectId,(Select id,ActorId,OriginalActorId from workitems) from processInstance where TargetObject.Name like 'QN-%' and status ='Pending']);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('scope'+scope);
        Map<Id,Set<Id>> quoteItemsPendingForApprovalMap = New Map<Id,Set<Id>>();
        Map<Id,MAP<Id,String>> mapOfQuoteIdCreatorIdEmail = New Map<Id,MAP<Id,String>>();
        Map<Id,List<Quote_Item__c>> mapOfQuoteIdAndLineItems = New Map<Id,List<Quote_Item__c>>();
        List<Quote_Item__c> ListOfRSMApprovers = New List<Quote_Item__c>();
        List<Quote_Item__c> ListOfPLmApprovers = New List<Quote_Item__c>();
        Map<Id,Quote_Item__c> mapOfQuoteItemToBeUpdated = New Map<Id,Quote_Item__c>();
        For(sobject sobj:scope){
            System.debug('sobj'+sobj);
            IF(sobj.getSObjects('workitems')!=Null){
                FOR(processInstanceWorkItem piwObj :sobj.getSObjects('workitems')){
                    IF(quoteItemsPendingForApprovalMap.containskey((Id)sobj.get('TargetObjectId'))){
                        quoteItemsPendingForApprovalMap.get((Id)sobj.get('TargetObjectId')).add(piwObj.OriginalActorId);
                    }Else{
                        quoteItemsPendingForApprovalMap.put((Id)sobj.get('TargetObjectId'),New Set<ID>{piwObj.OriginalActorId});
                        
                    }
                }
            }
        }
        For(Quote_Item__c quoteItemObj:[Select Id,Quote__c,Quote__r.createdByID,Quote__r.createdBy.Email,RSM_Approver__c,PLM_Approver__c,Line_Status__c,Approval_From__c,RSM_Approval__c,PLM_Approval__c 
                                        from Quote_Item__c 
                                        where id in :quoteItemsPendingForApprovalMap.keySet() And Approval_From__c ='BothApprovers']){
            If(mapOfQuoteIdAndLineItems.containskey(quoteItemObj.quote__c)){
                mapOfQuoteIdAndLineItems.get(quoteItemObj.quote__c).add(quoteItemObj);
            }
            else{
                mapOfQuoteIdAndLineItems.put(quoteItemObj.quote__c,New List<Quote_Item__c>{quoteItemObj});
            }
            
        }
        For(Id quoteId:mapOfQuoteIdAndLineItems.keyset()){
            Boolean RSmApproverPresent =False;
            Boolean PLMApproverPresent = False;
            Map<ID,String> mapofcreatorIdandEmail = New Map<ID,String>();
            // mapofcreatorIdandEmail.put(mapOfQuoteIdAndLineItems.get(quoteId).get(0).Quote__r.createdByID,mapOfQuoteIdAndLineItems.get(quoteId).get(0).Quote__r.createdBy.Email));
            For(Quote_Item__c quoteItemObj :mapOfQuoteIdAndLineItems.get(quoteId)){
                mapofcreatorIdandEmail.put(mapOfQuoteIdAndLineItems.get(quoteId).get(0).Quote__r.createdByID,mapOfQuoteIdAndLineItems.get(quoteId).get(0).Quote__r.createdBy.Email);
                IF(quoteItemsPendingForApprovalMap.get(quoteItemObj.Id).contains(quoteItemObj.RSM_Approver__c)){
                    RSmApproverPresent = True;
                }
                IF(quoteItemsPendingForApprovalMap.get(quoteItemObj.Id).contains(quoteItemObj.PLM_Approver__c)){
                    PLMApproverPresent = True;
                }
            }
            IF(RSmApproverPresent ^ PLMApproverPresent){
                mapOfQuoteIdCreatorIdEmail.put(quoteId,mapofcreatorIdandEmail);
                IF(RSmApproverPresent){
                    ListOfPLMApprovers.addall(mapOfQuoteIdAndLineItems.get(quoteId));
                }
                IF(PLMApproverPresent){
                    ListOfRSMApprovers.addall(mapOfQuoteIdAndLineItems.get(quoteId));
                }
                
            }
        }
        FOR(Quote_Item__c quoteItemObj:ListOfRSMApprovers){
            quoteItemObj.RSM_Approval__c ='Approved';
            quoteItemObj.PLM_Approval__c = 'Approval Pending';
            mapOfQuoteItemToBeUpdated.put(quoteItemObj.Id,quoteItemObj);
        }
        FOR(Quote_Item__c quoteItemObj:ListOfPLMApprovers){
            quoteItemObj.PLM_Approval__c ='Approved';
            quoteItemObj.RSM_Approval__c = 'Approval Pending';
            mapOfQuoteItemToBeUpdated.put(quoteItemObj.Id,quoteItemObj);
            
        }
        
        IF(!mapOfQuoteItemToBeUpdated.isempty()){
            update mapOfQuoteItemToBeUpdated.values();
        }
        System.debug('QuoteCreatorIdSet'+mapOfQuoteIdCreatorIdEmail);
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Quote_Reminder_To_Creator_Reminder'];
        FOR(Id quoteId :mapOfQuoteIdCreatorIdEmail.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.id);
            mail.setToAddresses(New List < String > {
                mapOfQuoteIdCreatorIdEmail.get(quoteId).values().get(0)
                    });
            mail.setTargetObjectId(new list<Id>(mapOfQuoteIdCreatorIdEmail.get(quoteId).keyset())[0]);
            mail.setSaveAsActivity(false);
            mail.setWhatId(quoteId);
            mailList.add(mail);
        }
        System.debug('MailList'+mailList );
        Messaging.sendEmail(mailList);
    }
    
    public void finish(Database.BatchableContext BC){
    }
}