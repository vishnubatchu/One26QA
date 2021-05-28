public class ContentDocumentLinkTriggerHelper {
    public static void updateFilesCount(List<ContentDocumentLink> files){
        Map<String, Integer> orderLineCount = new Map<String, Integer>();
        List<Order_Line__c> orderlines = new List<Order_Line__c>();
        for(ContentDocumentLink file : files){
            System.debug('Sobject name==>'+file.LinkedEntityId.getSObjectType().getDescribe().getName());
            if(file.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Order_Line__c'){
                orderLineCount.put(file.LinkedEntityId, 0);
            }
        }
        system.debug('orderLineCount'+orderLineCount);
        if(!orderLineCount.isEmpty()){
         for(ContentDocumentLink att : [SELECT Id, LinkedEntityId, visibility 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId IN : orderLineCount.keySet()]){
                                            orderLineCount.put(att.LinkedEntityId, orderLineCount.get(att.LinkedEntityId)+1);
                                        }
        system.debug('orderLineCount'+orderLineCount);
        for(String ordLineId : orderLineCount.keySet()){
            orderlines.add(new Order_Line__c(id = ordLineId, NoofFilesAttached__c = orderLineCount.get(ordLineId)));
        }
        system.debug('orderlines'+orderlines);
        if(orderlines != null && !orderlines.isEmpty()){
            update orderlines;
        }
    }
    }
}