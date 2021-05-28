global class  CaseApprovalEmailServicehandler  implements Messaging.InboundEmailHandler {
    public static ID headerID;
    public static String headerObjectName;
    public static String action;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        List<Approval.ProcessWorkitemRequest> approvalList = new List<Approval.ProcessWorkitemRequest>();
        List <String> plaintextbody = email.plainTextBody.split('\n', 0);
        if(plaintextbody.size()>0){
            action = plaintextbody.get(0).split(':').size()>1 ? plaintextbody.get(0).split(':').get(1).trim():'';
            for (String bodyString: plaintextbody) {
                IF(bodyString.contains('Id : [')) {
                    headerID = bodyString.substringAfter('Id : [').remove(']');
                }
            }	
        }
        try{
            User approvinguser = [select id, name, UserRole.name from user where email = :envelope.fromAddress And isActive=True limit 1];
            List <ProcessInstanceWorkitem > pItemRecordList = [SELECT Id, ActorId, ProcessInstance.TargetObjectId 
                                                               FROM ProcessInstanceWorkitem 
                                                               WHERE ProcessInstance.TargetObjectId =:headerID AND 
                                                               ActorId =:approvinguser.id];    
            if (CommonConstants.approvalActions.contains(action)) {
                if(pItemRecordList.size()>0){
                    for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        req2.setComments('Approving request.');
                        req2.setAction('Approve');
                        req2.setWorkitemId(pitemObj.Id);
                        approvalList.add(req2);
                    }
                }
            }
            if (CommonConstants.rejectionActions.contains(action)) {
                System.debug('pItemRecordList'+pItemRecordList);
                if(pItemRecordList.size()>0){
                    for(ProcessInstanceWorkitem pitemObj : pItemRecordList){
                        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                        req2.setComments('Rejecting request.');
                        req2.setAction('Reject');
                        req2.setWorkitemId(pitemObj.id);
                        approvalList.add(req2);
                    }
                }
            }
            if(approvalList != null && !approvalList.isEmpty()){
                Approval.process(approvalList);
            }
            
        }catch(Exception exp){
            ErrorLog__c err = new ErrorLog__c();
            err.ClassName__c = 'CaseApprovalEmailServicehandler';
            err.MethodName__c = 'handleInboundEmail';
            err.ErrorMessage__c = exp.getMessage() +' User Email : '+envelope.fromAddress +' RecordId : '+headerID;
            insert err;
        }
        return result;
    }
}