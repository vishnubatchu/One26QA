public class PriceListController {
@AuraEnabled
    public static WrapperClass PriceListQuery(Id quoteId){
        WrapperClass PriceListWrapper = new WrapperClass();
        String AccountId;
        String CostumerId;
        String SiteId;
        String QuoteCreatorProfile ;
        String PricingType;
        String ErrMessage;
        // fetch Account details from Quote
        if(quoteId != null) {
           Quote Quotedata = new Quote();
            Quotedata = [SELECT Id,Account__c,Type_of_Pricing__c,Customer__c,Site__c,QuoteCreatorProfile__c FROM Quote where ID = :quoteId];
            AccountId = Quotedata.Account__c;
            CostumerId = Quotedata.Customer__c;
            SiteId = Quotedata.Site__c;
            PricingType = Quotedata.Type_of_Pricing__c;
            QuoteCreatorProfile = Quotedata.QuoteCreatorProfile__c;
        }
        if(PricingType != 'Blanket Price Agreement'){
            ErrMessage = 'PriceList Selection is available only for Blanket Price Agreement Quotes';
        }
        
        //fetch All PriceLists
        String GrandparentId ;
        List<Account> AccountPriceLists = new List<Account>();
        if((AccountId != '') && (AccountId != Null)){
                            GrandparentId = AccountId.substring(0,15);
                            AccountPriceLists = [SELECT Price_List__c FROM Account where 
                                                                    (((ID = :AccountId) OR (ParentId =:AccountId) OR (GrandParentId__c =:GrandparentId))
                                                                     AND ((Price_List__c != '') AND (Price_List__c != Null)
                                                                     ))];
        									}
        // fetch distinct PriceLists
        List<Account> DistinctPriceList = new List<Account>();
        for(Account Temp: AccountPriceLists){
            Boolean found = false;
            for(Integer i=0; i< DistinctPriceList.size(); i++){
            if(Temp.Price_List__c.equalsIgnoreCase(DistinctPriceList[i].Price_List__c)){ 
            found=true;
            break;
            }
            }
            if(!found)
            DistinctPriceList.add(Temp);
        	}
        
        // Insert Creator PriceList
        Account QuoteCreatorPriceList = new Account(Name= 'TempPricelist');
        if(QuoteCreatorProfile == 'Finisar Partner Community User'){
            QuoteCreatorPriceList.Price_List__c = 'FNSR REP PRICE LIST';
        }else{
            QuoteCreatorPriceList.Price_List__c = 'FNSR RSM PRICE LIST';
        }
        DistinctPriceList.add(QuoteCreatorPriceList);
        System.debug(AccountPriceLists);
        System.debug(GrandparentId);
        PriceListWrapper.AccountPriceListOutput = DistinctPriceList;
        PriceListWrapper.errorMessage = ErrMessage;
        return PriceListWrapper;
    }
 
@AuraEnabled
    public static String PriceListUpdate(Id quoteId, String pricelist){ 
        System.debug(pricelist);
        System.debug(quoteId);
        if(quoteId != null) {
            Quote Quotedata = new Quote();
            Quotedata = [SELECT Id,PriceListSelected__c FROM Quote where ID = :quoteId];
            Quotedata.PriceListSelected__c = pricelist;
            update Quotedata;
        } 
        Return pricelist;
    } 
    
    public class WrapperClass {
        @AuraEnabled public List<Account> AccountPriceListOutput;
        @AuraEnabled public String errorMessage;
    }
}