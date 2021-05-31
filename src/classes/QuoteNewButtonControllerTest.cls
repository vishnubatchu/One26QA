@isTest
public class QuoteNewButtonControllerTest {
    @isTest
    static void createQuote(){ 
        PageReference pageRef = Page.QuoteNewButtonPage;
        Account acc = new Account(name='Account ', 
                                  billingcity='New York', billingcountry='USA',Status__c='Active',Type='Customer',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        
        insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String roleId =[select Id,name from UserRole where Name='RSM of AMERICAS - WESTERN' LIMIT 1].Id;
        User u = createTestUser(roleId,p.Id,'Test','Case');
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert u;
        }
        Opportunity opp = new Opportunity(Name='Test',AccountId=acc.id,Project_Name__c='Test',StageName='Open - Discussion',Type='New',CloseDate=System.today(),
                                          Next_12_Months_Revenue__c=10, Market_Segment__c='Consumer',Region__c='JAPAN',RSM__c=u.id,NextStep='test',Next_Action_Due_Date__c=System.today()+2);
        insert opp;
        
        Quote qrec = new Quote(Account__c=acc.id);
        List<String> acclist = new List<String>();
        acclist.add(acc.id);
        String accStr = JSON.serializePretty(acclist);
        Test.startTest();
        QuoteNewButtonController.saveQuote1(JSON.serialize(String.valueof(acc.id)) );
        //QuoteNewButtonController.saveQuote1(accStr);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(qrec);
        QuoteNewButtonController controller = new QuoteNewButtonController(sc); 
        controller.redirect();
        QuoteNewButtonController.getOpportunityRec(opp.id);
        Test.stopTest();
    }
    
    public static User createTestUser(Id roleId, Id profID, String fName, String lName) {
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                              lastName = lName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profId,
                              UserRoleId = roleId);
        return tuser;
    }
    
}