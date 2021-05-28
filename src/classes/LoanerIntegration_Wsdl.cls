public class LoanerIntegration_Wsdl {
    
    public Class LoanerParameter 
    {
        @InvocableVariable(label='loanerId' required='true')
        public String loanerId;
        @InvocableVariable(label='LoanerName' required='true')
        public String LoanerName;
    }
    
    @InvocableMethod(label='LoanerService' description='Call Webservice From in This Class')
    public static  List<String> invokeService(List<LoanerParameter> LoanerParameters)
    {	
        List<String> errormessages = new List<String>();
        System.debug('Inside invokeMethod');
        LoanerIntegration_Wsdl loanerintegrationwsdl = new LoanerIntegration_Wsdl();
        for( LoanerParameter  LP : LoanerParameters)
        { System.debug('  '+LP);
         errormessages.add(sendRequesttoInformatica(LP.loanerId));}
        System.debug(errormessages);
        return errormessages;
        
    }
    public static String  sendRequesttoInformatica(String loanerid)
    {	
        try{
            servicesInformaticaComRtPrcCaiLoan LoanerRequestInf = new servicesInformaticaComRtPrcCaiLoan();
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_main_Service Loanerservicesend = new  servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_main_Service();
            
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element response =Loanerservicesend.Prc_cai_loaner_main(loanerid);
            
            String validation = validateRecords(loanerid);
            if(!String.isEmpty(validation) && response.error_message != null )
            {
                
                return  validation  + response.error_message ;
            }
             if(String.isEmpty(validation) && response.error_message != null )
            {
                
                return  response.error_message ;
            }
            if(!String.isEmpty(validation))
            {
                 return  validation;
            }
              
            return 'Validation Successfull';
            
        }
        catch(Exception e)
        {
            System.debug(' Exception Occurred '+e.getMessage() +' Line Number '+e.getLineNumber());
            return e.getMessage();
        }
    }
    
    public static String validateRecords(String recordId){
        sobject loanerObj = RecordApprovalDao.getHeaderRecord(recordId);
        for(String fieldName : CommonConstants.LoanerRequiredFields){
            If(loanerObj.get(fieldName)==Null){
                   String LoanerOpportunityType =(String) loanerObj.get('Opportunity_Type__c');
                  if(fieldName.equalsIgnoreCase('Opportunity__c') && LoanerOpportunityType.equalsIgnoreCase('New Opportunity'))
                  {
                      String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                       return ' Required Field '+fieldlabel+ ' Must be Filled As Opportunity Type is ' +loanerObj.get('Opportunity_Type__c');
                  }
                 else if(!fieldName.equalsIgnoreCase('Opportunity__c'))
                 { 
                	String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                     return ' Required Field '+fieldlabel+ ' Must be Filled';
                 }
            }
        }
        
        if(loanerObj.getSObjects('Loaner_Lines__r')!=Null){
            System.debug(loanerObj);
            for(sobject sobj:loanerObj.getSObjects('Loaner_Lines__r')){
                For(String fieldName :CommonConstants.LoanerLineRequiredFields){
                    If(sobj.get(fieldName)==NULL){
                        String fieldlabel = Schema.getGlobalDescribe().get('Loaner_Line__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                        
                        return ' Required Field '+fieldlabel+ ' Must be Filled For Line Item '+loanerObj.get('Name');
                    } 
                }
            }
        }
        return '';
    }
}