/**
 * Name : OpportunityTeamMemberTrigger
 * created date: 25/05/2020
 * created By : Surendar
 * Description : adding validation when Non WSS users are added on WSS Opportunity sales team
**/
trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert) {
    if(trigger.isInsert && trigger.isBefore){
        OpportunityTeamMemberTriggerHelper.checkUserRole(trigger.new);
    }
}