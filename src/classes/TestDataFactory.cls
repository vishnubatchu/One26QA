public class TestDataFactory {
   /** public static void createCountrycodes(){
        Country_Code__c cc = new Country_Code__c(Name = 'US', Country__c = 'UNITED STATES');
        insert cc;
    } **/
    public static List<Account> createAccounts(Integer count){
        //createCountrycodes();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i< count; i++){
            accList.add(new Account(Name = 'Test Account '+i, Business_Segment__c = 'CORP',
                                   ShippingCity = 'city', ShippingCountry = 'US', CurrencyIsoCode = 'USD', Display_Shipping_Country__c = 'American Samoa'));
        }
        if(accList != null && !accList.isEmpty()){
            insert accList;
        }
        return accList;
    }
    public static List<Opportunity> createOpportunity(Integer count, String accountId){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i = 0; i<count; i++){
        	oppList.add(new Opportunity(name = 'test Opp '+i, AccountId = accountId,Qual_Required__c ='Yes',
        Project_Name__c   = 'Test', StageName = 'Qualified Opportunity', Legacy_Id__c = '43s3432',
                                        CloseDate = Date.today().addDays(30)));    
        }
        if(oppList != null && !oppList.isEmpty()){
            insert oppList;
        }
        return oppList;
    }
    public static List<Product2> createProducts(String segment, Integer count, Boolean usmo){
        List<Product2> prdList = new List<Product2>();
        for(Integer i=0; i<count; i++){
            prdList.add(new Product2(Name = 'Test Product' +i, ProductCode = 'code 3' +i, isActive = true, Source_System__c = 'Glovia',
                                 Source_System_Id__c='system id' +i,Usmo__c = usmo,Segment_Number__c = segment));
       
        }
        if(prdList != null && !prdList.isEmpty()){
            insert prdList;
        } 
        return prdList;
    }
    public static List<OpportunityLineItem> creatOppLine(String oppId, Integer count, String productId, String pdeId ){
        List<OpportunityLineItem> oppLines  = new List<OpportunityLineItem>();
        for(Integer i = 0; i<count; i++){
            oppLines.add(new OpportunityLineItem(OpportunityId = oppId, Product2Id = productId, UnitPrice = 1,
                                                quantity = 1, PriceBookEntryId = pdeId,Sales_Price_reflects_Opp_Currency__c  = true));
        }
        if(oppLines != null && !oppLines.isEmpty()){
            insert oppLines;
        }
        return oppLines;
    }
    public static void createOppRatePla(String lineId, decimal quantity, Decimal unitPrice){
        OpportunityRatePlan__c rate = new OpportunityRatePlan__c(OpportunityLineItem__c = lineId, LeadTime__c = '2 weeks',
                                                                SequenceNumber__c = quantity, SalesPrice__c = unitPrice);
        insert rate;
    }
    public static List<Order> createOrders(String oppId, String accId, Integer count){
        List<Order> orderList = new List<Order>();
        for(Integer i = 0; i<count; i++){
            	orderList.add(new order(OpportunityId = oppId, AccountId = accid, Name = 'test Order'+i,
                                       EffectiveDate = Date.today(), Status = 'Draft'));
        }
        if(orderList != null && !orderList.isEmpty()){
            insert orderList;
        }
        return orderList;
    } 
    public static List<Order_Line__c> createOrderLines(String orderId, String prdid,  String pbId, Integer n){
        List<Order_Line__c> oItems = new List<Order_Line__c>();
        for(Integer i = 0; i<n; i++){
            oItems.add(new Order_Line__c(Order__c = orderId, Part_Number__c = prdId, Unit_Selling_Price__c  = 10,
                                    Quantity__c = 10));
        }
        if(oItems != null && !oItems.isEmpty()){
            insert oItems;
        }
        return oItems;
    }
  /**  public static void createOrderRatePlan(String lineId, Integer sequesnceNo, Decimal unitPrice){
        OrderRatePlan__c plan = new OrderRatePlan__c(LeadTime__c = '2 weeks', OrderProduct__c = lineId,
                                                    SalesPrice__c = unitPrice, SequenceNumber__c = sequesnceNo);
        insert plan;
    } **/
    public static List<Quote> createQuote(String oppId, String pbId, integer n){
        List<Quote> qts = new List<Quote>();
        for(Integer i = 0; i<n; i++){
            qts.add(New Quote(OpportunityId = oppId, PriceBook2Id = pbId, Name = 'TestQuote'+i));
        }
        if(qts != null && !qts.isEmpty()){
            insert qts;
        }
        return qts;
    }
    public static List<Quote_Item__c> createQuoteLines(String qtId, String prdId, String pbeId, integer count){
        List<Quote_Item__c> lines = new List<Quote_Item__c>();
        for(Integer i = 0; i < count; i++){
           lines.add(new Quote_Item__c(Quote__c = qtId, Product__c  = prdId, Quantity__c = 10
                                      )); 
        }
        system.debug('lst23 ' + lines);
        if(lines != null && !lines.isEmpty()){
            insert lines;
        }
        return lines;
    }
    public static void createQuoteRatePlan(String lineId, integer seqNo, Decimal salesPrice){
        QuoteRatePlan__c plan = new QuoteRatePlan__c(QuoteLineItem__c = lineId, SalesPrice__c = salesPrice,
                                                    SequenceNumber__c = seqNo, LeadTime__c = '2 Weeks');
        insert plan;
    }
}