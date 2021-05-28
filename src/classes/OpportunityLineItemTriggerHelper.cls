public class OpportunityLineItemTriggerHelper {
    public static void updateUnitPriceFromProductTier(List<OpportunityLineItem> newLines, Map<Id, OpportunityLineItem> oldMap){
        List<OpportunityLineItem> updatedLines = new List<OpportunityLineItem>();
        List<String> lineIds  = new List<String>();
        Map<String, List<OpportunityRatePlan__c>> ratePlanMap = new Map<String, List<OpportunityRatePlan__c>>();
        for(OpportunityLineItem newLine : newLines){
            if(newLine.Quantity != oldMap.get(newLine.Id).Quantity){
                lineIds.add(newLine.Id);
                updatedLines.add(newLine);
            }
        }
        if(updatedLines != null && !updatedLines.isEmpty()){
            for(OpportunityRatePlan__c plan : [SELECT Id, OpportunityLineItem__c, SalesPrice__c, SequenceNumber__c, Description__c
                                               FROM OpportunityRatePlan__c 
                                               WHERE OpportunityLineItem__c IN :lineIds order By SequenceNumber__c]){
                                                   if(ratePlanMap.containsKey(plan.OpportunityLineItem__c)){
                                                       ratePlanMap.get(plan.OpportunityLineItem__c).add(plan);
                                                   } else {
                                                       ratePlanMap.put(plan.OpportunityLineItem__c, new List<OpportunityRatePlan__c>{plan});
                                                   }
                                               }
        }
        for(OpportunityLineItem line: updatedLines){
            if(ratePlanMap.containsKey(line.Id)){
                for(OpportunityRatePlan__c plan : ratePlanMap.get(line.Id)){
                    if(plan.SequenceNumber__c < line.Quantity){
                        line.UnitPrice = plan.SalesPrice__c;
                    }
                }
            }
        }
    }
    public static void updateSortOrder(List<OpportunityLineItem> deletedLines){
        Set<Id> oppIds = new Set<Id>();
        Map<Id, List<OpportunityLineItem>> linesMap = new Map<Id, List<OpportunityLineItem>>();
        for(OpportunityLineItem line : deletedLines){
            oppIds.add(line.OpportunityId);
        }
        for(OpportunityLineItem line : [SELECT Id, OpportunityId, SortOrder 
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId IN :oppIds ORDER BY SortOrder]){
                                            if(linesMap.containsKey(line.OpportunityId)){
                                                line.SortOrder = linesMap.get(line.OpportunityId).size()+1;
                                                linesMap.get(line.OpportunityId).add(line);
                                            } else {
                                                line.SortOrder = 1;
                                                linesMap.put(line.OpportunityId, new List<OpportunityLineItem>{line});
                                            }
                                        }
        List<OpportunityLineItem> updateList = new List<OpportunityLineItem>();
        if(linesMap != null && !linesMap.isEmpty()){
            for(Id oppId : linesMap.keySet()){
                updateList.addAll(linesMap.get(oppId));
            }
            update updateList;
        }
    }
    public static void updateSortOrderonLines(List<OpportunityLineItem> lineItems){
        Set<Id> OppIds = new set<Id>();
        for(OpportunityLineItem line : lineItems){
            OppIds.add(line.opportunityId);
        }
        Map<Id, Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, No_of_line_items__c FROM Opportunity WHERE Id IN :oppIds]);
        Map<Id, integer> linesMap = new Map<Id, integer>();
        for(OpportunityLineItem line : lineItems){
            system.debug('line'+line.SortOrder);
            if(linesMap.containsKey(line.OpportunityId)){
                line.SortOrder = linesMap.get(line.OpportunityId)+ 1;
                linesMap.put(line.OpportunityId, linesMap.get(line.OpportunityId)+1);
            } else{
                if(oppMap.get(line.OpportunityId).No_of_line_items__c != null){
                line.SortOrder = integer.valueOf(oppMap.get(line.OpportunityId).No_of_line_items__c)+1;
                linesMap.put(line.OpportunityId, integer.valueOf(oppMap.get(line.OpportunityId).No_of_line_items__c)+1);
                }
            }
        }
    }
}