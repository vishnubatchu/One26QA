public with sharing class OrderRatePlan_Controller {
    public List<OrderRatePlan__c> orderTier{get; set;}
    public Order_Line__c orLine{get; set;}
    public OrderRatePlan_Controller(ApexPages.StandardController controller) {
        if(!test.isRunningTest())
            controller.addFields(New List<String> {'TotalPrice__c', 'Quantity__c'});
        orLine = (Order_Line__c)controller.getRecord();
        system.debug('oppline id '+orLine.Id);
        List<OrderRatePlan__c> plans = [SELECT Id, OrderProduct__c, SalesPrice__c, SequenceNumber__c, LeadTime__c
                                        FROM OrderRatePlan__c 
                                        WHERE OrderProduct__c = :orLine.Id ORDER BY SequenceNumber__c asc];
        if(plans != null && !plans.isEmpty()){
            orderTier = plans;
        } else {
            orderTier = new List<OrderRatePlan__c>();
            OrderRatePlan__c rate = new OrderRatePlan__c();
            orderTier .add(rate);
        }
    }
    public pageReference addNewRow(){
        OrderRatePlan__c rate = new OrderRatePlan__c();
        orderTier.add(rate);
        return null;
    }
    public pageReference saveAction(){
        List<OrderRatePlan__c> plans = new List<OrderRatePlan__c>();
        for(OrderRatePlan__c plan : orderTier ){
            if(plan.SequenceNumber__c != null && plan.SalesPrice__c !=0){
                plan.OrderProduct__c = orline.Id;
                plans.add(plan);
                if(plan.SequenceNumber__c < orLine.Quantity__c){
                    orLine.TotalPrice__c = plan.SalesPrice__c;
                }
            }
        }
        if(plans != null && !plans.isEmpty()){
            upsert plans;
            update orLine;
        }
        return new pageReference('/'+orLine.Id);
    }
    public pageReference CancelAction(){
        return new pageReference('/'+orLine.Id);
    }
    
}