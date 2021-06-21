public class UpdateChildAccountFlag {
public static void UpdateChildAccountsInHierarchy(list<Account> accList) {
    map<id,Account> topAccountMap = new map<id,Account>();
        list<Account> AccountHierachyList = [select id from Account where (Parent.Id In: accList Or Parent.Parent.Id In: accList Or Parent.Parent.Parent.Id In: accList
                                                                          Or Parent.Parent.Parent.Parent.Id In: accList)];
    for(Account ac : AccountHierachyList){
        string globalParentId = '';
        boolean UpdateFlaf = false;
        if(topAccountMap.get(ac.Parent.Id) != null){
           ac.Global_Parent_Updated__c  =  True;
        }
        
    }
    
    system.debug('ac__ ' + AccountHierachyList);
   
}
}