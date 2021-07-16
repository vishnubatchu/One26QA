/*
* Created by : Pooja U
* Date : 26th May 2021
* Description: This helper class inserts/delete share records for all related private records within the global hierarchy including Contacts, 
* Opportunities, Quotes, Orders, Order Lines and Cases when Account owner on Global Parent is changed or when Global parent is changed on an Account 
*/
public class GlobalParentOwnerBatch_Helper {
    
    //This method deletes  and insert share records
    public static List<CustomError> deleteAndInsertShareRecords(List<Account> accountList,boolean isOwnerChange){
        List<CustomError> errorList=new List<CustomError>();
        if(accountList!=null && !accountList.isEmpty()){
            try{
                Map<String,List<SObject>> shareRecordsMap=getShareRcrdsTobeDeletedOrInserted(accountList,isOwnerChange);
                if(shareRecordsMap!=null && !shareRecordsMap.isEmpty()){
                    List<Sobject> listOfShareRecTobeDeleted=new List<Sobject>();
                    List<Sobject> listOfShareRecTobeInserted=new List<Sobject>();
                    if(shareRecordsMap.containsKey('deleteList') && shareRecordsMap.get('deleteList')!=null
                       && !shareRecordsMap.get('deleteList').isEmpty()){
                           listOfShareRecTobeDeleted.addAll(shareRecordsMap.get('deleteList'));
                       }
                    if(shareRecordsMap.containsKey('insertList') && shareRecordsMap.get('insertList')!=null
                       && !shareRecordsMap.get('insertList').isEmpty()){
                           listOfShareRecTobeInserted.addAll(shareRecordsMap.get('insertList'));
                       }
                    if(!listOfShareRecTobeDeleted.isEmpty()){
                            // Delete the records
                            Database.DeleteResult[] drList = Database.delete(listOfShareRecTobeDeleted, false);
                            Integer lstIndex=0;
                            // Iterate through each returned result
                            for(Database.DeleteResult dr : drList) {
                                if (!dr.isSuccess()) {
                                    String message='';
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : dr.getErrors()) {
                                        message+= err.getMessage();
                                    }
                                    errorList.add(new CustomError(listOfShareRecTobeDeleted[lstIndex].Id,listOfShareRecTobeDeleted[lstIndex].Id.getSObjectType().getDescribe().getName(),'Delete',message));
                                }
                                lstIndex++;
                            }
                    }
                    if(!listOfShareRecTobeInserted.isEmpty()){
                            Database.SaveResult[] srList = Database.insert(listOfShareRecTobeInserted, false);
                            // Iterate through each returned result
                            for (Database.SaveResult sr : srList) {
                                if (!sr.isSuccess()) {
                                    String message='';
                                    // Operation failed, so get all errors                
                                    for(Database.Error err : sr.getErrors()) {
                                        message+= err.getMessage();
                                    }
                                    errorList.add(new CustomError('','ShareObj','Insert',message));
                                }
                            }
                    }
                }
            }catch(Exception excpn){
                errorList.add(new CustomError('','','','Exception occured in deleteAndInsertShareRecords()==>At line:'+excpn.getLineNumber()+',Message:'+excpn.getMessage()));
            }
        }
        return errorList;
    }
    
    //This method get all related share records to be inserted or deleted
    public static Map<String,List<SObject>> getShareRcrdsTobeDeletedOrInserted(List<Account> accountList,boolean isOwnerChange){
        Map<String,List<SObject>> finalReturnMap=new Map<String,List<SObject>>();
        if(accountList!=null && !accountList.isEmpty()){
            
            Set<Id> previousOwnerIdSet=new Set<Id>();
            for(Account eachAcc:accountList){
                if(isOwnerChange){
                    previousOwnerIdSet.add(eachAcc.Global_Parent_Previous_Owner__c);
                }else{
                    if(eachAcc.Changed_Global_Parent_Old_Owner__c!=null){
                        previousOwnerIdSet.add(eachAcc.Changed_Global_Parent_Old_Owner__c);
                    }
                    
                }
                
            }
            processReturnedMap(getContactShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            processReturnedMap(getOppShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            processReturnedMap(getQuoteShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            processReturnedMap(getOrderShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            processReturnedMap(getOrderLineShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            processReturnedMap(getCaseShareRecords(accountList,previousOwnerIdSet,isOwnerChange),finalReturnMap);
            
        }
        return finalReturnMap;
        
    }
    
    //This method get all contact share records to be inserted or deleted
    public static Map<String,List<Sobject>> getContactShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> contactShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> cntctShrListTobeInsrtd=new List<ContactShare>();
            List<Sobject> cntctShrListTobeDltd=new List<ContactShare>();
            for(Contact eachCon:[Select Id,Account.RecordType.Name,Account.OwnerId,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                                 (Select Id,ContactId,UserOrGroupId  from Shares where RowCause='Manual' and ContactAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                 from Contact 
                                 where AccountId IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachCon.Account.Global_Parent_Previous_Owner__c:
                                eachCon.Account.Changed_Global_Parent_Old_Owner__c);
                if(eachCon.Shares!=null){
                    for(ContactShare eachCntctShrRec:eachCon.Shares){
                        if(eachCntctShrRec.UserOrGroupId==prevOwnerId){
                            cntctShrListTobeDltd.add(eachCntctShrRec);
                        }  
                    }
                }
                Id newOwnerId=(eachCon.Account.RecordType.Name=='Global Parent')?eachCon.Account.OwnerId:eachCon.Account.Global_Ultimate_Parent__r.OwnerId;                     
                if(eachCon.OwnerId!=newOwnerId){
                    cntctShrListTobeInsrtd.add(new ContactShare(ContactId=eachCon.Id,UserOrGroupId=newOwnerId,
                                                                RowCause='Manual',ContactAccessLevel='Read'));
                }
            }
            contactShareRecordsMap.put('deleteList',cntctShrListTobeDltd);
            contactShareRecordsMap.put('insertList',cntctShrListTobeInsrtd);
        }
        return contactShareRecordsMap;
    }
    
    //This method get all opp share records to be inserted or deleted
    public static Map<String,List<Sobject>> getOppShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> oppShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> oppShrListTobeInsrtd=new List<OpportunityShare>();
            List<Sobject> oppShrListTobeDltd=new List<OpportunityShare>();
            for(Opportunity eachOpp:[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                                     (Select Id,OpportunityId,UserOrGroupId from Shares where RowCause='Manual' and OpportunityAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                     from Opportunity 
                                     where AccountId IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachOpp.Account.Global_Parent_Previous_Owner__c:
                                eachOpp.Account.Changed_Global_Parent_Old_Owner__c);
                if(eachOpp.Shares!=null){
                    for(OpportunityShare eachOppShrRec:eachOpp.Shares){
                        if(eachOppShrRec.UserOrGroupId==prevOwnerId){
                            oppShrListTobeDltd.add(eachOppShrRec);
                        }  
                    }
                }
                if(eachOpp.OwnerId!=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId){
                    oppShrListTobeInsrtd.add(new OpportunityShare(OpportunityId=eachOpp.Id,UserOrGroupId=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                  RowCause='Manual',OpportunityAccessLevel='Read'));
                }
            }
            oppShareRecordsMap.put('deleteList',oppShrListTobeDltd);
            oppShareRecordsMap.put('insertList',oppShrListTobeInsrtd);
        }
        return oppShareRecordsMap;
    }
    
    //This method get all quote share records to be inserted or deleted
    public static Map<String,List<Sobject>> getQuoteShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> quoteShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> quoteShrListTobeInsrtd=new List<QuoteShare>();
            List<Sobject> quoteShrListTobeDltd=new List<QuoteShare>();
            for(Quote eachQuote:[Select Id,Account__r.Global_Parent_Previous_Owner__c,Account__r.Changed_Global_Parent_Old_Owner__c,Account__r.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                                 (Select Id,ParentId,UserOrGroupId from Shares where RowCause='Manual' and AccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                 from Quote 
                                 where Account__c IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachQuote.Account__r.Global_Parent_Previous_Owner__c:
                                eachQuote.Account__r.Changed_Global_Parent_Old_Owner__c);
                if(eachQuote.Shares!=null){
                    for(QuoteShare eachQuoteShrRec:eachQuote.Shares){
                        if(eachQuoteShrRec.UserOrGroupId==prevOwnerId){
                            quoteShrListTobeDltd.add(eachQuoteShrRec);
                        }  
                    }
                }
                if(eachQuote.OwnerId!=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId){
                    quoteShrListTobeInsrtd.add(new QuoteShare(ParentId=eachQuote.Id,UserOrGroupId=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',AccessLevel='Read'));
                }
            }
            quoteShareRecordsMap.put('deleteList',quoteShrListTobeDltd);
            quoteShareRecordsMap.put('insertList',quoteShrListTobeInsrtd);
        }
        return quoteShareRecordsMap;
    }
    
    //This method get all order share records to be inserted or deleted
    public static Map<String,List<Sobject>> getOrderShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> orderShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> orderShrListTobeInsrtd=new List<OrderShare>();
            List<Sobject> orderShrListTobeDltd=new List<OrderShare>();
            for(Order eachOrder:[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                                 (Select Id,OrderId,UserOrGroupId from Shares where RowCause='Manual' and OrderAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                 from Order 
                                 where AccountId IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachOrder.Account.Global_Parent_Previous_Owner__c:
                                eachOrder.Account.Changed_Global_Parent_Old_Owner__c);
                if(eachOrder.Shares!=null){
                    for(OrderShare eachOrderShrRec:eachOrder.Shares){
                        if(eachOrderShrRec.UserOrGroupId==prevOwnerId){
                            orderShrListTobeDltd.add(eachOrderShrRec);
                        }  
                    }
                }
                if(eachOrder.OwnerId!=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId){
                    orderShrListTobeInsrtd.add(new OrderShare(OrderId=eachOrder.Id,UserOrGroupId=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',OrderAccessLevel='Read'));
                }
            }
            orderShareRecordsMap.put('deleteList',orderShrListTobeDltd);
            orderShareRecordsMap.put('insertList',orderShrListTobeInsrtd);
        }
        return orderShareRecordsMap;
    }
    
    //This method get all order line share records to be inserted or deleted
    public static Map<String,List<Sobject>> getOrderLineShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> orderLineShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> orderLineShrListTobeInsrtd=new List<Order_Line__Share>();
            List<Sobject> orderLineShrListTobeDltd=new List<Order_Line__Share>();
            for(Order_Line__c eachOrderLine:[Select Id,Order__r.Account.Global_Parent_Previous_Owner__c,Order__r.Account.Changed_Global_Parent_Old_Owner__c,Order__r.Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                                             (Select Id,ParentId,UserOrGroupId from Shares where RowCause='Manual' and AccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                                             from Order_Line__c 
                                             where Order__r.AccountId IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachOrderLine.Order__r.Account.Global_Parent_Previous_Owner__c:
                                eachOrderLine.Order__r.Account.Changed_Global_Parent_Old_Owner__c);
                if(eachOrderLine.Shares!=null){
                    for(Order_Line__Share eachOrderLineShrRec:eachOrderLine.Shares){
                        if(prevOwnerId!=null && eachOrderLineShrRec.UserOrGroupId==prevOwnerId){
                            orderLineShrListTobeDltd.add(eachOrderLineShrRec);
                        }  
                    }
                }
                if(eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId!=null && 
                   eachOrderLine.OwnerId!=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId){
                    orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=eachOrderLine.Id,UserOrGroupId=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                         RowCause='Manual',AccessLevel='Read'));
                }
            }
            orderLineShareRecordsMap.put('deleteList',orderLineShrListTobeDltd);
            orderLineShareRecordsMap.put('insertList',orderLineShrListTobeInsrtd);
        }
        return orderLineShareRecordsMap;
    }
    
    //This method get all case share records to be inserted or deleted
    public static Map<String,List<Sobject>> getCaseShareRecords(List<Account> accountList,Set<Id> previousOwnerIdSet,boolean isOwnerChange){
        Map<String,List<Sobject>> caseShareRecordsMap=new Map<String,List<Sobject>>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Sobject> caseShrListTobeInsrtd=new List<CaseShare>();
            List<Sobject> caseShrListTobeDltd=new List<CaseShare>();
            for(Case eachCase:[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId,
                               (Select Id,CaseId,UserOrGroupId from Shares where RowCause='Manual' and CaseAccessLevel='Read' and UserOrGroupId IN :previousOwnerIdSet) 
                               from Case 
                               where AccountId IN: accountList]){
                Id prevOwnerId=(isOwnerChange==true?eachCase.Account.Global_Parent_Previous_Owner__c:
                                eachCase.Account.Changed_Global_Parent_Old_Owner__c);
                if(eachCase.Shares!=null){
                    for(CaseShare eachCaseShrRec:eachCase.Shares){
                        if(eachCaseShrRec.UserOrGroupId==prevOwnerId){
                            caseShrListTobeDltd.add(eachCaseShrRec);
                        }  
                    }
                }
                if(eachCase.OwnerId!=eachCase.Account.Global_Ultimate_Parent__r.OwnerId){
                    caseShrListTobeInsrtd.add(new CaseShare(CaseId=eachCase.Id,UserOrGroupId=eachCase.Account.Global_Ultimate_Parent__r.OwnerId,
                                                            RowCause='Manual',CaseAccessLevel='Read'));
                }
            }
            caseShareRecordsMap.put('deleteList',caseShrListTobeDltd);
            caseShareRecordsMap.put('insertList',caseShrListTobeInsrtd);
        }
        return caseShareRecordsMap;
    }
    
    //This is util method to process each related object's deleteList and insertList 
    public static void processReturnedMap(Map<String,List<Sobject>> shareRecMap,Map<String,List<SObject>> finalReturnMap){
        if(shareRecMap!=null && !shareRecMap.isEmpty()){
            List<SObject> shareRecordsToBeDeleted=new List<SObject>();
            List<SObject> shareRecordsToBeInserted=new List<SObject>();
            if(finalReturnMap!=null && !finalReturnMap.isEmpty()){
                if(finalReturnMap.containsKey('deleteList') && finalReturnMap.get('deleteList')!=null && !finalReturnMap.get('deleteList').isEmpty()){
                    shareRecordsToBeDeleted.addAll(finalReturnMap.get('deleteList'));
                }
                if(finalReturnMap.containsKey('insertList') && finalReturnMap.get('insertList')!=null && !finalReturnMap.get('insertList').isEmpty()){
                    shareRecordsToBeInserted.addAll(finalReturnMap.get('insertList'));
                }
            }
            if(shareRecMap.containsKey('deleteList') && shareRecMap.get('deleteList')!=null && !shareRecMap.get('deleteList').isEmpty()){
                shareRecordsToBeDeleted.addAll(shareRecMap.get('deleteList'));
            }
            if(shareRecMap.containsKey('insertList') && shareRecMap.get('insertList')!=null && !shareRecMap.get('insertList').isEmpty()){
                shareRecordsToBeInserted.addAll(shareRecMap.get('insertList'));
            }
            finalReturnMap.put('deleteList',shareRecordsToBeDeleted);
            finalReturnMap.put('insertList',shareRecordsToBeInserted);
        }
    }
    
    public class CustomError
    {
        public String id{get;set;}
        public String objectName{get;set;}
        public String operation{get;set;}
        public String message{get;set;}
       	public CustomError(String id,String objectName,String operation,String message){
            this.id=id;
            this.objectName=objectName;
            this.operation=operation;
            this.message=message;
        }
    }
    
}