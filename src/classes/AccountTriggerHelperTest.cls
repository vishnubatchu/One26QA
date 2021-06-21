@isTest
public class AccountTriggerHelperTest {
    @isTest
    public static void testAccountInsert(){
        Id siteRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
       	
        Id globalParentRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId();

        Account parent = new Account(Name = 'Test ultimate ' + DateTime.now(), RecordTypeId = globalParentRT_Id);
        insert parent;
        
       	Account acct = new Account(RecordTypeId = siteRT_Id, 
                                   Name = 'Test site ' + DateTime.now(), 
                                   ParentId = parent.Id,
                                   ShippingState = 'NY',
                                   ShippingCity = 'Test City',
                                   ShippingCountry = 'IND',
                                   ShippingPostalCode = '560100',
                                   ShippingStreet = 'Test Street',
                                   Type = 'Site',
                                   AR_Amount__c = 0,
                                   Site_Use_Code__c='BILL_TO'
                                  );
        insert acct; 
        
        acct.Type = 'Customer';
        acct.AR_Amount__c = 1;
                
        update acct;  
        
        System.assertEquals(1, acct.AR_Amount__c);
        System.assertEquals('Customer', acct.Type);
    }
    
   
}