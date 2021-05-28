trigger ContactTrigger on Contact (before insert,before update, before delete,after insert) {
    
    if( trigger.isBefore){
        if( trigger.isInsert ){
          //  ContactForGDPR.checkCountry(trigger.new);
            ContactForGDPR.checkMarketingCommunication(trigger.new);
        } 
        if(trigger.isUpdate) {
          //  ContactForGDPR.checkCountry(trigger.new);
            List<Contact> newCon= new List<Contact>();
            for(Contact c:trigger.new){
               Contact oldCon = Trigger.oldMap.get(c.ID);
                system.debug('oldCon=='+oldCon);
                system.debug('c=='+c);
                if(c.MailingCountry != oldCon.MailingCountry) {
                    newCon.add(c);
                }
            }
            if(newCon.size()>0){
               ContactForGDPR.checkMarketingCommunication(newCon); 
            }
            
        }
     if( trigger.isDelete){
            system.debug('trigger.new==='+Trigger.old);
            ContactForGDPR.sendMailUponDeletion(trigger.old);
        }
   
     }
    if(trigger.isAfter) {
        if( trigger.isInsert){
            ContactForGDPR.sendMailUponCreation(trigger.new);
        }
        
    }
}