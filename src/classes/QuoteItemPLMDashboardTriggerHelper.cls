public class QuoteItemPLMDashboardTriggerHelper {
    
    public static void UpdateQuotePLMDashboardDetails(Map<Id,Quote> oldQuote,Map<Id,Quote> newQuote)
    {
        List<Quote> Quote = New List<Quote>();
        List<Quote_Item__c> QuoteItemGroup = New List<Quote_Item__c>();
        List<Quote> AllRelatedQuoteItems = New List<Quote>();
        List<String> QuoteIds = New List<String>();
        FOR(Id quoteId:newQuote.keySet()){
            IF(oldQuote.get(quoteId).Status!=newQuote.get(quoteId).Status && newQuote.get(quoteId).Status=='Approval Pending'){
                QuoteIds.add(quoteId);
            }
        }
        IF(!QuoteIds.isEmpty()){
            System.debug('Inside Method in pending Approval');
            List<Quote> DistinctQuoteList = new List<Quote>();
            For(Quote quoteObj:[Select Id,Contribution_Profit__c,Gross_Profit__c,(Select id,Quote__c,Contribution_Profit__c,Gross_Profit__c from Quote_Items__r) 
                                From Quote where id in :QuoteIds])
            {
                IF(quoteObj.Quote_Items__r.size()>0){
                    Decimal contribution_profit =0.0;
                    Decimal Gross_Profit = 0.0;
                    For(Quote_Item__c quoteItemObj:quoteObj.Quote_Items__r){
                        IF(quoteItemObj.Contribution_Profit__c!=Null){
                            contribution_profit =contribution_profit + quoteItemObj.Contribution_Profit__c;
                        }
                        IF(quoteItemObj.Gross_Profit__c!=Null){
                            Gross_Profit =Gross_Profit + quoteItemObj.Gross_Profit__c;
                        }
                    }
                    System.debug('contribution_profit'+contribution_profit);
                    System.debug('Gross_Profit'+Gross_Profit);
                    newQuote.get(quoteObj.Id).Contribution_Profit__c = contribution_profit;
                    newQuote.get(quoteObj.Id).Gross_Profit__c = Gross_Profit;
                }
                
            }
        }
    }
    
}