trigger CreateSrNumberFaultCode on FA_FV_Detail__c (After Insert, Before Delete) {
    Map<Id,List<Failure_Modes__c>> faFvAnalysisandFailureModesMap = new Map<Id,List<Failure_Modes__c>>();
    Set<Id> analysisIdset = new Set<Id>();
    List<Serial_Number_Fault_Codes__c> SNFClstToinsert = new List<Serial_Number_Fault_Codes__c>();
    List<Serial_Number_Fault_Codes__c> SNFClstToDelete = new List<Serial_Number_Fault_Codes__c>();
    List<FA_FV_Analysis__c> fafvAnalysisList = new List<FA_FV_Analysis__c>();
    if(Trigger.isInsert){
        for(FA_FV_Detail__c fafvDetail : Trigger.New){
            if(fafvDetail.FA_FV__c!=null){
                analysisIdset.add(fafvDetail.FA_FV__c);
            }
        }
        fafvAnalysisList = [Select Id, (Select Id from Failure_Modes__r) from FA_FV_Analysis__c where Id in:analysisIdset];
        for(FA_FV_Analysis__c fafvAnalysis : fafvAnalysisList){
            if(fafvAnalysis.Failure_Modes__r!=null && fafvAnalysis.Failure_Modes__r.size()>0){
                for(Failure_Modes__c failuremodes : fafvAnalysis.Failure_Modes__r){
                    if(!faFvAnalysisandFailureModesMap.containsKey(fafvAnalysis.Id)){
                        faFvAnalysisandFailureModesMap.put(fafvAnalysis.Id, new List<Failure_Modes__c>());
                        faFvAnalysisandFailureModesMap.get(fafvAnalysis.Id).add(failuremodes);
                    } else {
                        faFvAnalysisandFailureModesMap.get(fafvAnalysis.Id).add(failuremodes);
                    }
                }
            }
        }
        for(FA_FV_Detail__c fafvDetail : Trigger.New){
            if(faFvAnalysisandFailureModesMap.containsKey(fafvDetail.FA_FV__c)){
                for(Failure_Modes__c failuremodes : faFvAnalysisandFailureModesMap.get(fafvDetail.FA_FV__c)){
                    Serial_Number_Fault_Codes__c snfc = new Serial_Number_Fault_Codes__c();
                    snfc.FA_FV_Detail__c = fafvDetail.Id;
                    snfc.Failure_Modes__c = failuremodes.Id;
                    SNFClstToinsert.add(snfc);
                }
            }
        }
        if(SNFClstToinsert!=null && SNFClstToinsert.size()>0){
            insert SNFClstToinsert;
        }
    }
    if(Trigger.isDelete){
        SNFClstToDelete = [Select Id from Serial_Number_Fault_Codes__c where FA_FV_Detail__c in:Trigger.Old];
        if(SNFClstToDelete!=null && SNFClstToDelete.size()>0){
            delete SNFClstToDelete;
        }
    }
}