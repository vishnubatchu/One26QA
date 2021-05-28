trigger CreateSrNumberFaultCodeonFailureMode on Failure_Modes__c (After Insert,before update, Before Delete) {
    Map<Id,List<FA_FV_Detail__c>> faFvAnalysisandFaFvDetailMap = new Map<Id,List<FA_FV_Detail__c>>();
    Set<Id> analysisIdset = new Set<Id>();
    List<Serial_Number_Fault_Codes__c> SNFClstToinsert = new List<Serial_Number_Fault_Codes__c>();
    List<Serial_Number_Fault_Codes__c> SNFClstToDelete = new List<Serial_Number_Fault_Codes__c>();
    List<FA_FV_Analysis__c> fafvAnalysisList = new List<FA_FV_Analysis__c>();
    if(Trigger.isInsert){
        for(Failure_Modes__c failureMode : Trigger.New){
            if(failureMode.FAFV_Analysis__c!=null){
                analysisIdset.add(failureMode.FAFV_Analysis__c);
            }
        }
        fafvAnalysisList = [Select Id, (Select Id from FA_FV_Details__r) from FA_FV_Analysis__c where Id in:analysisIdset];
        for(FA_FV_Analysis__c fafvAnalysis : fafvAnalysisList){
            if(fafvAnalysis.FA_FV_Details__r!=null && fafvAnalysis.FA_FV_Details__r.size()>0){
                for(FA_FV_Detail__c fafvDetail : fafvAnalysis.FA_FV_Details__r){
                    if(!faFvAnalysisandFaFvDetailMap.containsKey(fafvAnalysis.Id)){
                        faFvAnalysisandFaFvDetailMap.put(fafvAnalysis.Id, new List<FA_FV_Detail__c>());
                        faFvAnalysisandFaFvDetailMap.get(fafvAnalysis.Id).add(fafvDetail);
                    } else {
                        faFvAnalysisandFaFvDetailMap.get(fafvAnalysis.Id).add(fafvDetail);
                    }
                }
            }
        }
        for(Failure_Modes__c failureMode : Trigger.New){
            if(faFvAnalysisandFaFvDetailMap.containsKey(failureMode.FAFV_Analysis__c)){
                for(FA_FV_Detail__c fafvDetail : faFvAnalysisandFaFvDetailMap.get(failureMode.FAFV_Analysis__c)){
                    Serial_Number_Fault_Codes__c snfc = new Serial_Number_Fault_Codes__c();
                    snfc.FA_FV_Detail__c = fafvDetail.Id;
                    snfc.Failure_Modes__c = failureMode.Id;
                    SNFClstToinsert.add(snfc);
                }
            }
        }
        if(SNFClstToinsert!=null && SNFClstToinsert.size()>0){
            insert SNFClstToinsert;
        }
    }
    Profile userprofile = [select Id,Name From Profile where Id =:UserInfo.getProfileId() Limit 1];
    if(Trigger.isUpdate){
         
        if(Trigger.isBefore &&  Label.Profiles.containsIgnoreCase(userprofile.Name)){
             for(Failure_Modes__c failuremode : Trigger.New)
        		{
                    
                    
                    if(failuremode.FAFVStatus__c == 'Finalized')
      		      failuremode.addError('User cannot Delete step when FA FV Status is \'Finalized \'');
                }
        }
    
    }
    if(Trigger.isDelete){
        
       if(Trigger.isBefore)
       {
        List<Failure_Modes__c> deleteFailureModesOpen = new  List<Failure_Modes__c>();
        for(Failure_Modes__c failuremode : Trigger.Old)
        {
        	if(failuremode.FAFVStatus__c == 'InProgress')
       		 		deleteFailureModesOpen.add(failuremode);
	        if(failuremode.FAFVStatus__c == 'Finalized'  &&  Label.Profiles.containsIgnoreCase(userprofile.Name))
      		      failuremode.addError('User cannot Delete step when FA FV Status is \'Finalized \'');
            
        }
          List<Serial_Number_Fault_Codes__c> SNFClstToDelete = [Select Id from Serial_Number_Fault_Codes__c where Failure_Modes__c in:deleteFailureModesOpen];
    		if(SNFClstToDelete != null && SNFClstToDelete.size()>0)
        		delete SNFClstToDelete;
    
    	}
    }
    
}