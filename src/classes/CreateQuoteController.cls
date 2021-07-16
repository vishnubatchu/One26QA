public with sharing class CreateQuoteController {
    public Opportunity opp;
    public CreateQuoteController(ApexPages.StandardController controller) {
        if(!test.isRunningTest()){
            controller.addFields(New List<String> {'Name', 'CurrencyIsoCode','Primary_Shipping_Contact__c'});    
        }
        opp = (Opportunity)controller.getRecord();
    }
    
    public pageReference createQuote(){
        Id qtRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Quote_Record_Type').getRecordTypeId();
        Quote newQte;
        pageReference pgRef ;
        List<OpportunityLineItem> oppLines = [SELECT Id,name, OpportunityId , Product2Id, Description, Quantity, UnitPrice,CurrencyIsoCode,Description__c,
                                              PriceBookEntryId, Additional_Specifications__c, II_VI_DE_Long_Description__c, Long_Description_English__c,
                                              Long_Description_French__c, Alternate_Description__c, Request_Date__c, Ship_Date__c, Lead_Time__c, Rich_Text_Deutsch__c,
                                              Rich_Text_English__c,SortOrder 
                                              FROM OpportunityLineItem 
                                              WHERE OpportunityId = :opp.Id Order By CreatedDate];
        system.debug('oppLines + ' + oppLines.size());
        if(oppLines != null && !oppLines.isEmpty()){
            newQte = new Quote(OpportunityId = opp.Id, Name = opp.Name, CurrencyIsoCode = opp.CurrencyIsoCode, RecordtypeId = qtRecordTypeId,
                              ContactId = opp.Primary_Shipping_Contact__c, QuoteType__c = 'Customer');
            insert newQte;
            Map<Id, Quote_Item__c > oppQteLineMap = new Map<Id, Quote_Item__c >();
            //List<QuoteLineItem> qLines = new List<QuoteLineItem>();
            for(OpportunityLineItem oLine :oppLines){
                Quote_Item__c  qLine = new Quote_Item__c (Quote__c  = newQte.Id,
                                                       Product__c  = oLine.Product2Id,
                                                        Quantity__c  = oLine.Quantity,
                                                        DescriptionShort__c  = oLine.Description__c,
                                                        UnitPrice__c = oLine.UnitPrice, 
                                                        Target_Price__c = oLine.UnitPrice,  
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
                                                        SortOrder__c = oLine.SortOrder,CurrencyIsoCode=newQte.CurrencyIsoCode);
                oppQteLineMap.put(oLine.Id, qLine);
                //qLines.add(qLine);
            }
            system.debug('opp@@' + oppQteLineMap.values().Size());
            insert oppQteLineMap.values();
            List<QuoteRatePlan__c> qRatePlans = new List<QuoteRatePlan__c>();
            for(OpportunityRatePlan__c oRate : [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, LeadTime__c
                                                FROM OpportunityRatePlan__c 
                                                WHERE OpportunityLineItem__c IN :oppQteLineMap.keySet()]){
                                                    QuoteRatePlan__c plan = new QuoteRatePlan__c();
                                                    plan.QuoteLineItem__c = oppQteLineMap.get(oRate.OpportunityLineItem__c).Id;
                                                    plan.LeadTime__c = oRate.LeadTime__c;
                                                    plan.SequenceNumber__c = oRate.SequenceNumber__c;
                                                    plan.SalesPrice__c = oRate.SalesPrice__c;
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
    public pageReference redirectToOpp(){
        pageReference pgRef = new pageReference('/'+opp.Id);
        return pgRef;
    }
}