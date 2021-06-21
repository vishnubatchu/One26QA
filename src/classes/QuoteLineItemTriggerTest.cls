@isTest(seeAllData = false)
private class QuoteLineItemTriggerTest {
    @istest
    static void testQuoteItemTrigger(){
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc = TestDataFactory.createAccounts(1);
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 2, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Legacy Marlow Products' AND CurrencyIsoCode = 'USD'];
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        update opp;
        PriceBookEntry pb = [Select Id from PriceBookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
        //TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
        test.startTest();
        List<Quote> qts = TestDataFactory.createQuote(opp[0].Id, pricel[0].Id, 1);
        List<Quote_Item__c> qLines =  TestDataFactory.createQuoteLines(qts[0].Id, prd[0].Id, pb.id, 1);
        TestDataFactory.createQuoteRatePlan(qLines[0].Id, 20, 100);
        qLines[0].Quantity__c  = 30;
        update qLines;
        test.stopTest();
    }
}