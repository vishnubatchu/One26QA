@IsTest(seeAllData = true)
    public class trgRollUpToAccountTest{
       
  
    private static testmethod void trgRollUpToOpportunityTest4(){
        Account acc = new Account();
        acc.name='Test Account';
        // Opportunities_Business_Unit_s__c,
        Test.StartTest();
            insert acc;
            
            Pricebook2 standardPB = [SELECT Id, Name FROM PriceBook2 Limit 1];
            opportunity opp = new opportunity();
            opp.Name='Test';
            opp.Pricebook2ID = standardPB.Id ;
            opp.CloseDate=date.today().addDays(5);
            opp.AccountId=acc.id;
            opp.Business_Unit_Name_Product_Rollup__c='Components';
            opp.StageName='Closed Won';
            opp.amount=100;
        opp.Project_Name__c = 'Test';
         opp.Qual_Required__c = 'Yes';
        opp.Marlow_Product_BU__c = 'Power';
            insert opp;
            
            opportunity opp1 = opp.clone();
            opportunity opp2 = opp.clone();
            opportunity opp3 = opp.clone();
            
            opp1.Business_Unit_Name_Product_Rollup__c='Components';
            opp1.amount=101;
            insert opp1;
            opp2.Business_Unit_Name_Product_Rollup__c='Systems';
            opp2.amount=100;
            insert opp2;
            
            opp3.Business_Unit_Name_Product_Rollup__c='Systems';
            opp3.amount=100;
            insert opp3;
            
            update opp;
            update opp1;
            update opp2;
            update opp3;
            
          //  delete opp;
            
            
            
        Test.StopTest();
    }        
            
}