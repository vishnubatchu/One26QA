public class SendEmailsToRSMPLM {
    
     public class QuoteParameters{
        @InvocableVariable(required=true)
        public Id quoteId;
        @InvocableVariable(required=true)
        public String TemplateName;
		 @InvocableVariable(required=true)	        
         public String Status; 
    }
    
    @InvocableMethod
    public static void sendEmailsToRSMandPLM(QuoteParameters[] quoteParamters) {
        set<id> userIds = New Set<id>();
        List<String> statusList = quoteParamters.get(0).Status.split(',');
        System.debug('statusList'+statusList);
        List<Quote_item__c> quoteItemsList = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(quoteParamters.get(0).quoteId,statusList);
        System.debug('quoteItemsList'+quoteItemsList);
        if(quoteItemsList.size()>0){
            for(Quote_item__c qitemObj:quoteItemsList){
                if(qitemObj.RSM_Approver__c!=Null && (qitemObj.Approval_From__c=='BothApprovers' || qitemObj.approval_From__c=='RSM')){
                    userIds.add(qitemObj.RSM_Approver__c);
                    System.debug('userIds'+userIds);
                }
                if(qitemObj.PLM_Approver__c!=Null && (qitemObj.Approval_From__c=='BothApprovers' || qitemObj.approval_From__c=='PLM')){
                    userIds.add(qitemObj.PLM_Approver__c);
                    System.debug('userIds'+userIds);
                }
            }
            
            RecordsLineItemApprovalHelper.sendEmailwithTemplete(userIds,quoteParamters.get(0).quoteId,quoteParamters.get(0).TemplateName);
        }
    }
}