public with sharing class FAFVAnalysisTriggerHelper {

     public static void beforeUpdate(List<FA_FV_Analysis__c> newFAFVlist,Map<Id,FA_FV_Analysis__c> oldFAFVMap)
    {
        
            for(FA_FV_Analysis__c newFAFVAnalysis : newFAFVlist)
            {
                FA_FV_Analysis__c oldFAFVAnalysis = oldFAFVMap.get(newFAFVAnalysis.id);
                if(oldFAFVAnalysis.FA_FV_Status__c == newFAFVAnalysis.FA_FV_Status__c &&  newFAFVAnalysis.FA_FV_Status__c == 'Finalized'  )
                {
                    newFAFVAnalysis.addError('User cannot Update FA or FV Analysis  when FA FV Status is \'Finalized \'');
                }
                if(oldFAFVAnalysis.FA_FV_Status__c != newFAFVAnalysis.FA_FV_Status__c &&  oldFAFVAnalysis.FA_FV_Status__c == 'Finalized'  )
                {
                    newFAFVAnalysis.addError('User cannot Update FA or FV Analysis  when FA FV Status is \'Finalized \'');
                }
            }
    }
     public static void beforeDelete(List<FA_FV_Analysis__c> oldFAFVlist)
    {
        for(FA_FV_Analysis__c oldFAFVAnalysis : oldFAFVlist)
            {
                
                if(oldFAFVAnalysis.FA_FV_Status__c == 'Finalized' )
                {
                    oldFAFVAnalysis.addError('User cannot Delete FA or FV Analysis  when FA FV Status is \'Finalized \'');
                }
            }
    }
    
}