@isTest
public class Opportunity_Handler_test  {
    
    //basic opportunity test
    static testMethod void Opportunity_Handler_Test1 () {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            
            User mike = new User();
            mike.Username= 'mike.white911@company.com';
            mike.Email = 'mike.white911@company.com';
            mike.Lastname = 'mike';
            mike.Firstname = 'white';
            mike.Alias = 'mwhite';
            mike.CommunityNickname = 'mwhite01';
            mike.ProfileId = [ select id, name from profile where name = 'System Administrator' ].Id;       
            mike.TimeZoneSidKey = 'GMT';
            mike.LocaleSidKey = 'en_US';
            mike.EmailEncodingKey = 'ISO-8859-1';
            mike.LanguageLocaleKey = 'en_US';
            mike.UserPermissionsMobileUser = false;
            insert mike;
            
            System.test.startTest();
            
            //Create new account
            Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId()	);
            insert globalParentAcc;
            Account a = new Account();
            a.name='Nulled Gardenia009'; 
            a.Type='Customer';
            a.CurrencyIsoCode='USD';
            a.Company_number__c='01';
            a.ShippingCity = 'New York'; 
            a.ShippingCountry ='US';
            a.ParentId = globalParentAcc.Id;
            a.Display_Shipping_Country__c ='United States';  
            a.Display_Billing_Country__c = 'United States';
            insert a; 
            
            //Create a new date & format it 
            DateTime dT = System.now();
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            //Create a new opportunity
            Opportunity o = new Opportunity();
            o.name='Gardenia Sheep_opportunity';
            o.AccountId=a.Id;
            o.CloseDate=myDate;
            o.stagename='Prospect';
            o.CurrencyIsoCode='USD';
            o.Marlow_Product_BU__c='Components';
            o.Market__c='30 - Medical';
            o.ITAR__c='NO';
            o.REACH__c='NO';
            o.Qual_Required__c = 'Yes'; 
            o.Project_Name__c = 'Test';    
            insert o;
            update o;
            System.assert(o.AccountId == a.Id);     
        }
        
        System.test.stopTest();
    }
}