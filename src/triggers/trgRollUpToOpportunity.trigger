trigger trgRollUpToOpportunity on OpportunityLineItem (before insert,after insert, before update,after update, after delete) {
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert)    OpportunityProductHandler.updateBUNOnOpportunityProduct(trigger.New);
        if (Trigger.isUpdate)    OpportunityProductHandler.updateBUNOnOpportunityProduct(trigger.New);
    }  
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert)    OpportunityProductHandler.RollUpBUN(trigger.New);
        if (Trigger.isUpdate)    OpportunityProductHandler.RollUpBUN(trigger.New);
        if(trigger.IsDelete)     OpportunityProductHandler.RollUpBUN(System.trigger.old);
    }    
        
}