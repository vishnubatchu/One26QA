public class SendReminderEmailLoaner {
    public class LoanerParameters 
    {
        @InvocableVariable(required = true)
        public Id loanerId;
        @InvocableVariable(required = true)
        public String TemplateName;
        @InvocableVariable(required = true)
        public String Status;
    }
    
    @InvocableMethod
    public static void SendReminderEmailLoaner(LoanerParameters[] loanerParamters) {
        set < id > userIds = New Set < id > ();
        List < String > statusList = loanerParamters.get(0).Status.split(',');
        List < Loaner_line__c > loanerItemsList = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(loanerParamters.get(0).loanerId, statusList);
        set < id > actorIdsSet = New set < id > ();
        for (ProcessInstanceWorkitem piwObj: [Select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :loanerItemsList]) {
            actorIdsSet.add(piwObj.ActorId);
        }
        If(actorIdsSet.size()>0){
            RecordsLineItemApprovalHelper.sendEmailwithTemplete(actorIdsSet, loanerParamters.get(0).loanerId, loanerParamters.get(0).TemplateName);
        }
    }
}