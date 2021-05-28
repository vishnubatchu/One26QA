@isTest(seeAllData = false)
private class LoanerLineTriggerTest {
    @isTest
    static void testLoanerLineTrigger(){
        // Loaner__c loaner = new Loaner__c();
        TestDataUtilityClass.preparetestData();
        Loaner_Line__c line = [SELECT id FROM Loaner_Line__c Limit 1];
        test.startTest();
        delete line;
        test.stopTest();
    }
}