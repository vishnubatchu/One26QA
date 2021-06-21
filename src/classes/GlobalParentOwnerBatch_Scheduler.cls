global class GlobalParentOwnerBatch_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) 
    {
            GlobalParentOwner_Batch batchObj = new GlobalParentOwner_Batch();
            Database.executeBatch(batchObj);
    }
}