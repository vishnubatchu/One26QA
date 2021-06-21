@isTest
private class LoanerOrderlinkbatchTest {
    @testSetup 
    static void setup() {
        UserRole insdieuserrole = [Select Id from UserRole Where DeveloperName ='Inside_Sales_FAE'];
        Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        User insideUser = new User(LastName='Usrlast',ProfileId=usrProfile.Id,UserRoleId=insdieuserrole.id,alias ='testusr',
                                   Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@finisar.com');
        insert insideUser;
        User sysAdm = new User(LastName='Usrlast1111',ProfileId=usrProfile.Id,alias ='trsysy',
                               Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser@finisar.com');
        system.runAs(sysAdm){
                 Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
            Account acc = new Account(name='Account ', ShippingCity = 'New York', ShippingCountry ='US',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                      billingcity='New York', billingcountry='USA',parentId=globalParentAcc.id,Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
            
            insert acc;
            Account acc1 = new Account(ParentId = globalParentAcc.Id,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',name='Account1 ', ShippingCity = 'New York', ShippingCountry ='US',
                                       billingcity='New York test', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
            
            insert acc1;
            Account acc4 = new Account(name='Testing11/123',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ParentId=acc.Id, Party_Number__c ='203956',
                                       AccountNumber ='1234',shippingcity='Raipur',shippingcountry='US',
                                       Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',
                                       Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
                                       Legacy_Id__c ='eoqw321413242134122',Site_Use_Code__c='SHIP_TO',Org_ID__c= '2', Site_Use_Status__c='Active');
            
            insert acc4;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
            User u = createTestUser(roleId,p.Id,'Test','Case');
            
            Product2 prod = new Product2(IsActive = true,Status__c = 'Active',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
            insert prod;
            List<Order> orders = new List<Order>();
            List<Order_Line__c> orderLines = new List<Order_Line__c>();
            List<Loaner__c> loaners = new List<Loaner__c>();
            List<Loaner_Line__c> loanerLines = new List<Loaner_Line__c>();
            // insert 10 test data
            for (Integer i=0;i<10;i++) {
                //Orders
                orders.add(new order(AccountId=acc.Id,Status = 'Draft',Ordered_Date__c = Date.Today(),EffectiveDate = Date.Today(),Legacy_Id__c = 'Leg'+i,RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('RMA Order').getRecordTypeId(),
                                     billingcity='New York', billingcountry='USA',PoNumber = ''+i));
                //Loaners     
                loaners.add(new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc.Id,Company_Name_End_Cust__c = acc.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),Address_ship_to__c = acc4.Id,
                                          Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock',RSM_PLM_Finisar__c = U.Id, RSM_PLM_Approval__c = U.Id,Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id));
            }
            insert orders;
            insert loaners;
            
            for(Order ord : orders){
                //OrderLines
                Integer i=0;
                orderLines.add(new Order_Line__c(Order__c = ord.Id,RecordTypeId = Schema.SObjectType.Order_Line__c.getRecordTypeInfosByName().get('Sales Order Line').getRecordTypeId(), 
                                                 Line_Id__c='l'+i));
                i++;
            }
            for(Loaner__c loan :  loaners){
                Integer i=0;
                //LonaerLines     
                loanerLines.add(new Loaner_Line__c(Loaner__c = loan.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                   Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = ''+i,SO_Line_Migration__c='l'+i));
                i++;
                
            }
            insert orderLines;
            insert loanerLines;
        }  
    }
    static testmethod void test() {        
        Test.startTest();
        LoanerOrderlinkbatch uca = new LoanerOrderlinkbatch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        //System.assertEquals(10, [select count() from contact where MailingCity = 'New York']);
    }
    public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              UserRoleId = roleId);
        return tuser;
    }
    
}