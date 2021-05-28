public with sharing class AddRatePlanController {
    public List<OpportunityRatePlan__c> ratePlans {get; set;}
    public OpportunityLineItem oppLine{get; set;}
    public AddRatePlanController(ApexPages.StandardController controller) {
        if(!test.isRunningTest()){
            controller.addFields(New List<String> {'UnitPrice', 'Quantity'});
        }
        oppLine = (OpportunityLineItem)controller.getRecord();
        List<OpportunityRatePlan__c> plans = [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, Description__c,LeadTime__c
                                              FROM OpportunityRatePlan__c 
                                              WHERE OpportunityLineItem__c = :oppLine.Id ORDER BY SequenceNumber__c asc];
        if(plans != null && !plans.isEmpty()){
            ratePlans = plans;
        } else {
            ratePlans = new List<OpportunityRatePlan__c>();
            OpportunityRatePlan__c rate = new OpportunityRatePlan__c();
            ratePlans .add(rate);
        }
        
    }
    public pageReference addNewRow(){
        OpportunityRatePlan__c rate = new OpportunityRatePlan__c();
        ratePlans .add(rate);
        return null;
    }
    public pageReference saveAction(){
        List<OpportunityRatePlan__c> plans = new List<OpportunityRatePlan__c>();
        List<OpportunityRatePlan__c> deletePlans = new List<OpportunityRatePlan__c>();
        for(OpportunityRatePlan__c plan : ratePlans ){
            system.debug('plan'+plan);
            if(plan.SequenceNumber__c != null && (plan.SalesPrice__c ==0 || plan.SalesPrice__c == null)){
                apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Sales price should be Provided'));
                return null;
            }
            if(plan.SequenceNumber__c != null && plan.SalesPrice__c !=0){
                plan.OpportunityLineItem__c = oppline.Id;
                plans.add(plan);
                if(plan.SequenceNumber__c < oppLine.Quantity){
                    oppLine.UnitPrice = plan.SalesPrice__c;
                }
            } else {
                if(plan.Id != null)
                    deletePlans.add(plan);
            }
        }
        if(plans != null && !plans.isEmpty()){
            upsert plans;
            update oppLine;
        }
        if(deletePlans != null && !deletePlans.isEmpty()){
            delete deletePlans;
        }
        return new pageReference('/'+oppLine.Id);
    }
    public pageReference CancelAction(){
        return new pageReference('/'+oppLine.Id);
    }
}