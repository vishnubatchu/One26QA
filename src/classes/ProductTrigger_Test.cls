@isTest
private class ProductTrigger_Test {
    @testSetup static void setup() {
        // Create common test pricebook and product records
        List<Pricebook2> priceBookList = new List<Pricebook2>();
        priceBookList.add(new Pricebook2(Name = 'Legacy Finisar Products', IsActive=true));
        
        priceBookList.add(new Pricebook2(Name = 'Legacy Photonics Products', IsActive=true));
        
        
        priceBookList.add(new Pricebook2(Name = 'Legacy Marlow Products', IsActive=true));
        
        
        priceBookList.add(new Pricebook2(Name = 'Legacy II-VI Products', IsActive=true));
        
        
        priceBookList.add(new Pricebook2(Name = 'Legacy II-VI Military Products',IsActive=true));
        
        priceBookList.add(new Pricebook2(Name = 'Legacy II-VI Epiworks Products',IsActive=true));
        
        insert priceBookList; 
        
        List<Product2> prdList = new List<Product2>();
        prdList.add(new Product2(Name = 'Test Product 1', ProductCode = 'code 1', isActive = true, Source_System__c = 'Oracle-EBS',
                                 Source_System_Id__c='system id 1',Usmo__c = false,Marketing_P_N__c='Test',Status__c ='Active',ExternalId__c ='123'));
        
        prdList.add(new Product2(Name = 'Test Product 2', ProductCode = 'code 2', isActive = true, Source_System__c = 'SAP-China',
                                 Source_System_Id__c='system id 2',Usmo__c = true));
        
        
        prdList.add(new Product2(Name = 'Test Product 3', ProductCode = 'code 3', isActive = true, Source_System__c = 'Glovia',
                                 Source_System_Id__c='system id 3',Usmo__c = true,Marketing_P_N__c='Test',Status__c ='Active',ExternalId__c ='123'));
        
        
        prdList.add(new Product2(Name = 'Test Product 4', ProductCode = 'code 4', isActive = true, Source_System__c = 'SAP-US',
                                 Source_System_Id__c='system id 4',Usmo__c = true));
        
        
        prdList.add(new Product2(Name = 'Test Product 5', ProductCode = 'code 5', isActive = true, Source_System__c = 'SAP-US',
                                 Source_System_Id__c='system id 5',Usmo__c = false,Segment_Number__c='16'));
        
        prdList.add(new Product2(Name = 'Test Product 6', ProductCode = 'code 6', isActive = true, Source_System__c = 'SAP-US',
                                 Source_System_Id__c='system id 6',Usmo__c = false,Segment_Number__c='18'));
       	insert prdList;
        
    }
    
    @isTest static void testUpdateProductSharingOnInsert() {
        List<Product2> prdList=[Select Id from Product2];
        List<PriceBookEntry> pbList=[SELECT Id FROM PricebookEntry 
                                                      WHERE Product2Id IN : prdList];
        List<CurrencyType> currencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        Integer expectedPbEntryCount=currencies.size()*prdList.size()*2;
        System.assertEquals(expectedPbEntryCount, pbList.size());
    }
    
        @isTest static void testUpdateProductSharingOnUSMOChange() {
        Product2 prd=[Select Id from Product2 where Name='Test Product 6'];
        prd.Usmo__c=true;
        update  prd;   
        List<PriceBookEntry> pbList=[SELECT Id FROM PricebookEntry 
                                                      WHERE Product2Id =: prd.Id];
        List<CurrencyType> currencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        Integer expectedPbEntryCount=(currencies.size()*2)+currencies.size();
        System.assertEquals(expectedPbEntryCount,
                             pbList.size());
    }
    
    @isTest static void testUpdateProductSharingOnSgmntNmbrChange() {
        List<String> nameList=new List<String>{'Test Product 4','Test Product 5'};
        List<Product2> prdList=[Select Id from Product2 where Name IN : nameList];
        prdList[0].Usmo__c=false;
        prdList[0].Segment_Number__c='16';
        prdList[1].Segment_Number__c='19';
        update  prdList;   
        List<PriceBookEntry> pbList=[SELECT Id FROM PricebookEntry 
                                                      WHERE Product2Id IN : prdList];
        List<CurrencyType> currencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        Integer expectedPbEntryCount=(currencies.size()*prdList.size()*2)+(currencies.size()*prdList.size());
        System.assertEquals(expectedPbEntryCount,
                             pbList.size());
    }
    
}