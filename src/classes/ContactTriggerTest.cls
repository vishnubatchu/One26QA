@istest(seeAllData = false)
private class ContactTriggerTest {
@isTest
    static void testContactTrigger(){
        Contact newCon  = new Contact();
        newCon.LastName = 'Lastcon';
        newCon.FirstName = 'conf';
        newCon.Email = 'Lastname.conf@con.com';
        newCon.Display_Mailing_Country__c = 'United States';
        newCon.MailingCountry = 'US';
        test.startTest();
        insert newCon;
        test.stopTest();
       // Contact con =[SELECT Id, IndividualId FROM Contact LIMIT 1];
       // system.assert(con.IndividualId != null, 'Individual recors mapped with Contact');
    }
    @isTest
    static void testDeletecontactTrigger(){
        Contact newCon  = new Contact();
        newCon.LastName = 'Lastcon';
        newCon.FirstName = 'conf';
        newCon.Email = 'Lastname.conf@con.com';
        newCon.Display_Mailing_Country__c = 'United States';
        newCon.MailingCountry = 'US';
        insert newCon;
        test.startTest();
        Delete newCon;
        test.stopTest();
        List<Contact> con =[SELECT Id, IndividualId FROM Contact LIMIT 1];
        system.assert(con.isEmpty(), 'Deleted Contact');
    }
}