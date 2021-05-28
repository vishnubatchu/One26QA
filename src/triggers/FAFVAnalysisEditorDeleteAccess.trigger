trigger FAFVAnalysisEditorDeleteAccess on FA_FV_Analysis__c (before update,before delete) {
    
    
    
    
    
    if(Trigger.isBefore )
    {
        Profile userprofile = [select Id,Name From Profile where Id =:UserInfo.getProfileId() Limit 1];
        if(Trigger.isUpdate &&  !Label.Profiles.containsIgnoreCase(userprofile.Name))
        {
            
            FAFVAnalysisTriggerHelper.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        
        
        
        if(Trigger.isDelete && !Label.Profiles.containsIgnoreCase(userprofile.Name) ) 
        {
            
           FAFVAnalysisTriggerHelper.beforeDelete(Trigger.old);
        }
        
    }
    
}