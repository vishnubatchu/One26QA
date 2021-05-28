public with sharing class QuoteRatePlan_Controller {
    public List<QuoteRatePlan__c> quoteTier{get; set;}
    public Quote_Item__c qtLine{get; set;}
    public Boolean transfrQuote{get; set;}
    public Map<String, Double> rateConvertionMap;
    public QuoteRatePlan_Controller(ApexPages.StandardController controller) {
        transfrQuote = false;
        rateConvertionMap = new Map<String, Double>();
        Id qtRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Quote_Record_Type').getRecordTypeId();
        if(!test.isRunningTest()){
            controller.addFields(New List<String> {'Target_Price__c', 'Quantity__c','Quote__r.RecordtypeId','TQ_Currency__c','CurrencyIsoCode'});    
        }
        qtLine = (Quote_Item__c)controller.getRecord();
        system.debug('oppline id '+qtLine.Id);
        if(qtLine.Quote__r.RecordtypeId != qtRecordTypeId){
            transfrQuote = true;
            for(DatedConversionRate conVal : [SELECT Id,Isocode, StartDate,NextStartDate, ConversionRate 
                                              FROM DatedConversionRate 
                                              WHERE StartDate <= :date.today() and NextStartDate > :date.today()]){
                                                  rateConvertionMap.put(conVal.IsoCode, conVal.ConversionRate); 
                                              }
        }
        List<QuoteRatePlan__c> plans = [SELECT Id, QuoteLineItem__c, SalesPrice__c, SequenceNumber__c, LeadTime__c,
                                        QuoteLineItem__r.Quote__r.RecordtypeId,Transfer_Price__c, TQ_Currency__c
                                        FROM QuoteRatePlan__c 
                                        WHERE QuoteLineItem__c = :qtLine.Id ORDER BY SequenceNumber__c asc];
        if(plans != null && !plans.isEmpty()){
            quoteTier = plans;
        } else {
            quoteTier = new List<QuoteRatePlan__c>();
            QuoteRatePlan__c rate = new QuoteRatePlan__c();
            rate.TQ_Currency__c = qtLine.TQ_Currency__c;
            quoteTier.add(rate);
        }
    }
    public pageReference addNewRow(){
        QuoteRatePlan__c rate = new QuoteRatePlan__c();
        rate.TQ_Currency__c = qtLine.TQ_Currency__c;
        /* for(QuoteRatePlan__c rp: quoteTier){
system.debug('rp'+rp);
if(rp.Transfer_Price__c != 0 && rp.SalesPrice__c == null){
system.debug('rp'+rp);
rp.SalesPrice__c = (rp.Transfer_Price__c / rateConvertionMap.get(rp.TQ_Currency__c)) * rateConvertionMap.get(qtLine.CurrencyIsoCode);
}
}*/
        system.debug('quoteTier'+quoteTier);
        quoteTier.add(rate);
        return null;
    }
    public pageReference saveAction(){
        List<QuoteRatePlan__c> plans = new List<QuoteRatePlan__c>();
        for(QuoteRatePlan__c plan : quoteTier ){
            if(plan.SequenceNumber__c != null && (plan.SalesPrice__c !=0 || plan.Transfer_Price__c != 0)){
                plan.QuoteLineItem__c = qtline.Id;
                plans.add(plan);
                if(plan.SequenceNumber__c < qtLine.Quantity__c){
                    if(plan.SalesPrice__c != 0)
                        qtLine.Target_Price__c = plan.SalesPrice__c;
                    if(plan.Transfer_Price__c != 0)
                        qtLine.Transfer_Currency_Amount__c = plan.Transfer_Price__c;
                }
            }
        }
        if(plans != null && !plans.isEmpty()){
            upsert plans;
            update qtLine;
        }
        return new pageReference('/'+qtLine.Id);
    }
    public pageReference CancelAction(){
        return new pageReference('/'+qtLine.Id);
    }
    public pageReference updatesalesPrice(){
        for(QuoteRatePlan__c rp: quoteTier){
            if(rp.Transfer_Price__c != null && rp.Transfer_Price__c != 0 ){
                rp.SalesPrice__c = (rp.Transfer_Price__c / rateConvertionMap.get(rp.TQ_Currency__c)) * rateConvertionMap.get(qtLine.CurrencyIsoCode);
            }
        }
        return null;
    }
}