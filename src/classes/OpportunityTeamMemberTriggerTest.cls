@isTest(seeAllData = false)
private class OpportunityTeamMemberTriggerTest {
    @isTest
    static void testOptTemMemTrigger(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Profile']; 
        UserRole uRole = [SELECT Id FROM UserRole where DeveloperName ='RSM_of_AMERICAS_EASTERN_WSS'];
        User rsm = new User(Alias = 'rsmU', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='rsmstandarduser@testorg.com', UserRoleId = uRole.Id);
        system.runAs(rsm){
      Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
            Opportunity opt = new Opportunity();
            opt.Name = 'Test Opportunity';
            opt.CloseDate = Date.today().addDays(30);
            opt.StageName = 'Open - Discussion';
            opt.Project_Name__c = 'Test Project';
            opt.Type = 'Replacement';
            opt.RSM__c = rsm.Id;
            opt.Pricebook2Id = customPB.id;
            insert opt;
            Product2 prd = new Product2();
            prd.Name = '1277';
            prd.IsActive = true;
            prd.Marketing_P_N__c = '10WSCN08LFL';
            prd.Status__c = 'Loaner';
            prd.ProductCode = '1277';
            prd.Product_Family__c = 'WSS-DWP50';
            prd.BU_Code__c = '0040';
            prd.ExternalId__c = '10WSCN08LFL';
            insert prd;
         
            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = customPB.id,
                Product2Id = prd.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;
            OpportunityLineItem optPr = new OpportunityLineItem();
            optPr.OpportunityId = opt.Id;
            optPr.product2Id = prd.Id;
            optPr.Quantity = 100;
            optPr.TotalPrice = 1000;
            insert optpr;
            OpportunityTeamMember optem = new OpportunityTeamMember();
            optem.OpportunityId = opt.Id;
            optem.UserId = userInfo.getUserId();
            optem.OpportunityAccessLevel = 'Read';
            test.startTest();
            insert optem;
            test.stopTest();  
        }
        
    }
}