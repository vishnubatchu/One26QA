@isTest(seeAllData = false)
private class CloneOppWithDiffCurrecnyControllerTest {
    @testSetup static void data() {
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc = TestDataFactory.createAccounts(1);
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 2, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Legacy Marlow Products' AND CurrencyIsoCode = 'USD'];
        system.debug('pricel '+pricel);
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        
        update opp;
        PriceBookEntry pb = [Select Id from PriceBookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
        TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
    }
    @isTest
    static void testcloneOpp(){
        Opportunity opp = [SELECT Id, Name,CurrencyIsoCode,Amount,StageName,Project_Name__c,Qual_Required__c, CloseDate, AccountId, Pricebook2Id FROM Opportunity LIMIT 1];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        CloneOppWithDiffCurrecny_Controller testcloneOpp = new CloneOppWithDiffCurrecny_Controller(sc);
        testcloneOpp.currecyIdAndName = 'CHF';
        testcloneOpp.cloneOpp();
        test.stopTest();
    }
}