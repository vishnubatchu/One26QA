@isTest
private class CloneOpportunityExtensionTest {
@testSetup static void data() {
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc = TestDataFactory.createAccounts(1);
        system.debug('price book '+[Select id,Name from Pricebook2]);
        system.debug('standard '+ Test.getStandardPricebookId());
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 2, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Legacy Marlow Products' AND CurrencyIsoCode = 'USD'];
        system.debug('pricel '+pricel);
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        update opp;
        PriceBookEntry pb = [Select Id from PriceBookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
    BOM_Parts__c bp = new BOM_Parts__c();
    bp.Name = 'test';
    insert bp;
    BOM_Product_Part__c   bpp = new BOM_Product_Part__c(); 
    bpp.BOM_Part__c   = bp.id;
 bpp.Name = 'test'; 
    insert bpp;
    Ordered_BOM_Parts__c obp = new Ordered_BOM_Parts__c();
    obp.OpportunityProduct__c = oppLines[0].id;
    obp.BOM_Product_Part__c  = bpp.id;
    insert obp;
        TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
    }
    @isTest
    static void testcloneOpp(){
        Opportunity opp = [SELECT Id, Name,Project_Name__c,Qual_Required__c,CurrencyIsoCode,Amount,StageName, CloseDate, AccountId, Pricebook2Id FROM Opportunity LIMIT 1];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        CloneOpportunityExtension testcloneOpp = new CloneOpportunityExtension(sc);
        testcloneOpp.cloneOpp();
        test.stopTest();
    }
}