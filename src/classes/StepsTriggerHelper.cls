public with sharing class StepsTriggerHelper {

    public static void beforeUpdate(List<Steps__c> newsteplist,List<Steps__c> oldstepslist)
    {
        for(Steps__c step : newsteplist)
            {
                if(step.FAFVStatus__c =='Finalized')
                {
                    
                    step.addError('User cannot Edit step when it is \'Finalized\'');
                }
            }
    }
    
    public static void beforeDelete(List<Steps__c> oldstepslist)
    {
        for(Steps__c oldstep : oldstepslist)
            {
                if(oldstep.FAFVStatus__c =='Finalized' )
                {
                    
                    oldstep.addError('User cannot Delete step when FA FV Status is \'Finalized \'');
                }
            }
    }
    
}