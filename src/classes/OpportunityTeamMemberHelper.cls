/***
* Class Name : OpportunityTeamMemberHelper
* Created Date : 28th Aug 2019
* version : 1
* Description: adding RSM region members to Opportunity Team
**/
public class OpportunityTeamMemberHelper {
    /**
* Method Name: addRsmTeamMembers
* Input Parameters: List<Opportunity> opps
* out Parameters : NA
* Description: adding RSM region members to Opportunity Team,
*               Invoking from add_or_delete_user_from_Opportunity Flow.
**/
    @invocableMethod
    public static void addRsmTeamMembers(List<Opportunity> opps){
        Set<Id> rsmIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        List<String> teamEmails = new List<String>();
        Map<Id,String> rsmMap = new Map<Id,String>();
        Map<String,String> accMap = new Map<String,String>();
        Map<String,Id> emailUIdMap = new Map<String,Id>();
        Map<String, List<String>> rsmTeamMap = new Map<String, List<String>>();
        Map<String, List<String>> rsmTeamAccMap = new Map<String, List<String>>();
        List<OpportunityTeamMember> members = new List<OpportunityTeamMember>();
        for(Opportunity opp : opps){
            //skiping FNSR WSS opportunities
            if(opp.Business_Unit__c != '0040'){
                rsmIds.add(opp.RSM__c);
                oppIds.add(opp.Id);
            }
        }
        for(User rsm :[SELECT id, Email 
                       FROM User
                       WHERE Id IN :rsmIds]){
                           rsmMap.put(rsm.Id, rsm.Email); 
                       }
        for(OpptyTeamMembers_for_RSM__mdt mdt : [SELECT RSMEmail__c, TeamMemberEmail__c, Account_Name__c 
                                                 FROM OpptyTeamMembers_for_RSM__mdt
                                                 WHERE RSMEmail__c IN : rsmMap.values()]){
                                                     teamEmails.add(mdt.TeamMemberEmail__c);
                                                     if(mdt.Account_Name__c == null){
                                                         if(rsmTeamMap.containsKey(mdt.RSMEmail__c)){
                                                             rsmTeamMap.get(mdt.RSMEmail__c).add(mdt.TeamMemberEmail__c);
                                                         } else {
                                                             rsmTeamMap.put(mdt.RSMEmail__c, new List<String>{mdt.TeamMemberEmail__c});
                                                         }
                                                     } else {
                                                         accMap.put(mdt.RSMEmail__c, mdt.Account_Name__c);
                                                         if(rsmTeamAccMap.containsKey(mdt.RSMEmail__c)){
                                                             rsmTeamAccMap.get(mdt.RSMEmail__c).add(mdt.TeamMemberEmail__c);
                                                         } else {
                                                             rsmTeamAccMap.put(mdt.RSMEmail__c, new List<String>{mdt.TeamMemberEmail__c});
                                                         }
                                                     }
                                                     
                                                 }
        for(User tUser : [SELECT Id, Email 
                          FROM User
                          WHERE Email IN : teamEmails]){
                              emailUIdMap.put(tUser.Email, tUser.Id);
                          }
        for(Opportunity opp :[SELECT Id, RSM__c, Account.name 
                              FROM Opportunity 
                              WHERE Id IN :oppIds]){
                                  String accountName = opp.Account.Name;
                                  if(rsmTeamAccMap.containsKey(rsmMap.get(opp.RSM__c)) && 
                                     accountName.containsIgnoreCase(accMap.get(rsmMap.get(opp.RSM__c)))){
                                         for(String email : rsmTeamAccMap.get(rsmMap.get(opp.RSM__c))){
                                             if(emailUIdMap.get(email) != null){
                                             OpportunityTeamMember member = new OpportunityTeamMember();
                                             member.OpportunityId = opp.Id;
                                             member.UserId = emailUIdMap.get(email);
                                             member.OpportunityAccessLevel = 'All';
                                             member.TeamMemberRole = 'Team Member';
                                             members.add(member);
                                             }
                                         }
                                     } else if(rsmTeamMap.containsKey(rsmMap.get(opp.RSM__c))){
                                         for(String email : rsmTeamMap.get(rsmMap.get(opp.RSM__c))){
                                                if(emailUIdMap.get(email) != null){
                                             OpportunityTeamMember member = new OpportunityTeamMember();
                                             member.OpportunityId = opp.Id;
                                             member.UserId = emailUIdMap.get(email);
                                             member.OpportunityAccessLevel = 'All';
                                             member.TeamMemberRole = 'Team Member';
                                             members.add(member);
                                                }
                                         }
                                     }
                              }
        if(members != null && !members.isEmpty())
            insert members;
    }
}