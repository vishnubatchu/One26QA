public class UpdateGlobalUltimateParentBatchHelper {
    
    public static returnValue UpdateGlobalParent(List<Account> accountList,map<id,Account> globalParentMap ){
        returnValue finalValue = new returnValue();
        List<GlobalParentOwnerBatch_Helper.CustomError> errorList = new List<GlobalParentOwnerBatch_Helper.CustomError>();
        list<Account> updateAcc = new list<Account>();
        list<Order> updateOrder = new list<Order>();
        list<Quote> updateQuote = new list<Quote>();
        list<opportunity> updateOpp = new list<opportunity>();
        finalValue.allAccSuccessId  = new set<id>();
        //Account update List Creation 
        for(Account ac : accountList){
            boolean UpdateFlaf = false;
            string prntId = getParentId(ac,globalParentMap);
            if(prntId != ''){
                ac.Global_Ultimate_Parent__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                ac.Changed_Global_Parent_Old_Owner__c = globalParentMap.get(prntId).Changed_Global_Parent_Old_Owner__c;
                updateAcc.add(ac);
            }
        }
        // Order update List Creation 
        list<opportunity> opList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from opportunity Where AccountId  In:updateAcc ];
        if(opList.size() > 0 && opList != null){
            for(opportunity op : opList){
                string prntId = getParentId(op,globalParentMap);
                if(prntId != ''){
                    op.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    updateOpp.add(op); 
                }
            }
        }
        
        // Order update List Creation 
        list<Order> ordList = [select id,AccountId ,Account.Parent.Parent.Parent.Parent.Id,Account.Parent.Parent.Parent.Id,Account.Parent.Parent.Id,Account.Id,Account.Parent.Id,Global_Ultimate_Account__c   from Order Where AccountId  In:updateAcc ];
        if(ordList.size() > 0 && ordList != null){
            for(Order ord : ordList){
                string prntId = getParentId(ord,globalParentMap);
                if(prntId != ''){
                    ord.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    updateOrder.add(ord); 
                }
            }
        }
        
        // Quote update List Creation 
        list<Quote> qtList = [select id,Account__c,Account__r.Parent.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Parent.Id,Account__r.Parent.Parent.Id,Account__r.Id,Account__r.Parent.Id,Global_Ultimate_Account__c  from Quote Where Account__c In:updateAcc ];
        if(qtList.size() > 0 && qtList != null){
            for(Quote Qt : qtList){
                string prntId = getParentId(Qt,globalParentMap);
                if(prntId != ''){
                    Qt.Global_Ultimate_Account__c = globalParentMap.get(prntId).Global_Ultimate_Parent__c;
                    updateQuote.add(Qt); 
                }
            }
        }
        //Update Account
        try{
            if(updateAcc.size() > 0 && updateAcc != null ){
                database.SaveResult[] accResult=database.update(updateAcc,false);
                for(Database.SaveResult acRslt : accResult) {
                    if (acRslt.isSuccess()) {
                        finalValue.allAccSuccessId.add(acRslt.getId());
                    }
                }
                if(finalValue.csvBody != ''){
                    finalValue.csvBody +=  createCSVBody('Account' , accResult);
                }else{
                    finalValue.csvBody = createCSVBody('Account' , accResult); 
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        //Update Opportunity
        try{
            if(updateOpp.size() > 0 && updateOpp != null ){
                database.SaveResult[] oppResult=database.update(updateOpp,false);
                if(finalValue.csvBody != ''){
                    finalValue.csvBody +=  createCSVBody('Opportunity' , oppResult);
                }else{
                    finalValue.csvBody = createCSVBody('Opportunity' , oppResult); 
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        //Update Order
        try{
            if(updateOrder.size() > 0 && updateOrder != null ){
                database.SaveResult[] ordResult=database.update(updateOrder,false);
                if(finalValue.csvBody != ''){
                    finalValue.csvBody += createCSVBody('Order' , ordResult);
                }else{
                    finalValue.csvBody = createCSVBody('Order' , ordResult); 
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        //Update Quote
        try{
            if(updateQuote.size() > 0 && updateQuote != null ){
                database.SaveResult[] qtResult=database.update(updateQuote,false);
                if(finalValue.csvBody != ''){
                    finalValue.csvBody += createCSVBody('Quote' , qtResult);
                }else{
                    finalValue.csvBody = createCSVBody('Quote' , qtResult); 
                }
            }
        }catch(Exception e){
            system.debug('**Error at line number---'+e.getLineNumber() + ' - '+ e.getMessage());
        }
        //GlobalParentOwnerBatch_Helper call
        list<Account> acSharing = [select id,Changed_Global_Parent_Old_Owner__c from Account where Id in:finalValue.allAccSuccessId ]; 
        if(acSharing.size() > 0 && acSharing != null){
            // GlobalParentOwnerBatch_Helper.getShareRcrdsTobeDeletedOrInserted(acSharing,False);
            errorList=GlobalParentOwnerBatch_Helper.deleteAndInsertShareRecords(acSharing,false);
            for(GlobalParentOwnerBatch_Helper.CustomError err : errorList){
                finalValue.csvBody += err.ID+ ',';
                finalValue.csvBody += err.objectName + ','; 
                finalValue.csvBody += err.message + ','; 
                finalValue.csvBody += '\n';
            }
        }
        return finalValue;
        
    }
    public static string createCSVBody(string ObjName ,database.SaveResult[] updateResult){
        string body = '';
        
        for(Integer i=0; i < updateResult.size(); i++) {
            if(updateResult.get(i).isSuccess()) {
                System.debug('Records are updated Successfully for ' + updateResult.get(i).Id);
            } 
            else if(!updateResult.get(i).isSuccess()) {
                body += updateResult.get(i).Id + ',';
                body += ObjName + ',';
                string errorMsg = '';
                for(Database.Error error : updateResult[i].getErrors()){
                    errorMsg += error.getMessage() + ',';
                }
                errorMsg = errorMsg.removeEnd(',');
                body += '"'+errorMsg + '"' + ','; 
                body += '\n';
            }
        }
        return body;
    }
    public static string  getParentId(sobject obj, map<id,Account> globalParentMap){
        string parentId = '';
        if(obj.Id.getSObjectType().getDescribe().getName() == 'Account'){
            Account Acc = (Account)obj; 
            if(globalParentMap.get(Acc.Parent.Id) != null){
                parentId = Acc.Parent.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Id;  
            }else if(globalParentMap.get(Acc.Id) != null){
                parentId = Acc.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(Acc.Parent.Parent.Parent.Parent.Id) != null){
                parentId = Acc.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Quote'){
            Quote qt = (Quote)obj; 
            if(globalParentMap.get(qt.Account__r.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Id;  
            }else if(globalParentMap.get(qt.Account__r.Id) != null){
                parentId = qt.Account__r.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(qt.Account__r.Parent.Parent.Parent.Parent.Id) != null){
                parentId = qt.Account__r.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Opportunity'){
            Opportunity opp = (Opportunity)obj; 
            if(globalParentMap.get(opp.Account.Parent.Id) != null){
                parentId = opp.Account.Parent.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Id;  
            }else if(globalParentMap.get(opp.Account.Id) != null){
                parentId = opp.Account.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(opp.Account.Parent.Parent.Parent.Parent.Id) != null){
                parentId = opp.Account.Parent.Parent.Parent.Parent.Id;
            } 
        }else if(obj.Id.getSObjectType().getDescribe().getName() == 'Order'){
            Order ord = (Order)obj; 
            if(globalParentMap.get(ord.Account.Parent.Id) != null){
                parentId = ord.Account.Parent.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Id;  
            }else if(globalParentMap.get(ord.Account.Id) != null){
                parentId = ord.Account.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Parent.Id;
            }else if(globalParentMap.get(ord.Account.Parent.Parent.Parent.Parent.Id) != null){
                parentId = ord.Account.Parent.Parent.Parent.Parent.Id;
            } 
        }
        return  parentId;
    } 
    public class returnValue
    {
        public String csvBody{get;set;}
        public set<id> allAccSuccessId{get;set;}
    }
}