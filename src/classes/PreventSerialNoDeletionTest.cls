@isTest
private class PreventSerialNoDeletionTest {
	
    static testmethod void testPreventSnDel(){
           Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
       Account acc = new Account(name='Account',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='New York', billingcountry='USA',Legacy_Id__c='1234',Status__c='Active',Type='Partner',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc;
         Contact conObj = New Contact(lastname='TEst Contact',AccountId=acc.Id,MailingCountry='United States',Display_Mailing_Country__c='United States');
        Insert conObj;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Admin Profile' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        User u = createTestUser(roleId,p.Id,'Test','Case');
         System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
             
        System.runAs(u){
        
        Order orderObj= new Order(AccountId = acc.id,Type='RMA Order',Status='Draft',Legacy_Id__c='test123',RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('RMA Order').getRecordTypeId(),
                             EffectiveDate = System.today()+1);
        insert orderObj;
       
        Order_Line__c orderLineObj = new Order_Line__c(Order__c=orderObj.id,RecordTypeId = Schema.SObjectType.Order_Line__c.getRecordTypeInfosByName().get('Sales Order Line').getRecordTypeId());
        insert orderLineObj;
        Serial_Number__c snumber = new Serial_Number__c(Name = 'sN12344' , Order_Line__c = orderLineObj.id);
        insert snumber;
        try{
           delete snumber;
        }catch(DMLexception e){
            system.assert(e.getMessage().contains('Serial Number Cannot be deleted'),'Serial Number Cannot be deleted');                       
        }
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