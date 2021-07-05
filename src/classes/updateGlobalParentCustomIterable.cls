public class updateGlobalParentCustomIterable implements Iterable<sObject> {
   public Iterator<sObject> iterator(){
      List<sObject> scope = new List<sObject>();
        scope.addAll([select id,Global_Ultimate_Account__c, Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Order where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId  from Opportunity where Global_Ultimate_Account__c = null and AccountId != null and  Account.Global_Ultimate_Parent__c != null ]);
        scope.addAll([select id,Global_Ultimate_Account__c,Account.Global_Ultimate_Parent__c,Account.Global_Ultimate_Parent__r.OwnerId,Account.Changed_Global_Parent_Old_Owner__c,AccountId from Quote  where Global_Ultimate_Account__c = null and AccountId != null and Account.Global_Ultimate_Parent__c != null  ]);
      return new CustomIterator(scope);
   }
}