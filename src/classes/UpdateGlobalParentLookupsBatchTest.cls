/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This test class is for "UpdateGlobalParentLookupsBatch" and UpdateGlobalParentLookupsBatchHelper  
*/
@isTest
public class UpdateGlobalParentLookupsBatchTest {
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
        
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id 	);
        insert globalParentAcc;
      list<Account> accInsertList = new list<Account>();
      map<string,Account> accInsertMap = new map<string,Account>();
   
        Account siteAcc1=new Account(Name='Site Test Acc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2',OwnerId=testUserList[0].Id );
      
         insert siteAcc1;
 

        
        List<Contact> contactList=new List<Contact>();
        for(integer i = 0 ; i < 10 ; i ++){
            contactList.add(new Contact(LastName='Test Contact '+i,FirstName = 'test',AccountId=siteAcc1.Id));
        }  
        insert contactList;
       
       List<Opportunity> oppList=new List<Opportunity>();
        for(integer i = 0 ; i < 5; i ++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=siteAcc1.Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+i,StageName='Qualifying',Project_Name__c='Test',RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Aftermarket').getRecordTypeId()));
        } 
        insert oppList;
        
        List<Quote> quoteList=new List<Quote>();
        for(integer i = 0 ; i < 5 ; i ++){
            quoteList.add(new Quote(OpportunityId=oppList[i].Id,Account__c=oppList[i].AccountId,Name='Test Quote '+i));
        }
        insert quoteList;
        
        List<Order> orderList=new List<Order>();
        for(integer i = 0 ; i < 5 ; i ++){
            orderList.add(new Order(Legacy_Id__c='12345'+i,OpportunityId=oppList[i].Id,AccountId=oppList[i].AccountId,Name='Test order '+i,
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
        Test.stopTest();
        list<opportunity> oplist = [select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity where Global_Ultimate_Account__c = null ];
        System.assertEquals(oplist.size(),0);
       
    }
}