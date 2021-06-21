@isTest
public class FileUploadControllerTest {
 @isTest
    static void UploadCSV(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RMA Admin' LIMIT 1].Id;
         User u = createTestUser(roleId,p.Id,'Test','Case');
          System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
         Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId());
        insert globalParentAcc;
        
         Account acc = new Account(name='Account ', Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                  billingcity='New York',ShippingCity = 'New York', ShippingCountry ='US',ParentId = globalParentAcc.Id, Global_Ultimate_Parent__c=globalParentAcc.Id,billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        Account acc1 = new Account(ParentId = acc.Id,name='Account1 ',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States', Legacy_Id__c='1234',ShippingCity = 'Test',ShippingCountry ='US',ShippingState ='NE',ShippingPostalCode ='63572',ShippingStreet = 'Test4',
                billingcity='New York test',Site_Use_Code__c = 'SHIP_TO',Site_Use_Status__c= 'Active', billingcountry='US',Status__c='Active',Type='Reseller',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        
        insert acc1;
         case cs = new Case(Found_By__c='Customer', 
                                  Ship_To_Address__c = acc1.Id,Customer_Name__c=acc.id,Ship_To_Customer__c=acc.id,Outbound_RMA_PO__c='234534',CustomerRef_RMANo__c='67545',Requested_Service__c='Failure Verification Only',  Status='Open',Finisar_Sales_Manager__c=u.id,RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId());
        
        insert cs;
        
        case case2 = new Case(Found_By__c='Customer', 
                                  Ship_To_Address__c = acc1.Id,Customer_Name__c=acc.id,Ship_To_Customer__c=acc.id,Outbound_RMA_PO__c='234534',CustomerRef_RMANo__c='67545',Requested_Service__c='Failure Verification Only',  Status='Pending RMA Admin Review',Finisar_Sales_Manager__c=u.id,RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId());
        
        insert case2;
        string content1 = 'SerialNumber,Description,ReturnReason,POPriceType,SpecialInstructions +\n+ 2345,test,Product Failure,Other,test\n+ 23456,test,,Other,test'; 
        boolean header = True;
        
         string content2 = 'SerialNumber,Description,ReturnReason,POPriceType,SpecialInstructions +\n+ 2345,test,Product Failure,Other,test\n+ 23456,test,Rework,Other,test'; 
        boolean header2 = True;
         string content3 = 'SerialNumber,Description,ReturnReason,POPriceType,SpecialInstructions +\n+ 2345,test,Product Failure,Other,test\n+ 23456,test,Rework,Other,test'; 
        boolean header3 = True;
         string content4 = 'SerialNumber,Description,ReturnReason,POPriceType,SpecialInstructions +\n+ ,,,Product Failure!,Other!,test\n+ ,test,Rework,Other,test'; 
        boolean header4 = True;
         string content5 = 'SerialNumber,Description,ReturnReason,POPriceType,SpecialInstructions +\n+ 2345,test,Product Failure,Other,test\n+ 23456,test,Rework'; 
        boolean header5 = True;
        
        Test.startTest();
        FileUploadController.parseCSV(content1,header,cs.id);
        
        FileUploadController.parseCSV(content2,header2,cs.id);
          FileUploadController.parseCSV(content3,header3,case2.id);
        FileUploadController.parseCSV(content4,header4,case2.id);
        FileUploadController.parseCSV(content5,header5,cs.id);
        Forecast__c fct = new Forecast__c(PLM__c= u.Id);
        insert fct;
        fct.Actual_Revenue__c = 2343;
        fct.RSM__c = U.Id;
        update fct;
        Test.stopTest();
        
    }
    @isTest
    static void ForesatShareTriggerTest(){
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RMA Admin' LIMIT 1].Id;
         User u = createTestUser(roleId,p.Id,'Test','Case');
          System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
        Forecast__c fct = new Forecast__c(RSM__c= u.Id);
        insert fct;
        Test.StartTest();
        fct.Actual_Revenue__c = 2343;
        fct.PLM__c = U.Id;
        update fct;
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