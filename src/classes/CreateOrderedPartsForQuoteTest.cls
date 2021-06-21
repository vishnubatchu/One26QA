@isTest(seeAllData = false)
private class CreateOrderedPartsForQuoteTest {
    @testSetup static void data() {
        Pricebook2 pb2  = new pricebook2(name='Legacy Marlow Products', CurrencyIsoCode  = 'USD',IsActive  = true);
        insert pb2;
        List<Account> acc = TestDataFactory.createAccounts(1);
        List<Opportunity> opp = TestDataFactory.createOpportunity(1, acc[0].Id);
        List<Product2> prd = TestDataFactory.createProducts('2', 1, false);
        List<Pricebook2> pricel = [Select Id from Pricebook2 Where Name = 'Legacy Marlow Products' AND CurrencyIsoCode = 'USD'];
        system.debug('pricel '+pricel);
        opp[0].Pricebook2Id = pricel[0].Id;
        opp[0].CurrencyIsoCode = 'USD';
        update opp;
        
        PricebookEntry pb = [Select Id from PricebookEntry Where product2Id = :prd[0].Id AND CurrencyIsoCode = 'USD' AND PriceBook2Id = :pricel[0].Id limit 1];
        
        List<OpportunityLineItem> oppLines = TestDataFactory.creatOppLine(opp[0].Id, 2, prd[0].Id, pb.id);
        TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
        /*List<Quote> qts = TestDataFactory.createQuote(opp[0].Id, pricel[0].Id, 1);
        List<Quote_Item__c> qLines =  TestDataFactory.createQuoteLines(qts[0].Id, prd[0].Id, pb.id, 1);*/  
        
    }
    @isTest
    static void testcreateBOM(){
        test.startTest();
        
        OpportunityLineItem oppLine=[Select Id,OpportunityId,Product2Id,PriceBookEntryId from OpportunityLineItem LIMIT 1];
        PricebookEntry pbEntry = [Select Id,product2Id,Pricebook2Id from PricebookEntry Where product2Id = :oppLine.Product2Id AND CurrencyIsoCode = 'USD' limit 1];
        List<Quote> qts = TestDataFactory.createQuote(oppLine.OpportunityId, pbEntry.Pricebook2Id, 1);
        List<Quote_Item__c> qLines =  TestDataFactory.createQuoteLines(qts[0].Id, oppLine.Product2Id, pbEntry.id, 1);
        
       Product2 prd = [select Id from Product2 limit 1];
        BOM_Parts__c bompart12 = new BOM_Parts__c();
        bompart12.Name = 'Test123';
        bompart12.Quantity__c = 12;
        
        insert bompart12;
        
        BOM_Product_Part__c bompartProd= new BOM_Product_Part__c();
        bompartProd.BOM_Part__c = bompart12.id;
        bompartProd.Product__c = prd.id;
        bompartProd.Quantity__c = 12;
        
        insert bompartProd;
        
        Quote_Item__c qtLine = [SELECT Id, Quote__c FROM Quote_Item__c LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qtLine);
        CreateOrderedPartsForQuote testaddOpp = new CreateOrderedPartsForQuote(sc);
        BOM_Product_Part__c bom = [SELECT Id,BOM_Part__r.Quantity__c, Sequence__c, BOM_Part__r.Name, BOM_Part__r.Deutch_Description__c,
                                   BOM_Part__r.English_Description__c, BOM_Part__r.English_Rich_Text_Description__c, BOM_Part__r.Deutsch_Rich_Text_Description__c from BOM_Product_Part__c LIMIT 1];
        CreateOrderedPartsForQuote.ClassBOMProdWrapper wrp = new CreateOrderedPartsForQuote.ClassBOMProdWrapper();
        wrp.bomProd = bom;
        wrp.isSelected = true;
        testaddOpp.listOfClassBOMProdWrapper.add(wrp);
        testaddOpp.cancel();
        testaddOpp.addParts();
        testaddOpp.sortListByName();
        testaddOpp.sortListByPostion();
        testaddOpp.removeBOMOrderedProduct();
        testaddOpp.save();
        test.stopTest();
    }
    @isTest
    static void testcreateBOMExp(){
        Test.startTest();
        OpportunityLineItem oppLine=[Select Id,OpportunityId,Product2Id,PriceBookEntryId from OpportunityLineItem LIMIT 1];
        PricebookEntry pbEntry = [Select Id,product2Id,Pricebook2Id from PricebookEntry Where product2Id = :oppLine.Product2Id AND CurrencyIsoCode = 'USD' limit 1];
        List<Quote> qts = TestDataFactory.createQuote(oppLine.OpportunityId, pbEntry.Pricebook2Id, 1);
        List<Quote_Item__c> qLines =  TestDataFactory.createQuoteLines(qts[0].Id, oppLine.Product2Id, pbEntry.id, 1);
        //Quote_Item__c qtLine = [SELECT Id, Quote__c FROM Quote_Item__c LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(qLines[0]);
        CreateOrderedPartsForQuote testaddOpp = new CreateOrderedPartsForQuote(sc);
        test.stopTest();
    }
}