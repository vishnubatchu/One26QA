@isTest
private class GlobalParentOwnerBatch_Test {
    @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'One II-VI Sales Rep' LIMIT 1];
        //UserRole faeRole = [SELECT Id FROM UserRole WHERE Name LIKE  '%FAE%' LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        List<User>  testUserList=new List<User>();
        System.RunAs(usr)
        {
            UserRole usrRoleRec=new UserRole(Name= 'FAE'); 
            insert usrRoleRec; 
            
            for(Integer i=0;i<2;i++){
                String orgId = userInfo.getOrganizationId();
                String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                String uniqueName = orgId + dateString + randomInt;
                testUserList.add(new User(firstname = 'Test',
                                          lastName = 'User '+(i+1),
                                          email = uniqueName + '@test' + orgId + '.org',
                                          Username = uniqueName + '@test' + orgId + '.org',
                                          EmailEncodingKey = 'ISO-8859-1',
                                          Alias = uniqueName.substring(18, 23),
                                          TimeZoneSidKey = 'America/Los_Angeles',
                                          LocaleSidKey = 'en_US',
                                          LanguageLocaleKey = 'en_US',
                                          ProfileId = salesUserProfile.Id,
                                          isActive = True,
                                          UserRoleId = usrRoleRec.Id));  
            }
            testUserList.add(new User(LastName='Usrlast1111',ProfileId=[SELECT Id from Profile where Name ='System Administrator'].Id,alias ='trsysy',Legacy_Company__c ='Finisar',
                                      Email='standarduser1@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@finisar.com'));
            insert testUserList;
            //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Change_Account_Ownership'];
            //insert new PermissionSetAssignment(AssigneeId = testUserList[2].id, PermissionSetId = ps.Id);
        }
        List<Account> globalParentAccList=new List<Account>();  
        globalParentAccList.add(new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId(),OwnerId=testUserList[0].Id));
        globalParentAccList.add(new Account(Name='Global Parent Test Acc1',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId(),OwnerId=testUserList[1].Id));
        insert globalParentAccList;  
        List<Account> accList=new List<Account>(); 
        for(Integer i=1;i<=6;i++){
            accList.add(new Account(Name='Test Acc '+i,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),ShippingCity = 'New York', ShippingCountry ='US',
                                    ParentId=globalParentAccList[0].Id,Global_Ultimate_Parent__c=globalParentAccList[0].Id,Status__c='Active',Type='Customer'));
        }  
        accList.add(new Account(Name='Site Test Acc',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                ParentId=globalParentAccList[0].Id,Global_Ultimate_Parent__c=globalParentAccList[0].Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='US',Type='Site',
                                Org_ID__c= '2'));
        insert accList;
        List<Contact> contactList=new List<Contact>();
        Integer index=1;
        for(Integer i=0;i<accList.size()-1;i++){
            contactList.add(new Contact(FirstName='Test ',LastName='Contact '+index,AccountId=accList[i].Id,MailingCountry='United States',Display_Mailing_Country__c='United States'));
            index++;
        }  
        insert contactList;
        List<Opportunity> oppList=new List<Opportunity>();
        index=1;
        for(Integer i=0;i<accList.size()-1;i++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=accList[i].Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+index,StageName='Qualifying',Project_Name__c='Test',RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Aftermarket').getRecordTypeId()));
            index++;
        } 
        insert oppList;
        List<Quote> quoteList=new List<Quote>();
        index=1;
        for(Opportunity eachOpp:oppList){
            quoteList.add(new Quote(OpportunityId=eachOpp.Id,Account__c=eachOpp.AccountId,Name='Test Quote '+index));
            index++;
        }
        insert quoteList;
        List<Order> orderList=new List<Order>();
        index=1;
        for(Opportunity eachOpp:oppList){
            orderList.add(new Order(Legacy_Id__c='12345'+index,OpportunityId=eachOpp.Id,AccountId=eachOpp.AccountId,Name='Test Quote '+index,
                                    EffectiveDate=System.today(),Status='Draft'));
            index++;
        }
        insert orderList;
        List<Order_Line__c> orderLineList=new List<Order_Line__c>();
        //index=1;
        for(Order eachOrder:orderList){
            orderLineList.add(new Order_Line__c(Order__c=eachOrder.Id,Customer_Name__c=eachOrder.AccountId));
            //index++;
        }
        insert orderLineList;
        List<Case> caseList=new List<Case>();
        
        for(Integer i=0;i<accList.size()-1;i++){
            /*caseList.add(new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId(),Failure_Location__c='Dead on Arrival',AccountId=accList[i].Id,
Finisar_Sales_Manager__c=UserInfo.getUserId(),Requested_Service__c='Loaner Return',Billing_Type__c='Others',
Ship_To_Address__c=accList[6].Id,Ship_To_Customer__c=accList[i].Id));*/
            caseList.add(new Case(RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('HY').getRecordTypeId(),Found_By__c='Customer',Part_Numbers_s__c='12345',AccountId=accList[i].Id,
                                  FAE__c=testUserList[0].Id,Subject='Test Case '+i));
        }  
        insert caseList;
    }
    
    @isTest static void testGlobalParentOwnerBatch() {
        User sysAdmin=[Select Id from User where userName='testuser1@finisar.com'];
        User testUser=[Select Id from User where lastName='User 2'];
        Account globalParentAcc=[Select Id from Account where Name='Global Parent Test Acc'];
        globalParentAcc.OwnerId=testUser.Id;
        System.runAs(sysAdmin){
            update globalParentAcc;
        }
        Test.startTest();
        GlobalParentOwner_Batch batchObj = new GlobalParentOwner_Batch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
        List<Contact> cntctList=[Select Id from Contact];
        List<ContactShare> cntctShrList=[Select Id from ContactShare where UserOrGroupId=:testUser.Id and ContactAccessLevel='Read'
                                         and RowCause='Manual' and ContactId in: cntctList];
        
        System.assertEquals(cntctList.size(),cntctShrList.size());
    }
    
    @isTest static void testGlobalParentAccountChange() {
        Account globalParentAcc=[Select Id,OwnerId from Account where Name='Global Parent Test Acc'];
        Account globalParentAcc1=[Select Id,OwnerId from Account where Name='Global Parent Test Acc1'];
        List<Account> accList=[Select Id from Account where RecordType.Name='Customer Account'];
        for(Account eachAcc:accList){
            eachAcc.Changed_Global_Parent_Old_Owner__c=globalParentAcc.OwnerId;
            eachAcc.Global_Ultimate_Parent__c=globalParentAcc1.Id;
        }
        update accList;
        Test.startTest();
        GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(accList, false);
        Test.stopTest();
        List<Contact> cntctList=[Select Id from Contact];
        List<ContactShare> cntctShrList=[Select Id from ContactShare where UserOrGroupId=:globalParentAcc1.OwnerId and ContactAccessLevel='Read'
                                         and RowCause='Manual' and ContactId in: cntctList];
        
        System.assertEquals(cntctList.size(),cntctShrList.size());
    }
    
    @isTest static void testGlobalParentOwnerBatchScheduler() {
        User sysAdmin=[Select Id from User where userName='testuser1@finisar.com'];
        User testUser=[Select Id from User where lastName='User 2'];
        Account globalParentAcc=[Select Id from Account where Name='Global Parent Test Acc'];
        globalParentAcc.OwnerId=testUser.Id;
        System.runAs(sysAdmin){
            update globalParentAcc;
        }
        Test.startTest();
        GlobalParentOwnerBatch_Scheduler schObj = new GlobalParentOwnerBatch_Scheduler();
        Date today=System.today();
        String CRON_EXP ='0 0 0 '+today.day()+' '+today.month()+' ? *'; 
        String jobId = System.schedule('Schedule to update Account Name',CRON_EXP,schObj);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
        
}