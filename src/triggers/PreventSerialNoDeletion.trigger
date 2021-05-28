trigger PreventSerialNoDeletion on Serial_Number__c (before delete, after Insert, after update) {
    String uRoleId = userinfo.getProfileId();
    Map<Id, String> orderlineMap = new Map<Id, String>();
    List<Order_Line__c> oliLst = new List<Order_Line__c>();
    if(trigger.isDelete){
        Profile ur = [Select id, Name from Profile where id  =: uRoleId ]; 
        if(ur.Name != 'System Administrator'){
            for(Serial_Number__c sn : trigger.old){
                sn.adderror('Serial Number Cannot be deleted');
            } 
        }
    } else {
        for(Serial_Number__c sn : trigger.new){
            orderlineMap.put(sn.Order_Line__c, sn.RMA_Id__c);
        }
        for(Order_Line__c oli : [SELECT Id, RMAID__c 
                                FROM Order_Line__c
                                 WHERE Id IN :orderlineMap.keySet()]){
                                     if(oli.RMAID__c == null){
                                        oli.RMAID__c =  orderlineMap.get(oli.Id);
                                         oliLst.add(oli);
                                     }
                                 }
        if(oliLst != null && !oliLst.isEmpty())
            update oliLst;
    }
    
}