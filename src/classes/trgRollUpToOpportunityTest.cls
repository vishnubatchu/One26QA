@IsTest(seeAllData = true)
    public class trgRollUpToOpportunityTest{
        private static testmethod void trgRollUpToOpportunityTest1(){
        Account acc = new Account();
        acc.name='Test Account';
        Test.StartTest();
            insert acc;
            Pricebook2 standardPB;
            standardPB = [SELECT Id, Name FROM PriceBook2 Limit 1];
            
            opportunity opp = new opportunity();
            opp.Name='Test';
            opp.Pricebook2ID = standardPB.Id;
            opp.CloseDate =date.today().addDays(5);
            opp.AccountId =acc.id;
            opp.StageName ='Closed Won';
            opp.Qual_Required__c = 'Yes';
            opp.Business_Unit__c = 'Power';
            insert opp;
            System.AssertEquals(opp.Pricebook2ID,standardPB.Id);
             
            Product2 p = new Product2();
            p.ProductCode = 'Test';
            p.Name = 'TestName';
            p.description ='On Premise License';
            p.isactive=true;
            insert p;
            System.assertEquals(p.isactive, true);
            
            PricebookEntry pe = new PricebookEntry();
            pe.Product2Id = p.Id;
            pe.Pricebook2Id = standardPB.Id;
            pe.UnitPrice = 1000;
            pe.IsActive = true;
            insert pe;
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId = pe.Id;
            oli.Quantity = 1;
            oli.UnitPrice = 1000;
            oli.Business_Unit_Name__c = 'Systems';
            insert oli; 
            
            OpportunityLineItem oli1 = new OpportunityLineItem();
            oli1.OpportunityId = opp.Id;
            oli1.PricebookEntryId = pe.Id;
            oli1.Quantity = 1;
            oli1.UnitPrice = 1000;
            oli1.Business_Unit_Name__c = 'Systems';
            insert oli1;  
            
            opp.Business_Unit_Name_Product_Rollup__c = oli1.Business_Unit_Name__c;
            update opp;
            system.AssertEquals(opp.Business_Unit_Name_Product_Rollup__c,'Systems');
        Test.StopTest();
    }
    
 
   
            
}