/*
* Created by : Pooja U
* Date : 23rd June 2021
* Description: This helper class populates 'Global_Ultimate_Account__c' on order with the same value in Order.AccountId.Global_Ultimate_Parent__c 
* and also inserts share records for the Order & OrderLine linked/associated Account's Global Parent Account owner
*/
public class OrderAndOrderLineBatch_Helper {
    
    /*This method updates order and insert order and orderline share records
    *Also Sets "Batch_Flag__c" on order/orderline records
	*/
    public static List<CustomError> updateOrderAndInsertShareRecords(List<Order> orderList,List<Order_Line__c>orderLineList){
        List<CustomError> errorList=new List<CustomError>();
        if((orderList!=null && !orderList.isEmpty()) || (orderLineList!=null && !orderLineList.isEmpty())){
            try{
                Map<String,List<SObject>> orderupdateAndShareRecordsMap=getRcrdsTobeUpdatedOrInserted(orderList,orderLineList);
                if(orderupdateAndShareRecordsMap!=null && !orderupdateAndShareRecordsMap.isEmpty()){
                    List<Sobject> listOfRecordsTobeUpdated=new List<Sobject>();
                    List<Sobject> listOfShareRecTobeInserted=new List<Sobject>();
                    if(orderupdateAndShareRecordsMap.containsKey('updateList') && orderupdateAndShareRecordsMap.get('updateList')!=null
                       && !orderupdateAndShareRecordsMap.get('updateList').isEmpty()){
                           listOfRecordsTobeUpdated.addAll(orderupdateAndShareRecordsMap.get('updateList'));
                       }
                    if(orderupdateAndShareRecordsMap.containsKey('insertList') && orderupdateAndShareRecordsMap.get('insertList')!=null
                       && !orderupdateAndShareRecordsMap.get('insertList').isEmpty()){
                           listOfShareRecTobeInserted.addAll(orderupdateAndShareRecordsMap.get('insertList'));
                       }
                    if(!listOfRecordsTobeUpdated.isEmpty()){
                            // Update the records
                            Database.SaveResult[] srList = Database.update(listOfRecordsTobeUpdated, false);
                            Integer lstIndex=0;
                            // Iterate through each returned result
                            for(Database.SaveResult sr : srList) {
                                if (!sr.isSuccess()) {
                                    String message='';
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        message+= err.getMessage();
                                    }
                                    errorList.add(new CustomError(listOfRecordsTobeUpdated[lstIndex].Id,listOfRecordsTobeUpdated[lstIndex].Id.getSObjectType().getDescribe().getName(),'Update',message));
                                }
                                lstIndex++;
                            }

                    }
                    if(!listOfShareRecTobeInserted.isEmpty()){
                            Database.SaveResult[] srList = Database.insert(listOfShareRecTobeInserted, false);
                            // Iterate through each returned result
                            for (Database.SaveResult sr : srList) {
                                if (!sr.isSuccess()) {
                                    String message='';
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        message+= err.getMessage();
                                    }
                                    errorList.add(new CustomError('','OrderShare/Order_Line__Share','Insert',message));
                                }
                            }

                    }
                }
            }catch(Exception excpn){
                errorList.add(new CustomError('','','','Exception occured in updateOrderAndInsertShareRecords()==>At line:'+excpn.getLineNumber()+',Message:'+excpn.getMessage()));
            }
        }
        return errorList;
    }
    
    //This method get order records to be updated and order/orderline share records to be inserted
    public static Map<String,List<SObject>> getRcrdsTobeUpdatedOrInserted(List<Order> orderList,List<Order_Line__c>orderLineList){
        Map<String,List<SObject>> finalReturnMap=new Map<String,List<SObject>>();
        if((orderList!=null && !orderList.isEmpty()) || (orderLineList!=null && !orderLineList.isEmpty())){
            
            processReturnedMap(getOrderAndShareRecords(orderList),finalReturnMap);
            processReturnedMap(getOrderLineShareRecords(orderLineList),finalReturnMap);
            
        }
        return finalReturnMap;
        
    }
    
    
    //This method get order share records to be inserted and order records to be updated
    public static Map<String,List<Sobject>> getOrderAndShareRecords(List<Order> orderList){
        Map<String,List<Sobject>> orderAndShareRecordsMap=new Map<String,List<Sobject>>();
        if(orderList!=null && !orderList.isEmpty()){
            List<Order> orderListTobeUpdated=new List<Order>();
            List<Sobject> orderShrListTobeInsrtd=new List<Sobject>();
            for(Order eachOrder:orderList){
                Order orderRecTobeUpdated=new Order();
                if(eachOrder.AccountId!=null && eachOrder.Account.Global_Ultimate_Parent__c!=null){
                    orderRecTobeUpdated.Id=eachOrder.Id;
                    orderRecTobeUpdated.Global_Ultimate_Account__c=eachOrder.Account.Global_Ultimate_Parent__c;
                    if(eachOrder.OwnerId!=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId){
                        orderShrListTobeInsrtd.add(new OrderShare(OrderId=eachOrder.Id,UserOrGroupId=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                  RowCause='Manual',OrderAccessLevel='Read'));
                    }
                }
                //Sets "Batch_Flag__c"
                orderRecTobeUpdated.Batch_Flag__c=true;
                orderListTobeUpdated.add(orderRecTobeUpdated);
            }
            orderAndShareRecordsMap.put('updateList',orderListTobeUpdated);
            orderAndShareRecordsMap.put('insertList',orderShrListTobeInsrtd);
        }
        return orderAndShareRecordsMap;
    }
    
    //This method get order line share records to be inserted and batchFlagOrderLineUpdateList
    public static Map<String,List<Sobject>> getOrderLineShareRecords(List<Order_Line__c> orderLineList){
        Map<String,List<Sobject>> orderLineShareRecordsMap=new Map<String,List<Sobject>>();
        if(orderLineList!=null && !orderLineList.isEmpty()){
            List<Order_Line__c> batchFlagUpdateList=new List<Order_Line__c>();
            List<Sobject> orderLineShrListTobeInsrtd=new List<Sobject>();
            for(Order_Line__c eachOrderLine:orderLineList){
                if(eachOrderLine.Order__c!=null && 
                   eachOrderLine.Order__r.AccountId!=null && eachOrderLine.Order__r.Account.Global_Ultimate_Parent__c!=null
                   && eachOrderLine.OwnerId!=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId){
                       orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=eachOrderLine.Id,UserOrGroupId=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                            RowCause='Manual',AccessLevel='Read'));
                   }
                //Sets "Batch_Flag__c"
                eachOrderLine.Batch_Flag__c=true;
                batchFlagUpdateList.add(eachOrderLine);
            }
            orderLineShareRecordsMap.put('updateList',batchFlagUpdateList);
            orderLineShareRecordsMap.put('insertList',orderLineShrListTobeInsrtd);
        }
        return orderLineShareRecordsMap;
    }
    
    //This is util method to process each related object's updateList and insertList 
    public static void processReturnedMap(Map<String,List<Sobject>> recMap,Map<String,List<SObject>> finalReturnMap){
        if(recMap!=null && !recMap.isEmpty()){
            List<SObject> recordsToBeUpdated=new List<SObject>();
            List<SObject> shareRecordsToBeInserted=new List<SObject>();
            if(finalReturnMap!=null && !finalReturnMap.isEmpty()){
                if(finalReturnMap.containsKey('updateList') && finalReturnMap.get('updateList')!=null && !finalReturnMap.get('updateList').isEmpty()){
                    recordsToBeUpdated.addAll(finalReturnMap.get('updateList'));
                }
                if(finalReturnMap.containsKey('insertList') && finalReturnMap.get('insertList')!=null && !finalReturnMap.get('insertList').isEmpty()){
                    shareRecordsToBeInserted.addAll(finalReturnMap.get('insertList'));
                }
            }
            if(recMap.containsKey('updateList') && recMap.get('updateList')!=null && !recMap.get('updateList').isEmpty()){
                recordsToBeUpdated.addAll(recMap.get('updateList'));
            }
            if(recMap.containsKey('insertList') && recMap.get('insertList')!=null && !recMap.get('insertList').isEmpty()){
                shareRecordsToBeInserted.addAll(recMap.get('insertList'));
            }
            finalReturnMap.put('updateList',recordsToBeUpdated);
            finalReturnMap.put('insertList',shareRecordsToBeInserted);
        }
    }
    
    public class CustomError
    {
        public String id{get;set;}
        public String objectName{get;set;}
        public String operation{get;set;}
        public String message{get;set;}
        CustomError(String id,String objectName,String operation,String message){
            this.id=id;
            this.objectName=objectName;
            this.operation=operation;
            this.message=message;
        }
    }
}