public class RecordsLineItemApprovalHelper {
    
    public static void sendEmail(Set < id > userSet, Id recordId) {
        String Template; 
		sobject sobj= RecordApprovalDao.getHeaderRecord(recordId);
        if(recordId.getSObjectType().getDescribe().getName().equalsIgnorecase('Quote')){
            Template = 'Quote_Line_Item_Approval_Email_Template';
        }
        if(recordId.getSObjectType().getDescribe().getName().equalsIgnorecase('Loaner__c')){
            If((CommonConstants.LoanerRequestRecordtypeId==sobj.get('recordTypeID')|| CommonConstants.LoanerRequestReadOnlyRecordtypeId==sobj.get('recordTypeID')) && sobj.get('Loaner_Duration__c')=='No_Return'){
                Template = 'Loaner_No_Return_Email_Template';
            }
            If((CommonConstants.LoanerRequestRecordtypeId==sobj.get('recordTypeID')|| CommonConstants.LoanerRequestReadOnlyRecordtypeId==sobj.get('recordTypeID')) && sobj.get('Loaner_Duration__c')!='No_Return'){
                System.debug('Inside Templete');
                Template = 'Loaner_Line_Item_Approval_Email_Template';
            }
            If(CommonConstants.LoanerExtensiontypeId==sobj.get('recordTypeID')||CommonConstants.LoanerExtensionReadOnlytypeId==sobj.get('recordTypeID')){
                Template = 'Loaner_Extension_Approval_Email_Template';
            }
        }
		sendEmailwithTemplete(userSet,recordId,Template);      
        //sendEmailwithTemplete(userSet,recordId,sobjectDeveloperMap.get(recordId.getSObjectType().getDescribe().getName()));
    }
    
