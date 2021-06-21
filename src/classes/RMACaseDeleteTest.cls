@isTest
public class RMACaseDeleteTest {
    
    @isTest
    public static void updateCase1(){
        String aMsg = '';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        User u = createTestUser(roleId,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
                 Id recordid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId();

             Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acc = new Account(name='Account ',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test2',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=acc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='Illionis', billingcountry='USA',Status__c='Active',Type='Distributor',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Account').getRecordTypeId());
        
        insert acc1;
        Account acc4 = new Account(name='Testing11/123',ParentId=acc.Id, Party_Number__c ='203956',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                       AccountNumber ='1234',shippingcity='Raipur',shippingcountry='India',
                                       Status__c='Active',Type='Customer',Credit_Limit__c=2.00,Oracle_Party_Id__c='8989',
                                       Oracle_Account_Id__c='7865',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId(),
                                       Legacy_Id__c ='eoqw321413242134122',Site_Use_Code__c='SHIP_TO',Org_ID__c= '2', Site_Use_Status__c='Active');
            
            insert acc4;
        case c= new case(Status='Closed',RecordTypeId = recordid,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                         Ship_To_Address__c = acc4.Id,Outbound_RMA_PO__c='Test',Ship_To_Customer__c=acc.id ,Return_Reason__c='Other');
        insert c;
        Test.startTest();
        try{
            delete c;
        }
        catch(exception e)
        {
            aMsg = e.getMessage();
        }
        
        System.Assert(aMsg.contains('RMA Case cannot be deleted in current status.'));

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
                                UserRoleId = roleId);
        return tuser; 
    }   
}