global class OrderAndOrderLineBatch_Scheduler implements Schedulable{
	global void execute(SchedulableContext sc) 
    {
            OrderAndOrderLine_Batch batchObj = new OrderAndOrderLine_Batch();
            Database.executeBatch(batchObj);
    }
}