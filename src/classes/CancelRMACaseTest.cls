@isTest
public class CancelRMACaseTest{

     @isTest
    public static void updateCase(){
      Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
            insert globalParentAcc;
         Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id,Display_Shipping_Country__c ='United States',  Display_Billing_Country__c = 'United States',
                                  billingcity='New York', billingcountry='US',ShippingCity = 'New York', ShippingCountry ='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Account acc1 = new Account(name='Account test',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                  billingcity='Illionis',ShippingCity = 'New York', ShippingCountry ='US',ParentId=globalParentAcc.id, billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc1;
        Account shiptocustomer = new Account(name='AccountCustomer1 ',EC__c = 'test',Display_Shipping_Country__c ='United States',  Display_Billing_Country__c = 'United States',
                                   Source_System__c ='Oracle-EBS',ParentId=acc1.Id,Status__c='Active',ShippingCity = 'New York', ShippingCountry ='US',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
        insert shiptocustomer;
         Account siteacc = new Account(name='AccountSite ',Display_Shipping_Country__c ='United States',  Display_Billing_Country__c = 'United States',
                                      ShippingCity = 'New York',Site_Use_Code__c='SHIP_TO',Site_Use_Status__c='Active',parentId=shiptocustomer.id, shippingcountry='US',Status__c='Active',Type='Site',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        insert siteacc;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        User u = createTestUser(roleId,p.Id,'Mark','Robinson');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
        system.debug('u==='+u);
        system.debug('acc==='+acc);
        system.debug('acc1==='+acc1);
        Id recordid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId();
       list<case> caseList = new list<Case>();
        case c= new case(Status='Open',RecordTypeId = recordid,Ship_To_Address__c=siteacc.id,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc1.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id);
        caseList.add(c);
        case c1= new case(Status='Open',RecordTypeId = recordid,Ship_To_Address__c=siteacc.id,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc1.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id,Return_Reason__c='Rework');
         caseList.add(c1);
        case c2= new case(Status='Open',RecordTypeId = recordid,Ship_To_Address__c=siteacc.id,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc1.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id ,Return_Reason__c='Rework');
         caseList.add(c2);
        insert caseList;
        list<RMA_Request_Line__c> rmReqstLists = new list<RMA_Request_Line__c>();
        RMA_Request_Line__c rmaLine = new RMA_Request_Line__c(RMA_Request__c=caseList[0].id,name='test',Return_Reason__c='Rework');
        rmReqstLists.add(rmaLine);
        RMA_Request_Line__c rmaLine2 = new RMA_Request_Line__c(RMA_Request__c=caseList[1].id,name='test2',Return_Reason__c='Rework',PO_Price__c='Other');
        rmReqstLists.add(rmaLine2);
        RMA_Request_Line__c rmaLine3 = new RMA_Request_Line__c(RMA_Request__c=caseList[2].id,name='test1',Org_Code__c='KOR',Return_Reason__c='Rework');
        rmReqstLists.add(rmaLine3);
        insert rmReqstLists;
        Test.startTest();
        CancelRMACase.getDetailsCondition(caseList[0].id);
        CancelRMACase.getDetailsCondition(caseList[1].id);
        CancelRMACase.getDetailsCondition(caseList[2].id);
        Test.stopTest(); 
    }
     @isTest
    public static void updateCase1(){
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',ShippingCity = 'New York',Display_Billing_Country__c = 'United States',Display_Shipping_Country__c ='United States',  ShippingCountry ='US',RecordTypeId=getRecordTypeIdByName('Global Parent'));
        insert globalParentAcc;
        
         Account acc = new Account(name='Account ', ParentId=globalParentAcc.Id,Display_Billing_Country__c = 'United States',Display_Shipping_Country__c ='United States', 
                                  billingcity='New York', ShippingCity = 'New York', ShippingCountry ='US',billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
 		Account shiptocustomer = new Account(name='AccountCustomer1 ', Display_Billing_Country__c = 'United States',Display_Shipping_Country__c ='United States', 
                                   Source_System__c ='Oracle-EBS',ParentId=acc.Id,ShippingCity = 'New York', ShippingCountry ='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId());
        insert shiptocustomer;
         Account siteacc = new Account(name='AccountSite ',EC__c = 'test',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',
                                      shippingcity='New York',Site_Use_Code__c='SHIP_TO',Site_Use_Status__c='Active',parentId=shiptocustomer.id, shippingcountry='USA',Status__c='Active',Type='Site',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId());
        insert siteacc;
   
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        User u = createTestUser(roleId,p.Id,'Mark','Robinson');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
             insert u;
        }
        system.debug('u==='+u);
        system.debug('acc==='+acc);
        Id recordid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Request').getRecordTypeId();
        list<case> caseList = new list<Case>();
        case c= new case(Status='Open',RecordTypeId = recordid,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Ship_To_Address__c=siteacc.id,Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id ,Return_Reason__c='Rework');
        caseList.add(c);
        case c1= new case(Status='Open',RecordTypeId = recordid,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Ship_To_Address__c=siteacc.id,Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id,Return_Reason__c='Rework');
        caseList.add(c1);
        
        case c2= new case(Status='Open',RecordTypeId = recordid,Finisar_Sales_Manager__c= u.id,Customer_Name__c=acc.id,AccountId=acc.id,Requested_Service__c='Loaner Return',CustomerRef_RMANo__c='Test',
                        Ship_To_Address__c=siteacc.id,Outbound_RMA_PO__c='Test',Ship_To_Customer__c=shiptocustomer.id,Return_Reason__c='Rework');
        caseList.add(c2);
        insert caseList;
        list<RMA_Request_Line__c> rmaRestList = new list<RMA_Request_Line__c>();
        RMA_Request_Line__c rmaLine = new RMA_Request_Line__c(RMA_Request__c=caseList[0].id,name='test',Return_Reason__c='Rework',
                                                              PO_Price__c='Other',Org_Code__c='KOR',End_Customer__c='Testtt');
        rmaRestList.add(rmaLine);
        RMA_Request_Line__c rmaLine1 = new RMA_Request_Line__c(RMA_Request__c=caseList[0].id,name='test1',End_Customer__c='test1',Return_Reason__c='Rework');
        rmaRestList.add(rmaLine1);
        
         RMA_Request_Line__c rmaLine2 = new RMA_Request_Line__c(RMA_Request__c=caseList[1].id,name='test',Return_Reason__c='Rework',PO_Price__c='Other');
        rmaRestList.add(rmaLine2);
        RMA_Request_Line__c rmaLine22 = new RMA_Request_Line__c(RMA_Request__c=caseList[1].id,name='test2',Return_Reason__c='Rework',PO_Price__c='Other');
        rmaRestList.add(rmaLine22);
        
        RMA_Request_Line__c rmaLine3 = new RMA_Request_Line__c(RMA_Request__c=caseList[2].id,name='test1',Org_Code__c='KOR',Return_Reason__c='Rework');
        rmaRestList.add(rmaLine3);
        
        /*RMA_Request_Line__c rmaLine4 = new RMA_Request_Line__c(RMA_Request__c=c2.id,name='test1',Error_Message__c='Serial Number is not Valid');
        insert rmaLine4;*/
        
        RMA_Request_Line__c rmaLine33 = new RMA_Request_Line__c(RMA_Request__c=caseList[2].id,name='test3',Return_Reason__c='Rework',PO_Price__c='Other');
        rmaRestList.add(rmaLine33);
        insert rmaRestList;
        Test.startTest();
        CancelRMACase.getDetailsCondition(caseList[0].id);
        CancelRMACase.getDetailsCondition(caseList[1].id);
        CancelRMACase.getDetailsCondition(caseList[2].id);
        FA_FV_Analysis__c fRec = new FA_FV_Analysis__c(Name= 'test',Legacy_Id__c = '12342',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert fRec;
        Failure_Modes__c fc= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        insert fc;
        Delete fc;
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
    
    static Id getRecordTypeIdByName(String recordTypeName){
       return [Select Id from RecordType where Name=:recordTypeName].Id;
    }
}