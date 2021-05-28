public class QuoteShareTriggerHelper {
    
    public static void accessToInsideSales(Map<id,Quote> quoteMap){
        System.debug('accessToInsideSales');
        Set<String> salesChannelgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Quote quoteObj:quoteMap.values()){
            System.debug('quoteObj'+quoteObj);
            if(quoteObj.SalesChanelGroupName__c!=Null){
                salesChannelgroup.add(quoteObj.SalesChanelGroupName__c);
            }
        }
        System.debug('salesChannelgroup'+salesChannelgroup);
        List<group> groupList =[select id,name from group where name in:salesChannelgroup];
        System.debug('groupList'+groupList);
        if(groupList.size()>0){
            for(group groupObj :groupList){
                mapGroupNameAndId.put(groupObj.name,groupObj.Id);
            }
        }
        List<QuoteShare> quoteShareList = New List<QuoteShare>();
        for(Quote quoteObj:quoteMap.values()){
            IF(mapGroupNameAndId.containskey(quoteObj.SalesChanelGroupName__c)){
                QuoteShare quoteShareObj = New QuoteShare();
                quoteShareObj.ParentId = quoteObj.Id;
                quoteShareObj.AccessLevel ='Read';
                quoteShareObj.UserOrGroupId = mapGroupNameAndId.get(quoteObj.SalesChanelGroupName__c);
                quoteShareList.add(quoteShareObj);
            }
        }
        System.debug('quoteShareList'+quoteShareList);
        If(quoteShareList.size()>0){
            upsert quoteShareList;
        }
    } 
    
    public static void removeAccessToInsideSales(Map<id,Quote> quoteMap){
        System.debug('removeAccessToInsideSales');
        Set<String> salesChannelgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Quote quoteObj:quoteMap.values()){
            if(quoteObj.SalesChanelGroupName__c!=Null){
                salesChannelgroup.add(quoteObj.SalesChanelGroupName__c);
            }
        }
        List<group> groupList =[select id,name from group where name in:salesChannelgroup];
        List<QuoteShare> quoteShareList = [Select id from QuoteShare where ParentId in:quoteMap.keyset() And UserOrGroupId in:groupList];
        System.debug('quoteShareList'+quoteShareList);
        if(quoteShareList.size()>0){
            delete quoteShareList;
        }
    }
    
    public static void updateSalesChannelShare(Map<id,Quote> quoteNewMap, Map<id,Quote> quoteOldMap){
        Map<Id,Quote> quoteToBeUpdatedMap = New Map<Id,Quote>();
        Map<Id,Quote> quoteToBeRemovedMap = New Map<Id,Quote>();
        for(quote quoteObj : quoteNewMap.values()){
            if(quoteOldMap.get(quoteObj.Id).SalesChanelGroupName__c!= quoteObj.SalesChanelGroupName__c){
                quoteToBeUpdatedMap.put(quoteObj.Id,quoteObj);
                quoteToBeRemovedMap.put(quoteObj.Id,quoteOldMap.get(quoteObj.Id));
            }
        }
        If(quoteToBeUpdatedMap.size()>0){
            removeAccessToInsideSales(quoteToBeRemovedMap);
            accessToInsideSales(quoteToBeUpdatedMap);
        }
    }
    
    public static void provideAccesstoExternalUserInSameCompany(Map<id,Quote> quoteNewMap){
        List<Quote> quoteRelatedFieldsList =[Select id,createdby.Account.Legacy_Id__c from Quote where Id in:quoteNewMap.keyset()];
        Map<Id,String> MapOfQuoteIdAndLegacyCode = New Map<Id,String>();
        For(Quote quoteObj:quoteRelatedFieldsList){
            IF(quoteObj.createdby.Account.Legacy_Id__c!=Null ){
                MapOfQuoteIdAndLegacyCode.put(quoteObj.id,quoteObj.createdby.Account.Legacy_Id__c);
            }
        }
        IF(MapOfQuoteIdAndLegacyCode.size()>0){
            List<QuoteShare> quoteShareList = New List<QuoteShare>();
            Map<String,Id>MapOfGroupNameAndId = New Map<String,Id>();
            For(Group groupObj :[Select Id,name from Group where name in :MapOfQuoteIdAndLegacyCode.values()]){
                MapOfGroupNameAndId.put(groupObj.name,groupObj.Id);
            }
            For(Id quoteId : MapOfQuoteIdAndLegacyCode.keyset()){
                IF(MapOfGroupNameAndId.containskey(MapOfQuoteIdAndLegacyCode.get(quoteId))){
                    QuoteShare quoteShareObj = New QuoteShare();
                    quoteShareObj.ParentId = quoteId;
                    quoteShareObj.AccessLevel ='Edit';
                    quoteShareObj.UserOrGroupId = MapOfGroupNameAndId.get(MapOfQuoteIdAndLegacyCode.get(quoteId));
                    quoteShareList.add(quoteShareObj);
                }
            }
            System.debug('quoteShareList'+quoteShareList);
            IF(quoteShareList.size()>0){
                insert quoteShareList;
            }
        }
    }
}