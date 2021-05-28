public class OrderlineOwnerupdate {
    public static void updateOwnerAtOrderLines(List<Order_Line__c> newOrderLineList1, Set<String> productGroupSet1){
        List<Order_Line__c> newOrderLineList = [select id,name,createdDate,Marketing_Family__c,End_Customer__c,Ship_From_Inventory__c,Product_Group__c 
                                                from order_line__c 
                                                where OwnerId = '0051N000007GUI3QAO' and Ship_From_Inventory__c ='IPH' and createdDate > 2020-09-01T00:01:14.000+0000] ;
        Set<String> productGroupSet = new Set<String>();
        List<Order_Line__c> updatlines = new List<Order_Line__c>();
        for(Order_Line__c line : newOrderLineList){
            productGroupSet.add(line.Product_Group__c);
        }
        Map<String,List<RMA_Serial_Number_Owner__mdt>> medtMap = New Map<String,List<RMA_Serial_Number_Owner__mdt>>();
        Set<String> userEmailSet = New Set<String>();
        Map<String,User> UserEmailObjMap = New Map<String,User>();
        For(RMA_Serial_Number_Owner__mdt mdt :[Select id,Owner__c,End_Customer__c,Marketing_Family__c,Product_Group__c,Location__c 
                                                                        from RMA_Serial_Number_Owner__mdt 
                                                                        where Product_Group__c in:productGroupSet]){
                                                                            IF(medtMap.containskey(mdt.Product_Group__c)){
                                                                                medtMap.get(mdt.Product_Group__c).add(mdt);
                                                                            }
                                                                            else{
                                                                                medtMap.put(mdt.Product_Group__c,New List<RMA_Serial_Number_Owner__mdt>{mdt});
                                                                            } 
                                                                            userEmailSet.add(mdt.Owner__c);                                                   
                                                                        }
        IF(!medtMap.isempty()){
            For(User userObj : [Select id,email from user where email in:userEmailSet and IsActive=True]){
                UserEmailObjMap.put(userObj.email,userObj);
            }
            For(Order_line__c orderlineObj:newOrderLineList){
                System.debug('orderlineObj'+orderlineObj);
                
                IF(medtMap.containskey(orderlineObj.Product_Group__c)){
                    
                    For(RMA_Serial_Number_Owner__mdt metaDataObj: medtMap.get(orderlineObj.Product_Group__c)){
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
                               updatlines.add(orderlineObj);
                           }
                    }
                }
            }
        }
        system.debug('orderlineObj '+updatlines);
    }
    
}