@isTest(seeAllData = false)
private class PartnerAccountGroupCreationBatchTest {
    testMethod static void testbatch(){
       // List<Account> accList = TestDataUtilityClass.createAccounts();
          Account Parentacc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert Parentacc;
        List<Account> acList = new List<Account>();
        for(Integer i=0; i<10; i++){
            Account acc1 = new Account(name='AccountTopLevelTest'+i, Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                       Status__c='Active',
                                       Type='Customer',parentId=Parentacc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                       RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId(),
                                       Legacy_Id__c = 'TestLega'+i );
            acList.add(acc1);
        }
        insert acList;
        List<Contact> conList = new List<Contact>();
        for(Account acc :acList){
            contact con = new contact(LastName = acc.Name, accountId= acc.Id, Email ='testcon@test.com',MailingCountry='United States',Display_Mailing_Country__c='United States');
            conList.add(con);
        }
        insert conList;
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Finisar Partner Community User' LIMIT 1];
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        List<user> userList = new List<User>();
        for(contact con1 : conList){
          User tuser = new User(lastName = con1.LastName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username =  con1.LastName+ '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = salesUserProfile.Id,
                              isActive = True,
                              ContactId = con1.Id);
            userList.add(tuser);
        }
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert userList;
        }
        test.startTest();
        PartnerAccountGroupCreationBatch bat = new PartnerAccountGroupCreationBatch();
        database.executeBatch(bat);
        test.stopTest();
    }
}