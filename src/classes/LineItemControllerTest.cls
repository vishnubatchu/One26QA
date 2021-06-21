@isTest
public class LineItemControllerTest {
    
    @isTest
    public static void getLonaerItemTest(){
        UserRole insdieuserrole = [Select Id from UserRole Where DeveloperName ='Inside_Sales_FAE_WSS'];
        Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        User insideUser = new User(LastName='Usrlast',ProfileId=usrProfile.Id,UserRoleId=insdieuserrole.id,alias ='testusr',
                                   Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@finisar.com');
        insert insideUser;
        User sysAdm = new User(LastName='Usrlast1111',ProfileId=usrProfile.Id,alias ='trsysy',
                               Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser@finisar.com');
        system.runAs(sysAdm){
            // Account acc = new Account(name='Account ', 
            // billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
            Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',ShippingCity = 'New York', ShippingCountry ='US', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId());
            insert globalParentAcc;
            Account acc = new Account(name='Account3',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ParentId = globalParentAcc.Id,Global_Ultimate_Parent__c=globalParentAcc.Id,shippingcity='Raipur',shippingcountry='India',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),Legacy_Id__c ='eoqw3214132421341');
            insert acc;
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
            String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
            String roleId2 =[select Id,Name from UserRole where DeveloperName='Inside_Sales_FAE_WSS' LIMIT 1].Id;
            String roleId3 =[select Id from UserRole where Name='EVP' LIMIT 1].Id;
            //String roleId4 =[select Id from UserRole where Name='RSM' LIMIT 1].Id;
            User u = createTestUser(roleId,p.Id,'Test','Case');
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
                insert u;
            }
            User u1 = createTestUser(roleId2,p.Id,'Test1','Case1');
            User u2 = createTestUser(roleId3,p.Id,'Test2','Case2');
            // User u3 = createTestUser(roleId4,p.Id,'Test3','Case3');
            u1.SVP__c = u.Id;
            u1.VP__c = u.Id;
            u2.SVP__c = u.Id;
            u2.VP__c = u.Id;
            insert u1;
            insert u2;
            Product2 prod = new Product2(IsActive = true,Status__c = 'Active',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN',BU_Code__c = '0040');
            insert prod;
            Account acc2 = new Account(name='Test11/12',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',Global_Ultimate_Parent__c=globalParentAcc.Id,ParentId=acc.Id,Party_Number__c ='203956',AccountNumber ='1234',shippingcity='Raipur',shippingcountry='India',Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),Legacy_Id__c ='eoqw32141324213412');
            insert acc2;
            Account acc3 = new Account(name='Testing11/12',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ParentId=globalParentAcc.Id,Party_Number__c ='203956',AccountNumber ='1234',shippingcity='Raipur',shippingcountry='India',Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId(),Legacy_Id__c ='eoqw32141324213413');
            insert acc3;
            Account acc4 = new Account(name='Testing11/123',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',Global_Ultimate_Parent__c=globalParentAcc.Id,ParentId=acc3.Id,Party_Number__c ='203956',AccountNumber ='1234',shippingcity='Raipur',shippingcountry='India',Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
                                       Legacy_Id__c ='eoqw321413242134122',Site_Use_Code__c='SHIP_TO',Org_ID__c= '2', Site_Use_Status__c='Active');
            insert acc4;
            system.debug('acc1 ' + acc2);
            Loaner__c loaner = new Loaner__c();
            Loaner_Line__c loanerLine = new Loaner_Line__c();
            Loaner_Line__c loanerLine1 = new Loaner_Line__c();
            Loaner_Line__c loanerLine2 = new Loaner_Line__c();
            Loaner_Line__c loanerLine3 = new Loaner_Line__c();
            List<Loaner_Line__c> loanerLineList = new  List<Loaner_Line__c>();
            //Loaners 
            UserRole rsmrole = [select Id From UserRole where Name like 'RSM%' Limit 1];
            User RSMUser = [select Id From User where UserRoleId =:rsmrole.Id Limit 1];
            Opportunity opty= new Opportunity(Name='Test Oppty 1');
            Account accounttest =[select Id From Account where Name ='Testing11/12'];
            opty.AccountId = accounttest.Id;
            opty.Project_Name__c ='test project';
            opty.StageName ='Open - Discussion';
            opty.Next_Action_Due_Date__c = Date.Today();
            opty.NextStep = 'Test';
            opty.CloseDate = System.today() + 60 ;
            opty.RSM__c =RSMUser.Id;
            insert opty;
            loaner = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc3.Id,Company_Name_End_Cust__c = acc3.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),Address_ship_to__c = acc4.Id,
                                   Opportunity_Type__c='New Opportunity',Opportunity__c =opty.id, Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock',RSM_PLM_Finisar__c = u1.Id, RSM_PLM_Approval__c = u.Id,Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c =insideUser.Id);
            System.debug('loaner===='+loaner);
            insert loaner;
            loanerLine= new Loaner_Line__c(Loaner__c = loaner.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                           Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = '',SO_Line_Migration__c='l');
            loanerLine1= new Loaner_Line__c(Loaner__c = loaner.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                            Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = '',SO_Line_Migration__c='l');
            loanerLine2= new Loaner_Line__c(Loaner__c = loaner.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                            Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = '',SO_Line_Migration__c='l');
            loanerLine3= new Loaner_Line__c(Product__c=prod.Id, Loaner_Qty__c=5,Est_Annual_Qty__c = 5,SOM__c = 5,SO_Number_Migration__c = '',SO_Line_Migration__c='l',Loaner_Price_100_999_column_price__c=10);
            Test.startTest();
            //errors on Loaner Header Record 
            string idss = insideUser.Id;
            system.debug('isdddds@@@ ' + idss);
            Loaner__c loaner3 = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc3.Id,Company_Name_End_Cust__c = acc3.Id,Project_Engineer__c='Test',Project_Name__c = 'Test2OpportunityTest',Est_Production_Date__c =Date.today(),
                                              RSM_PLM_Finisar__c=idss,Address_ship_to__c=acc4.Id, Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Draft',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id);
            insert loaner3;
            Loaner_Line__c loaner3line1= new Loaner_Line__c(Loaner__c = loaner3.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                            Line_Status__c='Draft',Production_Price_ASP__c = 20,SOM__c= 30,Loaner_Qty__c= 20,Product__c=prod.Id,Est_Annual_Qty__c=45);
            insert loaner3line1;
            String message1 = LineItemController.validateRecords(loaner3.id);
            String message2 = LineItemController.validateRecordsONSaveAndClose(loaner3.id);
            
            // errors on Loaner Record Other than opportunity 
            Loaner__c loaner4 = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc3.Id,Company_Name_End_Cust__c = acc3.Id,Project_Engineer__c='Test',Project_Name__c = 'Test2OpportunityTest',
                                              RSM_PLM_Finisar__c=u1.Id,Address_ship_to__c=acc4.Id, Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock', Status_Approval__c ='Draft',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.Id);
            insert loaner4;
            Loaner_Line__c loaner4line1= new Loaner_Line__c(Loaner__c = loaner4.Id,RecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId(), Loaner_Price_100_999_column_price__c=10,
                                                            Line_Status__c='Draft',Product__c=prod.Id,Loaner_Qty__c =null,Est_Annual_Qty__c=null);
            insert loaner4line1;
            String msg1 = LineItemController.validateRecords(loaner3.id);
            String msg2 = LineItemController.validateRecordsONSaveAndClose(loaner3.id);
            insert loanerLine;
            loanerLine.Loaner_Qty__c=8;
            loanerLineList.add(loanerLine);
            loanerLineList.add(loanerLine1);
            loanerLineList.add(loanerLine2);
            loanerLineList.add(loanerLine3);
            String s = JSON.serialize(loanerLineList);
            LineItemController.getLoanerLineItem(loaner.id);
            LineItemController.saveLoanerLineItem(loanerLineList,loaner3.id);
            LineItemController.getRecordType(loanerLine.id);
            LineItemController.sendRequesttoInformatica(loaner.id);
            String message3 = LineItemController.validateRecords(loaner.id);
            String message4 = LineItemController.validateRecordsONSaveAndClose(loaner.id);
            LineItemController.getLoanerStatus(loaner.id);
            LineItemController.getUserPermission();
            LineItemController.deleteLoanerLineItem(loanerLine);
            Test.stopTest();
        }
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