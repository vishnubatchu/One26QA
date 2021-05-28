public class UserTriggerHelper {
    public static void addUserInPubicGroup(List<User> users){
        Map<String, Id> groupIdMap = new Map<String, Id>();
        List<GroupMember> members = new List<GroupMember>();
        for(group grp : [SELECT Id, DeveloperName 
                         FROM Group 
                         WHERE DeveloperName IN ('WSS_Users', 'Common_Access_Group')]){
                             groupIdMap.put(grp.DeveloperName, grp.Id);
                         }
        for(User usr :users){
            if(usr.UserType != 'PowerPartner'){
                GroupMember gm = new GroupMember();
                gm.UserOrGroupId = usr.Id;
                if(usr.DataVisibility__c == 'Both'){
                    gm.GroupId = groupIdMap.get('Common_Access_Group');
                    members.add(gm);
                } else if(usr.DataVisibility__c == 'WSS'){
                    gm.GroupId = groupIdMap.get('WSS_Users');
                    members.add(gm);
                }
            }
            
        }
        system.debug('members'+members);
        if(members != null && !members.isEmpty()){
            insert members;
        }
    }
    public static void updateGroupDetails(Map<Id, User> oldMap, List<User> usrs){
        List<user> updatedUsers = new List<User>();
        Map<String, Id> groupIdMap = new Map<String, Id>();
        set<Id> groupids = new Set<Id>();
        List<GroupMember> deleteGMs = new List<GroupMember>();
        for(group grp : [SELECT Id, DeveloperName
                         FROM Group 
                         WHERE DeveloperName IN ('WSS_Users', 'Common_Access_Group', 'Non_WSS_User_Group')]){
                             groupIdMap.put(grp.DeveloperName, grp.Id);
                             groupids.add(grp.Id);
                         }
        for(User usr : usrs){
            if(usr.UserType != 'PowerPartner'){
                if(usr.DataVisibility__c != oldMap.get(usr.Id).DataVisibility__c){
                    updatedUsers.add(usr);
                }
            }
        }
        for(GroupMember gm : [SELECT Id,GroupId 
                              FROM GroupMember 
                              WHERE UserOrGroupId IN : updatedUsers]){
                                  if(groupids.contains(gm.GroupId)){
                                      deleteGMs.add(gm);
                                  }
                              }
        if(deleteGMs != null && !deleteGMs.isEmpty()){
            delete deleteGMs;
        }
        if(updatedUsers != null && !updatedUsers.isEmpty()){
            addUserInPubicGroup(updatedUsers);
        }
        
    }
}