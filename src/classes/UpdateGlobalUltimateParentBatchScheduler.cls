global class UpdateGlobalUltimateParentBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) 
    {
            UpdateGlobalUltimateParentBatch batchObj = new UpdateGlobalUltimateParentBatch();
            Database.executeBatch(batchObj);
    }
}