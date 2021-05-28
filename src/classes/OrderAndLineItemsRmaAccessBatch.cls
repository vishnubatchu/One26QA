public class OrderAndLineItemsRmaAccessBatch implements Database.Batchable < sObject > {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String Query = 'Select id,ownerid,RMA_Request__r.OwnerID,Disti_Name__c,Disti_Name__r.Name,Disti_Name__r.Legacy_Id__c,(select id from RMA_Lines__r),RMA_Request__c from Order where Order_Changed__c = true';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext BC, List < Order > scope) {
        List < Caseshare > caseRecordListToBeUpdated = New List < Caseshare > ();
        List < order_line__share > orderLineTobeUpdated = New List < order_line__share > ();
        Map <Id, order > orderMapTobeUpdated = New Map <Id, order > ();
        List<OrderShare> orderShareList = New List<OrderShare>();
        Map<Id,String> groupNameMap = New Map<Id,String>();
        Map<String,Id> mapOfGroupNameAndId = New Map<String,Id>();
        Map<Id,Id> caseownerOrderMap = New Map<Id,Id>();
        Map<Id,Order> mapOfOrderfromScope = New Map<Id,Order>(scope);
        for (order orderObj: scope) {
            If (orderObj.RMA_Request__r.OwnerID != Null) {
                caseownerOrderMap.put(orderObj.RMA_Request__r.OwnerID,orderObj.Id);
            }
            If(orderObj.Disti_Name__c!=Null){
                groupNameMap.put(orderObj.Id,orderObj.Disti_Name__r.Legacy_Id__c+'%');
            }
            orderObj.Order_Changed__c = false;
            orderMapTobeUpdated.put(orderObj.id,orderObj);
        }
        IF(caseownerOrderMap.size()>0){
            For(User userObj :[Select id,IsPortalEnabled from User where id in:caseownerOrderMap.keyset() and IsActive=true]){
                IF(userObj.IsPortalEnabled){
                    OrderShare orderShareObj = New OrderShare();
                    orderShareObj.OrderId = caseownerOrderMap.get(userObj.Id);
                    orderShareObj.OrderAccessLevel = 'Read';
                    orderShareObj.UserOrGroupId =userObj.Id;
                    orderShareList.add(orderShareObj);
                    IF(mapOfOrderfromScope.get(caseownerOrderMap.get(userObj.Id)).RMA_Lines__r.size()>0){
                        For (order_line__c orderLineObj: mapOfOrderfromScope.get(caseownerOrderMap.get(userObj.Id)).RMA_Lines__r) {
                            order_line__share orderLineshareObj = new order_line__share();
                            orderLineshareObj.ParentId = orderLineObj.Id;
                            orderLineshareObj.UserOrGroupId = userObj.Id;
                            orderLineshareObj.AccessLevel = 'Read';
                            orderLineTobeUpdated.add(orderLineshareObj);
                        }
                    }
                }
            }
        }
        For(Group groupObj: [select id, Name from Group where Name like: groupNameMap.values()]) {
            mapOfGroupNameAndId.put(groupObj.Name,groupObj.Id);
        }
        If(groupNameMap.size()>0){
            for(id orderId:groupNameMap.keyset()){
                if(mapOfGroupNameAndId.containskey(groupNameMap.get(orderId).remove('%'))){
                    OrderShare orderShareObj = New OrderShare();
                    orderShareObj.OrderId = orderId;
                    orderShareObj.OrderAccessLevel = 'Read';
                    orderShareObj.UserOrGroupId =mapOfGroupNameAndId.get(groupNameMap.get(orderId).remove('%'));
                    orderShareList.add(orderShareObj);
                }}
        }
        If (caseRecordListToBeUpdated.size() > 0) {
            upsert caseRecordListToBeUpdated;
        }
        If (orderLineTobeUpdated.size() > 0) {
            upsert orderLineTobeUpdated;
        }
        If (orderMapTobeUpdated.size() > 0) {
            update orderMapTobeUpdated.values();
        }
        
        If(orderShareList.size()>0){
            upsert orderShareList;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
}