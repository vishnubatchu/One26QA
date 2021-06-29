/*
* Created by : Pooja U
* Date : 23rd June 2021
* Description: When Order and OrderLine records are inserted from Integration, batch class pick those records based on Integration flag,
* populates 'Global_Ultimate_Account__c' on order with the same value in Order.AccountId.Global_Ultimate_Parent__c 
* and also inserts share records for the Order & OrderLine linked/associated Account's Global Parent Account owner   
*/
public class OrderAndOrderLine_Batch implements Database.Batchable<sObject>,Database.Stateful{
    List<OrderAndOrderLineBatch_Helper.CustomError> finalErrorList=new List<OrderAndOrderLineBatch_Helper.CustomError>();
    List<Sobject> ordrAndOrdrLineLstTobeUpdtd=new List<Sobject>();
    string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    string mainContent = csvHeader;
    
    //This method queries all Order and OrderLine records that are coming from Integration and not picked up by batch yet i.e.,Integration_Flag__c=true and Batch_Flag__c=false
    public List<Sobject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<Sobject> orderAndOrderLineList=new List<Sobject>();
        List<Order> orderList=[Select Id,AccountId,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                               from Order 
                               where Integration_Flag__c=true and Batch_Flag__c=false];
        orderAndOrderLineList.addAll(orderList);
        List<Order_Line__c> orderLineList=[Select Id,Order__c,Order__r.AccountId,Order__r.Account.Global_Ultimate_Parent__r.OwnerId,OwnerId 
                                           from Order_Line__c 
                                           where Integration_Flag__c=true and Batch_Flag__c=false];
        orderAndOrderLineList.addAll(orderLineList);
        return orderAndOrderLineList;
    }
    
    /*This method populates 'Global_Ultimate_Account__c' on order  with the same value in Order.AccountId.Global_Ultimate_Parent__c.
     * Also inserts share records for the Order & OrderLine linked/associated Account's Global Parent Account owner
     */
    public void execute(Database.BatchableContext bc, List<Sobject> orderAndOrderLineList){
        // process each batch of records
        if(orderAndOrderLineList!=null && !orderAndOrderLineList.isEmpty()){
            List<Order> orderList=new List<Order>();
            List<Order_Line__c> orderLineList=new List<Order_Line__c>();
            for(Sobject eachOrderOrOrderLine:orderAndOrderLineList){
                if(eachOrderOrOrderLine.Id.getSObjectType().getDescribe().getName()=='Order'){
                    Order orderRec=(Order)eachOrderOrOrderLine;
                    orderList.add(orderRec);
                    orderRec.Batch_Flag__c=true;
                    ordrAndOrdrLineLstTobeUpdtd.add(orderRec);
                }else{
                    Order_Line__c orderLineRec=(Order_Line__c)eachOrderOrOrderLine;
                    orderLineList.add(orderLineRec);
                    orderLineRec.Batch_Flag__c=true;
                    ordrAndOrdrLineLstTobeUpdtd.add(orderLineRec);
                }
            }
            List<OrderAndOrderLineBatch_Helper.CustomError> errorList=OrderAndOrderLineBatch_Helper.updateOrderAndInsertShareRecords(orderList,orderLineList);
            if(errorList!=null && !errorList.isEmpty()){
                finalErrorList.addAll(errorList);
                for(OrderAndOrderLineBatch_Helper.CustomError eachError:errorList){
                    string errStr = eachError.id+','+eachError.objectName+','+eachError.operation+','+eachError.message +'\n';
                    mainContent += errStr;
                }
            }
        }
    }
    
    /*This method sends failed record details to configured emailId if any and 
    	sets "Batch_Flag__c" so that the same order/orderline record will not be pickup by batch again
	*/
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(finalErrorList!=null && !finalErrorList.isEmpty()){
             OrderAndOrderLineBatch_Helper.sendEmail(mainContent);
        }
        if(ordrAndOrdrLineLstTobeUpdtd!=null && !ordrAndOrdrLineLstTobeUpdtd.isEmpty()){
            List<List<Sobject>> orderAndOrderLineTobeUpdtdInChunks=new List<List<Sobject>>();
            if(ordrAndOrdrLineLstTobeUpdtd.size()>10000){
                OrderAndOrderLineBatch_Helper.doSubList(ordrAndOrdrLineLstTobeUpdtd, 10000, orderAndOrderLineTobeUpdtdInChunks);
            }else{
                orderAndOrderLineTobeUpdtdInChunks.add(ordrAndOrdrLineLstTobeUpdtd);
            }
            for(List<Sobject> eachChunk:orderAndOrderLineTobeUpdtdInChunks){
            	update eachChunk;
            }
        }
    }
}