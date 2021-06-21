@isTest
public class UpdateGlobalParentLookupsBatchTest {
  @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile' LIMIT 1];
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
        Account siteAcc1=new Account(Name='Site Test Acc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId(),
                                     Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2');
         accInsertList.add(siteAcc1);
        Account siteAcc=new Account(Name='Site Test Acc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId(),
                                    Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                    Site_Use_Status__c='Active',ParentId=globalParentAcc.id,shippingcity='New York',shippingcountry='USA',Type='Customer',
                                    Org_ID__c= '2');
        accInsertList.add(siteAcc);
        Account child1 = new Account(Name='child1',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = globalParentAcc.Id,Status__c='Active'); 
        accInsertList.add(child1);
        Account child2 = new Account(Name='child2',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = globalParentAcc.Id,Status__c='Active');  
        accInsertList.add(child2);
        Account child3 = new Account(Name='child2',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = globalParentAcc.Id,Status__c='Active');  
        accInsertList.add(child3);
        Account child4 = new Account(Name='child4',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = globalParentAcc.Id,Status__c='Active');  
        accInsertList.add(child4);
      insert accInsertList;
        
        List<Account> accList=new List<Account>(); 
        accList.add(new Account(Name='TestAcc1',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[0].id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc2',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[1].id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc3',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[2].id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc4',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[3].Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc5',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[4].Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc6',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = accInsertList[5].Id,Status__c='Active'));
        insert accList;
        
        List<Contact> contactList=new List<Contact>();
        Integer index=1;
        for(Account eachAcc:accList){
            contactList.add(new Contact(LastName='Test Contact '+index,AccountId=eachAcc.Id));
            index++;
        }  
        insert contactList;
        
        List<Opportunity> oppList=new List<Opportunity>();
        index=1;
        for(Account eachAcc:accList){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=eachAcc.Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+index,StageName='Qualifying',Project_Name__c='Test',RecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Aftermarket').getRecordTypeId()));
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
        
    }
    
    @isTest static void testGlobalParentChange() {
        list<Opportunity> oppList=[Select Id from Opportunity ];
        list<Order> orderList=[Select Id from Order ];
        list<Quote> quoteList=[Select Id from Quote ];
        list<Opportunity> listOpp = new list<Opportunity>();
        list<order> listOrd = new list<order>();
        list<quote> listQt = new list<quote>();
        for(Opportunity op : oppList){
            op.Global_Ultimate_Account__c = null;
            listOpp.add(op);
        }
         for(Order ord : orderList){
            ord.Global_Ultimate_Account__c = null;
            listOrd.add(ord);
        }
         for(Quote qt : quoteList){
            qt.Global_Ultimate_Account__c = null;
            listQt.add(qt);
        }
        update listOpp;
        update listOrd;
        update listQt;
        Test.startTest();
        UpdateGlobalParentLookupsBatch batchObj = new UpdateGlobalParentLookupsBatch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
       
    }
}