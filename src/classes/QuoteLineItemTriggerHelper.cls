public class QuoteLineItemTriggerHelper {
    public static void updateConverionValue(List<Quote_Item__c> lineItems){
        system.debug('in lineItems'+lineItems);
        Map<String, Double> rateConvertionMap = new Map<String, Double>();
        for(DatedConversionRate conVal : [SELECT Id,Isocode, StartDate,NextStartDate, ConversionRate 
                                          FROM DatedConversionRate 
                                          WHERE StartDate <= :date.today() and NextStartDate > :date.today()]){
                                              rateConvertionMap.put(conVal.IsoCode, conVal.ConversionRate); 
                                          }
        for(Quote_Item__c  item : lineItems){
            if(item.CurrencyIsoCode  != item.TQ_Currency__c && item.TQ_Currency__c != null){
                system.debug('item.UnitPrice '+item.Target_Price__c  );
               /* if(item.UnitPrice != 0){
                    system.debug('item.Transfer_Currency_Amount__c'+item.Transfer_Currency_Amount__c);
                    item.Transfer_Currency_Amount__c = (item.UnitPrice/rateConvertionMap.get(item.CurrencyIsoCode)) * rateConvertionMap.get(item.TQ_Currency__c) ;
                } else */if(item.Transfer_Currency_Amount__c != null){
                    system.debug('item.Transfer_Currency_Amount__c'+item.Transfer_Currency_Amount__c);
                    item.Target_Price__c   = (item.Transfer_Currency_Amount__c / rateConvertionMap.get(item.TQ_Currency__c)) * rateConvertionMap.get(item.CurrencyIsoCode);
                }
                
            }
        }
    }
    
    public static void updateConverionValue(Map<Id, Quote_Item__c > newLineItems, Map<Id, Quote_Item__c > oldLineItems){
        Id transferRecordtypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Transfer_Quote').getRecordTypeId();
         Map<String, Double> rateConvertionMap = new Map<String, Double>();
        for(DatedConversionRate conVal : [SELECT Id,Isocode, StartDate,NextStartDate, ConversionRate 
                                          FROM DatedConversionRate 
                                          WHERE StartDate <= :date.today() and NextStartDate > :date.today()]){
                                              rateConvertionMap.put(conVal.IsoCode, conVal.ConversionRate); 
                                          }
        for(Quote_Item__c  newItem :newLineItems.values()){
            Quote_Item__c  oldItem = oldLineItems.get(newItem.Id);
            if(newItem.TQ_Currency__c != null && newItem.CurrencyIsoCode != newItem.TQ_Currency__c){
                if(oldItem.Transfer_Currency_Amount__c != newItem.Transfer_Currency_Amount__c){
                    newItem.Target_Price__c   = (newItem.Transfer_Currency_Amount__c / rateConvertionMap.get(newItem.TQ_Currency__c)) * rateConvertionMap.get(newItem.CurrencyIsoCode);
                }
             /*   if(oldItem.UnitPrice != newItem.UnitPrice){
                    newItem.Transfer_Currency_Amount__c = (newItem.UnitPrice / rateConvertionMap.get(newItem.CurrencyIsoCode)) * rateConvertionMap.get(newItem.TQ_Currency__c);
                }*/
            }
        }
    }
    
    public static void updateunitPrice(List<Quote_Item__c > newItems, Map<Id, Quote_Item__c > oldMap){
        List<Quote_Item__c > qUpdatedLines = new List<Quote_Item__c >();
        Map<Id, Quote_Item__c > updateMap = new Map<Id, Quote_Item__c >();
        for(Quote_Item__c  line : newItems){
            if(line.Quantity__c  != null && line.Quantity__c  != oldMap.get(line.id).Quantity__c ){
                updateMap.put(line.Id, line);
            }
        }
        if(updateMap != null && !updateMap.isEmpty()){
            for(QuoteRatePlan__c rate : [SELECT Id, LeadTime__c, SalesPrice__c, SequenceNumber__c, QuoteLineItem__c
                                         FROM QuoteRatePlan__c 
                                         WHERE QuoteLineItem__c IN : updateMap.keySet() order BY SequenceNumber__c]){
                                             if(updateMap.get(rate.QuoteLineItem__c).Quantity__c  >= rate.SequenceNumber__c){
                                                 updateMap.get(rate.QuoteLineItem__c).Quantity__c  = rate.SalesPrice__c;
                                             } 
                                         }
        }
    }
}