/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This test class is for "UpdateGlobalUltimateParentBatch" and UpdateGlobalUltimateParentBatchHelper  
*/
@isTest
public class UpdateGlobalUltimateParentBatchTest {
    @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile Clone' LIMIT 1];
        List<User>  testUserList=new List<User>();
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
                                      UserRoleId = null));  
        }
        insert testUserList;
        //Create Global Account
        list<Account> globalParentList = new list<Account>();
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id	);
        globalParentList.add(globalParentAcc);
        Account globalParentAcc2=new Account(Name='Global Parent Test Acc2',shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
        globalParentList.add(globalParentAcc2);
        insert globalParentList;
        //Create Customer Account
        Account customerAccount = new Account(Name='customerAcc',ParentId = globalParentList[1].Id,Global_Ultimate_Parent__c=globalParentList[0].Id,shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                              Status__c='Active'); 
        insert customerAccount;
        //Create Site Account
        Account siteAccount=new Account(Name='siteAcc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId(),
                                        Site_Use_Code__c='SHIP_TO',Status__c='Active',ParentId = customerAccount.Id,
                                        Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Site',
                                        Org_ID__c= '2');
        insert siteAccount;
        //Create Contact
        List<Contact> contactList=new List<Contact>();
        for(integer i = 0 ; i < 5 ; i++){
            contactList.add(new Contact(LastName='Test Contact '+i,FirstName = 'test',Display_Mailing_Country__c='United States',MailingCountry='United States',AccountId=customerAccount.Id));
        }  
        insert contactList;
        //Create Opportunity
        List<Opportunity> oppList=new List<Opportunity>();
        for(integer i = 0 ; i < 5 ; i++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=customerAccount.Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+i,StageName='Qualifying',Project_Name__c='Test',RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Aftermarket').getRecordTypeId()));
        } 
        insert oppList;
        //Create Quote
        List<Quote> quoteList=new List<Quote>();
        integer index=1;
        for(Opportunity eachOpp:oppList){
            quoteList.add(new Quote(OpportunityId=eachOpp.Id,Account__c=eachOpp.AccountId,Name='Test Quote '+index));
            index++;
        }
        insert quoteList;
        //Create Order
        List<Order> orderList=new List<Order>();
        index=1;
        for(Opportunity eachOpp:oppList){
            orderList.add(new Order(Legacy_Id__c='12345'+index,OpportunityId=eachOpp.Id,AccountId=eachOpp.AccountId,Name='Test Quote '+index,
                                    EffectiveDate=System.today(),Status='Draft'));
            index++;
        }
        insert orderList;
        //Create Order line
        List<Order_Line__c> orderLineList=new List<Order_Line__c>();
        for(Order eachOrder:orderList){
            orderLineList.add(new Order_Line__c(Order__c=eachOrder.Id,Customer_Name__c=eachOrder.AccountId));
        }
        insert orderLineList;
        
    }
    
    @isTest static void testGlobalParentChange() {
        Test.startTest();
        User testUser=[Select Id from User where lastName='User 2'];
        Account childAcc=[Select Id,UltimateParent__c,Global_Parent_Updated__c,Global_Ultimate_Parent__c from Account where Name='customerAcc'];
        Account globalParent=[Select Id from Account where Name='Global Parent Test Acc2'];
        childAcc.Global_Ultimate_Parent__c=globalParent.Id;
        update childAcc;
       UpdateGlobalUltimateParentBatchScheduler batchObj = new UpdateGlobalUltimateParentBatchScheduler();
       // DataBase.executeBatch(batchObj,200);
          Date today=System.today();
        String CRON_EXP ='0 0 0 '+today.day()+' '+today.month()+' ? *'; 
        String jobId = System.schedule('Schedule to update Account Name',CRON_EXP,batchObj);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
        list<Account> finalList = [select id,Global_Parent_Updated__c from Account where Global_Parent_Updated__c = True]; 
        
    }
    @isTest static void testDoSubListHelperMethod() {
        Test.startTest();
        List<Account> orderList=[Select Id from Account];
        List<List<Sobject>> sObjectList=new List<List<Sobject>>();
        sObjectList = UpdateGlobalUltimateParentBatchHelper.doSubList(orderList);
        Test.stopTest();
        System.assertEquals(1,sObjectList.size());
        
    }
    @isTest static void testCreateCSVHelperMethod() {
        Test.startTest();
        list<Account> globalParentList = new list<Account>();
        for(integer i= 0; i<3 ; i++){
            Account globalParentAcc2=new Account(Name='Global Parent Test Acc2'+ i,shippingcountry = 'USA',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
            globalParentList.add(globalParentAcc2);  
        }
        Database.SaveResult[] srList = Database.insert(globalParentList, True); 
        string  sObjectList = UpdateGlobalUltimateParentBatchHelper.createCSVBody('Account',srList);
        //  System.assertEquals(1,sObjectList.size());
        Test.stopTest();
    }
}