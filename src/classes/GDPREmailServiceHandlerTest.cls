@isTest
public class GDPREmailServiceHandlerTest {
    
    @isTest
    static void testData(){
           Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId());
        insert globalParentAcc;
        
         Account acc = new Account(name='Account ',ShippingCity = 'New York', ShippingCountry ='US',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                  billingcity='New York',ParentId = globalParentAcc.Id, Global_Ultimate_Parent__c=globalParentAcc.Id,billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        Account acc1 = new Account(ParentId = acc.Id,name='Account1 ', Legacy_Id__c='1234',ShippingCity = 'Test',ShippingCountry ='US',ShippingState ='NE',ShippingPostalCode ='63572',ShippingStreet = 'Test4',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                billingcity='New York test',Site_Use_Code__c = 'SHIP_TO',Site_Use_Status__c= 'Active', billingcountry='USA',Status__c='Active',Type='Reseller',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        
        insert acc1;
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
        Contact c = new Contact(FirstName = 'Test',LastName = 'Contact',AccountId = acc.Id,Display_Mailing_Country__c = 'United States',MailingCountry='United States',Email='rest@vv.com');
        insert c;
        Test.startTest();
        sendInboundEmail(u,c);
        sendInboundEmail1(u,c);
        Test.stopTest();
        
    }  
    
    static void sendInboundEmail(user u,Contact conObj) {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.Header hditem= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1]; 
        hditem.name='Date'; 
        hditem.value='Tue, 28 Dec 2018 14:08:37 -0700'; 
        email.headers[0]=hditem;
        // setup the data for the email
        email.subject = 'RE:Opt-In Contact';
        env.fromAddress = u.Email;
        email.ccAddresses = new String[] {'dataprivacy@finisar.com'};
        String body = 'Opt-In'; 
        body = body+'\r\n';
        body = body+'For Finisar Use Only: ['+conObj.Id+']';
        
        System.debug('body=='+body);
        email.htmlBody =body;
        system.debug('email.headers==='+email.headers);
        system.debug('email.htmlBody==='+email.htmlBody);
        GDPREmailServiceHandler contactEmailObj =    New GDPREmailServiceHandler();
        contactEmailObj.handleInboundEmail(email, env);
    }
    static void sendInboundEmail1(user u,Contact conObj) {
        system.debug('Insideeeee==');
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.Header hditem= new Messaging.InboundEmail.Header();
        email.headers=new Messaging.InboundEmail.Header[1]; 
        hditem.name='Date'; 
        hditem.value='Tue, 28 Dec 2018 14:08:37 -0700'; 
        email.headers[0]=hditem;
        // setup the data for the email
        email.subject = 'Opt-In Contact';
        env.fromAddress = u.Email;
        email.ccAddresses = new String[] {'dataprivacy@finisar.com'};
        String body = 'Dear'; 
        body = body+'\r\n';
        body = body+'For Finisar Use Only: ['+conObj.Id+']';
        
        System.debug('body1=='+body);
        email.htmlBody =body;
        system.debug('email.headers1==='+email.headers);
        system.debug('email.htmlBody1==='+email.htmlBody);
        GDPREmailServiceHandler contactEmailObj =    New GDPREmailServiceHandler();
        contactEmailObj.handleInboundEmail(email, env);
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