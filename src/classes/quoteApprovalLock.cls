public without sharing class quoteApprovalLock {

    @invocablemethod
    public static void lockrecords(List<List<Id>> recordIdList){
        System.debug('Inside quoate ApprovalLock '+recordIdList);
        
        If(recordIdList.size()>0){
            Approval.lock(recordIdList.get(0), false);
        }
    }
}