    public static void sendEmailwithTemplete(Set <id> userSet,ID recordId , String TemplateName ){
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        System.debug('Before Email');
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :TemplateName];
        System.debug('After Email');
        List< user > userList = New List < User > (RecordApprovalDao.getUserVPSVPDetails(userSet));
        for (user u : userList) {
            System.debug('User Object'+ u);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.id);
            mail.setToAddresses(New List < String > {
                u.email
                    });
            mail.setTargetObjectId(u.id);
            mail.setSaveAsActivity(false);
            mail.setWhatId(recordId);
            mail.setReplyTo(Label.Apex_Email_Service_Address);
            //Added by surendar for SAL-3576
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'FinisarCRM'];
            mail.setOrgWideEmailAddressId(owea[0].id);
            //end
            mailList.add(mail);
        }
        System.debug('MailList'+mailList );
        Messaging.sendEmail(mailList);
    }
    
    
    
    public static void ApproveRecords(Set < id > recordLineitemsToBeApprovedSet, String headerObjectName, Id headerID, Id userID) {
        System.debug('Inside Approve Records');
        Set<id> useridSet = RecordApprovalDao.getUserFromDelegatedApproverID(userID);
        List <ProcessInstanceWorkitem > pItemRecordList = New List<ProcessInstanceWorkitem>([Select Id,ActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :recordLineitemsToBeApprovedSet and ActorId in:useridSet]);
       	System.debug('pItemRecordList'+pItemRecordList);
        Set<id> targetobjectIds = New Set<id>();
        if(pItemRecordList.size()>0){
            for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                System.debug('ApprovalEmailServiceHandler.comments--------->'+ApprovalEmailServiceHandler.comments);
                ApprovalEmailServiceHandler.comments = String.isEmpty(ApprovalEmailServiceHandler.comments)|| ApprovalEmailServiceHandler.comments.equals('')?'Approving request.':ApprovalEmailServiceHandler.comments;
                req2.setComments(ApprovalEmailServiceHandler.comments);
                req2.setAction('Approve');
                req2.setWorkitemId(pitemObj.Id);
                Approval.ProcessResult result2 = Approval.process(req2);
                targetobjectIds.add(pitemObj.ProcessInstance.TargetObjectId);
            }
            if (headerObjectName.equalsIgnoreCase('Loaner__c')) {
                System.debug('Loaner__c');
                List < ProcessInstanceWorkitem > processItemworkList = [Select Id, ActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in:targetobjectIds];
                System.debug('processItemworkList'+processItemworkList);
                Set<Id> sequeantialapproverIdSet = New Set<id>();
                if (processItemworkList.size() > 0) {
                    for(ProcessInstanceWorkitem pobj :processItemworkList ){
                        sequeantialapproverIdSet.add(pobj.ActorId);
                    }
                    Set<id> delegatedApproverSet = RecordApprovalDao.getDelegatedApprovedID(sequeantialapproverIdSet);
                        sequeantialapproverIdSet.addall(delegatedApproverSet);
                    RecordsLineItemApprovalHelper.sendEmail(sequeantialapproverIdSet, headerID);
                }
            }
        }
        
    }
    
    public static void RejectRecords(Set < id > recordLineitemsToBeRejectedSet, String headerObjectName,Id userID) {
        Set<id> useridSet = RecordApprovalDao.getUserFromDelegatedApproverID(userID);
        List<ProcessInstanceWorkitem> pItemRecordList= New List<ProcessInstanceWorkitem>([Select Id,Actorid,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :recordLineitemsToBeRejectedSet and Actorid in :useridSet]);
        if(pItemRecordList.size()>0){
            for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                ApprovalEmailServiceHandler.comments = String.isEmpty(ApprovalEmailServiceHandler.comments)|| ApprovalEmailServiceHandler.comments==''?'Rejecting request.':ApprovalEmailServiceHandler.comments;
                req2.setComments(ApprovalEmailServiceHandler.comments);
                req2.setAction('Reject');
                req2.setWorkitemId(pitemObj.id);
                Approval.ProcessResult result2 = Approval.process(req2);
            }
        }
    }
    
    public static void reAssignUser(Id headerID,user u,String emailAddressToChange,Set<id> lineItemIds){
        String headerObjectName = headerId.getSObjectType().getDescribe().getName();
        List<sobject> sobjectList = New List<sobject>();
        if(lineItemIds.size()>0){
            sobjectList = RecordApprovalDao.getLineItemsRecordsForApprovalByLineItems(headerID, u.Id,lineItemIds);
        }
        else{
            sobjectList = RecordApprovalDao.getLineItemsRecordsForApproval(headerID, u.Id);			
        }
        System.debug('sobjectList'+sobjectList);
        List<User> userEmailToBeChanged = [select id, email,UserRoleId, UserRole.Name from user where email = :emailAddressToChange and isActive=True limit 1];
        System.debug('userEmailToBeChanged'+userEmailToBeChanged);
        list < sobject > sobjectListToBeupdated = New List < sobject > ();
        List<ProcessInstanceWorkitem> processInstanceworkItemList = New List<ProcessInstanceWorkitem>();
        List < ProcessInstanceWorkitem > processItemworkList = [Select Id, ActorId ,OriginalActorId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in:sobjectList and ActorId=:u.id];
        if (sobjectList.size() > 0 && userEmailToBeChanged.size()>0) {
            For(sobject sobj: sobjectList) {
                System.debug('sobj'+sobj);
                System.debug('TEst'+CommonConstants.mapOfRolesReassignment.get(headerObjectName).get(userEmailToBeChanged.get(0).UserRole.Name).contains(u.UserRole.name));
                If (CommonConstants.mapOfRolesReassignment.get(headerObjectName).get(userEmailToBeChanged.get(0).UserRole.Name).contains(u.UserRole.name)) {
                    for (String apiFieldName: CommonConstants.mapOfUserField.get(headerObjectName)) {
                        If (sobj.get(apiFieldName) != Null && sobj.get(apiFieldName) == u.Id) {
                            sobj.put(apiFieldName, userEmailToBeChanged.get(0).Id);
                            sobjectListToBeupdated.add(sobj);
                        }
                    } 
                    for(ProcessInstanceWorkitem pIWItemObj : processItemworkList){
                        If(pIWItemObj.ActorId==u.Id){
                            pIWItemObj.ActorId = userEmailToBeChanged.get(0).Id;
                            pIWItemObj.OriginalActorId = userEmailToBeChanged.get(0).Id;
                            processInstanceworkItemList.add(pIWItemObj);
                        }
                    }
                }
            }
            If (sobjectListToBeupdated.size() > 0) {
                update sobjectListToBeupdated;
            }
            If(processInstanceworkItemList.size()>0){
                update processInstanceworkItemList;
            }
            RecordsLineItemApprovalHelper.sendEmail(New Set<id>{userEmailToBeChanged.get(0).id},headerId);
        }
    }
}