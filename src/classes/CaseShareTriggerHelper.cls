public class CaseShareTriggerHelper {
    public static void accessToSalesOrDistributor(Map<id,Case> CaseMap){
        System.debug('accessToInsideSales');
        Set<String> salesAndDistributorgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Case CaseObj:CaseMap.values()){
            System.debug('CaseObj'+CaseObj);
            If(CaseObj.SalesFirmGroupName__c!=Null){
                salesAndDistributorgroup.add(CaseObj.SalesFirmGroupName__c);
            }
            IF(CaseObj.DistributorFirmGroupName__c!=Null){
                salesAndDistributorgroup.add(CaseObj.DistributorFirmGroupName__c);
            }
        }
        System.debug('salesChannelgroup'+salesAndDistributorgroup);
        List<group> groupList =[select id,name from group where name in:salesAndDistributorgroup];
        System.debug('groupList'+groupList);
        if(groupList.size()>0){
            for(group groupObj :groupList){
                mapGroupNameAndId.put(groupObj.name,groupObj.Id);
            }
        }
        List<CaseShare> CaseShareList = New List<CaseShare>();
        for(Case CaseObj:CaseMap.values()){
            IF(mapGroupNameAndId.containskey(CaseObj.SalesFirmGroupName__c)){
                CaseShare CaseShareObj = New CaseShare();
                CaseShareObj.CaseId = CaseObj.Id;
                CaseShareObj.CaseAccessLevel ='Read';
                CaseShareObj.UserOrGroupId = mapGroupNameAndId.get(CaseObj.SalesFirmGroupName__c);
                CaseShareList.add(CaseShareObj);
            }
            IF(mapGroupNameAndId.containskey(CaseObj.DistributorFirmGroupName__c)){
                CaseShare CaseShareObj = New CaseShare();
                CaseShareObj.CaseId = CaseObj.Id;
                CaseShareObj.CaseAccessLevel ='Read';
                CaseShareObj.UserOrGroupId = mapGroupNameAndId.get(CaseObj.DistributorFirmGroupName__c);
                CaseShareList.add(CaseShareObj);
            }
        }
        System.debug('CaseShareList'+CaseShareList);
        If(CaseShareList.size()>0){
            upsert CaseShareList;
        }
    } 
    
    public static void removeAccessToInsideSales(Map<id,Case> CaseMap){
        System.debug('removeAccessToInsideSales');
        Set<String> salesAndDistributorgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Case CaseObj:CaseMap.values()){
            If(CaseObj.SalesFirmGroupName__c!=Null){
                salesAndDistributorgroup.add(CaseObj.SalesFirmGroupName__c);
            }
            IF(CaseObj.DistributorFirmGroupName__c!=Null){
                salesAndDistributorgroup.add(CaseObj.DistributorFirmGroupName__c);
            }
        }
        List<group> groupList =[select id,name from group where name in:salesAndDistributorgroup];
        List<CaseShare> CaseShareList = [Select id from CaseShare where CaseId in:CaseMap.keyset() And UserOrGroupId in:groupList];
        System.debug('CaseShareList'+CaseShareList);
        if(CaseShareList.size()>0){
            delete CaseShareList;
        }
    }
    
    public static void updateSalesRepAndDistributorShare(Map<id,Case> caseNewMap,Map<id,Case> caseOldMap){
        System.debug('In updateSalesRepAndDistributorShare ');
        Map<Id,Case> caseToBeUpdatedMap = New Map<Id,Case>();
        Map<Id,Case> caseToBeRemovedMap = New Map<Id,Case>();
        for(Case CaseObj : CaseNewMap.values()){
            if(CaseOldMap.get(CaseObj.Id).SalesFirmGroupName__c!= CaseObj.SalesFirmGroupName__c||
               CaseOldMap.get(CaseObj.Id).DistributorFirmGroupName__c!= CaseObj.DistributorFirmGroupName__c){
                   CaseToBeUpdatedMap.put(CaseObj.Id,CaseObj);
                   CaseToBeRemovedMap.put(CaseObj.Id,CaseOldMap.get(CaseObj.Id));
               }
        }
        System.debug('CaseToBeUpdatedMap'+CaseToBeUpdatedMap);
                System.debug('CaseToBeRemovedMap'+CaseToBeRemovedMap);

        If(CaseToBeUpdatedMap.size()>0){
            accessToSalesOrDistributor(CaseToBeUpdatedMap);
            removeAccessToInsideSales(CaseToBeRemovedMap);
        }
    }
}