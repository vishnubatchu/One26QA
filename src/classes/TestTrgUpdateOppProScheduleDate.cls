@IsTest(Seealldata=true)
public class TestTrgUpdateOppProScheduleDate{
    private static testmethod void trgUpdateOppProScheduleDateTest(){
        Account acc = new Account();
        acc.name='Test Account';
        insert acc;
        
        Pricebook2 standardPB = [SELECT Id, Name FROM PriceBook2 Limit 1];
        
        opportunity opp = new opportunity();
        opp.Name='Test';
        opp.Pricebook2ID = standardPB.Id ;
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
        pe.Pricebook2Id = standardPB.Id;
        pe.UnitPrice = 1000;
        pe.IsActive = true;
        insert pe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 1000;
        insert oli; 
          OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pe.Id;
        oli2.Quantity = 3;
        oli2.UnitPrice = 10000;
        insert oli2; 
         OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pe.Id;
        oli3.Quantity = 3;
        oli3.UnitPrice = 10000;
        insert oli3; 
        
        update oli;  
        
    }
}