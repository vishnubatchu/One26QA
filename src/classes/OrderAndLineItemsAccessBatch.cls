public class OrderAndLineItemsAccessBatch implements Database.Batchable < sObject > {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String Query = 'select id,Order_Line__c,Order_Line__r.Order__c,Salesrep_Name1__c,Salesrep_Name1__r.Name,Salesrep_Name1__r.Legacy_Id__c ,Salesrep_Name2__c,Salesrep_Name2__r.Name,Salesrep_Name2__r.Legacy_Id__c ,Salesrep_Name3__c,Salesrep_Name3__r.Name,Salesrep_Name3__r.Legacy_Id__c ,Salesrep_Name4__c ,Salesrep_Name4__r.Name,Salesrep_Name4__r.Legacy_Id__c,Salesrep_Name5__c,Salesrep_Name5__r.Name,Salesrep_Name5__r.Legacy_Id__c ,Salesrep_Name6__c,Salesrep_Name6__r.Name ,Salesrep_Name6__r.Legacy_Id__c,Salesrep_Name7__c,Salesrep_Name7__r.Name,Salesrep_Name7__r.Legacy_Id__c ,Salesrep_Name8__c ,Salesrep_Name8__r.Name,Salesrep_Name8__r.Legacy_Id__c,Salesrep_Name9__c ,Salesrep_Name9__r.Name,Salesrep_Name9__r.Legacy_Id__c,Salesrep_Name10__c,Salesrep_Name10__r.Name,Salesrep_Name10__r.Legacy_Id__c,Commisions_Change__c from commisions__C where Commisions_Change__c = true';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext BC, List < Commisions__c > scope) {
        System.debug('In OrderAndLineItemsAccessBatch'+Scope);
        Map<id,Commisions__c> mapOfCommisions = New Map<id,Commisions__c>(scope);
        List < Order_Line__share > orderLineShareToBeUpdated = New List < Order_Line__share > ();
        List < ordershare > orderShareToBeUpdated = New List < ordershare > ();
        List < Commisions__c > commisionsObjToBeupdated = New List < Commisions__c > ();
        Map < Id, List < String >> mapAccountOrderLine = New Map < Id, List < String >> ();
        Set< String > setOfAccountNameAndLegacyCode = New Set< String > ();
        map < String, Id > mapOfGroupNameAndId = New Map < String, Id > ();
        map<id,id> mapoforderLineAndOrder = New Map<id,id>();
        For(Commisions__c commisionsObj: scope) {
            If(commisionsObj.Salesrep_Name1__c != Null && commisionsObj.Order_Line__c!=Null) {
                If(mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name1__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > { commisionsObj.Salesrep_Name1__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name1__r.Legacy_Id__c + '%');
            }
            
            IF(commisionsObj.Salesrep_Name2__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name2__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > { commisionsObj.Salesrep_Name2__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name2__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Salesrep_Name3__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name3__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name3__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name3__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Salesrep_Name4__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name4__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name4__r.Legacy_Id__c
                        });
                }
                mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name4__r.Legacy_Id__c + '%');
				setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name4__r.Legacy_Id__c + '%');
			}
            IF(commisionsObj.Salesrep_Name5__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name5__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name5__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name5__r.Legacy_Id__c + '%');
            }
            IF(commisionsObj.Salesrep_Name6__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name6__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > { commisionsObj.Salesrep_Name6__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name6__r.Legacy_Id__c + '%');
            }
            IF(commisionsObj.Salesrep_Name7__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name7__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name7__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name7__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Salesrep_Name8__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name8__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > { commisionsObj.Salesrep_Name8__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name8__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Salesrep_Name9__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add( commisionsObj.Salesrep_Name9__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name9__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name9__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Salesrep_Name10__c != Null && commisionsObj.Order_Line__c!=Null) {
                If (mapAccountOrderLine.containskey(commisionsObj.Order_Line__c)) {
                    mapAccountOrderLine.get(commisionsObj.Order_Line__c).add(commisionsObj.Salesrep_Name10__r.Legacy_Id__c);
                }
                Else {
                    mapAccountOrderLine.put(commisionsObj.Order_Line__c, New List < String > {commisionsObj.Salesrep_Name10__r.Legacy_Id__c
                        });
                }
                setOfAccountNameAndLegacyCode.add(commisionsObj.Salesrep_Name10__r.Legacy_Id__c + '%');
            }
            If(commisionsObj.Order_Line__c!=Null  && commisionsObj.Order_Line__r.Order__c!=Null){
                mapoforderLineAndOrder.put(commisionsObj.Order_Line__c,commisionsObj.Order_Line__r.Order__c);
            }
            commisionsObj.Commisions_Change__c = False;
            commisionsObjToBeupdated.add(commisionsObj);
        }
        //
        For(Group groupObj: [select id, Name from Group where Name like: setOfAccountNameAndLegacyCode]) {
            mapOfGroupNameAndId.put(groupObj.Name,groupObj.Id);
        }
        //
        //
        System.debug('scope'+scope);
        System.debug('setOfAccountNameAndLegacyCode'+setOfAccountNameAndLegacyCode);
        System.debug('mapAccountOrderLine' + mapAccountOrderLine);
        System.debug('mapOfGroupNameAndId'+mapOfGroupNameAndId);
        if (mapAccountOrderLine.size() > 0) {
            for (id orderLineId: mapAccountOrderLine.keyset()) {
                if(mapAccountOrderLine.get(orderLineId).size()>0){
                    for(String groupName:mapAccountOrderLine.get(orderLineId)){
                        if(mapOfGroupNameAndId.containskey(groupName)){
                            Order_Line__share orderLineshareObj = new Order_Line__share();
                            orderLineshareObj.parentid = orderLineId;
                            orderLineshareObj.AccessLevel = 'Read';
                            orderLineshareObj.UserOrGroupId = mapOfGroupNameAndId.get(groupName);
                            orderLineShareToBeUpdated.add(orderLineshareObj);
                            if(mapoforderLineAndOrder.containskey(orderLineId)){
                                ordershare orderShareObj = New ordershare();
                                orderShareObj.OrderId = mapoforderLineAndOrder.get(orderLineId);
                                orderShareObj.OrderAccessLevel = 'Read';
                                orderShareObj.UserOrGroupId = mapOfGroupNameAndId.get(groupName);
                                orderShareToBeUpdated.add(orderShareObj);
                            }}}}}
            if (orderLineShareToBeUpdated.size() > 0) {
                upsert orderLineShareToBeUpdated;
            }
            if (orderShareToBeUpdated.size() > 0) {
                upsert orderShareToBeUpdated;
            }
        }
        	if (commisionsObjToBeupdated.size() > 0) {
                update commisionsObjToBeupdated;
            }
    }
    public void finish(Database.BatchableContext BC) {
        Database.executeBatch(New OrderAndLineItemsRmaAccessBatch());
    }
}