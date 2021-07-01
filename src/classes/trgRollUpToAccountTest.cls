@IsTest(seeAllData = true)
    public class trgRollUpToAccountTest{
       
  
    private static testmethod void trgRollUpToOpportunityTest4(){
         Account globalParentAcc=new Account(Name='Global Parent1',ShippingCountry = 'US',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Global_Parent').getRecordTypeId()	);
        insert globalParentAcc;
      list<Account> accInsertList = new list<Account>();
      map<string,Account> accInsertMap = new map<string,Account>();
   
        Account siteAcc1=new Account(Name='Site Test Acc1',Display_Shipping_Country__c ='United States', Display_Billing_Country__c = 'United States',RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId(),
                                     Global_Ultimate_Parent__c=globalParentAcc.Id,ParentId = globalParentAcc.Id,Site_Use_Code__c='SHIP_TO',Status__c='Active',
                                     Site_Use_Status__c='Active',shippingcity='New York',shippingcountry='USA',Type='Customer',
                                     Org_ID__c= '2');
      
        Test.StartTest();
            insert siteAcc1;
            list<opportunity> updateOppList = new list<opportunity>();
            Pricebook2 standardPB = [SELECT Id, Name FROM PriceBook2 Limit 1];
            opportunity opp = new opportunity();
            opp.Name='Test';
            opp.Pricebook2ID = standardPB.Id ;
            opp.CloseDate=date.today().addDays(5);
            opp.AccountId=siteAcc1.id;
            opp.Business_Unit_Name_Product_Rollup__c='Components';
            opp.StageName='Closed Won';
            opp.amount=100;
        opp.Project_Name__c = 'Test';
         opp.Qual_Required__c = 'Yes';
        opp.Marlow_Product_BU__c = 'Power';
        updateOppList.add(opp);
            insert opp;
            
            opportunity opp1 = opp.clone();
            opportunity opp2 = opp.clone();
            opportunity opp3 = opp.clone();
            list<opportunity> oppList = new list<opportunity>();
            opp1.Business_Unit_Name_Product_Rollup__c='Components';
            opp1.amount=101;
             oppList.add(opp1);
        updateOppList.add(opp1);
            opp2.Business_Unit_Name_Product_Rollup__c='Systems';
            opp2.amount=100;
            oppList.add(opp2);
            updateOppList.add(opp2);
            opp3.Business_Unit_Name_Product_Rollup__c='Systems';
            opp3.amount=100;
            oppList.add(opp3);
        updateOppList.add(opp3);
            insert oppList;
            update updateOppList;
         
            
            
            
        Test.StopTest();
    }        
            
}