trigger OrderItemPLMDashboardTrigger on Order_Line__c (before update,before insert,after insert, after update) {
    if(!AccountTriggerHelper.isAccountupdate){
        List<Order_Line__c> updatedOrderLines = new List<Order_Line__c>();
        If(Trigger.isInsert && Trigger.isAfter){
            OrderItemPLMDashboardTriggerHelper.UpdateOrderPLMDashboardDetails(Trigger.New);
            OrderItemPLMDashboardTriggerHelper.updateOrderWarehouse(trigger.new);
        }
        
        If(Trigger.isUpdate && Trigger.isAfter){
            for(Order_Line__c ol : trigger.new){
                if(ol.Gross_Profit__c != trigger.oldMap.get(ol.id).Gross_Profit__c ||
                   ol.Contribution_Profit__c  != trigger.oldMap.get(ol.id).Contribution_Profit__c ||
                   ol.Revenue__c != trigger.oldMap.get(ol.id).Revenue__c){
                       updatedOrderLines.add(ol);
                   }
            }
            if(updatedOrderLines != null && !updatedOrderLines.isEmpty())
                OrderItemPLMDashboardTriggerHelper.UpdateOrderPLMDashboardDetails(updatedOrderLines);
            OrderItemPLMDashboardTriggerHelper.updateOrderWarehouse(trigger.new);
        }
        
        
        IF((Trigger.isUpdate && Trigger.isBefore)){
            OrderItemPLMDashboardTriggerHelper.updateOwnerAtOrderLinesonUpdate(Trigger.oldMap,Trigger.newMap);
            //OrderItemPLMDashboardTriggerHelper.checkHROCM(trigger.new);
        }
        IF((Trigger.isInsert && Trigger.isBefore)){
            OrderItemPLMDashboardTriggerHelper.insertOwnerAtOrderLinesonUpdate(Trigger.new);
            OrderItemPLMDashboardTriggerHelper.checkHROCM(trigger.new);
        }
    }
}