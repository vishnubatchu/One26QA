public class OrderItemPLMDashboardTriggerHelper {
    
    public static void UpdateOrderPLMDashboardDetails(List<Order_Line__c> OrderItems)
    {
        List<Order> Order = New List<Order>();
        List<Order_Line__c> OrderItemGroup = New List<Order_Line__c>();
        List<Order_Line__c> AllRelatedOrderItems = New List<Order_Line__c>();
        List<String> OrderIds = New List<String>();
        
        for(Order_Line__c OrderitmObj: OrderItems){
            OrderIds.add(OrderitmObj.Order__c);
        }
        
        AllRelatedOrderItems = [Select Order__c,Contribution_Profit__c,Gross_Profit__c,Revenue__c from Order_Line__c 
                                where Order__c IN : OrderIds];
        System.debug('AllRelatedOrderItems'+AllRelatedOrderItems);
        List<Order> DistinctOrderList = new List<Order>();
        Map<Id, order> ordermap = new Map<Id, order>();
        for(Order_Line__c temp: AllRelatedOrderItems){
            if(ordermap.containsKey(temp.Order__c)){
                order tempor = ordermap.get(temp.Order__c);
                tempor.Gross_Profit__c = tempor.Gross_Profit__c + Temp.Gross_Profit__c ;
                tempor.Contribution_Profit__c = tempor.Contribution_Profit__c + Temp.Contribution_Profit__c ;    
                tempor.Revenue__c = tempor.Revenue__c + Temp.Revenue__c ; 
                ordermap.put(tempor.Id, tempor);
            } else {
                Order OrderTemp = new Order();    
                OrderTemp.Id = Temp.Order__c;
                OrderTemp.Gross_Profit__c = Temp.Gross_Profit__c;
                OrderTemp.Contribution_Profit__c = Temp.Contribution_Profit__c; 
                OrderTemp.Revenue__c = Temp.Revenue__c ;
                ordermap.put(OrderTemp.Id, OrderTemp);
            }
        }
        if(ordermap != null && !ordermap.isEmpty()){
            //update ordermap.values();
            String jsonString = json.serialize(ordermap.values());
            system.debug('jsonString 38 '+jsonString);
            updateOrders(jsonString);
        }
        /*Boolean found = false;
for(Integer i=0; i< DistinctOrderList.size(); i++){
if(Temp.Order__c == DistinctOrderList[i].Id){ 

DistinctOrderList[i].Gross_Profit__c = DistinctOrderList[i].Gross_Profit__c + Temp.Gross_Profit__c ;
DistinctOrderList[i].Contribution_Profit__c = DistinctOrderList[i].Contribution_Profit__c + Temp.Contribution_Profit__c ;    
DistinctOrderList[i].Revenue__c = DistinctOrderList[i].Revenue__c + Temp.Revenue__c ;   
found=true;
System.debug('InsideFound'+Temp); 
System.debug('InsideFound'+DistinctOrderList);     
break;
}
}
if(!found)
{   
Order OrderTemp = new Order();    
OrderTemp.Id = Temp.Order__c;
OrderTemp.Gross_Profit__c = Temp.Gross_Profit__c;
OrderTemp.Contribution_Profit__c = Temp.Contribution_Profit__c; 
OrderTemp.Revenue__c = Temp.Revenue__c ;    
DistinctOrderList.add(OrderTemp);
System.debug('InsideNotFound'+OrderTemp); 
System.debug('InsideNotFound'+DistinctOrderList); 
}    
}
System.debug('DistinctOrderList'+DistinctOrderList);
If(DistinctOrderList.size()>0){
update DistinctOrderList;
}
*/
    }
    public static void updateOwnerAtOrderLinesonUpdate(Map<Id,Order_Line__c> oldMap, Map<Id,Order_Line__c> newMap){
        Set<String> productGroupSet = New Set<String>();
        List<Order_line__c> orderLines = new List<Order_line__c>();
        Map<Id,Order_line__c> mapOfOrderLineToBeUpdated = New Map<Id,Order_line__c>();
        FOR(Id recordId:newMap.keyset()){
            IF(newMap.get(recordId).Ship_From_Inventory__c != 'WXI'
               && oldMap.get(recordId).Part_Number__c != newMap.get(recordId).Part_Number__c && 
               newMap.get(recordId).Part_Number__c!=Null){
                   orderLines.add(newMap.get(recordId));
                   productGroupSet.add(newMap.get(recordId).Product_Group__c);
               }
        }
        if(!productGroupSet.isEmpty() && productGroupSet != null){
            updateOwnerAtOrderLines(orderlines, productGroupSet);   
        }
        
    }
    public static void insertOwnerAtOrderLinesonUpdate(List<Order_line__c> orderLineList){
        Set<String> productGroupSet = New Set<String>();
        List<Order_line__c> orderlines = new List<Order_line__c>();
        Map<Id, Order_line__c> mapOfOrderLineToBeUpdated = New Map<Id,Order_line__c>();
        FOR(Order_line__c orderLineObj : orderLineList){
            IF(orderLineObj.Ship_From_Inventory__c != 'WXI' && orderLineObj.Product_Group__c != Null){
                productGroupSet.add(orderLineObj.Product_Group__c);
                orderlines.add(orderLineObj);
            }
        }
        updateOwnerAtOrderLines(orderlines, productGroupSet);
    }
    public static void updateOwnerAtOrderLines(List<Order_Line__c> newOrderLineList,Set<String> productGroupSet){
        Map<String,List<RMA_Serial_Number_Owner__mdt>> mapOfProductGroupAndOwnerMetadata = New Map<String,List<RMA_Serial_Number_Owner__mdt>>();
        Set<String> userEmailSet = New Set<String>();
        Map<String,User> UserEmailObjMap = New Map<String,User>();
        For(RMA_Serial_Number_Owner__mdt serialNumberOwnerMetadataObj :[Select id,Owner__c,End_Customer__c,Marketing_Family__c,Product_Group__c,Location__c 
                                                                        from RMA_Serial_Number_Owner__mdt 
                                                                        where Product_Group__c in:productGroupSet]){
                                                                            IF(mapOfProductGroupAndOwnerMetadata.containskey(serialNumberOwnerMetadataObj.Product_Group__c)){
                                                                                mapOfProductGroupAndOwnerMetadata.get(serialNumberOwnerMetadataObj.Product_Group__c).add(serialNumberOwnerMetadataObj);
                                                                            }
                                                                            else{
                                                                                mapOfProductGroupAndOwnerMetadata.put(serialNumberOwnerMetadataObj.Product_Group__c,New List<RMA_Serial_Number_Owner__mdt>{serialNumberOwnerMetadataObj});
                                                                            } 
                                                                            userEmailSet.add(serialNumberOwnerMetadataObj.Owner__c);                                                   
                                                                        }
        IF(!mapOfProductGroupAndOwnerMetadata.isempty()){
            For(User userObj : [Select id,email from user where email in:userEmailSet and IsActive=True]){
                UserEmailObjMap.put(userObj.email,userObj);
            }
            For(Order_line__c orderlineObj:newOrderLineList){
                System.debug('orderlineObj'+orderlineObj);
                
                IF(mapOfProductGroupAndOwnerMetadata.containskey(orderlineObj.Product_Group__c)){
                    
                    For(RMA_Serial_Number_Owner__mdt metaDataObj:mapOfProductGroupAndOwnerMetadata.get(orderlineObj.Product_Group__c)){
                        System.debug(metaDataObj.Location__c.equalsIgnoreCase(orderlineObj.Ship_From_Inventory__c));
                        IF(!metaDataObj.Location__c.equalsIgnoreCase(orderlineObj.Ship_From_Inventory__c)){
                            continue;
                        }
                        IF(!String.isBlank(orderlineObj.Marketing_Family__c) && !(metaDataObj.Marketing_Family__c.contains(orderlineObj.Marketing_Family__c)|| metaDataObj.Marketing_Family__c.equalsignorecase('All'))){
                            continue;
                        }
                        IF(((!String.isBlank(orderlineObj.End_Customer__c) && orderlineObj.End_Customer__c.contains(metaDataObj.End_Customer__c))||
                            metaDataObj.End_Customer__c.equalsignorecase('All')||
                            metaDataObj.End_Customer__c.equalsignorecase('others')) &&
                           UserEmailObjMap.containskey(metaDataObj.Owner__c)){
                               orderlineObj.OwnerId = UserEmailObjMap.get(metaDataObj.Owner__c).Id;
                               System.debug('orderlineObj'+orderlineObj);
                           }
                    }
                }
            }
        }
    }
    // Added method to update Failure Location from Case object into Orderline Object using Serial number Rma id column 
    public static void failureLocationupdate(Map<id,Order_Line__c> newordline){ 
        List<String> ordrmaid = new List<String>();
        system.debug(newordline);
        for(Id recordid:newordline.keySet()){
            system.debug(newordline.get(recordid).Failure_Location__c);
            if ((newordline.get(recordid).rmaid__c != null && newordline.get(recordid).Failure_Location__c == null)){
                ordrmaid.add(newordline.get(recordid).rmaid__c);
            }
        }
        if(!ordrmaid.isEmpty())
            updateOrderLineLocation(newordline.keySet(), ordrmaid);
        // updateOrderLineLocation(newordline,ordrmaid);
    }
    
    public static void updateOrderLineLocation(set<id> ordline, List<String> rmaid){
        
        
        if(!rmaid.isEmpty())
        {
            List<Order_Line__c> ordlinelist = [select id,Failure_Location__c,rmaid__c from Order_Line__c where id in :ordline];
            List<Case> cs = [select id,casenumber,Failure_Location__c from Case where casenumber in :rmaid];
            List<Order_Line__c> updateorderlist = new  List<Order_Line__c>();
            Map<String,String> cs_Floc = new Map<String,String>();
            for(Case c:cs){
                cs_Floc.put(c.casenumber, c.Failure_Location__c);
            }
            for(Order_Line__c ordlnid : ordlinelist){
                //     for(Order_Line__c ordlnid : ordline.values()){
                if(cs_Floc.containsKey(ordlnid.rmaid__c))
                {
                    ordlnid.Failure_Location__c = cs_Floc.get(ordlnid.rmaid__c);
                    updateorderlist.add(ordlnid);
                }
            } 
            if(updateorderlist != null)
                update updateorderlist;
        }
        
    }
    public static void checkHROCM(List<Order_Line__c> orderLines){
        Set<Id> orderIds = new Set<Id>();
        Set<Id> PrdIds = new Set<Id>();
        List<Order> orders = new List<Order>();
        for(Order_Line__c line : orderLines){
            PrdIds.add(line.Part_Number__c);
        }
        Map<Id,Product2> prdMap = new Map<Id, Product2>([SELECT id, Name, Product_Family__c FROM Product2 WHERE Id IN :PrdIds]);
        for(Order_Line__c line : orderLines){
            if(line.Ship_From_Inventory__c == 'WXI' && 
               prdMap.containsKey(line.Part_Number__c) &&
               (prdMap.get(line.Part_Number__c).Product_Family__c == 'WSS-OCM' ||
                prdMap.get(line.Part_Number__c).Product_Family__c == 'WSS-OIG')){
                    line.HROCM_Line__c = true;
                    orderIds.add(line.Order__c);
                }
        }
        /*   for(Id orderId : orderIds){
orders.add(new order(id = orderId, HROCM_Order__c = true ));
}
if(orders != null && !orders.isEmpty()){
//update orders;
String jsonString = json.serialize(orders);
updateOrders(jsonString);
}*/
    }
    
    public static void updateOrderWarehouse(List<Order_line__c> orderlines){
        List<String> orderIds = new List<String>();
        List<Order> updatedOrder = new List<Order>();
        Set<Id> updatedIds = new Set<Id>();
        for(order_Line__c line :orderlines){
            orderIds.add(line.order__c);
        }
        Map<Id, Order> orderMap = new Map<Id, Order>([SELECT Id, HROCM_Order__c, Warehouse__c FROM Order WHERE Id IN :orderIds]);
        for(order_Line__c line :orderlines){
            if(orderMap.containsKey(line.Order__c)){
                if(line.HROCM_Line__c && !orderMap.get(line.Order__c).HROCM_Order__c){
                    orderMap.get(line.Order__c).HROCM_Order__c = true;
                    updatedIds.add(line.Order__c);
                }
                if(orderMap.get(line.Order__c).Warehouse__c != 'SYD' &&
                   orderMap.get(line.Order__c).Warehouse__c != line.Ship_From_Inventory__c){
                       orderMap.get(line.Order__c).Warehouse__c = line.Ship_From_Inventory__c;
                       updatedIds.add(line.Order__c);
                   }
            }
            
        }
        for(Id orderId : updatedIds){
            updatedOrder.add(orderMap.get(orderId));
        }
        if(updatedOrder != null && !updatedOrder.isEmpty()){
            String jsonString = json.serialize(updatedOrder);
            system.debug('jsonString 233 '+jsonString);
            updateOrders(jsonString);
        }
    }
    @future
    public static void updateOrders(String jsonOrders){
        List<Order> orderList = (List<Order>)Json.deserialize(jsonOrders, List<Order>.class);
        database.update(orderList, false) ;
    }
}