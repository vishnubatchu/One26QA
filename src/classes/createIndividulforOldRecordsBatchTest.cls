@isTest(seeAllData = false)
private class createIndividulforOldRecordsBatchTest {
    @testSetup static void methodName() {
        Lead newLd  = new Lead();
        newLd.LastName = 'Lastname';
        newLd.FirstName = 'Leadf';
        newLd.Email = 'Lastname.Leadf@lead.com';
        newLd.Display_ISO_Country__c = 'United States';
        newLd.Company = 'ii-vi';
        newLd.Country = 'US';
        insert newLd;
    }
    static testmethod void contactForGDPRtest() { 
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id, Display_Billing_Country__c ='United States',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc;
        Account acc1 = new Account(ParentId = globalParentAcc.Id,name='Account1 ', Display_Billing_Country__c ='United States',
                                   billingcity='New York test', billingcountry='USA',Status__c='Active',Type='Party',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc1;
        List<Contact> conlist = new List<Contact>(); 
        Contact c = new Contact(FirstName = 'Test',LastName = 'Contact',Display_Mailing_Country__c='United States',AccountId = acc.Id,MailingCountry='United States',Email='rest@vv.com');
        conlist.add(c); 
        insert conlist;
        c.IndividualId = null;
        update c;
        Test.startTest();
        createIndividulforOldRecordsBatch bat = new createIndividulforOldRecordsBatch(null, false);
        database.executeBatch(bat);
        Test.stopTest();
    }
    @isTest
    static void testLeadTrigger(){
        Lead newLd  = [select id, IndividualId from Lead limit 1];
        newLd.IndividualId = null;
        update newLd;
        system.debug('newLd'+newLd.IndividualId);
        delete [Select id from Individual];
        
        String leadQuery = 'SELECT Id, Name,FirstName, LastName, Email,IndividualId, Display_ISO_Country__c FROM Lead WHERE IndividualId = null ';
        test.startTest();
        List<lead> ldl = [SELECT Id, Name,FirstName, LastName, Email,IndividualId, Display_ISO_Country__c FROM Lead WHERE IndividualId = null];
        system.debug('ld'+ldl);
        createIndividulforOldRecordsBatch bat = new createIndividulforOldRecordsBatch(null, false);
        database.executeBatch(bat);
        test.stopTest();
        Lead ld =[SELECT Id, IndividualId FROM Lead LIMIT 1];
        system.assert(ld.IndividualId != null, 'Individual recors mapped with Lead');
    }
}