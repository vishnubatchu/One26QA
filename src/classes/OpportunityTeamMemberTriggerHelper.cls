/**
* Name : OpportunityTeamMemberTriggerHelper
* created date: 25/05/2020
* created By : Surendar
* Description : adding validation when Non WSS users are added on WSS Opportunity sales team
**/
public class OpportunityTeamMemberTriggerHelper {
    /**
* MethodName : checkUserRole
* input Parameter : List<OpportunityTeamMember> optMembers
* Out Parameters: NA
* Description : adding validation when Non WSS users are added on WSS Opportunity sales team
**/
    public static void checkUserRole(List<OpportunityTeamMember> optMembers){
        Map<String, String> opptBuMap = new Map<String, String>();
        Map<String, String> userRoleMap = new Map<String, String>();
        for(OpportunityTeamMember opt : optMembers){
            opptBuMap.put(opt.OpportunityId, null);
            userRoleMap.put(opt.userId, null);
        }
        for(Opportunity opp : [SELECT Id, Business_Unit__c 
                               FROM Opportunity 
                               WHERE Id IN :opptBuMap.keySet()]){
                                   opptBuMap.put(opp.Id, opp.Business_Unit__c);   
                               }
        for(user usr : [SELECT Id, UserRole.Name, UserType
                        FROM User 
                        WHERE Id IN :userRoleMap.keySet()]){
                            system.debug('usr.UserRole.Name'+usr.UserRole.Name);
                            if(usr.UserType != 'PowerPartner')
                                userRoleMap.put(usr.Id, usr.UserRole.Name);
                        }
        for(OpportunityTeamMember opt : optMembers){
            if(opptBuMap.get(opt.OpportunityId) == 'WSS' && 
               userRoleMap.get(opt.UserId) != null && 
               !userRoleMap.get(opt.UserId).contains('WSS')){
                   opt.addError('WSS user can be added in sales team for WSS Opportunities');
               }
        }
    }
}