@isTest
public class OpportunityTriggerHelperTest {
    @isTest
    public static void testOrder(){
        Test.startTest();
        //OpportunityTriggerHelper.orderCreated = true;
        //while(OpportunityTriggerHelper.orderCreated == false){
            List<Account> testAccounts = TestDataFactory.createAccounts(1);		
            Account a;
            if(!testAccounts.isEmpty()){
                a = testAccounts[0];         
            } else return;
            List<Opportunity> testOpps;
            if(a != Null){
                testOpps = TestDataFactory.createOpportunity(1, a.Id);
               
            }
        	
            User currentUser = [Select Id, Legacy_Company__c from User where Id = :UserInfo.getUserId()];
			currentUser.Legacy_Company__c = 'Corp II-VI';
        	update currentUser;
        
        	Opportunity opp = testOpps[0];
           	opp.StageName = 'Closed Won';
        	opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Aftermarket').getRecordTypeId();
        	System.debug('>>>>>>>>> ' + opp.stageName);        
            update opp; 
        
        list<Order> orders = [Select Id, AccountId, opportunityId from Order limit 10];
        System.debug('>>>>>>>>>>> Orders ' + orders);
        
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        for(integer i = 0; i <= 10; i++){
            OpportunityLineItem oppline = new OpportunityLineItem(OpportunityId = opp.Id);
            oppLines.add(oppline);
        }
        insert oppLines;
        //update opp;
        //}                        
        Test.stopTest();
    }
    
    @isTest
    public static void testRecursion(){
        //OpportunityTriggerHelper.orderCreated = false;
        //testOrder();
    }
}