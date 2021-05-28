public without sharing class SobjectCancellationUnlock {
    
    @invocablemethod
    public static void unlockRecords(List < Id > recordList) {
        Map < id,sobject > mapsobjets = New Map < id,sobject > (RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordList.get(0), New List < String > {
                'Draft','Approval Pending','Cancelled','Approved','Approval Cancelled','Rejected','Approval Rejected'
                    }));
        Map<Id,Id> mapTargetObjectId = New Map<Id,Id>();
        if (mapsobjets.size() > 0) {
            List < ProcessInstanceWorkitem > processInstanceList = [Select Id, actorid, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :mapsobjets.keySet()];
            for (id sobjId: mapsobjets.keySet()) {
                IF(Approval.isLocked(sobjId)) {
                    Approval.unlock(sobjId);
                }
            }
           
            if (processInstanceList.size() > 0) {
                For(ProcessInstanceWorkitem piworkItemObj : processInstanceList){
                    mapTargetObjectId.put(piworkItemObj.ProcessInstance.TargetObjectId,piworkItemObj.Id);
                }
                for (id piId: mapTargetObjectId.values()){
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Recalling request.');
                    req2.setAction('Removed');
                    req2.setWorkitemId(piId);
                    Approval.ProcessResult result2 = Approval.process(req2);
                }
            }
        }
    }
}