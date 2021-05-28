public class CloneFAFVRecord {
    
    @AuraEnabled
    public static String  getFAFVRecord(String FAFVRecId)
    {
        system.debug('FAFVRecId'+FAFVRecId);
        FA_FV_Analysis__c FAFVAnalysis;
        String FAFVAnalysisqueryfields = String.join(CommonConstants.FAAnalysisFields, ',');
        String FAFVAnalysisquery = 'select '+FAFVAnalysisqueryfields +' FROM FA_FV_Analysis__c WHERE Id =:FAFVRecId';
        List<Steps__c> stepsList;
        List<Failure_Modes__c> failuremodesList;
        String stepsfields =String.join(CommonConstants.StepFields, ',');
        String StepFieldsQuery = 'select '+stepsfields+' FROM Steps__c WHERE FA_FV__c =:FAFVRecId';
        String failuremodefields =String.join(CommonConstants.FailureModes, ',');
        String failuremodequery = 'select '+failuremodefields +' FROM Failure_Modes__c WHERE FAFV_Analysis__c=:FAFVRecId';
         String cloneFAFVName ;
        FA_FV_Analysis__c newFAFVRecord;
        try{
            FAFVAnalysis = Database.query(FAFVAnalysisquery);
            stepsList =Database.query(StepFieldsQuery);
            failuremodesList = Database.query(failuremodequery);
            newFAFVRecord =cloneFAFV(FAFVAnalysis);
            if(newFAFVRecord.Id != NULL)
            {
                System.debug('cloned FAFV Record'+newFAFVRecord.Id);
                cloneSteps(stepsList,newFAFVRecord);
                cloneFailureModes(failuremodesList,newFAFVRecord );
                cloneFAFVName =newFAFVRecord.Name;
            }
                
        }
        catch(QueryException e)
        {
            System.debug('************Query Exception'+e.getLineNumber()+'  '+e.getMessage());
        }
        
      
      if(cloneFAFVName != null)  return newFAFVRecord.Id;
      else return null;
    }
    public static FA_FV_Analysis__c cloneFAFV(FA_FV_Analysis__c oldFAFVRecord)
    {
        
        FA_FV_Analysis__c newFAFVAnalysis = new FA_FV_Analysis__c();
        try{
            
            if(oldFAFVRecord.RecordType.DeveloperName =='FA_Analysis')
            {
              
                newFAFVAnalysis.CA_Required__c =oldFAFVRecord.CA_Required__c;
                newFAFVAnalysis.RecordTypeId = oldFAFVRecord.RecordTypeId;
                newFAFVAnalysis.FA_FV_Status__c ='InProgress';
                newFAFVAnalysis.Site__c = oldFAFVRecord.Site__c;
                newFAFVAnalysis.Name =oldFAFVRecord.Name +'Clone';
                newFAFVAnalysis.FA_Findings__c =oldFAFVRecord.FA_Findings__c;
                newFAFVAnalysis.RC_Analysis__c =oldFAFVRecord.RC_Analysis__c;
                newFAFVAnalysis.Containment__c=oldFAFVRecord.Containment__c;
                newFAFVAnalysis.Failure_Mechanism__c=oldFAFVRecord.Failure_Mechanism__c;
                newFAFVAnalysis.Corrective_Action__c=oldFAFVRecord.Corrective_Action__c;
                newFAFVAnalysis.Conclusion__c=oldFAFVRecord.Conclusion__c;
                newFAFVAnalysis.Risk_Assessment__c =oldFAFVRecord.Risk_Assessment__c;
                
                insert newFAFVAnalysis;
                
            }
            else if(oldFAFVRecord.RecordType.DeveloperName =='FV_Analysis')
            {
                newFAFVAnalysis.RecordTypeId = oldFAFVRecord.RecordTypeId;
                newFAFVAnalysis.FA_FV_Status__c ='InProgress';
                newFAFVAnalysis.Name =oldFAFVRecord.Name +'Clone';
                newFAFVAnalysis.CA_Required__c =oldFAFVRecord.CA_Required__c;
                newFAFVAnalysis.Site__c = oldFAFVRecord.Site__c;
                newFAFVAnalysis.FV_Findings__c =oldFAFVRecord.FV_Findings__c;
                
                newFAFVAnalysis.Temp_BERT__c =oldFAFVRecord.Temp_BERT__c;
                newFAFVAnalysis.Temp_Bert_Comments__c =oldFAFVRecord.Temp_Bert_Comments__c;
                newFAFVAnalysis.VMI__c =oldFAFVRecord.VMI__c;
                newFAFVAnalysis.VMI_Comments__c =oldFAFVRecord.VMI_Comments__c;
                newFAFVAnalysis.Final_Function_Test__c =oldFAFVRecord.Final_Function_Test__c;
                newFAFVAnalysis.Final_Functional_Comments__c =oldFAFVRecord.Final_Functional_Comments__c;
                  insert newFAFVAnalysis;
            }
            
        }
        catch(DMLException e)
        {
            System.debug('**************DML EXCEPTION'+e.getLineNumber()+'   '+e.getStackTraceString());
           
        }
        catch(Exception e)
        {
            System.debug('*********FA ANALYSIS*****DML EXCEPTION'+e.getLineNumber()+'   '+e.getStackTraceString());
            
        }
        return newFAFVAnalysis;
    }
      public static void cloneSteps( List<Steps__c> stepsCloneList,FA_FV_Analysis__c newFAFVAnalysis )
    {
        System.debug('*************Inside Steps**************');
        List<Steps__c> newStepsList= new  List<Steps__c>();
        try{
            for(Steps__c oldstep :stepsCloneList )
            {
                newStepsList.add(new Steps__c(
                  Name =oldstep.Name,
                     FA_FV__c=newFAFVAnalysis.Id,
                   FA_Steps_Description_FA_Steps__c =oldstep.FA_Steps_Description_FA_Steps__c));
            }
            insert newStepsList;
        }
        catch(Exception e)
        {
            System.debug('**************STEPS DML EXCEPTION'+e.getLineNumber()+'   '+e.getStackTraceString());
        }
    }
      public static void cloneFailureModes( List<Failure_Modes__c> failuremodesCloneList,FA_FV_Analysis__c newFAFVAnalysis )
    {
         System.debug('*************Inside Failure Modes**************');
        List<Failure_Modes__c> newfailuremodesList= new  List<Failure_Modes__c>();
        try{
            for(Failure_Modes__c oldfailuremode :failuremodesCloneList )
            {
                newfailuremodesList.add(new Failure_Modes__c(
                  	PDC_Level_1__c =oldfailuremode.PDC_Level_1__c,
                    PDC_Level_2__c =oldfailuremode.PDC_Level_2__c,
                    PIC_Level_1__c =oldfailuremode.PIC_Level_1__c,
                    PIC_Level_2__c =oldfailuremode.PIC_Level_2__c,
                    Site__c =oldfailuremode.Site__c,
                     FAFV_Analysis__c=newFAFVAnalysis.Id,
                    Fault_Specification__c =oldfailuremode.Fault_Specification__c,
                    Component_Description__c =oldfailuremode.Component_Description__c,
                   Traceability_Information__c =oldfailuremode.Traceability_Information__c));
            }
            insert newfailuremodesList;
        }
        catch(Exception e)
        {
            System.debug('**************Failure_Modes__c DML EXCEPTION'+e.getLineNumber()+'   '+e.getStackTraceString());
        }
    }
    
}