public with sharing class CreateTransferQuote_Controller{
    public String currecyIdAndName{get;set;}
    public Opportunity opp;
    public Date startDate{get;set;}
    public List<SelectOption> curreciesOptions{get;set;}
    public CreateTransferQuote_Controller(ApexPages.StandardController controller) {
        startDate = Date.today();
        if(!test.isRunningTest()){
            controller.addFields(New List<String> {'Name', 'CurrencyIsoCode','StageName', 'Amount', 'CloseDate', 'AccountId', 'Pricebook2Id'});    
        }
        opp = (Opportunity)controller.getRecord();
        curreciesOptions = new List<SelectOption>();
        for(CurrencyType cu : [SELECT Id,Isocode,IsActive FROM CurrencyType WHERE IsActive = true]){
            if(opp.CurrencyIsoCode != cu.IsoCode)
                curreciesOptions.add(new SelectOption(cu.IsoCode, cu.IsoCode));
        }
    }
    
    public pageReference createQuote(){
        Quote newQte;
        Id trnsferQtRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Transfer_Quote').getRecordTypeId();
        pageReference pgRef ;
        List<OpportunityLineItem> oppLines = [SELECT Id,name, OpportunityId, Product2Id,Description, Quantity,UnitPrice,CurrencyIsoCode,Description__c,
                                              PriceBookEntryId, Additional_Specifications__c, II_VI_DE_Long_Description__c, Long_Description_English__c,
                                              Long_Description_French__c, Alternate_Description__c, Request_Date__c, Ship_Date__c, Lead_Time__c, Rich_Text_Deutsch__c,
                                              Rich_Text_English__c, SortOrder
                                              FROM OpportunityLineItem 
                                              WHERE OpportunityId = :opp.Id];
        if(oppLines != null && !oppLines.isEmpty()){
            Map<String, Double> rateConvertionMap = new Map<String, Double>();
            for(DatedConversionRate conVal : [SELECT Id,Isocode, StartDate,NextStartDate, ConversionRate 
                                              FROM DatedConversionRate 
                                              WHERE StartDate <= :startDate and NextStartDate > :startDate]){
                                                  rateConvertionMap.put(conVal.IsoCode, conVal.ConversionRate); 
                                              }
            newQte = new Quote(OpportunityId = opp.Id, Name = opp.Name, CurrencyIsoCode = opp.CurrencyIsoCode,
                               TqCurrency__c = currecyIdAndName, RecordTypeId = trnsferQtRecordTypeId, QuoteType__c ='Transfer');
            insert newQte;
            List<Quote_Item__c> qLines = new List<Quote_Item__c>();
            Map<Id,Quote_Item__c> oppQteLineMap = new Map<Id,Quote_Item__c>();
            for(OpportunityLineItem oLine :oppLines){
                Quote_Item__c qLine = new Quote_Item__c(Quote__c  = newQte.Id,
                                                        Product__c   = oLine.Product2Id,
                                                        Quantity__c  = oLine.Quantity,
                                                        DescriptionShort__c  = oLine.Description,
                                                        Description__c = oLine.Description__c,
                                                        UnitPrice__c  = oLine.UnitPrice,
                                                        TQ_Currency__c = currecyIdAndName,
                                                        Transfer_Currency_Amount__c = (oLine.UnitPrice / rateConvertionMap.get(opp.CurrencyIsoCode)) * rateConvertionMap.get(currecyIdAndName),
                                                        Alternate_Description__c = oLine.Alternate_Description__c,
                                                        II_VI_DE_Long_Description__c = oLine.II_VI_DE_Long_Description__c,
                                                        Long_Description_English__c = oLine.Long_Description_English__c,
                                                        Long_Description_French__c = oLine.Long_Description_French__c,
                                                        Additional_Specifications__c = oLine.Additional_Specifications__c,
                                                        Request_Date__c = oLine.Request_Date__c, 
                                                        Ship_Date__c = oLine.Ship_Date__c,
                                                        Lead_Time__c = oLine.Lead_Time__c,
                                                        Rich_Text_English__c = oLine.Rich_Text_English__c,
                                                        Rich_Text_Deutsch__c = oLine.Rich_Text_Deutsch__c,
                                                        SortOrder__c  = oLine.SortOrder
                                                       );
                oppQteLineMap.put(oLine.Id, qLine);
            }
            insert oppQteLineMap.values();
            List<QuoteRatePlan__c> qRatePlans = new List<QuoteRatePlan__c>();
            for(OpportunityRatePlan__c oRate : [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, LeadTime__c
                                                FROM OpportunityRatePlan__c 
                                                WHERE OpportunityLineItem__c IN :oppQteLineMap.keySet()]){
                                                    QuoteRatePlan__c plan = new QuoteRatePlan__c();
                                                    plan.QuoteLineItem__c = oppQteLineMap.get(oRate.OpportunityLineItem__c).Id;
                                                    plan.LeadTime__c = oRate.LeadTime__c;
                                                    plan.SequenceNumber__c = oRate.SequenceNumber__c;
                                                    if(oRate.SalesPrice__c != null)
                                                        plan.SalesPrice__c = (oRate.SalesPrice__c / rateConvertionMap.get(opp.CurrencyIsoCode)) * rateConvertionMap.get(currecyIdAndName);
                                                    qRatePlans.add(plan);
                                                }
            if(qRatePlans != null && !qRatePlans.isEmpty()){
                insert qRatePlans;
            }
            List<Ordered_BOM_Parts__c> boms = new List<Ordered_BOM_Parts__c>();
            for(Ordered_BOM_Parts__c bom : [SELECT Id,Name, BOM_Product_Part__c, Deutch_Description__c, Deutch_Rich_Text_Description__c,
                                            English_Description__c,English_Rich_Text_Description__c, OpportunityProduct__c, Position__c,
                                            Quantity__c,QuoteLineItem__c,Sequence__c
                                            FROM Ordered_BOM_Parts__c 
                                            WHERE OpportunityProduct__c IN : oppQteLineMap.keySet()]){
                                                Ordered_BOM_Parts__c newBom = bom.clone();
                                                newBom.OpportunityProduct__c = '';
                                                newBom.QuoteLineItem__c = oppQteLineMap.get(bom.OpportunityProduct__c).Id;
                                                boms.add(newBom);
                                            }
            if(boms != null && !boms.isEmpty()){
                insert boms;
            }
            pgRef = new pageReference('/'+newQte.Id);
        }else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no products associated with the Opportunity.'));
            return null;
        }
        return pgRef;
    }   
}