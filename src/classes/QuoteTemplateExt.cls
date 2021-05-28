public with sharing class QuoteTemplateExt {
    public Quote qteRec {get;set;}
    public Boolean approvedLines{get; set;}
    public QuoteTemplateExt(ApexPages.StandardController controller) {
        String qId = ApexPages.currentPage().getParameters().get('Id');
        approvedLines = false;
        system.debug('qid'+qId);
        qteRec = [SELECT id, name,QuoteNumber, Account__c,Account__r.Name, Account.name,Account__r.AccountNumber,Status,Type_of_Pricing__c,
                  ExpirationDate,Pricing_Effective_By__c, PrimarySalesperson__c,PrimarySalesperson__r.name,Pricing_Effective_Start_Date__c,
                  Ship_Debit__c , S_D_Start_Date__c, S_D_End_Date__c,S_D_End_Date_Reason__c, VAR_SI__c,Pricing_Effective_End_Date__c,
                  VAR_SI_Disti_EC__c ,Sales_Channel__c,Sales_Channel__r.Name, Sales_Channel_Code__c ,Price_List__c,CreatedDate,Contract_Manufacturer__c,
                  (Select id,Name, Product__c,Marketing_PN__c,Line_Status__c,Target_Price__c,Disti_Resale_Price__c,Quantity__c,
                   Disti_Margin__c,Product__r.Lead_Time__c from Quote_Items__r where Line_Status__c = 'Approved')
                   from Quote Where Id =:qId];
    if(qteRec.Quote_Items__r.size() > 0)
        approvedLines = true;
    }
    
    
}