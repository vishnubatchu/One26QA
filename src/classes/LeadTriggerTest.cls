/**
 * Name : LeadTriggerTest
 * Description : test class for LeadTrigger
**/
@isTest(seeAllData = false)
private class LeadTriggerTest {
    @isTest
    static void testLeadTrigger(){
        Lead newLd  = new Lead();
        newLd.LastName = 'Lastname';
        newLd.FirstName = 'Leadf';
        newLd.Email = 'Lastname.Leadf@lead.com';
        newLd.Display_ISO_Country__c = 'United States';
        newLd.Company = 'ii-vi';
        newLd.Country = 'US';
        test.startTest();
        insert newLd;
        test.stopTest();
        Lead ld =[SELECT Id, IndividualId FROM Lead LIMIT 1];
        system.assert(ld.IndividualId != null, 'Individual recors mapped with Lead');
    }
    @isTest
    static void testDeleteLeadTrigger(){
        Lead newLd  = new Lead();
        newLd.LastName = 'Lastname';
        newLd.FirstName = 'Leadf';
        newLd.Email = 'Lastname.Leadf@lead.com';
        newLd.Display_ISO_Country__c = 'United States';
        newLd.Company = 'ii-vi';
        insert newLd;
        test.startTest();
        Delete newLd;
        test.stopTest();
        List<Lead> ld =[SELECT Id, IndividualId FROM Lead LIMIT 1];
        system.assert(ld.isEmpty(), 'Deleted lead');
    }
}