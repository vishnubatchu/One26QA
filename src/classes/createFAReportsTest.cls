@isTest
public class createFAReportsTest {
 @isTest
    static void getOrderLineRecords()
    {
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        
        Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Order oRec= new Order(AccountId = acc.id,Type='RMA Order',Status='Draft',Legacy_Id__c='test123',RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('RMA Order').getRecordTypeId(),
                             EffectiveDate = System.today()+1);
        insert oRec;
        
        Order_Line__c olRec = new Order_Line__c(Order__c=oRec.id,RecordTypeId = Schema.SObjectType.Order_Line__c.getRecordTypeInfosByName().get('RMA Order Line').getRecordTypeId(),RMA_Received_Date__c= System.today());
        insert olRec;
        
        Serial_Number__c sRec = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Return');
        insert sRec;
        Serial_Number__c sRec1 = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Return');
        insert sRec1;
        Serial_Number__c sRec2 = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Return');
        insert sRec2;
        
        FA_FV_Analysis__c fRec = new FA_FV_Analysis__c(Name= 'test',Legacy_Id__c ='testttt112',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert fRec;
        
        FA_FV_Analysis__c fRec1 = new FA_FV_Analysis__c(Name= 'test1',Legacy_Id__c ='testttt111',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert fRec1;
        
        FA_FV_Detail__c fdRec = new FA_FV_Detail__c(Serial_Number__c =sRec.id,FA_FV__c=fRec.id,FA_Completion_Date__c= system.today());
        insert fdRec;
        
        FA_FV_Detail__c fdRec1 = new FA_FV_Detail__c(Serial_Number__c =sRec1.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        insert fdRec1;
        
        FA_FV_Detail__c fdRec2 = new FA_FV_Detail__c(Serial_Number__c =sRec2.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        insert fdRec2;
        List<String> serialId = new List<String>();
        serialId.add(sRec.id);
        serialId.add(sRec1.id);
        serialId.add(sRec2.id);
        List<Serial_Number__c> serialList = new List<Serial_Number__c>();
        serialList.add(sRec);
        serialList.add(sRec1);
        serialList.add(sRec2);
        List<FA_FV_Analysis__c> faList = new List<FA_FV_Analysis__c>();
        faList.add(fRec);
        faList.add(fRec1);
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.FAAndFVReport')); 
        ApexPages.currentPage().getParameters().put('orderLine', olRec.id);
        String selectedserials=String.join(serialId,',');
        ApexPages.currentPage().getParameters().put('selectedSerialNumber', selectedserials);
        createFAReports control = new createFAReports();
        createFAReports.ol =olRec;
        createFAReports.sN =serialList;
        createFAReports.fA =faList;
        createFAReports.getOrderlineData(olRec.id);
        createFAReports.getSerialNumberData(serialId);
        createFAReports.getFAFVData(serialId);
        createFAReports.getSerialNumber(oRec.id);
        createFAReports.prepareMapforSerialNumberTable(serialId);
        //createFAReports.getFADetails(serialId);
        Test.stopTest();
        
        
    }
}