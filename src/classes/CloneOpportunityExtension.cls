public with sharing class CloneOpportunityExtension {
    public Opportunity opp;
    public CloneOpportunityExtension(ApexPages.StandardController controller) {
        if(!test.isRunningTest())
            controller.addFields(New List<String> {'Name', 'CurrencyIsoCode','StageName', 'Amount', 'CloseDate', 'AccountId', 'Pricebook2Id',
                'Primary_Shipping_Contact__c','End_Customer_Lookup__c', 'Received_By__c', 'Segment__c', 'Requested_Information__c','Description',
                'Quote_Validity_Duration__c', 'LeadSource', 'Media__c', 'Epiworks_RPS_Number__c', 'Adjusted_Opportunity_Value2__c',
                 'PO_Number__c', 'Terms__c', 'EUV__c','PLC_Gate_Status__c',
                'Highlight_for_Review__c', 'Product_Line__c', 'Ship_Method__c', 'Shipping_Carrier__c', 'Collect_Account_Number__c', 'IncoTerms__c',
                'Named_Place__c', 'Drop_Ship__c', 'Special_Instructions__c', 'Shipping_Comments__c'});
        opp = (Opportunity)controller.getRecord();
    }
    public pagereference cloneOpp(){
        Map<Id, OpportunityLineItem> opplineMap = new Map<Id, OpportunityLineItem>();
        Opportunity newOpp = opp.clone();
        newOpp.StageName  = 'Analysis';
        newOpp.CloseDate = Date.today();
        newOpp.Contract_Review_Checklist_Completed__c = false;
        try{
            insert newOpp;
            for(OpportunityLineItem oppLine : [SELECT Id, name, OpportunityId, Product2Id, Description, Quantity, UnitPrice, ListPrice,
                                               PriceBookEntryId, CurrencyIsoCode, Lead_Time__c, Forecast__c, Part_Type__c, Adjusted_Total_Price__c,
                                               Taxable__c, Description__c, Additional_Specifications__c, Alternate_Description__c, II_VI_DE_Long_Description__c,
                                               Long_Description_English__c, Long_Description_French__c, Rich_Text_Deutsch__c, Rich_Text_English__c
                                               FROM OpportunityLineItem 
                                               WHERE OpportunityId = :opp.Id]){
                                                   OpportunityLineItem newLine = oppLine.clone();
                                                   newLine.OpportunityId = newOpp.Id;
                                                   newLine.Request_Date__c = Date.today();
                                                   newLine.Ship_Date__c = null;
                                                   
                                                   opplineMap.put(oppLine.Id, newLine);
                                               }
            if(opplineMap != null && !opplineMap.isEmpty()){
                insert opplineMap.values();
            }
            List<OpportunityRatePlan__c> newlineRates = new List<OpportunityRatePlan__c>();
            for(OpportunityRatePlan__c oRate : [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, LeadTime__c
                                                FROM OpportunityRatePlan__c 
                                                WHERE OpportunityLineItem__c IN :opplineMap.keySet()]){
                                                    OpportunityRatePlan__c rate = oRate.clone();
                                                    rate.OpportunityLineItem__c = opplineMap.get(oRate.OpportunityLineItem__c).Id;
                                                    newlineRates.add(rate);
                                                }
            if(newlineRates != null && !newlineRates.isEmpty()){
                insert newlineRates;
            }
            List<Ordered_BOM_Parts__c> oppBoms = new List<Ordered_BOM_Parts__c>();
            for(Ordered_BOM_Parts__c bom : [SELECT Id, BOM_Product_Part__c, Deutch_Description__c, Deutch_Rich_Text_Description__c,English_Description__c,
                                            English_Rich_Text_Description__c, OpportunityProduct__c, Position__c, Quantity__c, Sequence__c
                                            FRoM Ordered_BOM_Parts__c 
                                            WHERE OpportunityProduct__c IN :opplineMap.keySet()]){
                                                Ordered_BOM_Parts__c newBom = bom.clone();
                                                newBom.OpportunityProduct__c = opplineMap.get(bom.OpportunityProduct__c).Id;
                                                oppBoms.add(newBom);
                                            }
            if(oppBoms != null && !oppBoms.isEmpty()){
                insert oppBoms;
            }
            
        }catch(exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            system.debug('eror '+ex.getMessage());
            return null;
        }
        return new pageReference('/'+newOpp.Id);
    }
    
}