@isTest(seeAllData = false)
private class CreateOrderedPartsForOrderTest {
@testSetup static void data() {
          Pricebook2 pb2  = new pricebook2(name='Legacy Marlow Products', CurrencyIsoCode  = 'USD',IsActive  = true);
   insert pb2;
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
        List<Order> orders = TestDataFactory.createOrders(opp[0].Id, acc[0].Id, 1);
        orders[0].Pricebook2Id = pricel[0].Id;
        update orders;
        List<Order_Line__c> items = TestDataFactory.createOrderLines(orders[0].Id, prd[0].Id, pb.Id, 2);        
    }
    @isTest
    static void testcreateBOM(){
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
        
        Order_Line__c orLine = [SELECT Id, Order__c FROM Order_Line__c LIMIT 1];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(orLine);
        CreateOrderedPartsForOrder testaddOpp = new CreateOrderedPartsForOrder(sc);
        BOM_Product_Part__c bom = [SELECT Id,BOM_Part__r.Quantity__c, Sequence__c, BOM_Part__r.Name, BOM_Part__r.Deutch_Description__c,
                                   BOM_Part__r.English_Description__c, BOM_Part__r.English_Rich_Text_Description__c, BOM_Part__r.Deutsch_Rich_Text_Description__c from BOM_Product_Part__c LIMIT 1];
        CreateOrderedPartsForOrder.ClassBOMProdWrapper wrp = new CreateOrderedPartsForOrder.ClassBOMProdWrapper();
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
        Order_Line__c orLine = [SELECT Id, Order__c FROM Order_Line__c LIMIT 1];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(orLine);
        CreateOrderedPartsForOrder testaddOpp = new CreateOrderedPartsForOrder(sc);
        test.stopTest();
    }
}