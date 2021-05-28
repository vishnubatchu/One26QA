public with sharing class AccountExportController {

    public transient List<account> accList { get; set; }
   // public transient List<account> accList1 { get; set; }
    public transient List<List<account>> accList1 { get; set; }
    public AccountExportController(){
    accList1 = new List<List<account>>();
    accList  = [select id,name,External_Id__c,Legacy_Id__c from account limit 10000];
   /* integer noofAcc = [select count() from account];
    for(integer i = 0; i<noofAcc ; i++){
        accList  = [select id,name,External_Id__c,Legacy_Id__c from account limit 10000];
    }*/
    //accList1 = new List<List<account>>();
    //integer noofAcc = [select count() from account];
   /* for(integer i = 0; i< noofAcc/10000 ; i++){
    accList = new List<Account>();
    integer offsetv = i*10000;
    string acQuery = 'select id,name,External_Id__c,Legacy_Id__c from account limit 10000 OFFSET '+offsetv;
    accList  = database.query(acQuery );
    accList1.add(accList);
    }*/
    
    }
}