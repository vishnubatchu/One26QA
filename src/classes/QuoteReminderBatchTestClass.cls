@isTest(seealldata = false)
public class QuoteReminderBatchTestClass {
		
    @isTest   	
    static void sendQuoteReminderEmail(){
         Account acc = new Account(name='Account2', 
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test2',Party_Number__c ='1234',AccountNumber='12345',Status__c='Active',Type='Partner',Legacy_Id__c ='T1234',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor/Rep Account').getRecordTypeId());
        
        insert acc1;
        system.debug('acc1=='+acc1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
         User u = createTestUser(roleId,p.Id,'Test','Case');
        Id PlmId = [Select id from UserRole where name ='PLM' LIMIT 1].Id;
        user plmUser = [SELECT Id FROM User Where UserRoleId = :PlmId limit 1];
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
        
        Product2 prod = new Product2(IsActive = true,Status__c = 'Active',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
        insert prod;
        Account acountObj = [select id ,recordtypeid,recordtype.name,status__c,type from account where name='Account test2' limit 1];
        System.debug('acountObj'+acountObj);
        
        Quote qrec = new Quote(Name ='test1',Status='Draft',PrimarySalesperson__c =u.id,Type_of_Pricing__c='Dist Quote',ExpirationDate = System.today()+1,
                               Account__c=acc.id,sales_channel__c=acc1.Id);
        system.debug('qrec----'+qrec);
        insert qrec;
        system.debug('qrec1----'+qrec);
        
        List<Quote_Item__c> qList = new List<Quote_Item__c>();
        Quote_Item__c qLine1 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        //insert qLine1;
        qList.add(qLine1);
        
        Quote_Item__c qLine2 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft', PLM_Approver__c = plmUser.id);
        Quote_Item__c qLine3 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft', PLM_Approver__c = plmUser.id);
        Quote_Item__c qLine4 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=26,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft', PLM_Approver__c = plmUser.id);
        Quote_Item__c qLine5 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft', PLM_Approver__c = plmUser.id);
        qList.add(qLine2);
        qList.add(qLine3);
        qList.add(qLine4);
        qList.add(qLine5);
        insert qList;
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(Quote_Item__c qLin :qList){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(qLin.Id);
                        requests.add(req1);
        }
        Approval.process(requests);
        test.startTest();
        ScheduleQuoteReminder schQuoteObj = new ScheduleQuoteReminder();
		String cron = '0 0 23 * * ?'; 
        system.schedule('Test Quote Reminder', cron, schQuoteObj); 
        test.stopTest();
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