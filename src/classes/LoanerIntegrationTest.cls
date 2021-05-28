@isTest
private class LoanerIntegrationTest {
    
    @isTest 
    static void testValidateLoanerCallout()
    {
        TestDataUtilityClass.preparetestData();
        List<Loaner__c> loaners  = [select Id,Name,Opportunity_Type__c,Opportunity__c,Est_Production_Date__c ,(select Id,Product__c,Name,Est_Annual_Qty__c From Loaner_Lines__r ) From Loaner__c where  Opportunity_Type__c='New Opportunity - < 100K SAM' Limit 1];
        Test.setMock(WebServiceMock.class, new LoanerIntegrationMockResponse());
        LoanerIntegration_Wsdl.LoanerParameter loanerparameter = new LoanerIntegration_Wsdl.LoanerParameter();
        loanerparameter.loanerId =loaners[0].Id;
        List<LoanerIntegration_Wsdl.LoanerParameter> loanerparameters = new   List<LoanerIntegration_Wsdl.LoanerParameter> ();
        loanerparameters.add(loanerparameter);
        List<String> errormessages = LoanerIntegration_Wsdl.invokeService(loanerparameters);
        
        for(String msg:errormessages )
        {
            System.assertEquals('You have uncommitted work pending. Please commit or rollback before calling out' ,msg);
        }
        
        
    }
    @isTest 
    static void testValidateRecords()
    {
        
        TestDataUtilityClass.preparetestData();
        Test.startTest();
        Loaner__c loaner1  = [select Id,Name,Opportunity_Type__c,Opportunity__c,Est_Production_Date__c ,(select Id,Product__c,Name,Est_Annual_Qty__c From Loaner_Lines__r ) From Loaner__c where  Opportunity_Type__c='New Opportunity - < 100K SAM' Limit 1]; 
        String actualmsg1=LoanerIntegration_Wsdl.validateRecords(loaner1.Id);
        String expectedmsg1= 'Required Field '+'Est Annual Qty'+' Must be Filled For Line Item '+loaner1.get('Name');
        
        
        
        Loaner__c loaner2  = [select Id,Opportunity__c,Est_Production_Date__c,Opportunity_Type__c,Address_ship_to__c,(select Id,Product__c,Name,Loaner_Qty__c,Est_Annual_Qty__c,Loaner_Price_100_999_column_price__c From Loaner_Lines__r )  From Loaner__c where Project_Name__c ='Test2Invaliddata' and Opportunity_Type__c='New Opportunity' and  Status_Approval__c ='Draft']; 
        String actualmsg2=LoanerIntegration_Wsdl.validateRecords(loaner2.Id);
        String expectedmsg2='Required Field Est Production Date Must be Filled';
        
        
        Loaner__c loaner3  = [select Id,Opportunity__c,Est_Production_Date__c,Opportunity_Type__c,Address_ship_to__c,(select Id,Product__c,Name,Loaner_Qty__c,Est_Annual_Qty__c,Loaner_Price_100_999_column_price__c From Loaner_Lines__r )  From Loaner__c where Project_Name__c ='Test2OpportunityTest' and Opportunity_Type__c='New Opportunity' and  Status_Approval__c ='Draft']; 
        String actualmsg3=LoanerIntegration_Wsdl.validateRecords(loaner3.Id);
        
        
        Test.stopTest();
        
        
    }
}