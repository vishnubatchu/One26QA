@isTest
public class FAFVCustomUITest {
 @isTest
    public static void getFAFVDetail(){
        Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id,ShippingCity = 'New York', ShippingCountry ='US',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        Order oRec= new Order(AccountId = acc.id,Type='RMA Order',Status='Draft',Legacy_Id__c='test123',RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('RMA Order').getRecordTypeId(),
                             EffectiveDate = System.today()+1);
        insert oRec;
        Product2 prdRec = new Product2(Name = 'Test1',ProductCode = '12343',Marketing_P_N__c ='7865',Status__c='Concept',ExternalId__c  ='765453');
        insert prdRec;
        Order_Line__c olRec = new Order_Line__c(Order__c=oRec.id,RecordTypeId = Schema.SObjectType.Order_Line__c.getRecordTypeInfosByName().get('RMA Order Line').getRecordTypeId(),RMA_Received_Date__c= System.today(),Part_Number__c= prdRec.id);
        insert olRec;
        
        Serial_Number__c sRec = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Rework');
        insert sRec;
        Serial_Number__c sRec1 = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Rework');
        insert sRec1;
        Serial_Number__c sRec2 = new Serial_Number__c(Order_Line__c=olRec.id,Disposition__c='Rework');
        insert sRec2;
        
        FA_FV_Analysis__c fRec = new FA_FV_Analysis__c(Name= 'test',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert fRec;
        
        FA_FV_Analysis__c fRec1 = new FA_FV_Analysis__c(Name= 'test1',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId()); 
        insert fRec1;
        
         FA_FV_Analysis__c FAFvFinalRecord = new FA_FV_Analysis__c(Name= 'updateInprogress',RecordTypeId = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()); 
        insert FAFvFinalRecord;
        
        FA_FV_Detail__c fdRec = new FA_FV_Detail__c(Serial_Number__c =sRec.id,FA_FV__c=fRec.id,FA_Completion_Date__c= system.today());
        insert fdRec;
        
        FA_FV_Detail__c fdRec1 = new FA_FV_Detail__c(Serial_Number__c =sRec1.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        insert fdRec1;
        
        FA_FV_Detail__c fdRec2 = new FA_FV_Detail__c(Serial_Number__c =sRec2.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        insert fdRec2;
        
        List<FA_FV_Analysis__c> FAFVList = new  List<FA_FV_Analysis__c>();
        FAFVList.add(fRec);
        FAFVList.add(fRec1);
        
        Failure_Modes__c fc= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        Failure_Modes__c fc1= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        Failure_Modes__c fc2= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        Failure_Modes__c fc3= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        Failure_Modes__c fc4= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        Failure_Modes__c fmode5= new Failure_Modes__c(FAFV_Analysis__c =fRec.id,Fault_Specification__c='Defective',PDC_Level_2__c='Crack',PIC_Level_1__c =
                                                  'Component',PDC_Level_1__c='Flex',PIC_Level_2__c='Adhesive/Epoxy',Site__c='IPH' );
        
        List<Failure_Modes__c> fcList = new List<Failure_Modes__c>();
        fcList.add(fc);
        fcList.add(fc1);
        fcList.add(fc2);
        fcList.add(fc3);
        fcList.add(fc4);
        
        
        Steps__c  steps = new Steps__c(Name='test',FA_FV__c=fRec.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        Steps__c  steps1 = new Steps__c(Name='test',FA_FV__c=fRec.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        Steps__c  steps2 = new Steps__c(Name='test',FA_FV__c=fRec.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        Steps__c  steps3 = new Steps__c(Name='test',FA_FV__c=fRec.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        Steps__c  steps4 = new Steps__c(Name='test',FA_FV__c=fRec.id,FA_Findings__c='testtt',Comments__c='test',FA_Steps_Description_FA_Steps__c='testt');
        List<Steps__c> stepList = new List<Steps__c>();
        stepList.add(steps);
        stepList.add(steps1);
        stepList.add(steps2);
        stepList.add(steps3);
        stepList.add(steps4);
       
        FA_FV_Detail__c fdRecc = new FA_FV_Detail__c(Serial_Number__c =sRec.id,FA_FV__c=fRec.id,FA_Completion_Date__c= system.today());
        FA_FV_Detail__c fdRecc1 = new FA_FV_Detail__c(Serial_Number__c =sRec1.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        FA_FV_Detail__c fdRecc2 = new FA_FV_Detail__c(Serial_Number__c =sRec2.id,FA_FV__c=fRec1.id,FA_Completion_Date__c= system.today());
        list<FA_FV_Detail__c> DetailLists  = new list<FA_FV_Detail__c>();
        DetailLists.add(fdRecc);
        DetailLists.add(fdRecc1);
        DetailLists.add(fdRecc2);
        
        Test.startTest();
        FAFVCustomUI.getFAFVRecord(oRec.id);
        FAFVCustomUI.saveFAFV(fdRec2, FAFVList);
        FAFVCustomUI.savefCodeRec(fcList);
        FAFVCustomUI.saveStepsRec(stepList);
        FAFVCustomUI.saveSnoRec(DetailLists);
        FAFVCustomUI.getFAFVrelatedList(fRec.id, olRec.id);
        FAFVCustomUI.deleteRow(fdRecc.id);
        Test.stopTest();
        
    }
}