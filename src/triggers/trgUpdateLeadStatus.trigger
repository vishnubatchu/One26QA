/*********
 Trigger for update the Lead Status of any Lead that is currently in Lead Status of "Open" to Lead Status "Contacted"
 when user either Logs a Call that is related to that Lead or when they send an Email related to that Lead. 
 Only Leads in Status of "Open" gets updated.
**********/

trigger trgUpdateLeadStatus on Task (after insert,after Update) {
    String setStatus = 'Contacted';

    List<Id> getLeadIds = new List<Id>();
    for(Task t :trigger.new){
        If((t.WhoId != null) && (t.Subject == 'Call' || t.Subject.contains('Email'))){
            //To confirm if the task is associated with a lead record
            if(String.valueOf(t.whoId).startsWith('00Q') == true){ 
                // add corresponding Lead Ids to the list
                getLeadIds.add(t.whoId);
            }
        }
    }
    
    List<Lead> UpdateLeads = [SELECT Id,Status from Lead Where Id In :getLeadIds And Status = 'Open'];
    If(UpdateLeads != null && UpdateLeads.Size()>0)
        for(Lead ld :UpdateLeads){
            ld.Status = setStatus; // set Status = contacted
        }
        
     // Update list with updated status
     update UpdateLeads;
}