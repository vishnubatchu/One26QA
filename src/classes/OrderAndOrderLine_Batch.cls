/*
* Created by : Pooja U
* Date : 23rd June 2021
* Description: When Order and OrderLine records are inserted from Integration, batch class pick those records based on Integration flag,
* populates 'Global_Ultimate_Account__c' on order with the same value in Order.AccountId.Global_Ultimate_Parent__c 
* and also inserts share records for the Order & OrderLine linked/associated Account's Global Parent Account owner   
*/
public class OrderAndOrderLine_Batch implements Database.Batchable<sObject>,Database.Stateful{
    List<OrderAndOrderLineBatch_Helper.CustomError> finalErrorList=new List<OrderAndOrderLineBatch_Helper.CustomError>();
    string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    string mainContent = csvHeader;
    
    //This method queries all Order and OrderLine records that are coming from Integration and not picked up by batch yet i.e.,Integration_Flag__c=true and Batch_Flag__c=false
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        String orderQueryStr='Select Id,AccountId,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId from Order where Integration_Flag__c=true and Batch_Flag__c=false';
        return Database.getQueryLocator(orderQueryStr);
    }
    
    /*This method populates 'Global_Ultimate_Account__c' on order  with the same value in Order.AccountId.Global_Ultimate_Parent__c.
	* And inserts share records for the Order & OrderLine linked/associated Account's Global Parent Account owner
	* Also sets "Batch_Flag__c=true" so that the same order/orderline record will not be pickup by batch again
	*/
    public void execute(Database.BatchableContext bc, List<Order> orderList){
        // process each batch of records
        if(orderList!=null && !orderList.isEmpty()){
            List<OrderAndOrderLineBatch_Helper.CustomError> errorList=new List<OrderAndOrderLineBatch_Helper.CustomError>();
            try{
                List<Order_Line__c> orderLineList=[Select Id,Order__c,Order__r.AccountId,Order__r.Account.Global_Ultimate_Parent__r.OwnerId,OwnerId 
                                                   from Order_Line__c 
                                                   where Integration_Flag__c=true and Batch_Flag__c=false and Order__c IN : orderList];
                errorList=OrderAndOrderLineBatch_Helper.updateOrderAndInsertShareRecords(orderList,orderLineList);
                //Sets "Batch_Flag__c" so that the same order/orderline record will not be pickup by batch again
                List<Sobject> ordrAndOrdrLineLstTobeUpdtd=new List<Sobject>();
                for(Order eachOrder:orderList){
                    eachOrder.Batch_Flag__c=true;
                    ordrAndOrdrLineLstTobeUpdtd.add(eachOrder);
                }
                for(Order_Line__c eachOrderLine:orderLineList){
                    eachOrderLine.Batch_Flag__c=true;
                    ordrAndOrdrLineLstTobeUpdtd.add(eachOrderLine);
                }
                if(!ordrAndOrdrLineLstTobeUpdtd.isEmpty()){
                    // Update the records
                    Database.SaveResult[] srList = Database.update(ordrAndOrdrLineLstTobeUpdtd, false);
                    Integer lstIndex=0;
                    // Iterate through each returned result
                    for(Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            String message='';
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                message+= err.getMessage();
                            }
                            errorList.add(OrderAndOrderLineBatch_Helper.getCustomErrorObj(ordrAndOrdrLineLstTobeUpdtd[lstIndex].Id,'Order','Update',message));
                        }
                        lstIndex++;
                    }
                    
                }
                
                if(errorList!=null && !errorList.isEmpty()){
                    finalErrorList.addAll(errorList);
                    for(OrderAndOrderLineBatch_Helper.CustomError eachError:errorList){
                        string errStr = eachError.id+','+eachError.objectName+','+eachError.operation+','+eachError.message +'\n';
                        mainContent += errStr;
                    }
                }
            }catch(Exception excpn){
                errorList.add(OrderAndOrderLineBatch_Helper.getCustomErrorObj('','','','Exception occured in execute()==>At line:'+excpn.getLineNumber()+',Message:'+excpn.getMessage()));
            }
        }
        
    }
    
    /*This method sends failed record details to configured emailId if any
	*/
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(finalErrorList!=null && !finalErrorList.isEmpty()){
            OrderAndOrderLineBatch_Helper.sendEmail(mainContent);
        }
    }
}