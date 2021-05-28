@isTest(seeAllData = false)
private class CreateTransferQuote_ControllerTest {
    @isTest
    static void testcreateTransferQuotes(){
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc     = TestDataFactory.createAccounts(2);
        acc[1].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId();
        update acc[1];
        acc[0].Status__c      = 'Active';
        acc[0].RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Party_Account').getRecordTypeId();
        acc[0].ParentId     = acc[1].Id;
update acc[0];
    system.debug('price book '+[Select id,Name from Pricebook2]);
        system.debug('standard '+ Test.getStandardPricebookId());
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 2, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Laser Part List' AND CurrencyIsoCode = 'USD'];
        system.debug('pricel '+pricel);
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        update opp;
        PriceBookEntry pb = [Select Id from PriceBookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
        TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
        CreateTransferQuote_Controller testcreateQuote = new CreateTransferQuote_Controller(sc);
       // PageReference pageRef = Page.CreateQuote;
        //Test.setCurrentPage(pageRef);
        testcreateQuote.currecyIdAndName = 'CHF';
        testcreateQuote.createQuote();
        test.stopTest();
    }
}