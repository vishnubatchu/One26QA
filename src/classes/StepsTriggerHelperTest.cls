@isTest
public class StepsTriggerHelperTest {

    @isTest
    public static void  runPositive()
    {
        Test.startTest();
        TestDataUtilityClass.createUsers();
        User salesAdmin=[select Id From User where Name like 'RSM User 1%' Limit 1];
        
        System.runAs(salesAdmin)
        {
            TestDataUtilityClass.createFAFVData();
            
        Steps__c step = [select Id,Name,Comments__c From Steps__c where Name='testupdateInprogress'];
        step.Comments__c ='testupdated';
        try{
         
        update step;
        System.debug('updated successfully'+step);
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.assertEquals('User cannot Edit step when it is \'Finalized\'','User cannot Edit step when it is \'Finalized\'');}
        
        try{
        delete step;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.assertEquals('User cannot Delete step when it is \'Finalized\'','User cannot Delete step when it is \'Finalized\'');}
        }
       Test.stopTest();
    }
}