@isTest
public class UpdateGlobalUltimateParentBatchTest {
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
        
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId(),OwnerId=testUserList[0].Id	);
        insert globalParentAcc;
        Account globalParentAcc2=new Account(Name='Global Parent Test Acc2',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
        insert globalParentAcc2;
        Account siteAcc1=new Account(Name='Site Test Acc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId(),
                                     Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2');
        insert siteAcc1;
        Account siteAcc=new Account(Name='Site Test Acc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Site').getRecordTypeId(),
                                    Global_Ultimate_Parent__c=globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                    Site_Use_Status__c='Active',ParentId=siteAcc1.id,shippingcity='New York',shippingcountry='USA',Type='Customer',
                                    Org_ID__c= '2');
        insert siteAcc;
        Account child1 = new Account(Name='child1 ',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = siteAcc.Id,Status__c='Active'); 
        insert child1;
        Account child2 = new Account(Name='child2 ',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = child1.Id,Status__c='Active');  
        insert child2;
        Account child3 = new Account(Name='child2 ',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = child2.Id,Status__c='Active');  
        insert child3;
        Account child4 = new Account(Name='child4 ',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     ParentId = child3.Id,Status__c='Active');  
        insert child4;
        
        List<Account> accList=new List<Account>(); 
        accList.add(new Account(Name='TestAcc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = child1.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc2',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = child3.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc3',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = siteAcc1.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc4',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = child4.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc5',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = siteAcc.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc6',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = child2.Id,Status__c='Active'));
        accList.add(new Account(Name='TestAcc7',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                ParentId = siteAcc.Id,Status__c='Active'));
        
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
        User testUser=[Select Id from User where lastName='User 2'];
        Account globalParentAcc2=[Select Id from Account where Name='Global Parent Test Acc2'];
        Account globalParentAcc=[Select Id from Account where Name='Site Test Acc1'];
        globalParentAcc.Global_Ultimate_Parent__c=globalParentAcc2.Id;
        update globalParentAcc;
        Test.startTest();
        UpdateGlobalUltimateParentBatch batchObj = new UpdateGlobalUltimateParentBatch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
          list<Account> finalList = [select id,Global_Parent_Updated__c from Account where Global_Parent_Updated__c = True]; 
     
    }
}