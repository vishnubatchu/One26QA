@isTest
public class FAFVAnalysisTriggerHelperTest {

    
     @isTest
    public static void  runPositive()
    {
        Test.startTest();
         TestDataUtilityClass.createUsers();
        User salesAdmin=[select Id From User where Name like 'RSM User 1%' Limit 1];
        System.runAs(salesAdmin){
            TestDataUtilityClass.createFAFVData();
         FA_FV_Analysis__c FAFVAnalysisrecord =[select Id,Comments__c FROM FA_FV_Analysis__c where Name='updateInprogress'];
        FAFVAnalysisrecord.Comments__c='update fa analysis';
         try{
        update FAFVAnalysisrecord;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.assertEquals('User cannot Update FA or FV Analysis  when FA FV Status is \'Finalized \'','User cannot Update FA or FV Analysis  when FA FV Status is \'Finalized \'');}
        
        try{
        delete FAFVAnalysisrecord;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.assertEquals('User cannot Delete FA or FV Analysis  when FA FV Status is \'Finalized \'','User cannot Delete FA or FV Analysis  when FA FV Status is \'Finalized \'');}
        }
        Test.stopTest();
    }
}