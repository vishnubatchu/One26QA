@isTest
public class OpportunityEmailControllerTest {

    @testSetup
    public static void prepareOpportunityTest()
    {
        TestDataUtilityClass.preparetestData();
        
    }
    @isTest
    public static void sendOpportunityEmail()
    {
        OpportunityEmailCustomComponent oppEmail = new OpportunityEmailCustomComponent();
        Opportunity opportunityRecord = [select Id,Name from Opportunity Limit 1];
        oppEmail.currOpportunity =opportunityRecord;
        oppEmail.OpportunityId =opportunityRecord.Id;
        test.startTest();
        oppEmail.getduplicateOpportunities();
        oppEmail.getInstanceurl();
        oppEmail.getOpportunityRecord();
        test.stopTest();
      //  Test.setCurrentPage(ApexPage.);
    }
}