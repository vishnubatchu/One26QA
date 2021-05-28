public class ordersBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC ){
        if(!Test.isRunningTest()){
            return Database.getQueryLocator([select id,Warehouse__c from order where Warehouse__c = null  ]);  
        } else {
            return Database.getQueryLocator([select id,Warehouse__c from order where Warehouse__c = null AND recordtype.developername='PoS_Order' LIMIT 200]);
        }
        
    }
    public void execute(Database.BatchableContext BC, List<Order> scope) {
        List<Order> orderList = new List<Order>();
        Set<Id> hrOCM = New Set<Id>();
        List<Order_Line__c> orderLineList = new List<Order_Line__c>();
        Map<String, String> orderWarehouseMap = new Map<String, String>();
        for(Order_Line__c line : [SELECT Id, order__c, Ship_From_Inventory__c, Part_Number__r.Product_Family__c 
                                  FROM Order_Line__c 
                                  WHERE order__c IN :scope]){
                                      if(!orderWarehouseMap.containsKey(line.Order__c)){
                                          orderWarehouseMap.put(line.Order__c, line.Ship_From_Inventory__c);
                                      } else if(orderWarehouseMap.get(line.Order__c) != 'SYD'){
                                          orderWarehouseMap.put(line.Order__c, line.Ship_From_Inventory__c);
                                      }
                                      if(line.Ship_From_Inventory__c == 'WXI' && (
                                          line.Part_Number__r.Product_Family__c =='WSS-OCM' ||
                                          line.Part_Number__r.Product_Family__c =='WSS-OIG')){
                                              line.HROCM_Line__c = true;
                                              hrOCM.add(line.Order__c);
                                              orderLineList.add(line);
                                          }
                                  }
        for(Order ord : scope){
            ord.Warehouse__c = orderWarehouseMap.get(ord.Id);
            if(hrOCM.contains(ord.Id)){
                ord.HROCM_Order__c = true;
            }
            orderList.add(ord);
        }
        update orderList;
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}