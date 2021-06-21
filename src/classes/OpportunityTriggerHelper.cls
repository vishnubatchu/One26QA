public class OpportunityTriggerHelper {
    public static Boolean orderCreated = false;
    public static void createOrderonClosedOpps(Map<Id, Opportunity> oldMap, List<Opportunity> newList){
        List<Opportunity> closedownOpps = new List<Opportunity>();
        Map<Id, Order> oppOrderMap = new Map<Id, Order>();
        User loggedInUserRec=[Select Id,Legacy_Company__c from User where Id=:UserInfo.getUserId()];
        for(Opportunity opp : newList){
            //Added two additional criteria for Order and OrderLine record creation i.e.,User Legacy_Company__c='Corp II-VI' and Opp recordType='AfterMarket' 
            if(loggedInUserRec.Legacy_Company__c == 'Corp II-VI'
               && opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Aftermarket').getRecordTypeId()
               && (opp.StageName == 'Closed Won' || opp.StageName == 'Closed via PO') && 
               opp.StageName != oldMap.get(opp.Id).StageName)
            {
                closedownOpps.add(opp);
            }
        }
        for(Opportunity opp : closedownOpps){
            Order ord = new Order();
            //Added to match target and source field length
            if(opp.Name.length()>80){
               ord.Name = opp.Name.substring(0,80); 
            }else{
               ord.Name = opp.Name;
            }
            ord.AccountId = opp.AccountId;
            ord.opportunityId = opp.Id;
            ord.CurrencyIsoCode = opp.CurrencyIsoCode;
            ord.Status = 'Draft';
            ord.EffectiveDate = date.today();
            ord.Pricebook2Id = opp.Pricebook2Id;
            ord.Primary_Shipping_Contact__c = opp.Primary_Shipping_Contact__c;
            ord.Legacy_Id__c = opp.Legacy_Id__c ;
            ord.RecordTypeId= Schema.SObjectType.Order.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
            oppOrderMap.put(opp.Id, ord);
        }
        if(oppOrderMap != null && !oppOrderMap.isEmpty()){
            insert oppOrderMap.values();
            orderCreated = true;
        }
        Map<Id, Order_Line__c> newLineMap = new Map<Id, Order_Line__c>();
        Integer sequence = 1;
        for(OpportunityLineItem oppLine : [SELECT Id, Product2Id, ProductCode, ConfigureBOMParts__c, Quantity, Description, SortOrder,
                                           UnitPrice, Subtotal, Discount, TotalPrice, PricebookEntryId, OpportunityId,Description__c,
                                           Additional_Specifications__c, II_VI_DE_Long_Description__c, Long_Description_English__c,
                                           Long_Description_French__c, Alternate_Description__c, Request_Date__c, Ship_Date__c, Lead_Time__c
                                           FROM OpportunityLineItem 
                                           WHERE OpportunityId IN :oppOrderMap.keySet() ORDER By SortOrder]){
                                               Order_Line__c  newLine = new Order_Line__c ();
                                               newLine.Order__c  = oppOrderMap.get(oppLine.OpportunityId).Id;
                                               newLine.Customer_Name__c=oppOrderMap.get(oppLine.OpportunityId).AccountId;
                                               newLine.Part_Number__c   = oppLine.Product2Id;
                                               newLine.Line_Description__c = oppLine.Description;
                                               newLine.Long_Text_Description__c = oppLine.Description__c;
                                               newLine.Quantity__c  = oppLine.Quantity;
                                               newLine.Unit_Selling_Price__c = oppLine.UnitPrice;
                                               newLine.Additional_Specifications__c = oppLine.Additional_Specifications__c;
                                               newLine.II_VI_DE_Long_Description__c = oppLine.II_VI_DE_Long_Description__c;
                                               newLine.Long_Description_English__c = oppLine.Long_Description_English__c;
                                               newLine.Long_Description_French__c = oppLine.Long_Description_French__c;
                                               newLine.Alternate_Description__c = oppLine.Alternate_Description__c;
                                               newLine.Request_Date__c = oppLine.Request_Date__c;
                                               newLine.Ship_Date__c = oppLine.Ship_Date__c;
                                               newLine.Lead_Time__c = oppLine.Lead_Time__c;
                                               if(oppLine.SortOrder != null){
                                                   newLine.Order_Product_Sequence_Number__c  = oppLine.SortOrder;
                                               }else{
                                                   newLine.Order_Product_Sequence_Number__c = sequence;
                                                   sequence = sequence+1;
                                               }
                                               
                                               newLineMap.put(oppLine.Id, newLine);
                                           }
        if(newLineMap != null && !newLineMap.isEmpty()){
            insert newLineMap.values();
        }
        List<OrderRatePlan__c> ratePlans = new List<OrderRatePlan__c>();
        for(OpportunityRatePlan__c oplan : [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, 
                                            Description__c, LeadTime__c
                                            FROM OpportunityRatePlan__c 
                                            WHERE OpportunityLineItem__c IN :newLineMap.keySet()]){
                                                OrderRatePlan__c plan = new OrderRatePlan__c();
                                                plan.OrderProduct__c = newLineMap.get(oplan.OpportunityLineItem__c).Id;
                                                plan.LeadTime__c = oplan.LeadTime__c;
                                                plan.SalesPrice__c = oplan.SalesPrice__c;
                                                plan.SequenceNumber__c = oplan.SequenceNumber__c;
                                                ratePlans.add(plan);
                                            }
        if(ratePlans != null && !ratePlans.isEmpty()){
            insert ratePlans;
        }
    }
}