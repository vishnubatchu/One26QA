@IsTest(Seealldata=true)
public class TestTrgUpdateOppProScheduleDate{
    private static testmethod void trgUpdateOppProScheduleDateTest(){
        Account globalParentAcc=new Account(Name='Global Parent',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
            insert globalParentAcc;
         Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id,Display_Shipping_Country__c ='United States',  Display_Billing_Country__c = 'United States',
                                  billingcity='New York', billingcountry='US',ShippingCity = 'New York', ShippingCountry ='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        
        
         Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        opportunity opp = new opportunity();
        opp.Name='Test';
        opp.Pricebook2ID = customPB.Id ;
        opp.CloseDate=date.today().addDays(5);
        opp.AccountId=acc.id;
        opp.StageName='Closed Won';
        opp.Business_Unit__c = 'Power';
        opp.Qual_Required__c ='Yes';
        opp.Project_Name__c   = 'Test'; 
        insert opp;
         
        
        Product2 p = new Product2();
        p.ProductCode = 'Test';
        p.Name = 'TestName';
        p.description ='On Premise License';
        p.isactive=true;
        insert p;
        System.assertEquals(p.isactive, true);
        
        PricebookEntry pe = new PricebookEntry();
        pe.Product2Id = p.Id;
        pe.Pricebook2Id = customPB.Id;
        pe.UnitPrice = 1000;
        pe.IsActive = true;
        insert pe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 1000;
        insert oli; 
         
        
    }
}