@isTest(seeAllData = false)
private class OrderRatePlanControllerTest {
    @testSetup static void methodName() {
        //Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Pricebook2> priceBookList = new List<Pricebook2>();
        priceBookList.add(new Pricebook2(Name = 'Legacy Finisar Products', IsActive=true));
        priceBookList.add(new Pricebook2(Name = 'Legacy Photonics Products', IsActive=true));
        priceBookList.add(new Pricebook2(Name = 'Legacy Marlow Products', IsActive=true));
        priceBookList.add(new Pricebook2(Name = 'Legacy II-VI Epiworks Products',IsActive=true));
        insert priceBookList; 
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
        TestDataFactory.createOppRatePla(oppLines[0].Id, 10, 100);
        List<Order> orders = TestDataFactory.createOrders(opp[0].Id, acc[0].Id, 1);
        orders[0].Pricebook2Id = pricel[0].Id;
        update orders;
        List<Order_Line__c> items = TestDataFactory.createOrderLines(orders[0].Id, prd[0].Id, pb.Id, 2);
       // TestDataFactory.createOrderRatePlan(items[0].Id, 20, 90);
    }
    @istest
    static void testAddOrderRate(){
        List<Order_Line__c> items = [SELECT Id, Quantity__c, TotalPrice__c FROM Order_Line__c];
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(items[0]);
        OrderRatePlan_Controller testoderPlan = new OrderRatePlan_Controller(sc);
        testoderPlan.addNewRow();
        testoderPlan.CancelAction();
        testoderPlan.orderTier.add(new OrderRatePlan__c(SequenceNumber__c = 20, SalesPrice__c = 100));
        testoderPlan.saveAction();
        test.stopTest();
    }
}