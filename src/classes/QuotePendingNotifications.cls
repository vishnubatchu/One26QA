public class QuotePendingNotifications implements Database.Batchable<sObject> {
    public static final string STATUSPENDING ='0Q01N000001NfM5SAK';
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id, Status,(Select id,Line_Status__c,Name,Product__r.Name,Product__r.Marketing_P_N__c,Quantity__c,Target_Price__c,Disti_Resale_Price__c,Disti_Margin__c,Agreed_Upon_Share__c,Competitor_Info__c,Competitor_Price__c,RSM_Approver__c,PLM_Approver__c '+
                                        'from Quote_Items__r) FROM Quote Where ID =:STATUSPENDING');
    }
    
    public void execute(Database.BatchableContext BC, List<Quote> scope){
        List<Id> quoteItems = new List<Id>();
        Map<Id, String> quoteuser = new Map<Id,String>();
        Map<Id, List<ProcessInstanceWorkitem>> itemProcessMap = new Map<Id, List<ProcessInstanceWorkitem>>();
        Map<Id, List<Quote_Item__c>> quoteItemsMap = new Map<Id, List<Quote_Item__c>>();
        //List<Quote> quotes = new List<Quote>(scope);
        for(Quote qt : scope){
            quoteItemsMap.put(qt.Id, qt.Quote_Items__r);
            for(Quote_Item__c qtItm :qt.Quote_Items__r){
                quoteItems.add(qtItm.Id);
            }
        }
        for(processInstance proc :[Select id, targetobjectId, 
                                   (Select id, ActorId, OriginalActorId from workitems) 
                                   from processInstance 
                                   where TargetObjectid IN :quoteItems and status ='Pending']){
                                       itemProcessMap.put(proc.targetobjectId, proc.workitems);  
                                       quoteuser.put(proc.targetobjectId, proc.workitems[0].ActorId);
                                   }
        Map<Id,String> userNames = new Map<Id,String>();
        for(User usr :[Select id,name From User 
                       Where ID IN :quoteuser.values()]){
                           userNames.put(usr.Id, usr.Name);
                       }
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        for(Quote qt : scope){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setTemplateId(et.id);
            mail.setToAddresses(new list<Id>{'005c0000005s1iNAAQ'});
           // mail.setTargetObjectId(qt.Id);
            mail.setSaveAsActivity(false);
            mail.setWhatId(qt.Id);
            string emailBody ='<html><style>table, th, td {border: 1px solid black;}<table style="width:100%"> <tr ><th>Line #</th><th>ID#</th><th>Product</th><th>Quantity</th><th>Target Price</th><th>Disti Resale Price</th><th>Disti Margin %</th><th>Agreed Upon Share %</th><th>Competitor Info</th><th>Competitor Price</th><th>Status</th><th>Pending With</th></tr>';
            for(Quote_Item__c qtItm :qt.Quote_Items__r){
                emailBody = emailBody+'<tr><td>'+qtItm.Name+'</td><td>'+qtItm.Product__r.Name+'</td><td>'+
                    qtItm.Product__r.Marketing_P_N__c+'</td><td>'+qtItm.Quantity__c+'</td><td>'+qtItm.Target_Price__c+
                    '</td><td>'+qtItm.Disti_Resale_Price__c+'</td><td>'+qtItm.Disti_Margin__c+'</td><td>'+qtItm.Agreed_Upon_Share__c+'</td><td>'+qtItm.Competitor_Info__c
                    +'</td><td>'+qtItm.Competitor_Price__c+'</td>' ;
                if(qtItm.Line_Status__c == 'Approved'){
                    emailBody = emailBody+'<td>'+qtItm.Line_Status__c+'</td>';
                }else{
                    if(qtItm.RSM_Approver__c == quoteuser.get(qtItm.Id)){
                        emailBody = emailBody+'<td>'+qtItm.Line_Status__c+'</td><td>RSM :'+  userNames.get(quoteuser.get(qtItm.Id))+'</td>';
                    } else{
                        emailBody = emailBody+'<td>'+qtItm.Line_Status__c+'</td><td>PLM :'+  userNames.get(quoteuser.get(qtItm.Id))+'</td>';
                    }
                    
                }
            }
            emailBody = emailBody+'</tr></table></html>';
            mail.setHtmlBody(emailBody);
            mailList.add(mail);
        }
        Messaging.sendEmail(mailList);
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}