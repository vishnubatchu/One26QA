/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This schedule class is for "UpdateGlobalParentLookupsBatch"  
*/
global class UpdateGlobalUltimateParentBatchScheduler implements Schedulable{
    global void execute(SchedulableContext sc) 
    {
            UpdateGlobalParentLookupsBatch batchObj = new UpdateGlobalParentLookupsBatch();
            Database.executeBatch(batchObj);
    }
}