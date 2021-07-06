global class UpdateGlobalUltimateParentBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) 
    {
            UpdateGlobalParentLookupsBatch batchObj = new UpdateGlobalParentLookupsBatch();
            Database.executeBatch(batchObj);
    }
}