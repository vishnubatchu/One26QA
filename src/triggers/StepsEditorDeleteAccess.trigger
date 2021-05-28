trigger StepsEditorDeleteAccess on Steps__c (before update,before delete) {
    
    
    
    if(Trigger.isBefore)
    {
         Profile userprofile = [select Id,Name From Profile where Id =:UserInfo.getProfileId() Limit 1];
        if(Trigger.isUpdate &&   !Label.Profiles.containsIgnoreCase(userprofile.Name))
        {
           
            StepsTriggerHelper.beforeUpdate(Trigger.new,Trigger.old);
        }
        if(Trigger.isDelete && !Label.Profiles.containsIgnoreCase(userprofile.Name) )
        {
            StepsTriggerHelper.beforeDelete(Trigger.old);
        }
        
    }
}