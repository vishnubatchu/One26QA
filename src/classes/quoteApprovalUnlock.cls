public without sharing  class quoteApprovalUnlock {
    
    @invocablemethod
    public static List<List<Id>> unlockRecords(List < Id > recordList) {
        List<Id> lockedRecordIdList = New List<Id>();
        Map < id,sobject > mapsobjets = New Map < id,sobject > (RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordList.get(0), New List < String > {
            'Draft','Approval Pending','Cancelled','Approved','Approval Cancelled','Rejected','Approval Rejected'
                }));
        if (mapsobjets.size() > 0) {
            for (id sobjId: mapsobjets.keySet()) {
                IF(Approval.isLocked(sobjId)) {
                    Approval.unlock(sobjId);
                    lockedRecordIdList.add(sobjId);
                }
            }
        }
        return New List<List<Id>>{lockedRecordIdList};
    }
}