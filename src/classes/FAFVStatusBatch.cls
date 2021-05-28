public class FAFVStatusBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext jobcontext)
    {
        
        String FAFVDetail ='select Id,Status__c,FA_FV__r.FA_FV_Status__c,Serial_Number__c ,Serial_Number__r.Status__c from FA_FV_Detail__c';
        return Database.getQueryLocator(FAFVDetail);
		        
    }
	public void execute(Database.BatchableContext jobcontext, List<FA_FV_Detail__c> FAFVDetails)
    {
        
         List<FA_FV_Detail__c> updatedFAFVDetail = new  List<FA_FV_Detail__c>();
        List<FA_FV_Detail__c> updatedFAFVDetailForFAFVFinalized = new  List<FA_FV_Detail__c>();
        try{
           
        for( FA_FV_Detail__c FAFVDetailRecord:FAFVDetails )
        {
         	if(FAFVDetailRecord.Serial_Number__r.Status__c =='Closed' && FAFVDetailRecord.Status__c=='In Progress')
            {
                FAFVDetailRecord.Status__c ='Complete';
                updatedFAFVDetail.add(FAFVDetailRecord);
            }
            else if(FAFVDetailRecord.FA_FV__r.FA_FV_Status__c =='Finalized' && FAFVDetailRecord.Status__c=='In Progress')
            {
                FAFVDetailRecord.Status__c ='Complete';
                updatedFAFVDetailForFAFVFinalized.add(FAFVDetailRecord);
            }
            
            
        }
      
		if(updatedFAFVDetail.size()>0)
            Database.update(updatedFAFVDetail);
        if(updatedFAFVDetailForFAFVFinalized.size()>0)
			Database.update(updatedFAFVDetailForFAFVFinalized);
        }
        catch(Exception e)
        {
            System.debug('  '+e.getMessage());
        }
        
        
        
       
        
        
    }
    public void finish(Database.BatchableContext jobcontext)
    {
        
    }
}