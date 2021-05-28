public with sharing class QuoteTemplateController {
    public Quote qteRec {get;set;}
    public QuoteTemplateController() {
        String qId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('qid'+qId);
        qteRec = [SELECT id, name, Account__c, Account.name,Account.AccountNumber,Status,Type_of_Pricing__c,
                  ExpirationDate,Pricing_Effective_By__c, PrimarySalesperson__c,Pricing_Effective_Start_Date__c,
                  Ship_Debit__c , S_D_Start_Date__c, S_D_End_Date__c,S_D_End_Date_Reason__c, VAR_SI__c,
                  VAR_SI_Disti_EC__c ,Sales_Channel__c, Sales_Channel_Code__c ,
                  (Select id,Name, Product__c,Marketing_PN__c,Line_Status__c,Target_Price__c,Disti_Resale_Price__c,Quantity__c,
                   Disti_Margin__c from Quote_Items__r) from Quote Where Id =:qId];
    }
    
    @AuraEnabled
    public static Quote getQuoteDetails(String recId){
        return [SELECT id, name, Account__c, Account.name,Account.AccountNumber,Status,Type_of_Pricing__c,
                ExpirationDate,Pricing_Effective_By__c, PrimarySalesperson__c,Pricing_Effective_Start_Date__c,
                Ship_Debit__c , S_D_Start_Date__c, S_D_End_Date__c,S_D_End_Date_Reason__c, VAR_SI__c,
                VAR_SI_Disti_EC__c ,Sales_Channel__c, Sales_Channel_Code__c ,
                (Select id,Name, Product__c,Marketing_PN__c,Line_Status__c,Target_Price__c,Disti_Resale_Price__c,Quantity__c,
                 Disti_Margin__c from Quote_Items__r) from Quote Where Id =:recId];
    }
}