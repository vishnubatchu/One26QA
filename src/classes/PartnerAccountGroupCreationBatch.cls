public class PartnerAccountGroupCreationBatch implements Database.Batchable < sObject > {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String Query = 'Select id,isPartner,name,Legacy_Id__c from account where IsPartner=true';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext BC, List < Account > scope) {
        Map<Id,String> MapOfacountIdgroupName = New Map<Id,String>();
        List<Group> groupListToBeInserted = New List<Group>();
        Map<String,group> groupNameMap = New Map<String,Group>();
        Map<Id,Id> mapOfAccountIdAnduserid = New Map<Id,Id>();
        For(Account AccountObj:scope){
            IF(AccountObj.Name!=Null && AccountObj.Legacy_Id__c!=Null){
                MapOfacountIdgroupName.put(AccountObj.Id,AccountObj.Legacy_Id__c);
                groupNameMap.put(AccountObj.Legacy_Id__c,New Group(Name=AccountObj.Legacy_Id__c));
            }
        }
        For(Group GroupObj :[Select id,Name from Group where Name in:groupNameMap.keySet()]){
            IF(groupNameMap.containskey(GroupObj.Name)){
                System.debug('GroupObj.Name to be removed'+GroupObj.Name);
                groupNameMap.remove(GroupObj.Name);
            }
        }
        IF(groupNameMap.size()>0){
            Insert groupNameMap.values();
        }
        
        Map<ID,String> mapofgroupNameuserID = New Map<Id,String>();
        For(GroupMember GroupMemberObj :[SELECT Group.Id, Group.Name, UserOrGroupId FROM GroupMember where Group.type!='Queue' And Group.Name in:MapOfacountIdgroupName.values()]){
            mapofgroupNameuserID.put( GroupMemberObj.UserOrGroupId,GroupMemberObj.Group.Name );
        }
        
        System.debug('mapofgroupNameuserID'+mapofgroupNameuserID);
        Map<String,Id> mapGroupnameAndId = New Map<String,Id>();
        For(Group groupObj : [Select id,name from Group where Name in :MapOfacountIdgroupName.values()]){
            mapGroupnameAndId.put(groupObj.Name,groupObj.Id);
        }
        System.debug('mapGroupnameAndId'+mapGroupnameAndId);
        List<GroupMember> groupmembersListToBeUpdated = New List<Groupmember>();
        System.debug('Test Records'+[SELECT Id,Name,Email,ContactId,AccountId FROM User where AccountId in:scope And isActive=TRUE]);
        For(User userObj :[SELECT Id,Name,Email,ContactId,AccountId FROM User where AccountId in:scope And isActive=TRUE]){
            IF(mapofgroupNameuserID.containskey(userObj.Id)){
                IF(!mapofgroupNameuserID.get(userObj.Id).equals(MapOfacountIdgroupName.get(userObj.AccountId))){
                    GroupMember GroupmemberObj = New GroupMember();
                    GroupmemberObj.GroupId = mapGroupnameAndId.get(MapOfacountIdgroupName.get(userObj.AccountId));
                    GroupmemberObj.UserOrGroupId =userObj.Id;
                    groupmembersListToBeUpdated.add(GroupmemberObj);
                }}
            else{
                GroupMember GroupmemberObj = New GroupMember();
                GroupmemberObj.GroupId = mapGroupnameAndId.get(MapOfacountIdgroupName.get(userObj.AccountId));
                GroupmemberObj.UserOrGroupId =userObj.Id;
                groupmembersListToBeUpdated.add(GroupmemberObj);
            }        
        }
        System.debug('groupmembersListToBeUpdated'+groupmembersListToBeUpdated);
        IF(groupmembersListToBeUpdated.size()>0){
            insert groupmembersListToBeUpdated;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
}