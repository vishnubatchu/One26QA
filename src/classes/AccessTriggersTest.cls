@isTest
public class AccessTriggersTest {
    
    @testSetup static void createData(){
        UserRole insdieuserrole = [Select Id from UserRole Where DeveloperName ='Inside_Sales_FAE'];
        Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        User insideUser = new User(LastName='Usrlast',ProfileId=usrProfile.Id,UserRoleId=insdieuserrole.id,alias ='testusr',
                                   Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@finisar.com');
        insert insideUser;
       User guestUser = new User(LastName='Usrlast1234',ProfileId=[SELECT Id FROM Profile WHERE Name = 'Custom Web to Case Profile'].Id,alias ='siteusr',
                                   Email='siteguestusr@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='siteguestusr@finisar.com');
        insert guestUser;
        User sysAdm = new User(LastName='Usrlast1111',ProfileId=usrProfile.Id,alias ='trsysy',Legacy_Company__c ='Finisar',
                               Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser@finisar.com');
        system.runAs(sysAdm){
            Case caseObj = New Case(Found_By__c='Customer',Part_Numbers_s__c='12313',Status='Open',SuppliedEmail='test@gmail.com',OwnerId=guestUser.Id);
            insert caseObj;
            Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
            insert globalParentAcc;
            Account acc = new Account(name='Account ',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ParentId = globalParentAcc.Id,  ShippingCity = 'New York', ShippingCountry ='US',
                                      billingcity='New York', billingcountry='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
            insert acc;
            Account acc1 = new Account(ParentId = acc.Id,name='Account1 ', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                       billingcity='New York test', billingcountry='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(), Org_ID__c= '2',
                                      Site_Use_Code__c='SHIP_TO',Site_Use_Status__c='Active', ShippingCity = 'New York', ShippingCountry ='US');
            
            insert acc1;
            
            Contact cntct=new Contact(FirstName='Test',LastName='Contact',Email='test@gmail.com',MailingCountry='United States',Display_Mailing_Country__c='United States');
            insert cntct;
            
            Loaner__c loaner = new Loaner__c(RecordTypeId = Schema.SObjectType.Loaner__c.getRecordTypeInfosByName().get('Loaner Request').getRecordTypeId(), Company_Name_Ship_To__c = acc.Id,Company_Name_End_Cust__c = acc.Id,Project_Engineer__c='Test',Project_Name__c = 'Test',Est_Production_Date__c = Date.Today(),Address_ship_to__c = acc1.Id,
                                             Opportunity_Type__c='New Opportunity', Loaner_Duration__c='180',Loaner_Ship_From_Finisar__c = 'Factory Stock',Inside_Sales_Sales_rep__c = UserInfo.getUserId(),Inside_Sales_Finisar__c = insideUser.id);
            insert loaner;
            
            Quote quoteObj = new Quote(Name ='test',Status='Draft',Type_of_Pricing__c='Fixed - One Time Order',ExpirationDate = System.today()+1,
                                       Account__c=acc.id);
            insert quoteObj;   
        }
        
    }
    
    TestMethod static void testCaseTrigger(){
        Case caseObj = [Select id from Case];
    }
    
    TestMethod static void testLoanerTrigger(){
        Loaner__c loanerObj = [Select id,Loaner_Duration__c from Loaner__c Limit 1];
        loanerObj.Loaner_Duration__c = '90';
        update loanerObj;
    }
    
    TestMethod static void testQuoteTrigger(){
        User tstUsr=[Select Id from User where userName='testuser@finisar.com'];
        System.runAs(tstUsr){
            Quote quoteObj = [Select id,ExpirationDate from Quote Limit 1];
            quoteObj.ExpirationDate = System.today() +2;
            update quoteObj;
        }
    }
}