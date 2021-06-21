@isTest
public class CaseApprovalEmailServicehandlerTest {
    @testsetup static void testData(){
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=getRecordTypeIdByName('Global Parent'));
        insert globalParentAcc;
        Account acc = new Account(name='Account1 ', Shippingcity='Hyderabad',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', Shippingcountry='US',ParentId=globalParentAcc.Id,
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc;
       Account siteacc = new Account(name='AccountSite ', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                      shippingcity='New York',Site_Use_Code__c='SHIP_TO',Site_Use_Status__c='Active',parentId=acc.id, shippingcountry='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        insert siteacc;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='CFO' LIMIT 1].Id;
        String roleId2 =[select Id from UserRole where Name='VP of AMERICAS - WESTERN' LIMIT 1].Id;
        String FAEEngineer =[select Id from UserRole where Name='FA Engineer SNY' LIMIT 1].Id; 
        String roleId3 =[select Id from UserRole where Name='EVP' LIMIT 1].Id; 
        User u = createTestUser(roleId,p.Id,'Test','adas');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert u;
        }
       User u1 = createTestUser(FAEEngineer,p.Id,'Test1','Datan/W');
        User u2 = createTestUser(FAEEngineer,p.Id,'Test2','opticalIC');
         User u3 = createTestUser(roleId2,p.Id,'Test3','Wavelength');
         User u4 = createTestUser(FAEEngineer,p.Id,'Test4','3DSensing');
         User u5 = createTestUser(roleId3,p.Id,'Test5','SVP');
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert u1;
            insert u2;insert u3;insert u4;insert u5;
        }
        u.VP__c = u3.Id;
        u.email = 'kurt.adzema@finisar.com';
        u.SVP__c = u5.Id;
        update u;
        case case1 = new case(Finisar_Sales_Manager__c = u1.Id,Customer_Name__c=acc.id,CFO_User__c =u.id,Wavelength_BU_GM__c=u2.Id,SVP_of_Sales__c=u5.Id,X3DSensing_BU_GM__c=u2.Id,Data_n_W_BU_GM__c=u2.Id,OpticalIC_BU_GM__c=u2.Id ,Billing_Type__c ='Return For Credit Only, No Outbound Rebill Involved',Status ='Open', 
                              Ship_To_Customer__c=acc.id, Ship_To_Address__c =siteacc.id,Outbound_RMA_PO__c='456543',Requested_Service__c='Failure Analysis',CustomerRef_RMANo__c='345654',RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId(),EndCustomerInbound__c = 'ec');
        insert case1;
        system.debug('Testing5677 -- ' + case1.id); 
        IF(Approval.isLocked(case1.id)) {
            Approval.unlock(case1.Id);
        }
  Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(case1.Id);
        req1.setSubmitterId(u.id);
        Approval.ProcessResult result = Approval.process(req1); 
    }
     static testmethod void caseApprovalReminder2() { 
        Case cs1 =[select id from case limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='CFO' LIMIT 1].Id;
        user u = [select id,UserRoleId,profileid,vp__c,svp__c,email from user where lastname='adas' and isActive=true LIMIT 1];
         string arprv1  = 'Action:Approve';
        sendInboundEmail(u,cs1,arprv1);  
         System.debug('test executed');
    }
    static testmethod void caseApprovalReminder() { 
        Test.startTest();
        Case cs1 =[select id from case limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='CFO' LIMIT 1].Id;
        user u = [select id,UserRoleId,profileid,vp__c,svp__c,email from user where lastname='adas' and isActive=true LIMIT 1];
        string arprv  = 'Action: Reject';
        sendInboundEmail(u,cs1,arprv);      
        Test.stopTest();
    }
  
  
    static void sendInboundEmail(user u,case quoteObj , string approveReject) {
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        // setup the data for the email
        email.subject = 'case:'+quoteObj.id+' has been forwarded for your approval by';
        env.fromAddress = u.Email;
        String body =    approveReject; 
        body = body+'\r\n';
        body = body+'Comments in between the apostrophes to append to this notification'; 
        body = body+'\r\n';
        body = body+'Case Id : ['+quoteObj.id+']' ;
        System.debug('body'+body);
        email.plainTextBody =body;
        CaseApprovalEmailServicehandler approvalEmailObj =    New CaseApprovalEmailServicehandler();
        approvalEmailObj.handleInboundEmail(email, env);
    }
    
    public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = lName + '@huronconsultinggroup.com',
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
    
     static testmethod void cancelRMARequest(){
         Case cs1 =[select id from case where CustomerRef_RMANo__c ='345654' limit 1];
         RmaRequestCancellation.cancelRmaRequest(New List<Id>{cs1.Id});
    }
    
    static Id getRecordTypeIdByName(String recordTypeName){
       return [Select Id from RecordType where Name=:recordTypeName].Id;
    }
}