/**
* Created by : Akhilesh
* Date : 31th May 2021
* Description: This is a helper class for AccountTrigger has implemented as per below logic
* a) If the Global Ultimate Parent is changed on parent Account child account should be updated with parent Account global ultimate parent
*/
public class UpdateSubAccountGlobalUltimateParent {
    public static void updateSubAccount(List<Account> accountList){
        map<id,id> globalmap = new map<id,id>();
        list<Account> finalAccList = new list<Account>();
        for(Account acm : accountList){
            globalmap.put(acm.id,acm.Global_Ultimate_Parent__c);
        }
        list<Account> SubAccountList = [select id,Global_Ultimate_Parent__c, ParentId   from Account where ParentId  in: accountList ];
        for(Account ac : SubAccountList){
           ac.Global_Ultimate_Parent__c  = globalmap.get(ac.ParentId);
            finalAccList.add(ac);
        } 
        update finalAccList;
    }
}