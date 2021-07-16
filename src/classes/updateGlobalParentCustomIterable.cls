/**
* Created by : Akhilesh
* Date : 2nd June 2021
* Description: This iterable class is created for UpdateGlobalParentLookupsBatch batch class
*/
public class updateGlobalParentCustomIterable implements Iterable<sObject> {
   public Iterator<sObject> iterator(){
      List<sObject> scope = new List<sObject>();
       if(System.Label.IsOneTimeBatch  == 'True'){
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Order where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity where Global_Ultimate_Account__c = null and AccountId != null and  Account.Global_Ultimate_Parent__c != null ]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId from Quote  where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null  ]);
       }
       if(System.Label.IsOneTimeBatch  == 'False' || Test.isRunningTest() ){
           list<Account> accountList = [select id,Global_Parent_Updated__c,Global_Ultimate_Parent__c  from Account where Global_Parent_Updated__c  = True];
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Order  Where AccountId  In: accountList]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity  Where AccountId  In: accountList ]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId from Quote   Where AccountId  In: accountList ]);
       }
           return new CustomIterator(scope);
           
   }
}