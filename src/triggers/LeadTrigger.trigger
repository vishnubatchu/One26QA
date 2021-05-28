/**
Trigger Name : LeadTrigger
Date : 29th April 2021
created By : Surendar
Description : Lead trigger with before & after Insert events to map with individual record.
**/
trigger LeadTrigger on Lead (before insert, after insert, before delete) {
    if(trigger.isInsert && trigger.isBefore){
        // LeadTriggerHepler.updateLeadwithIndividual(trigger.new);
        IndividualRecordHelper.updatewithIndividual(trigger.new);
        LeadGDPRController.updatemarketingCommunication(trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){
        // LeadTriggerHepler.createNewIndividual(trigger.new);
        IndividualRecordHelper.createNewIndividual(trigger.new);
        LeadGDPRController.sendMailUponCreation(trigger.new);
    }
    if(trigger.isDelete && trigger.isBefore){
        LeadGDPRController.sendMailUponDeletion(trigger.old);
    }
}