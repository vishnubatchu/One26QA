/**
Class Name : LeadGDPRController
Date : 17th May 2021
created By : Surendar
Description : Lead GDPR Controller
**/
public class LeadGDPRController {
    /**
Method Name : updatemarketingCommunication
Date : 17th May 2021
created By : Surendar
description : updates lead marketing communication details using metadata .
**/
    
    public static void updatemarketingCommunication(List<Lead> newLeads){
        Set<String> countries = new Set<String>();
        for(lead ld : NewLeads){
            countries.add(ld.Display_ISO_Country__c);
        }
        system.debug('countries'+countries);
        Map<String, Map<String, String>> gdprCountryCatMap = ContactForGDPR.getEmailCategory(countries);
        system.debug('gdprCountryCatMap'+gdprCountryCatMap);
        for(Lead ld : NewLeads){
            String countryOption = gdprCountryCatMap.get(ld.Display_ISO_Country__c.toupperCase()).get('CUSTOMER');
            if(countryOption == 'OPT IN'){
                ld.Marketing_Communication_Opt_Out__c = true;
            }else{
                ld.Marketing_Communication_Opt_Out__c = false;
            }
        }
    }
    
    /**
Method Name : sendMailUponCreation
Date : 17th May 2021
created By : Surendar
description : Sending emails to Leads with email opt IN/OUT.
**/
    public static void sendMailUponCreation(List<Lead> leadList) {
        set<id> creatorId = new set<id>();
        Map<Id,String> idToLeadCreatorMap = new Map<Id,String>();
        Map<Id,String> idToLeadEmailMap = new Map<Id,String>();
        Map<String, Individual> individualMap = new Map<String, Individual>();
        List<Individual> updateIndividual = new List<Individual>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate etforOptIn = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lead_Email_OptIn'];
        EmailTemplate etforOptOut = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lead_Email_OptOut'];
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where DisplayName = 'FinisarCRM']; 
        for(Lead ld:leadList){
            creatorId.add(ld.CreatedById);
            if(ld.Email != null) {
                idToLeadEmailMap.put(ld.id, ld.Email); 
            }
        }
        for(User u :[SELECT Id,Name, Email FROM User WHERE id IN:creatorId]){
            idToLeadCreatorMap.put(u.id,u.Email);
        }
        for(Individual ind : [SELECT Id, ConsentDate__c, Email__c 
                              FROM Individual 
                              WHERE Email__c IN : idToLeadEmailMap.values()]){
                                  individualMap.put(ind.Email__c, ind);
                              }
        for(Lead ld:leadList) {
            if(ld.Email != null && individualMap.containsKey(ld.Email) && individualMap.get(ld.Email) != null && 
               individualMap.get(ld.Email).ConsentDate__c ==  null && ld.Country != null &&  
               Label.Contact_Email_Trigger_Condition.equalsIgnoreCase('True')){
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   if(ld.Marketing_Communication_Opt_Out__c == true){
                       mail.setTemplateId(etforOptIn.id);
                   }else if(ld.Marketing_Communication_Opt_Out__c == false){
                       mail.setTemplateId(etforOptOut.id);
                   }
                   mail.setToAddresses(New List <String> {idToLeadEmailMap.get(ld.id)});
                   mail.setWhatId(ld.Id);
                   mail.setTargetObjectId(ld.CreatedById);
                   mail.setSaveAsActivity(false);
                   mail.setOrgWideEmailAddressId(owea.get(0).Id);
                   mail.setBccAddresses(new String[] {Label.dataservice,Label.GDPR_Email_Service_Address});
                   mailList.add(mail);
                   individualMap.get(ld.Email).ConsentDate__c = DateTime.now();
                   updateIndividual.add(individualMap.get(ld.Email));
               }
        }
        if(mailList != null && !mailList.isEmpty())
            Messaging.sendEmail(mailList);
        if(updateIndividual != null && !updateIndividual.isEmpty()){
            update updateIndividual;
        }
    }
    
    /**
Method Name : sendMailUponDeletion
Date : 17th May 2021
created By : Surendar
description : Sending emails to lead created user when lead deleted.
**/
    public static void sendMailUponDeletion(List<Lead> leadlist) { 
        IF(Label.Contact_Email_Trigger_Condition.equalsIgnoreCase('True')){
            set<id> creatorId = new set<id>();
            Map<Id,String> idToLeadCreatorMap = new Map<Id,String>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Lead_Deletion_Templete'];
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where DisplayName = 'FinisarCRM'];
            for(Lead ld :leadlist){
                creatorId.add(ld.CreatedById);
            }
            for(User u :[SELECT id,name,email FROM user WHERE id IN:creatorId]){
                idToLeadCreatorMap.put(u.id,u.Email);
            }
            for(Lead ld: leadlist) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(et.id);
                mail.setToAddresses(New List <String> {idToLeadCreatorMap.get(ld.CreatedById)});
                mail.setWhatId(ld.Id);
                mail.setTargetObjectId(ld.CreatedById);
                mail.setSaveAsActivity(false);
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                mailList.add(mail);
            }
            Messaging.sendEmail(mailList);
        }
    }
    
}