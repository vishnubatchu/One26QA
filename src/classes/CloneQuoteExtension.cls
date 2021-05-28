public with sharing class CloneQuoteExtension {
    public Quote oldQuote;    
    public CloneQuoteExtension(ApexPages.StandardController controller) {
        if(!test.isRunningTest()){
            controller.addFields(New List<String> {'Name', 'CurrencyIsoCode','OpportunityId','Description','ExpirationDate','QuoteType__c',
                'RecordType','Status','TqCurrency__c','Delivery_Terms__c','FCA__c','Internal_Notes__c','International_Quote_Clause__c',
                'Link_to_Quote_on_Server__c','Manufacture_Location__c','Migrated__c','Notes__c','Terms__c','Validity__c','Pricebook2Id'});    
        }
        oldQuote = (Quote)controller.getRecord();
    }
    public pageReference cloneQuote(){
        Id qtRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Quote_Record_Type').getRecordTypeId();
        Quote newQte;
        pageReference pgRef ;
        List<Quote_Item__c > qteLines = [SELECT Id, Quote__c, Product__c,  Quantity__c, Target_Price__c,CurrencyIsoCode,DescriptionShort__c ,Rich_Text_Deutsch__c,
                                          Additional_Specifications__c, II_VI_DE_Long_Description__c, Long_Description_English__c,Rich_Text_English__c,
                                         Long_Description_French__c,SortOrder__c ,UnitPrice__c , Alternate_Description__c, Request_Date__c, Ship_Date__c, Lead_Time__c
                                         FROM Quote_Item__c  
                                         WHERE Quote__c = :oldQuote.Id];
        if(qteLines != null && !qteLines.isEmpty()){
            newQte = oldQuote.clone();
            newQte.RecordTypeId = qtRecordTypeId;
            newQte.QuoteType__c = 'Customer';
            insert newQte;
            Map<Id, Quote_Item__c> qteLineMap = new Map<Id, Quote_Item__c>();
            for(Quote_Item__c oLine :qteLines){
                Quote_Item__c qLine = new Quote_Item__c(Quote__c = newQte.Id,
                                                        Product__c = oLine.Product__c,
                                                        Quantity__c = oLine.Quantity__c,
                                                        DescriptionShort__c  = oLine.DescriptionShort__c,
                                                        Target_Price__c = oLine.Target_Price__c,
                                                        Alternate_Description__c = oLine.Alternate_Description__c,
                                                        II_VI_DE_Long_Description__c = oLine.II_VI_DE_Long_Description__c,
                                                        Long_Description_English__c = oLine.Long_Description_English__c,
                                                        Long_Description_French__c = oLine.Long_Description_French__c,
                                                        Additional_Specifications__c = oLine.Additional_Specifications__c,
                                                        Request_Date__c = oLine.Request_Date__c, 
                                                        Ship_Date__c = oLine.Ship_Date__c,
                                                        Lead_Time__c = oLine.Lead_Time__c,
                                                        SortOrder__c  = oLine.SortOrder__c,
                                                        UnitPrice__c  = oLine.UnitPrice__c,
                                                        Rich_Text_Deutsch__c = oLine.Rich_Text_Deutsch__c,
                                                        Rich_Text_English__c = oLine.Rich_Text_English__c);
                qteLineMap.put(oLine.Id, qLine);
            }
            insert qteLineMap.values();
            List<QuoteRatePlan__c> qRatePlans = new List<QuoteRatePlan__c>();
            for(QuoteRatePlan__c qRate : [SELECT Id, QuoteLineItem__c, SalesPrice__c, SequenceNumber__c, LeadTime__c
                                          FROM QuoteRatePlan__c 
                                          WHERE QuoteLineItem__c IN :qteLineMap.keySet()]){
                                              QuoteRatePlan__c plan = qRate.clone();
                                              plan.QuoteLineItem__c = qteLineMap.get(qRate.QuoteLineItem__c).Id;
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
                                            WHERE QuoteLineItem__c IN : qteLineMap.keySet()]){
                                                Ordered_BOM_Parts__c newBom = bom.clone();
                                                newBom.OpportunityProduct__c = '';
                                                newBom.QuoteLineItem__c = qteLineMap.get(bom.QuoteLineItem__c).Id;
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
    public pageReference redirectToOpp(){
        pageReference pgRef = new pageReference('/'+oldQuote.Id);
        return pgRef;
    }
}