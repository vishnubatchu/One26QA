@isTest
private class RecordApprovalControllerTest{
    
    @testsetup static void createdata(){
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
        Account acc = new Account(name='Account122', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test2',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=acc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='Illionis', billingcountry='USA',Status__c='Active',Type='Distributor',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Account').getRecordTypeId());
        
        insert acc1;
            Account acc4 = new Account(name='Testing11/123',ParentId=acc.Id, Party_Number__c ='203956',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                       AccountNumber ='1234',shippingcity='Raipur',shippingcountry='US',
                                       Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',
                                       Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
                                       Legacy_Id__c ='eoqw321413242134122',Site_Use_Code__c='SHIP_TO',Org_ID__c= '2', Site_Use_Status__c='Active');
            
            insert acc4;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
            String roleId2 =[select Id from UserRole where Name='VP of AMERICAS - WESTERN' LIMIT 1].Id;
            String roleId3 =[select Id from UserRole where Name='EVP' LIMIT 1].Id;
            User u = createTestUser(roleId,p.Id,'Test','Case');
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert u;
            }
            User u1 = createTestUser(roleId2,p.Id,'Test1','Case1');
            User u2 = createTestUser(roleId3,p.Id,'Test2','Case2');
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert u1;
                insert u2;
            }
            u.VP__c = u1.Id;
            u.SVP__c = u2.Id;
            System.debug('u1'+u1.Id);
            System.debug('u2'+u2.Id);
            update u;
            Product2 prod = new Product2(IsActive = true,Status__c = 'Active',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
            insert prod;
            Order order = new Order();
            Loaner__c loaner = new Loaner__c();
            Loaner_Line__c loanerLine = new Loaner_Line__c();
            //Orders
            order = new order(AccountId=acc.Id,Status = 'Draft',Ordered_Date__c = Date.Today(),EffectiveDate = Date.Today(),Legacy_Id__c = 'Leg',RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('RMA Order').getRecordTypeId(),
                              billingcity='New York', billingcountry='USA',PoNumber = '5');
            //Loaners     
            loaner = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc.Id,Company_Name_End_Cust__c = acc.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),Address_ship_to__c = acc4.Id,
                                   VP_PLD_Finisar__c=u1.id,Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock',RSM_PLM_Finisar__c = U.Id, RSM_PLM_Approval__c = U.Id,Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.id);
            insert order;
            insert loaner;
            
            loanerLine= new Loaner_Line__c(Loaner__c = loaner.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                           Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = '',SO_Line_Migration__c='l');
            insert loanerLine;
            System.debug('loanerLine'+loanerLine);
            System.debug('loaner'+loaner);
            System.Debug('<<<<<<<>>>>>>>>'+loaner.RecordTypeId);
        }
    }
    static testmethod void test1() { 
        Test.startTest();
        //RecordApprovalController rac = new RecordApprovalController();
        loaner__c loaner =[select id from loaner__c limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        user u = [select id,UserRoleId,profileid,vp__c,svp__c from user where userroleid =: roleId and isActive=true LIMIT 1];
        System.debug('user details '+u);
        System.runas(u){
            RecordApprovalController.sendLineItemEmails(loaner.Id);
        }
        Test.stopTest();
    }
    static testmethod void test2() { 
        Test.startTest();
        //RecordApprovalController rac = new RecordApprovalController();
        loaner__c loaner =[select id from loaner__c limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        user u = [select id,UserRoleId,UserRole.Name,profileid,vp__c,svp__c from user where UserRoleId =: roleId and isActive=true LIMIT 1];
        String roleIdVp =[select Id from UserRole where Name='VP of AMERICAS - WESTERN' LIMIT 1].Id;
        user u1 = [select id,email,UserRoleId,UserRole.Name,profileid,vp__c,svp__c from user where userroleId =:roleIdVp and isActive=true LIMIT 1];
        //User u1 = createTestUser(roleIdVp,p.Id,'Test','Case');
        System.debug('user details '+u);
        System.runas(u){
            RecordApprovalController.sendLineItemEmails(loaner.Id);
        }
        Set<ID> uSet = new Set<ID>();
        uSet.add(u.Id);
        RecordsLineItemApprovalHelper.sendEmail(uSet,loaner.Id);
        Loaner_Line__c loanerLine =[select id from Loaner_Line__c limit 1];
        Set < id > recordLineitemsToBeApprovedSet = new Set < id >();
        recordLineitemsToBeApprovedSet.add(loanerLine.Id);
        RecordsLineItemApprovalHelper.reAssignUser(loaner.Id,u1,u1.email,recordLineitemsToBeApprovedSet);
        RecordsLineItemApprovalHelper.RejectRecords(recordLineitemsToBeApprovedSet,'loaner__c',u1.Id);
        System.runas(u){
            RecordApprovalController.sendLineItemEmails(loaner.Id);
        }
        RecordsLineItemApprovalHelper.ApproveRecords(recordLineitemsToBeApprovedSet,'loaner__c',loaner.Id,u1.Id);
        Test.stopTest();
    }
    static testmethod void contactForGDPRtest() { 
        Test.startTest();
        List<Contact> conlist = new List<Contact>(); 
        Account acc = [SELECT Id from Account where name = 'Account122' Limit 1];
        Contact c = new Contact(FirstName = 'Test',LastName = 'Contact',AccountId = acc.Id,MailingCountry='United States',Display_Mailing_Country__c='United States');
        Contact c1 = new Contact(FirstName = 'Test1',LastName = 'Contact',AccountId = acc.Id,MailingCountry='United States',Display_Mailing_Country__c='United States');
        Contact c2 = new Contact(FirstName = 'Test2',LastName = 'Contact',AccountId = acc.Id,MailingCountry='United States',Display_Mailing_Country__c='United States');
        Contact c3 = new Contact(FirstName = 'Test3',LastName = 'Contact',AccountId = acc.Id,MailingCountry='United States',Display_Mailing_Country__c='United States');
        conlist.add(c); 
        conlist.add(c1);
        conlist.add(c2);
        conlist.add(c3);
        insert conlist;
        //ContactForGDPR.checkPartyAccount(conlist);
        //ContactForGDPR.checkMarketingCommunication(conlist);
        //DummyClassForCodeCoverage.fakeMethod();
        Test.stopTest();
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
                              isActive = True,
                              UserRoleId = roleId);
        return tuser;
    }
    
}