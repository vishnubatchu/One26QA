/** **********************************************************
    Name        : CustomLeadConversion .
    Function    : To convert Lead to Account, Contact and Opportunity(optional).
   
*/
public class CustomLeadConversion {

    public CustomLeadConversion() {

    }

    Public Id leadId;                                 // For Lead Id from url.
    Public Lead leadInfo{get; set;}                   // To store lead.
    Public List<Account> acct{get; set;}              // For Account list.
    Public List<Contact> cont{get; set;}              // For Contact list.
    
    Public String CompanyName;                        // For Company Name from Lead.  
    Public String CompanyNameAsOppy{get; set;}
    public String acctName{get; set;}   
    Public Boolean contCheckBox{get; set;}
    Public Boolean oppyCheckBox{get; set;}
    Public Boolean sendEmail{get; set;}
    public boolean contactList {get;set;}
    public List<SelectOption> ConOptions {get;set;}
    public List<SelectOption> options {get;set;}
    public String scriptvalue {get;set;}
    
    /* ******inner class for Task.***************** */
    public innerClassForTask inClsTask{get; set;}     
    public class innerClassForTask{
        Public Task tk{get;set;}
        public innerClassForTask(){ tk = new Task(); }
    }
    /* ******************************************** */
    
    /* ************  Constructor  ***************** */
    public CustomLeadConversion (ApexPages.StandardController stdController) {
        leadId = ApexPages.currentPage().getParameters().get('id');                 // Getting lead id from url.
        this.leadInfo = [Select id, name, company, status, Description, FirstName, LastName, OwnerId, ConvertedStatus__c from Lead where id =:leadId ];
        CompanyName = leadInfo.Company;
        CompanyNameAsOppy = leadInfo.Company;
        CompanyName = '%' + CompanyName + '%'; 
        acctName='';
        acct = [Select Id, Name from Account where Name LIKE :CompanyName ];        // Searching existing Accounts
        for (integer i=0; i<acct.size(); i++)
            System.debug(acct[i].Name);
        
        inClsTask = new innerClassForTask();
        innerClassForTask obj = new innerClassForTask();                            // call to the iner class constructor
    }
    /* ******************************************** */
    
    /* ************  Account List  **************** */
    public List<SelectOption> getAcctNames(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'You MUST select an Existing Account : '));
        for( Account a : acct){
            options.add(new SelectOption(a.id, 'Attach to Existing : '+a.Name));
         }
        return options;
    }
    /* ******************************************** */
    
    /* ************  To View Account  **************** */
    public PageReference getAcctView(){
        PageReference Page = null;
        if ( acctName != null ){ 
            Page = new PageReference('/'+acctName+'/p');
            Page.setRedirect(true);
        }
        if ( acctName == null ){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'You can only view existing accounts.')); }
        return Page;
    }
    /* ******************************************** */
    
    /* ************  Contact List  **************** */
    public String contName{get; set;}
    public Pagereference getContNames(){
        if ( acctName != null )
            cont = [ SELECT id, name from Contact where firstName =:leadInfo.FirstName and lastName=:leadInfo.LastName and accountId =:acctName];
            System.debug('Acct Name: '+cont);
        if ( cont != null && cont.size()>0 ){
            contactList = true;
            ConOptions = new List<SelectOption>();
            if (leadInfo.FirstName != null)
                ConOptions.add(new SelectOption('', 'Create New Contact: '+ leadInfo.FirstName+''+leadInfo.LastName));
            else
                ConOptions.add(new SelectOption('', 'Create New Contact: '+leadInfo.LastName));
                for( Contact c : cont)
                    ConOptions.add(new SelectOption(c.id, 'Attach to Existing : '+c.Name));
        }
        return null;
    }
    /* ******************************************** */
    
    /* ************  Convert Lead  **************** */
    Public PageReference ConvertMe(){
        PageReference Page;
        try{
            System.debug('Acct Name '+acctName);
            System.debug('Cont Name '+contName);
            System.debug('Acct Len '+acctName.length());
            
            List<Lead> updatedLeadOwner= new List<Lead>();
            updatedLeadOwner = [Select id, ownerid, Status, Record_Owner_After_Conversion__c from Lead where id =: leadInfo.id];
            if(updatedLeadOwner.size()>0)
            {
                updatedLeadOwner[0].Record_Owner_After_Conversion__c = leadInfo.ownerid;
                update updatedLeadOwner ;
            }
            
            if(acctName == 'Test Account' || acctName.length() == 0)
                acctName= null;
            if(contName == 'Test Contact' || contName.length() == 0)
                contName = null;
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setAccountId(acctName);
            lc.setContactId(contName);
            lc.setOwnerId(leadInfo.OwnerID);
            
            if (oppyCheckBox == true)   lc.doNotCreateOpportunity = true;
            if (contCheckBox == true)   lc.overwriteLeadSource = true;
            if (sendEmail == true)      lc.sendNotificationEmail = true;
            
            LeadStatus ls = [Select Id, MasterLabel from LeadStatus where IsConverted = TRUE];
            lc.setConvertedStatus(ls.MasterLabel);
            
            Database.LeadConvert[] lcArray = new Database.LeadConvert[]{lc};
            Database.LeadConvertResult[] lcr = Database.convertLead(lcArray);
            
            system.debug('testing new'+inclsTask);
            Task t = new Task();
            if ( inClsTask.tk.Subject == null){ t.subject = 'Default';} else { t.subject = inClsTask.tk.Subject; }
            if ( inClsTask.tk.Status == null){ t.Status = 'In Progress'; } else { t.Status = inClsTask.tk.Status; }
            if ( inClsTask.tk.ActivityDate != null){ t.ActivityDate = inClsTask.tk.ActivityDate;} 
            if ( inClsTask.tk.Priority == null){ t.Priority = 'Low'; } else { t.Priority = inClsTask.tk.Priority; }
            if (inClsTask.tk.Type != null){ t.Type = inClsTask.tk.Type;}
            t.WhatId = lcr[0].getAccountId();
            t.whoID = lcr[0].getContactId();
            t.ownerId = leadInfo.OwnerID;
            
            //if (lcr[0].getOpportunityId() != null){ t.WhatId = lcr[0].getOpportunityId(); Page = new PageReference('/'+lcr[0].getOpportunityId());}
            //else { t.WhatId = lcr[0].getAccountId(); Page = new PageReference('/'+lcr[0].getAccountId()); }
             t.WhatId = lcr[0].getAccountId();
             Page = new PageReference('/'+lcr[0].getAccountId()); 
            insert t;                                 // inserting Task
            
            Page.setRedirect(true);
            return Page; }catch(Exception e){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
        system.debug('test exception '+e.getMessage());}
    return null;
    }
    
    Public PageReference Back(){
        PageReference Page = new PageReference('/'+leadId);
        Page.setRedirect(true);
        return Page;
    }
}