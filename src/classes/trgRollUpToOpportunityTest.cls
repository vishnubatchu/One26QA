@IsTest(seeAllData = true)
    public class trgRollUpToOpportunityTest{
        private static testmethod void trgRollUpToOpportunityTest1(){
       Account globalParentAcc=new Account(Name='Global Parent432',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
            insert globalParentAcc;
         Account acc = new Account(name='Account ',ParentId=globalParentAcc.Id,Display_Shipping_Country__c ='United States',  Display_Billing_Country__c = 'United States',
                                  billingcity='New York', billingcountry='US',ShippingCity = 'New York', ShippingCountry ='US',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        Test.StartTest();
            insert acc;
              Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
            opportunity opp = new opportunity();
            opp.Name='Test';
            opp.Pricebook2ID = customPB.Id;
            opp.CloseDate =date.today().addDays(5);
            opp.AccountId =acc.id;
            opp.StageName ='Closed Won';
            opp.Qual_Required__c = 'Yes';
            opp.Marlow_Product_BU__c = 'Power';
            opp.Project_Name__c  = 'Test';
            insert opp;
            System.AssertEquals(opp.Pricebook2ID,customPB.Id);
             
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
            list<OpportunityLineItem> opLineList = new list<OpportunityLineItem>();
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pe.Id;
            oli.Quantity = 1;
            oli.UnitPrice = 1000;
            oli.Business_Unit_Name__c = 'Systems';
            opLineList.add(oli); 
            
            OpportunityLineItem oli1 = new OpportunityLineItem();
            oli1.OpportunityId = opp.Id;
            oli1.PricebookEntryId = pe.Id;
            oli1.Quantity = 1;
            oli1.UnitPrice = 1000;
            oli1.Business_Unit_Name__c = 'Systems';
            opLineList.add(oli1);
            
            insert opLineList;
            opp.Business_Unit_Name_Product_Rollup__c = opLineList[1].Business_Unit_Name__c;
            update opp;
            system.AssertEquals(opp.Business_Unit_Name_Product_Rollup__c,'Systems');
        Test.StopTest();
    }
}