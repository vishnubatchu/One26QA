public class AccountTriggerHelper {
    public static Boolean isAccountupdate = false;
    public static Boolean isRecursive =true;
    public static void afterInsert(List<Account> newAccounts){
        System.debug('calculate RollUp Summary ');
        Set<Id> parentAccountIds = new Set<Id>();
        for(Account billToAccount:newAccounts){
            if(billToAccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId())
                parentAccountIds.add(billToAccount.ParentId);       
        }
        if(isRecursive && !parentAccountIds.isEmpty())
            calculateARAmountRollup(parentAccountIds);
    }
    public static void afterUpdate(Map<Id,Account> oldAccountMap,Map<Id,Account>  newAccountMap){
        Set<Id> newAccountIds = new Set<Id>();
        Set<Id> parentAccIds = new Set<Id>();
        for(Account newaccount:newAccountMap.values()) {
            if(oldAccountMap.get(newaccount.id).Type != newAccountMap.get(newaccount.id).Type) {
                newAccountIds.add(newaccount.id);
            }
            if(newaccount.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId() &&
               isRecursive){                
                   if(oldAccountMap.get(newaccount.id).AR_Amount__c != newAccountMap.get(newaccount.id).AR_Amount__c) {
                       parentAccIds.add(newaccount.ParentId);
                   }
               } 
        }
        if(!newAccountIds.isEmpty())
          //  ContactForGDPR.updateAccountContact(newAccountIds);
        if(!parentAccIds.isEmpty())
            calculateARAmountRollup(parentAccIds);
    }
    
    public static void calculateARAmountRollup(Set<Id> ParentAccountIds){
        Map<Id,Account> accountstoUpdateMap = new Map<Id,Account>([select Id,AR_Amount_Rollup__c FROM Account Where Id in :parentAccountIds ]);
        List<Account> accountstoUpdateList = new List<Account>();
        List<AggregateResult> parentAccntsARAmountRollup = [select ParentId,SUM(AR_Amount__c) AR_Amount_Rollup   FROM Account Where Type='Site' and Site_Use_Code__c='BILL_TO' and ParentId in :ParentAccountIds Group By ParentId];
        for(AggregateResult aggresult:parentAccntsARAmountRollup)
        {
            Account account = (Account) accountstoUpdateMap.get((Id)aggresult.get('ParentId'));
            account.AR_Amount_Rollup__c=(Decimal)aggresult.get('AR_Amount_Rollup');
            accountstoUpdateList.add(account);
        }
        isRecursive=false;
        update accountstoUpdateList;
    }
    
    /*
Method Name : checkBerlinAccount
Input Parameters : List<Account> 
Outupt Parameters : NA
Description : Updates berlin accounts
*/
    /*
    Public static void checkBerlinAccount(List<Account> newAccounts){
        List<Account> berlinSites = new List<Account>();
        Set<Id> parentIds = new Set<Id>();
        Map<Id, List<Account>> berlinSiteMap = new Map<Id, List<Account>>();
        Map<Id, List<Account>> sitesMap = new Map<Id, List<Account>>();
        Set<Id> berlinOrgAccs = new Set<Id>();
        for(Account acc : newAccounts){
            parentIds.add(acc.ParentId);
        }
        for(Account sites : [SELECT Id, Org_Name__c,Type,ParentId,parent.Berlin_Account__c,Site_Use_Code__c
                             FROM Account
                             WHERE ParentId IN :parentIds AND Site_Use_Code__c = 'SHIP_TO']){
                                 if(sites.Parent.Berlin_Account__c && !berlinOrgAccs.contains(sites.ParentId)){
                                     berlinOrgAccs.add(sites.ParentId);
                                 }
                                 //  if(sites.Site_Use_Code__c == 'SHIP_TO'){
                                 if(sitesMap.containsKey(sites.ParentId)){
                                     sitesMap.get(sites.ParentId).add(sites);
                                 } else {
                                     sitesMap.put(sites.ParentId, new List<Account>{sites});
                                     // }
                                     if(sites.Org_Name__c == 'Finisar Berlin'){
                                         if(berlinSiteMap.containsKey(sites.ParentId)){
                                             berlinSiteMap.get(sites.ParentId).add(sites);
                                         } else {
                                             berlinSiteMap.put(sites.ParentId, new List<Account>{sites});
                                         }
                                     }
                                 }
                             }
        for(Id accId :berlinSiteMap.KeySet()){
            if(sitesMap.get(accId).size() == berlinSiteMap.get(accId).size() &&
               !berlinOrgAccs.contains(accId)){
                   account berlinAcc = new Account(id =accId, Berlin_Account__c = true);
                   berlinSites.add(berlinAcc);
               } else if(sitesMap.get(accId).size() != berlinSiteMap.get(accId).size() &&
                         berlinOrgAccs.contains(accId)) {
                             account berlinAcc = new Account(id =accId, Berlin_Account__c = false);
                             berlinSites.add(berlinAcc);
                         }
        }
        String csvStr;
        for(Account accid :berlinSites){
            csvStr = csvStr+'\n'+accid.Id+','+accid.Berlin_Account__c;
        }*/
        /*   attachment att = new attachment();
att.Body = Blob.valueOf(csvStr);
att.Name = 'accounts';
att.ParentId = '0011N00001mhZz3QAE';
att.ContentType = 'csv';
insert att;*/
    /*    system.debug('berlinSites '+berlinSites);
        if(berlinSites != null && !berlinSites.isEmpty()){
            upsert berlinSites;
        }
    }*/
    
    public static void updateOrderLines(List<Account> accounts, Map<Id, Account> oldMap){
        List<Id> updatedAccounts = new List<id>();
        Map<Id, Id> siteRSMMap = new Map<Id,Id>();
        List<Order_Line__c> updatedLines = new List<Order_Line__c>();
        for(Account acc : accounts){
            if(acc.RSM__c != oldMap.get(acc.Id).RSM__c){
                updatedAccounts.add(acc.Id);
                siteRSMMap.put(acc.id, acc.RSM__c);
            }
        }
        for(Order_Line__c line : [SELECT Id, RSM__c, Ship_To_Location__c 
                                  FROM Order_Line__c
                                  WHERE Ship_To_Location__c IN :updatedAccounts]){
                                      if(line.RSM__c != siteRSMMap.get(line.Ship_To_Location__c)){
                                          line.RSM__c = siteRSMMap.get(line.Ship_To_Location__c);
                                          updatedLines.add(line);
                                      }
                                  }
        if(updatedLines != null && !updatedLines.isEmpty()){
            isAccountupdate = true;
            Update updatedLines;
        }
    }
    
    
    
    /* This method checks if the Account Name for accounts where Record Type = Global Parent is unique,
     * else throws an error message  
     */
    /*public static void chckGlblPrntAccDplct(List<Account> newAccounts){
        set<String> newAccountNameSet = new set<String>();
        for(Account newAccount : newAccounts){
            newAccountNameSet.add(newAccount.Name);
        }      
        List<Account> existingAccounts = [SELECT Id,Name FROM Account WHERE Name IN :newAccountNameSet and RecordType.Name='Global Parent'];

        if(existingAccounts!=null && !existingAccounts.isEmpty()){
            Map<String,Id> existingAccountNameMap=new Map<String,Id>();
          
            for(Account eachExistingAccount : existingAccounts){
                existingAccountNameMap.put(eachExistingAccount.Name,eachExistingAccount.Id);
            }
            for(Account eachNewAccount : newAccounts){
                if(existingAccountNameMap.containsKey(eachNewAccount.Name) && eachNewAccount.RecordTypeId==
                   Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId()){
                    eachNewAccount.addError('There is an existing account with this name.');
                }
            	
        	} 
            
        }
    }*/

}