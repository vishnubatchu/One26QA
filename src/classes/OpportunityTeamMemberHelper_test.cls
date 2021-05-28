@istest(seeAllData = false)
public class OpportunityTeamMemberHelper_test{
    @testSetup static void testData() {
        List<Account> accLst = new List<Account>();
        List<Opportunity> oppLst = new List<Opportunity>();
        Account acct = new Account(Name= 'APPLE COMPUTER INC', Status__c='Active',
                                   recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acct;
        Account acc1 = new Account(Name= 'STRATEGIC SALES INC', Status__c='Active',
                                   recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc1;
        Opportunity opp = New Opportunity(Name = acct.Name+' Opp',RSM__c ='0051N000007GPjaQAG',Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acct.Id, CloseDate = date.today().addDays(365));
        insert opp;
        Opportunity opp1 = New Opportunity(Name = acct.Name+' Opp',RSM__c ='0051N000007GPjTQAW',Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acc1.Id, CloseDate = date.today().addDays(365));
        insert opp1;
    }
    @istest
    static void testAddMember(){
        system.debug('opp list '+[select id from account]);
        List<Opportunity> opplst =[Select Id,RSM__c from Opportunity];
        test.startTest();
        OpportunityTeamMemberHelper.addRsmTeamMembers(opplst);
        test.stopTest();
    }
}