public without sharing class RmaRequestCancellation {
    
   @invocablemethod
    public static void cancelRmaRequest(List < Id > recordList){
        IF(!recordList.isEmpty()){
            For(id sobjId: recordList) {
                IF(Approval.isLocked(sobjId)) {
                    Approval.unlock(sobjId);
                }
            }
            System.debug('recordList'+recordList);
            For(ProcessInstanceWorkitem piwobj :[Select Id, actorid, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :recordList]){
                System.debug('in piw');
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Recalling request.');
                req2.setAction('Removed');
                req2.setWorkitemId(piwobj.Id);
                Approval.ProcessResult result2 = Approval.process(req2);
            }
        }
    }
}