global class LoanerOrderlinkbatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, SO_Line_Migration__c, SO_Number_Migration__c,Loaner__c '+'  FROM Loaner_Line__c where SO_Line_Migration__c!=null and SO_Number_Migration__c!=null'//and Loaner__r.owner.FirstName = \'Prasoon\'
        );
    }
    global void execute(Database.BatchableContext bc, List<Loaner_Line__c> scope){
        Map<String,String> soNumberLoanerIdMap = new Map<String,String>();
        Map<String,String> soLineSoNumberandLoanerLineMap = new Map<String,String>();
        Map<String,String> loanerIdandOrderIdMap = new Map<String,String>();
        Map<String,String> loanerLineIdandOrderLineIdMap = new Map<String,String>();
        for(Loaner_Line__c loanLine : scope){
            soNumberLoanerIdMap.put(loanLine.SO_Number_Migration__c,loanLine.Loaner__c);
            soLineSoNumberandLoanerLineMap.put(loanLine.SO_Line_Migration__c+';'+loanLine.SO_Number_Migration__c,loanLine.Id);
            loanerIdandOrderIdMap.put(loanLine.Loaner__c,null);
            loanerLineIdandOrderLineIdMap.put(loanLine.Id,null);
        }
        List<Order> orderList = new List<Order>();
        List<Order> orderListUpdate = new List<Order>();
        List<Order_Line__c> orderLineUpdateList = new List<Order_Line__c>();
        orderList = [SELECT Id,PoNumber,(Select Id,Line__c from RMA_Lines__r) from Order where PoNumber IN : soNumberLoanerIdMap.keySet() /*and owner.FirstName = 'Prasoon'*/];
        for(Order ord : orderList){
            if(soNumberLoanerIdMap.containsKey(ord.PoNumber)){
                ord.Loaner__c = soNumberLoanerIdMap.get(ord.PoNumber);
                loanerIdandOrderIdMap.put(soNumberLoanerIdMap.get(ord.PoNumber),ord.Id);
                orderListUpdate.add(ord);
            }
            if(ord.RMA_Lines__r!=null && ord.RMA_Lines__r.size()>0){
                for(Order_Line__c ordLine : ord.RMA_Lines__r){
                    if(soLineSoNumberandLoanerLineMap.containsKey(ordLine.Line__c+';'+ord.PoNumber)){
                        ordLine.Loaner_Line__c = soLineSoNumberandLoanerLineMap.get(ordLine.Line__c+';'+ord.PoNumber);
                        orderLineUpdateList.add(ordLine);
                        if(soLineSoNumberandLoanerLineMap.containsKey(ordLine.Line__c+';'+ord.PoNumber)){
                            loanerLineIdandOrderLineIdMap.put(soLineSoNumberandLoanerLineMap.get(ordLine.Line__c+';'+ord.PoNumber),ordLine.Id);
                        }
                    }
                }
            }
        }
        System.Debug('<<<<<<<soLineSoNumberandLoanerLineMap>>>>>>>>'+soLineSoNumberandLoanerLineMap);
        List<Loaner__c> lnlistToUpdate = new List<Loaner__c>();
        List<Loaner_Line__c> lnLinelistToUpdate = new List<Loaner_Line__c>();
        for(String loanerID : loanerIdandOrderIdMap.keySet()){
            Loaner__c ln = new Loaner__c(Id=loanerID, Order__c = loanerIdandOrderIdMap.get(loanerID));
            lnlistToUpdate.add(ln);
        }
        for(String loanerLineID : loanerLineIdandOrderLineIdMap.keySet()){
            Loaner_Line__c lln = new Loaner_Line__c(Id=loanerLineID,Order_Line__c= loanerLineIdandOrderLineIdMap.get(loanerLineID));
            lnLinelistToUpdate.add(lln);
        }
        
        if(orderListUpdate!=null && orderListUpdate.size()>0){
            update orderListUpdate;
        }   
        if(orderLineUpdateList!=null && orderLineUpdateList.size()>0){
            update orderLineUpdateList;
        }
        
        if(lnlistToUpdate!=null && lnlistToUpdate.size()>0){
            update lnlistToUpdate;
        }   
        if(lnLinelistToUpdate!=null && lnLinelistToUpdate.size()>0){
            update lnLinelistToUpdate;
        }
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}