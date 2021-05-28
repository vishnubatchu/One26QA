@isTest

 public class trgUpdateLeadStatusTest{
    static testMethod void testtrgUpdateLeadStatus(){
    
    Test.StartTest();
    
    Lead ld1 = new Lead();
    ld1.FirstName = 'LeadRecord';
    ld1.LastName  = 'Test';
    ld1.Status    = 'Open';
    ld1.Company   = 'TestCompany';
    ld1.Market__c = '10 - DSP';
    ld1.Region__c = 'MIA';
    ld1.Phone = '9900334472';
    ld1.LeadSource = 'Web';
    insert ld1;
    upsert ld1;
    
    Lead ld2 = new Lead();
    ld2.FirstName = 'TestLeadRecord';
    ld2.LastName  = 'TestCase';
    ld2.Status    = 'Close';
    ld2.Company   = 'TestCompany';
    ld2.Market__c = '10 - DSP';
    ld2.Region__c = 'MIA';
    ld2.Phone = '8799845640';
    ld2.LeadSource = 'Web';
    insert ld2;
    upsert ld2;
    
    List<Task> lstToInsert = new List<Task>();
    // For bulk insertion
    for(Integer i=0; i<=300; i++){
        Task t1 = new Task();
        t1.whoId = ld1.Id;
        t1.subject = 'Call';
        lstToInsert.add(t1);
        System.AssertEquals(t1.subject,'Call');
        System.AssertEquals(t1.whoId,ld1.Id);
    }
    for(Integer i=0; i<=300; i++){
        Task t2 = new Task();
        t2.whoId = ld2.Id;
        t2.subject = 'Send Mail';
        lstToInsert.add(t2);
        System.AssertEquals(t2.subject,'Send Mail');
        System.AssertEquals(t2.whoId,ld2.Id);
    }
    If(lstToInsert != null && lstToInsert.size()>0)
        Insert lstToInsert;
    
    Test.StopTest();

   }
}