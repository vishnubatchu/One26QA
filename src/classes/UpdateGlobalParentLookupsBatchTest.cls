/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This test class is for "UpdateGlobalParentLookupsBatch" and InsertSharedRecordOneTimeBatch  
*/
@isTest
public class UpdateGlobalParentLookupsBatchTest {
  @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'One II-VI Sales Rep' LIMIT 1];
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
        
        Account globalParentAcc=new Account(Name='Global Parent Test Acc3',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id 	);
        insert globalParentAcc;
      Account globalParentAcc2=new Account(Name='Global Parent Test Acc4',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id 	);
        insert globalParentAcc2;
      list<Account> accInsertList = new list<Account>();
      map<string,Account> accInsertMap = new map<string,Account>();
   
        Account siteAcc1=new Account(Name='Site Test Acc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     Global_Ultimate_Parent__c=globalParentAcc.Id,ParentId = globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2',OwnerId=testUserList[0].Id );
      
         insert siteAcc1;
      siteAcc1.Global_Ultimate_Parent__c = globalParentAcc2.id;
      update siteAcc1;
        List<Contact> contactList=new List<Contact>();
        for(integer i = 0 ; i < 10 ; i ++){
            contactList.add(new Contact(LastName='Test Contact1 '+i,FirstName = 'test',AccountId=siteAcc1.Id,Display_Mailing_Country__c='United States',MailingCountry='United States'));
        }  
        insert contactList;
       
       List<Opportunity> oppList=new List<Opportunity>();
        for(integer i = 0 ; i < 5; i ++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=siteAcc1.Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp1 '+i,StageName='Qualifying',Project_Name__c='Test',RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Aftermarket').getRecordTypeId()));
        } 
        insert oppList;
        
        List<Quote> quoteList=new List<Quote>();
        for(integer i = 0 ; i < 5 ; i ++){
            quoteList.add(new Quote(OpportunityId=oppList[i].Id,Account__c=oppList[i].AccountId,Name='Test Quote '+i));
        }
        insert quoteList;
        
        List<Order> orderList=new List<Order>();
        for(integer i = 0 ; i < 5 ; i ++){
            orderList.add(new Order(Legacy_Id__c='12345'+i,OpportunityId=oppList[i].Id,AccountId=oppList[i].AccountId,Name='Test order1 '+i,
                                    EffectiveDate=System.today(),Status='Draft'));
        }
        insert orderList;
        
        List<Order_Line__c> orderLineList=new List<Order_Line__c>();
        for(integer i = 0 ; i < 2 ; i ++){
            orderLineList.add(new Order_Line__c(Order__c=orderList[i].Id,Customer_Name__c=orderList[i].AccountId));
        }
        insert orderLineList;
        
    }
    
    @isTest static void testGlobalParentChange() {
        list<Opportunity> oppList=[Select Id from Opportunity ];
        list<Order> orderList=[Select Id from Order ];
        list<Quote> quoteList=[Select Id from Quote ];
        list<sobject> finalUpdateList = new list<sobject>();
        for(Opportunity op : oppList){
            op.Global_Ultimate_Account__c = null;
            finalUpdateList.add(op);
        }
         for(Order ord : orderList){
            ord.Global_Ultimate_Account__c = null;
            finalUpdateList.add(ord);
        }
         for(Quote qt : quoteList){
            qt.Global_Ultimate_Account__c = null;
            finalUpdateList.add(qt);
        }
        update finalUpdateList;
        List<sObject> scope = new List<sObject>();
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Order where id in : finalUpdateList]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity where id in : finalUpdateList ]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId from Quote  where id in : finalUpdateList  ]);
        Test.startTest();
        UpdateGlobalParentLookupsBatch batchObj = new UpdateGlobalParentLookupsBatch();
        batchObj.execute(null,scope);
       DataBase.executeBatch(batchObj);
      
       
    }
        //This method tests the batch scheduler
    @isTest static void UpdateGlobalParentLookupsBatchScheduler() {
       Account parent = [select id , name from Account where name = 'Global Parent Test Acc3'];
        Account child = [select id , name,Global_Ultimate_Parent__c from Account where name = 'Global Parent Test Acc4'];
        child.Global_Ultimate_Parent__c = parent.id ;
        update child;
        Test.startTest();
        UpdateGlobalParentLookupsBatch schObj = new UpdateGlobalParentLookupsBatch();
        Date today=System.today();
        String CRON_EXP ='0 0 0 '+today.day()+' '+today.month()+' ? *'; 
        String jobId = System.schedule('Schedule to update global parent',CRON_EXP,schObj);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
    }
}