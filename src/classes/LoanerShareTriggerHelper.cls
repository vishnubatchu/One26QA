public class LoanerShareTriggerHelper {
    
    public static void accessToSalesOrDistributor(Map<id,Loaner__c> LoanerMap){
        System.debug('accessToInsideSales');
        sYSTEM.debug('LoanerMap'+LoanerMap);
        Set<String> salesAndDistributorgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Loaner__c LoanerObj:LoanerMap.values()){
            System.debug('LoanerObj'+LoanerObj);
            If(LoanerObj.SalesRepFirmGroup__c!=Null){
                salesAndDistributorgroup.add(LoanerObj.SalesRepFirmGroup__c);
            }
            IF(LoanerObj.DistributorFirmGroupName__c!=Null){
                salesAndDistributorgroup.add(LoanerObj.DistributorFirmGroupName__c);
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
        List<Loaner__Share> LoanerShareList = New List<Loaner__Share>();
        for(Loaner__c LoanerObj:LoanerMap.values()){
            IF(mapGroupNameAndId.containskey(LoanerObj.SalesRepFirmGroup__c)){
                Loaner__Share LoanerShareObj = New Loaner__Share();
                LoanerShareObj.parentId = LoanerObj.Id;
                LoanerShareObj.AccessLevel ='Edit';
                LoanerShareObj.UserOrGroupId = mapGroupNameAndId.get(LoanerObj.SalesRepFirmGroup__c);
                LoanerShareList.add(LoanerShareObj);
            }
            IF(mapGroupNameAndId.containskey(LoanerObj.DistributorFirmGroupName__c)){
                Loaner__Share LoanerShareObj = New Loaner__Share();
                LoanerShareObj.parentId = LoanerObj.Id;
                LoanerShareObj.AccessLevel ='Edit';
                LoanerShareObj.UserOrGroupId = mapGroupNameAndId.get(LoanerObj.DistributorFirmGroupName__c);
                LoanerShareList.add(LoanerShareObj);
            }
        }
        System.debug('LoanerShareList'+LoanerShareList);
        If(LoanerShareList.size()>0){
            upsert LoanerShareList;
        }
    } 
    
    public static void removeAccessToInsideSales(Map<id,Loaner__c> LoanerMap, Map<id,Loaner__c> loanerNewMap){
        System.debug('removeAccessToInsideSales');
        Set<String> salesAndDistributorgroup = New Set<String>();
        Map<String,Id> mapGroupNameAndId = New Map<String,Id>();
        for(Loaner__c LoanerObj:LoanerMap.values()){
            If(LoanerObj.SalesRepFirmGroup__c != Null && 
               loanerNewMap.get(LoanerObj.Id).SalesRepFirmGroup__c != LoanerObj.SalesRepFirmGroup__c){
                   salesAndDistributorgroup.add(LoanerObj.SalesRepFirmGroup__c);
               }
            IF(LoanerObj.DistributorFirmGroupName__c != Null && 
               loanerNewMap.get(LoanerObj.Id).DistributorFirmGroupName__c != LoanerObj.DistributorFirmGroupName__c){
                   salesAndDistributorgroup.add(LoanerObj.DistributorFirmGroupName__c);
               }
        }
        List<group> groupList =[select id,name from group where name in:salesAndDistributorgroup];
        List<Loaner__Share> LoanerShareList = [Select id from Loaner__Share where parentId in:LoanerMap.keyset() And UserOrGroupId in:groupList];
        System.debug('LoanerShareList'+LoanerShareList);
        if(LoanerShareList.size()>0){
            delete LoanerShareList;
        }
    }
    
    public static void updateSalesRepAndDistributorShare(Map<id,Loaner__c> LoanerNewMap,Map<id,Loaner__c> LoanerOldMap){
        Map<Id,Loaner__c> LoanerToBeUpdatedMap = New Map<Id,Loaner__c>();
        Map<Id,Loaner__c> LoanerToBeRemovedMap = New Map<Id,Loaner__c>();
        for(Loaner__c LoanerObj : LoanerNewMap.values()){
            if(LoanerOldMap.get(LoanerObj.Id).SalesRepFirmGroup__c!= LoanerObj.SalesRepFirmGroup__c||
               LoanerOldMap.get(LoanerObj.Id).DistributorFirmGroupName__c!= LoanerObj.DistributorFirmGroupName__c){
                   LoanerToBeUpdatedMap.put(LoanerObj.Id,LoanerObj);
                   LoanerToBeRemovedMap.put(LoanerObj.Id,LoanerOldMap.get(LoanerObj.Id));
               }
        }
        If(LoanerToBeUpdatedMap.size()>0){
            accessToSalesOrDistributor(LoanerToBeUpdatedMap);
            //  removeAccessToInsideSales(LoanerToBeRemovedMap);
            removeAccessToInsideSales(LoanerToBeRemovedMap, LoanerNewMap);
        }
    }
    
    public static void accessToinsideSalesAndRSM(List<loaner__c> newLoanerList){
        List<Loaner__Share> LoanerShareList = New List<Loaner__Share>();
        For(loaner__c loanObj:newLoanerList){
            IF(loanObj.Inside_Sales_Finisar__c!=Null && loanObj.CreatedById!=loanObj.Inside_Sales_Finisar__c && loanObj.InsideSalesActiveCheck__c){
                LoanerShareList.add(EditLoanerShareObjectAccess(loanObj,loanObj.Inside_Sales_Finisar__c));
            }
            IF(loanObj.RSM_PLM_Finisar__c!=Null && loanObj.CreatedById!=loanObj.RSM_PLM_Finisar__c && loanObj.RSMFinisarActiveCheck__c){
                LoanerShareList.add(EditLoanerShareObjectAccess(loanObj,loanObj.RSM_PLM_Finisar__c));
            }
        }
        IF(LoanerShareList.size()>0){
            insert LoanerShareList;
        }
    }
    
    public static void accessToinsideSalesAndRSM(Map<Id,loaner__c> oldLoanerMap,Map<Id,loaner__c> newLoanerMap){
        List<Loaner__Share> LoanerShareList = New List<Loaner__Share>();
        for(Id loanerId:newLoanerMap.keyset()){
            If(oldLoanerMap.get(loanerId).Inside_Sales_Finisar__c!=newLoanerMap.get(loanerId).Inside_Sales_Finisar__c && newLoanerMap.get(loanerId).createdById!=newLoanerMap.get(loanerId).Inside_Sales_Finisar__c && newLoanerMap.get(loanerId).InsideSalesActiveCheck__c){
                Loaner__Share loanshareObj = EditLoanerShareObjectAccess(newLoanerMap.get(loanerId),newLoanerMap.get(loanerId).Inside_Sales_Finisar__c);
                LoanerShareList.add(loanshareObj);
            }
            If(oldLoanerMap.get(loanerId).RSM_PLM_Finisar__c!=newLoanerMap.get(loanerId).RSM_PLM_Finisar__c && newLoanerMap.get(loanerId).createdById!=newLoanerMap.get(loanerId).RSM_PLM_Finisar__c && newLoanerMap.get(loanerId).RSMFinisarActiveCheck__c){
                Loaner__Share loanshareObj = EditLoanerShareObjectAccess(newLoanerMap.get(loanerId),newLoanerMap.get(loanerId).RSM_PLM_Finisar__c);
                LoanerShareList.add(loanshareObj);
            }
        }
        IF(LoanerShareList.size()>0){
            upsert LoanerShareList;
        }
    }
    
    public static Loaner__Share EditLoanerShareObjectAccess(Loaner__c loanerObj,Id userId){
        Loaner__Share LoanerShareObj = New Loaner__Share();
        LoanerShareObj.parentId = loanerObj.Id;
        LoanerShareObj.AccessLevel ='Edit';
        LoanerShareObj.UserOrGroupId =userId;
        return LoanerShareObj;
    }
    
    /**
* Method Name: updateVPSVP
* Input Parameter: List<Loaner__c> 
* output parameters: NA
* Description : updates VP and SVP on loaner from Custom metadata.
* Date : 22/04/2020
* */
    public static void updateVPSVP(List<Loaner__c> loanerList){
        system.debug('loanerList'+loanerList);
        List<String> rmsEmails = new List<String>();
        Map<String, String> emailMap = new Map<String, String>();
        Map<String, String> vpMapping = new Map<String, String>();
        Map<String, String> svpMapping = new Map<String, String>();
        for(Loaner__c loaner : loanerList){
            rmsEmails.add(loaner.RSMEmail__c);
        }
        for(VPSVP_Mapping__mdt mapping : [SELECT Id, SVP__c,VP__c, RSMName__c
                                          FROM VPSVP_Mapping__mdt 
                                          WHERE RSMName__c IN :rmsEmails]){
                                              emailMap.put(mapping.VP__c, '');
                                              vpMapping.put(mapping.RSMName__c, mapping.VP__c);
                                              if(mapping.VP__c != mapping.SVP__c){
                                                  svpMapping.put(mapping.RSMName__c, mapping.SVP__c);
                                                  emailMap.put(mapping.SVP__c, '');
                                              }
                                          }
        for(User usr : [SELECT Id, Name FROM User
                        WHERE Name IN : emailMap.keySet() AND isActive = true]){
                            emailMap.put(usr.Name, usr.Id);
                        }
        system.debug('emailMap'+emailMap);
        system.debug('vpMapping'+vpMapping);
        system.debug('svpMapping'+svpMapping);
        for(Loaner__c loaner : loanerList){
            system.debug('loaner.RSMEmail__c'+loaner.RSMEmail__c);
            if(vpMapping.containsKey(loaner.RSMEmail__c)){
                system.debug('loaner.RSMEmail__c'+loaner.RSMEmail__c);
                if(emailMap.get(vpMapping.get(loaner.RSMEmail__c)) != ''){
                    loaner.VP_PLD_Finisar__c = emailMap.get(vpMapping.get(loaner.RSMEmail__c));
                }
            }
            if(svpMapping.containsKey(loaner.RSMEmail__c)){
                if(emailMap.get(svpMapping.get(loaner.RSMEmail__c)) != ''){
                    loaner.SVP__c = emailMap.get(svpMapping.get(loaner.RSMEmail__c));
                }
            } else if(emailMap.get(vpMapping.get(loaner.RSMEmail__c)) != '') {
                loaner.SVP__c = emailMap.get(vpMapping.get(loaner.RSMEmail__c));
            }
            system.debug('loaner.SVP__c'+loaner.SVP__c);
        }
    }
    //Added for WSS
    public static void updateBuonLoaner(List<Loaner_Line__c> deletedLines){
        List<Id> loanerIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        Map<Id, String> loanerMap = new Map<Id, String>();
        for(Loaner_Line__c line : deletedLines){
            loanerMap.put(line.Loaner__c, null);
        }
        for(Loaner_Line__c lline : [SELECT Id, Product__c, Product__r.Bu_Code__c, Product__r.Product_Family__c, Loaner__c
                                   FROM Loaner_Line__c 
                                    WHERE Loaner__c IN: loanerMap.keySet()]){
                                       //loanerMap 
                                       if(lline.Product__r.Bu_Code__c == '0040' &&
                                          lline.Product__r.Product_Family__c != 'WSS-OCM' &&
                                          lline.Product__r.Product_Family__c != 'WSS-OIG'){
                                             loanerMap.put(lline.Loaner__c, 'WSS'); 
                                          } else if(loanerMap.get(lline.Loaner__c) == null){
                                              loanerMap.put(lline.Loaner__c, 'Non WSS');
                                          }
                                    }
        List<Loaner__c> loaners = new List<Loaner__c>();
        for(Id loanerId : loanerMap.keySet() ){
            loaners.add(new Loaner__c(Id = loanerId, BuCode__c = loanerMap.get(loanerId)));
        }
        if(loaners != null && !loaners.isEmpty()){
            update loaners;
        }
}
}