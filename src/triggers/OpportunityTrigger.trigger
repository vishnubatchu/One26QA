trigger OpportunityTrigger on Opportunity (before update , before insert , after update , after insert) {
     if(trigger.isUpdate && trigger.isAfter){
         //Commented the below code since Order creation logic is moved to flow.
        /*if(!OpportunityTriggerHelper.orderCreated)
            OpportunityTriggerHelper.createOrderonClosedOpps(trigger.oldMap, trigger.new);*/
    }
     Opportunity_Handler handler = new Opportunity_Handler(); 
     if(Trigger.isBefore && Trigger.isUpdate) 
    {
        handler.beforeUpdate(trigger.new);        
    }
/**  commented  by Akhilesh     
for(opportunity o : trigger.new)
{
    list<Opportunity> rec = new list<Opportunity>();
    {
        rec.add(o);
    }
                
    Opportunity_Handler handler = new Opportunity_Handler(); 
    
    if(Trigger.isBefore && Trigger.isUpdate) 
    {
        handler.beforeUpdate(rec);        
    }
}
 **/           
}