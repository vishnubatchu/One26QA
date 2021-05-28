@isTest
private class ConversionDetailsHelperTest {
    
    @testsetup 
    static void preparetestdata()
    {
        TestDataUtilityClass.preparetestData();
        
    }
    static testmethod void performNegativetestScenarios()
    {
        Test.startTest();
        Conversion_Details__c cd= new Conversion_Details__c();
        cd.Conversion_Date__c=System.today() + 10;
        
        Loaner__c loaner = [select Id From Loaner__c where Project_Name__c ='Test' Limit 1];
        Loaner_Line__c loanerline = [select Id From Loaner_Line__c where Loaner__c =:loaner.Id Limit 1];
        Return_Detail__c returnDet = [select Id From Return_Detail__c where Loaner_Line__c =:loanerline.Id Limit 1];
        Disposition_Transfer_Details__c dtdetail = [select Id,Quantity__c From Disposition_Transfer_Details__c where Return_Detail__c =:returnDet.Id];
        cd.Disposition_Transfer_Detail__c = dtdetail.Id;
        cd.Conversion_Qty__c =6;
        
        try{
            insert cd;
            
        }
        catch(Exception e)
        {
            
            SYSTEM.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Disposition Quantity5should be greater or equal to  Conversion Qty 6: []', E.getMessage());
            
        }
        Conversion_Details__c cd1= new Conversion_Details__c();
        cd1.Conversion_Date__c=System.today() + 10;
        cd1.Disposition_Transfer_Detail__c = dtdetail.Id;
        cd1.Conversion_Qty__c =5;
        insert cd1;
        cd1.Conversion_Qty__c = 4;
        try{
            update cd1;
        }
        catch(Exception e)
        {
            System.assertEquals('Update failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,Disposition Quantity should be greater than Conversion Qty', e.getMessage());
        }
        Test.stopTest();
        
    }
    
    static testmethod void performPostiveTestScenarios()
    {
        Test.startTest();
        
        Conversion_Details__c cd= new Conversion_Details__c();
        cd.Conversion_Date__c=System.today() + 10;
        
        Loaner__c loaner = [select Id From Loaner__c where Project_Name__c ='Test' Limit 1];
        Loaner_Line__c loanerline = [select Id From Loaner_Line__c where Loaner__c =:loaner.Id Limit 1];
        Return_Detail__c returnDet = [select Id From Return_Detail__c where Loaner_Line__c =:loanerline.Id Limit 1];
        Disposition_Transfer_Details__c dtdetail = [select Id From Disposition_Transfer_Details__c where Return_Detail__c =:returnDet.Id];
        cd.Disposition_Transfer_Detail__c = dtdetail.Id;
        cd.Conversion_Qty__c =5;
        insert cd;
        
        Conversion_Details__c cd1 =[select Id ,Conversion_Qty__c from Conversion_Details__c where Disposition_Transfer_Detail__c =:dtdetail.Id];
        cd1.Conversion_Qty__c =4;
        update cd1;
        Conversion_Details__c cd2 =[select Id ,Conversion_Qty__c from Conversion_Details__c where Disposition_Transfer_Detail__c =:dtdetail.Id];
        cd1.Conversion_Qty__c =5;
        update cd2;
        Test.stopTest();
    }
}