public class inshertSHaredRecordIterable implements Iterable<sObject> {
    public Iterator<sObject> iterator(){
        List<sObject> scope = new List<sObject>();
        list<Account> accountList = [select id from Account where oneTimeBatchFlag__c = true];
        scope=getShareRcrdsTobeDeletedOrInserted(accountList);
        return new CustomIterator(scope);
    }
       public static List<Sobject> getShareRcrdsTobeDeletedOrInserted(List<Account> accountList){
        List<SObject> finalReturnList=new list<SObject>();
        if(accountList!=null && !accountList.isEmpty()){
            finalReturnList.addAll(getContactShareRecords(accountList));
            finalReturnList.addAll(getOppShareRecords(accountList));
            finalReturnList.addAll(getQuoteShareRecords(accountList));
            finalReturnList.addAll(getOrderShareRecords(accountList));
            finalReturnList.addAll(getOrderLineShareRecords(accountList));
            finalReturnList.addAll(getCaseShareRecords(accountList));
            
        }
        return finalReturnList;
        
    }
        //This method get all contact records to be inserted or deleted
    public static List<Sobject> getContactShareRecords(List<Account> accountList){
            List<Sobject> cntctShrListTobeInsrtd=new List<ContactShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Contact> contactList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                       from Contact 
                                       where AccountId IN: accountList];
            for(Contact eachCon:contactList){
            
                if(eachCon.OwnerId!=eachCon.Account.Global_Ultimate_Parent__r.OwnerId){
                    cntctShrListTobeInsrtd.add(new ContactShare(ContactId=eachCon.Id,UserOrGroupId=eachCon.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                RowCause='Manual',ContactAccessLevel='Read'));
                }
            }
        }
        return cntctShrListTobeInsrtd;
    }
    
    //This method get all opp records to be inserted or deleted
    public static List<Sobject> getOppShareRecords(List<Account> accountList){
                    List<Sobject> oppShrListTobeInsrtd=new List<OpportunityShare>();

        if(accountList!=null && !accountList.isEmpty()){
            List<Opportunity> oppList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                       from Opportunity 
                                       where AccountId IN: accountList];
            for(Opportunity eachOpp:oppList){
            
                if(eachOpp.OwnerId!=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId){
                    oppShrListTobeInsrtd.add(new OpportunityShare(OpportunityId=eachOpp.Id,UserOrGroupId=eachOpp.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                  RowCause='Manual',OpportunityAccessLevel='Read'));
                }
            }
          
        }
        return oppShrListTobeInsrtd;
    }
    
    //This method get all quote records to be inserted or deleted
    public static List<Sobject> getQuoteShareRecords(List<Account> accountList){
                    List<Sobject> quoteShrListTobeInsrtd=new List<QuoteShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Quote> quoteList=[Select Id,Account__r.Global_Parent_Previous_Owner__c,Account__r.Changed_Global_Parent_Old_Owner__c,Account__r.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                   from Quote 
                                   where Account__c IN: accountList];
            for(Quote eachQuote:quoteList){

                if(eachQuote.OwnerId!=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId){
                    quoteShrListTobeInsrtd.add(new QuoteShare(ParentId=eachQuote.Id,UserOrGroupId=eachQuote.Account__r.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',AccessLevel='Read'));
                }
            }
        }
        return quoteShrListTobeInsrtd;
    }
    
    //This method get all order records to be inserted or deletede
    public static List<Sobject> getOrderShareRecords(List<Account> accountList){
                    List<Sobject> orderShrListTobeInsrtd=new List<OrderShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Order> orderList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                   from Order 
                                   where AccountId IN: accountList];
            for(Order eachOrder:orderList){
               
                if(eachOrder.OwnerId!=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId){
                    orderShrListTobeInsrtd.add(new OrderShare(OrderId=eachOrder.Id,UserOrGroupId=eachOrder.Account.Global_Ultimate_Parent__r.OwnerId,
                                                              RowCause='Manual',OrderAccessLevel='Read'));
                }
            }
        }
        return orderShrListTobeInsrtd;
    }
    
    //This method get all order line records to be inserted or deleted
    public static List<Sobject> getOrderLineShareRecords(List<Account> accountList){
        List<Sobject> orderLineShrListTobeInsrtd=new List<Order_Line__Share>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Order_Line__c> orderLineList=[Select Id,Order__r.Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                               from Order_Line__c 
                                               where Order__r.AccountId IN: accountList];
            for(Order_Line__c eachOrderLine:orderLineList){
             
                if(eachOrderLine.OwnerId!=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId){
                    orderLineShrListTobeInsrtd.add(new Order_Line__Share(ParentId=eachOrderLine.Id,UserOrGroupId=eachOrderLine.Order__r.Account.Global_Ultimate_Parent__r.OwnerId,
                                                                         RowCause='Manual',AccessLevel='Read'));
                }
            }
        }
        return orderLineShrListTobeInsrtd;
    }
    
    //This method get all case records to be inserted or deleted
    public static List<Sobject> getCaseShareRecords(List<Account> accountList){
         List<Sobject> caseShrListTobeInsrtd=new List<CaseShare>();
        if(accountList!=null && !accountList.isEmpty()){
            List<Case> caseList=[Select Id,Account.Global_Parent_Previous_Owner__c,Account.Changed_Global_Parent_Old_Owner__c,Account.Global_Ultimate_Parent__r.OwnerId,OwnerId
                                 from Case 
                                 where AccountId IN: accountList];
            for(Case eachCase:caseList){
               
                if(eachCase.OwnerId!=eachCase.Account.Global_Ultimate_Parent__r.OwnerId){
                    caseShrListTobeInsrtd.add(new CaseShare(CaseId=eachCase.Id,UserOrGroupId=eachCase.Account.Global_Ultimate_Parent__r.OwnerId,
                                                            RowCause='Manual',CaseAccessLevel='Read'));
                }
            }
        }
        return caseShrListTobeInsrtd;
    }
}