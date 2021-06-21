trigger ContactTrigger on Contact (before insert,before update, before delete,after insert, after update) {
    
    if( trigger.isBefore){
        if( trigger.isInsert ){
            //  ContactForGDPR.checkCountry(trigger.new);
            ContactForGDPR.checkMarketingCommunication(trigger.new);
            IndividualRecordHelper.updatewithIndividual(trigger.new);
        } 
        if(trigger.isUpdate) {
            //  ContactForGDPR.checkCountry(trigger.new);
            List<Contact> newCon= new List<Contact>();
            List<Contact> emailchangedCons = new List<Contact>();
            for(Contact c:trigger.new){
                Contact oldCon = Trigger.oldMap.get(c.ID);
                if(c.Display_Mailing_Country__c != oldCon.Display_Mailing_Country__c) {
                    newCon.add(c);
                }
            }
            if(newCon.size()>0){
                ContactForGDPR.checkMarketingCommunication(newCon); 
            }
            for(Contact con : trigger.new){
                if(con.Email != null && con.Email != trigger.oldMap.get(con.Id).Email){
                    emailchangedCons.add(con);
                }
            }
            if(emailchangedCons != null && !emailchangedCons.isEmpty()){
                IndividualRecordHelper.updatewithIndividual(trigger.new);
            }
            
        }
        if( trigger.isDelete){
            ContactForGDPR.sendMailUponDeletion(trigger.old);
        }
        
    }
    if(trigger.isAfter) {
        if( trigger.isInsert){
            IndividualRecordHelper.createNewIndividual(trigger.new);
            ContactForGDPR.sendMailUponCreation(trigger.new);
        }
        if(trigger.isUpdate){
            ContactForGDPR.handleEmailChange(trigger.oldMap, trigger.newMap);
        }
    }
}