@isTest
private class AccountTrigger_Test {
    @testSetup static void setup() {
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        List<User> testUserList=new List<User>();
        System.runAs(usr){
            testUserList.add(new User(LastName='Usrlast1111',ProfileId=[SELECT Id from Profile where Name ='System Administrator'].Id,alias ='trsysy',Legacy_Company__c ='Finisar',
                                      Email='standarduser12@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser12@finisar.com'));
            testUserList.add(new User(LastName='Usrlast11111',ProfileId=[SELECT Id from Profile where Name ='Sales Profile Clone'].Id,alias ='salespro',Legacy_Company__c ='Finisar',
                                      Email='salesuser123@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testsalesuser1@finisar.com'));
            insert testUserList;
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Change_Account_Ownership'];
            insert new PermissionSetAssignment(AssigneeId = testUserList[0].id, PermissionSetId = ps.Id);
        }
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId(),OwnerId=testUserList[0].Id);
        insert globalParentAcc;
        List<Account> accList=new List<Account>(); 
        for(Integer i=1;i<=6;i++){
            accList.add(new Account(Name='Test Acc '+i,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),ShippingCity = 'New York', ShippingCountry ='US',
                                    Global_Ultimate_Parent__c=globalParentAcc.Id,Status__c='Active',Type='Customer'));
        }
        accList.add(new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(), 
                                   Name = 'Test site 1', 
                                   ParentId = globalParentAcc.Id,
                                   Global_Ultimate_Parent__c=globalParentAcc.Id,
                                   ShippingState = 'NY',
                                   ShippingCity = 'Test City',
                                   ShippingCountry = 'IND',
                                   ShippingPostalCode = '560100',
                                   ShippingStreet = 'Test Street',
                                   Type = 'Site',
                                   AR_Amount__c = 0,
                                   Site_Use_Code__c='BILL_TO',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States'
                                  ));
   		insert accList;
    }
    
    @isTest static void testARAmountRollup() {
        Test.startTest();
        Account siteAcc=[Select Id from Account where Name='Test site 1'];
        siteAcc.Type = 'Customer';
        siteAcc.AR_Amount__c = 1;
        update siteAcc;  
        Test.stopTest();
    }
    
    @isTest static void testGlblPrntOwnerChange() {
        Test.startTest();
        User sysAdmin=[Select Id from User where userName='testuser12@finisar.com'];
        User salesUser=[Select Id from User where userName='testsalesuser1@finisar.com'];
        Account globalParentAcc=[Select Id from Account where Name='Global Parent Test Acc'];
        System.runAs(sysAdmin){
            globalParentAcc.OwnerId=salesUser.Id;
            update globalParentAcc;
        }
        Account upatedGlobalParentAcc=[Select Id,Global_Parent_Previous_Owner__c from Account where Name='Global Parent Test Acc'];
        System.assertEquals(sysAdmin.Id, upatedGlobalParentAcc.Global_Parent_Previous_Owner__c);
        Test.stopTest();
    }
}