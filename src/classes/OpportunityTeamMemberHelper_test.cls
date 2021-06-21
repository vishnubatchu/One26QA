@istest(seeAllData = false)
public class OpportunityTeamMemberHelper_test{
    @testSetup static void testData() {
            UserRole RSMRole = [Select Id from UserRole Where DeveloperName ='RSM_APAC'];
        Profile usrProfile = [SELECT Id from Profile where Name ='System Administrator'];
        User RSMUser = new User(LastName='Usrlast',ProfileId=usrProfile.Id,UserRoleId=RSMRole.id,alias ='testusr',
                                   Email='ben.yu@ii-vi.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='ben.yu@finisar.com.invalid1');
        insert RSMUser;
         User RSMUser2 = new User(LastName='Usrlast',ProfileId=usrProfile.Id,UserRoleId=RSMRole.id,alias ='testusr',
                                   Email='frank.wangfang@finisar.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='frank.wangfang@finisar.com');
        insert RSMUser2;
         User sysAdm = new User(LastName='Usrlast1111',ProfileId=usrProfile.Id,alias ='trsysy',
                               Email='standarduser@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser@finisar.com');
        system.runAs(sysAdm){
        List<Account> accLst = new List<Account>();
        List<Opportunity> oppLst = new List<Opportunity>();
             Account globalParentAcc=new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId());
        insert globalParentAcc;
        Account acct = new Account(Name= 'APPLE COMPUTER INC',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US', Status__c='Active',parentId=globalParentAcc.id,
                                   recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acct;
        Account acc1 = new Account(Name= 'STRATEGIC SALES INC',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US', Status__c='Active',parentId=globalParentAcc.id,
                                   recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Top Level Account').getRecordTypeId());
        insert acc1;
        Opportunity opp = New Opportunity(Name = acct.Name+' Opp',RSM__c = RSMUser.id,Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acct.Id, CloseDate = date.today().addDays(365));
        insert opp;
        Opportunity opp1 = New Opportunity(Name = acct.Name+' Opp',RSM__c =RSMUser.id,Project_Name__c = 'test',
                                          StageName = 'Open - Discussion', AccountId = acc1.Id, CloseDate = date.today().addDays(365));
        insert opp1;
        }
    }
    @istest
    static void testAddMember(){
        system.debug('opp list '+[select id from account]);
        List<Opportunity> opplst =[Select Id,Business_Unit__c,RSM__c from Opportunity];
        test.startTest();
        OpportunityTeamMemberHelper.addRsmTeamMembers(opplst);
        test.stopTest();
    }
}