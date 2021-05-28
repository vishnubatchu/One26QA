/*
 * 
 *  
 * 
 * 
 * 
 * 
*/

public class LoanerEmailCustomComponentController {
    
   
    public Id recordId { get;set; }
  public String recordObject { get;set; }
 /*   public boolean lonerSummary {get;set;}
    public boolean LineItemApprovalList{get;set;}
    public boolean lineItemsApproval {get;set;}
    public boolean LoanerlineItems {get;set;}
    public boolean lineItemFooter {get;set;} */
   	public Id recipientId {get;set;} 
   /*
    public list<Loaner_Line__c> getLineItems(){
        List<Loaner_Line__c> lineItems;
        lineItems = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordId,recipientId);
        System.debug('lineItems'+lineItems);
        return lineItems;
    }
    
        public list<Loaner_Line__c> getAllLineItems(){
        List<Loaner_Line__c> lineItems;
        List<String> statusList = New List<String>{'Approved','Rejected','Draft','Approval Pending','Cancelled'};    
        lineItems = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(recordId,statusList);
        System.debug('lineItems'+lineItems);
        return lineItems;
    } */
    
    public Loaner__c getLoaner(){
        Loaner__c sobj;
        sobj =(Loaner__c) RecordApprovalDao.getHeaderRecord(recordId);
       
        return sobj;
    }
    public String getQualSample(){
        Loaner__c sobj;
        string Qual ;
        sobj =(Loaner__c) RecordApprovalDao.getHeaderRecord(recordId);
        if(sobj.Qual_Sample_Finisar__c){
            Qual = 'Yes';
                }else{
                 Qual = 'No';   
                }
        return Qual;
    }
     public Loaner__c getExtension()
    {
        String recId =recordId;
        String querytofields = Label.Loaner_Fields;
        String extensionlinefields = Label.Extension_Lines_Fields;
        String query= 'SELECT '+ querytofields +' ,( SELECT ' +extensionlinefields +' FROM Loaner_Lines__r ) FROM Loaner__c  WHERE Id = :recordId';
        System.debug(query);
        Loaner__c loaner =Database.query(query);
        return loaner;
    }
    
    public List<Loaner_line__c> getErrorLineItems(){
        return RecordApprovalDao.getInvalidLoanersLineItemsRecords(recordId);
    }
    
}