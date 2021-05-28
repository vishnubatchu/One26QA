public class OrderAndLineItemsAccessSchedulable implements Schedulable {
	
    public void execute(SchedulableContext ctx) {
        OrderAndLineItemsAccessBatch oAccessbatchObj = new OrderAndLineItemsAccessBatch();
        Database.ExecuteBatch(oAccessbatchObj,200);
    } 
}