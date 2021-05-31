@isTest(seeAllData = false)
private class CreateSalesOrderInSAPTest {
    @testSetup static void data() {
        Test.loadData(Pricebook2.sObjectType, 'PriceListTestdata');
        List<Account> acc = TestDataFactory.createAccounts(1);
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
        List<Order> orders = TestDataFactory.createOrders(opp[0].Id, acc[0].Id, 1);
        orders[0].Pricebook2Id = pricel[0].Id;
        update orders;
        List<Order_Line__c> items = TestDataFactory.createOrderLines(orders[0].Id, prd[0].Id, pb.Id, 2);        
    }
    @isTest
    static void testCreateOrderInSAP(){
        Order ord = [select id, OpportunityId from Order limit 1];
        Opportunity opp = new Opportunity();
        opp.Id = ord.OpportunityId;
        opp.Drop_Ship__c = 'Drp ship';
        opp.PO_Number__c = 'PO123';
        opp.Received_By__c = 'Email';
        opp.Shipping_Carrier__c = 'FedEx Priority 1';
        opp.Description = 'Description';
        opp.Shipping_Comments__c = 'Shipping Comments';
        opp.Special_Instructions__c = 'Special Instructions';
        opp.Ship_Method__c = 'PrePaid';
        opp.Collect_Account_Number__c = '12344';
        opp.IncoTerms__c = 'CFR';
        opp.Named_Place__c = 'Named Place';
        update opp;
        ord.SAP_Order_Type__c = 'Standard';
        ord.Account_SAP_ID__c = 'SPID';
        ord.ActivatedDate = Date.today();
        ord.EndDate = Date.today().AddDays(30);
        ord.End_Customer_SAP_ID__c = 'endCus';
        update ord;
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        CreateSalesOrderInSAP testorderCre = new CreateSalesOrderInSAP(sc);
        testorderCre.createSalesOrderInSAP();
        testorderCre.returnToOrder();
        testorderCre.updateOrderFields(ord.Id, '21331', 'Completed');
        testorderCre.updateOrderFields(ord.Id, '', 'Sync Error');
        test.stopTest();
    }
    @isTest
    static void testCreateOrderInSAP1(){
        Order ord = [select id from Order limit 1];
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ord);
        CreateSalesOrderInSAP testorderCre = new CreateSalesOrderInSAP(sc);
        testorderCre.createSalesOrderInSAP();
        testorderCre.returnToOrder();
        testorderCre.updateOrderFields(ord.Id, '21331', 'Completed');
        testorderCre.updateOrderFields(ord.Id, '', 'Sync Error');
        test.stopTest();
    }
}