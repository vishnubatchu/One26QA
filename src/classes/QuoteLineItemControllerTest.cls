@isTest
public class QuoteLineItemControllerTest {
    @isTest
    static void createQuoteLine(){
           Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acc = new Account(name='Account ',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='Illionis', billingcountry='USA',Status__c='Active',Type='Distributor',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('External Account').getRecordTypeId());
        
        insert acc1;
        system.debug('acc1=='+acc1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
         User u = createTestUser(roleId,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
                String roleId2 =[select Id,name from UserRole where Name='Marketing Admin WSS' LIMIT 1].Id;
          User u2 = createTestUser(roleId2,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u2;
        }
         Opportunity opp = New Opportunity(Name = acc.Name+' Opp',RSM__c = u.id,Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acc.Id, CloseDate = date.today().addDays(365));
        insert opp;
        Product2 prod = new Product2(IsActive = true,Status__c = 'Active',BU_Code__c = '0040',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
        insert prod;
        
        
        Quote qrec = new Quote(Name ='test',Status='Draft',OpportunityId =opp.id,PrimarySalesperson__c =u2.id,Type_of_Pricing__c='Fixed - One Time Order',ExpirationDate = System.today()+1,
                               Account__c=acc.id);
        insert qrec;
        system.debug('qrec==='+qrec);
        List<Quote_Item__c> qList = new List<Quote_Item__c>();
        Quote_Item__c qLine1 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Target_Price__c=4564.77,Line_Status__c='Draft');
        insert qLine1;
        qList.add(qLine1);
          list<id> qtList = new list<id>();
          qtList.add(qLine1.id);
        Quote_Item__c qLine2 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine3 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine4 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=26,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine5 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Target_Price__c=4564.77,Line_Status__c='Draft');
        qList.add(qLine2);
        qList.add(qLine3);
        qList.add(qLine4);
        qList.add(qLine5);
        String s = JSON.serialize(qList);
        Test.startTest();
        QuoteLineItemController.updatePLM(qtList);
        QuoteLineItemController.getQuoteLineItem(qrec.id);
        //QuoteLineItemController.saveQuoteLineItem(s,qrec.id);
        //QuoteLineItemController.getLineStatus(qLine1.id);
        QuoteLineItemController.sendRequesttoInformatica(qrec.id);
        QuoteLineItemController.validateRulesRecords(qrec.id);
        QuoteLineItemController.deleteLoanerLineItem(qLine1);
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
    
  @isTest
    static void createQuoteLine2(){  
        
            Account globalParentAcc=new Account(Name='Global Parent Test Acc2',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acc = new Account(name='Account ',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test2',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', parentId=globalParentAcc.id,ShippingCity = 'New York', ShippingCountry ='US',
                                  billingcity='Illionis', billingcountry='USA',Status__c='Active',Type='Distributor',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc1;
        system.debug('acc1=='+acc1);
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
         User u = createTestUser(roleId,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
                   String roleId2 =[select Id,name from UserRole where Name='Marketing Admin WSS' LIMIT 1].Id;
          User u2 = createTestUser(roleId2,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u2;
        }
         Opportunity opp = New Opportunity(Name = acc.Name+' Opp',RSM__c = u.id,Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acc.Id, CloseDate = date.today().addDays(365));
        insert opp;
        Product2 prod = new Product2(IsActive = true,Status__c = 'Active',BU_Code__c = '0040',Name = 'Test Product',ExternalId__c = '12534', ProductCode = 'Test Product Code',Marketing_P_N__c = 'Test PN');
        insert prod;
        Account acountObj = [select id ,recordtypeid,recordtype.name,status__c,type from account where name='Account test2' limit 1];
        System.debug('acountObj'+acountObj);
        
        Quote qrec = new Quote(Name ='test1',OpportunityId =opp.id,Status='Draft',PrimarySalesperson__c =u2.id,Type_of_Pricing__c='Dist Quote',ExpirationDate = System.today()+1,
                               Account__c=acc.id,sales_channel__c=acc1.Id);
        system.debug('qrec----'+acc1.Type + 'status ' + acc1.Status__c);
        insert qrec;
        List<Quote_Item__c> qList = new List<Quote_Item__c>();
        Quote_Item__c qLine1 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        insert qLine1;
        qList.add(qLine1);
        list<id> qtList = new list<id>();
        qtList.add(qLine1.id);
        Quote_Item__c qLine2 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=23,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine3 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine4 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=26,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        Quote_Item__c qLine5 = new Quote_Item__c(Quote__c= qrec.id,Product__c=prod.id,Quantity__c=25,Disti_Resale_Price__c=5600.05,Target_Price__c=4564.77,Line_Status__c='Draft');
        qList.add(qLine2);
        qList.add(qLine3);
        qList.add(qLine4);
        qList.add(qLine5);
     
        String s = JSON.serialize(qList);
        Test.startTest();
        QuoteLineItemController.updatePLM(qtList);
        QuoteLineItemController.getQuoteLineItem(qrec.id);
        QuoteLineItemController.saveQuoteLineItem(qList,qrec.id);
        //QuoteLineItemController.getLineStatus(qLine1.id);
        QuoteLineItemController.sendRequesttoInformatica(qrec.id);
        QuoteLineItemController.validateRulesRecords(qrec.id);
        QuoteLineItemController.deleteLoanerLineItem(qLine1);
        
        
        //Quote Approval Controller Test cases
        
        Id appRecordIdId = [select id from Quote limit 1].Id;
        List<String> appRecordId = new List<String>();
        appRecordId.add(appRecordIdId);
        QuoteApprovalController.QuoteQuery([select id from Quote limit 1].Id);
        QuoteApprovalController.ApproveRecords(appRecordId,[select id from Quote limit 1].Id);
        QuoteApprovalController.RejectRecords(appRecordId);
        QuoteApprovalController.ReasignRecords(appRecordId,'test@mail.com',[select id from Quote limit 1].Id);
        
        Test.stopTest();
    }
}