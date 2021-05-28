public class QuoteEmailCustomComponentController {
    
    public static Id recordId { get;set; }
    public static String recordObject { get;set; }
    public static boolean quoteSummry {get;set;}
    public static boolean quoteLineItem {get;set;}
    public static boolean quoteLineItemShipAndDebit {get;set;}
    public static boolean quoteLineItemWithStatusFields {get;set;}
    public static boolean quoteLineItemsApproval {get;set;}
    public static boolean quoteFooter {get;set;}
    public static boolean quoteAllStatus {get;set;}
    public static Id recipientId {get;set;}
    public QuoteEmailCustomComponentController() {
        
    }
    public static List<String> approvalLineitemReocrds = New List<String>{}; 
        
        public list<Quote_Item__c> getLineItems(){
            List<Quote_Item__c> lineItems;
            System.debug('Get Line Items');
            lineItems = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordId,recipientId);
            return lineItems;
        }
    
    public list<Quote_Item__c> getLineItemsWithDifferentStatus(Id recordId,id recipientId,Set<String> Status){
        List<Quote_Item__c> lineItems;
        lineItems = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordId,recipientId);
        return lineItems;
    }
    
    public Quote getQuote(){
        Quote sobj;
        sobj =(Quote) RecordApprovalDao.getHeaderRecord(recordId);
        return sobj;
    } 
    
    public Case getCase(){
        case sobj;
        sobj =(case) RecordApprovalDao.getHeaderRecord(recordId);
        return sobj;
    } 
    
    public boolean getIsuserPlM(){
        List<User> userObjList = [Select Id,userrole.name from User where id=:recipientId];
        for(user userObj:userObjList){
            IF(userObj.userrole.name!=NUll && userObj.userrole.name.containsIgnoreCase('PLM')){
                System.debug('Inside If Block');
                return true;
            }
        }
        return false;
    }
    
    
    public list<Quote_Item__c> getShipAndDebitLineItems(){
        Quote sobj;
        sobj =(Quote) RecordApprovalDao.getHeaderRecord(recordId);
        return sobj.Quote_Items__r;
    }
}