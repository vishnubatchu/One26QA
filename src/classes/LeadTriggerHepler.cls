/**
Class Name : LeadTriggerHepler
Date : 29th April 2021
created By : Surendar
Description : Lead trigger Helper
**/
public class LeadTriggerHepler {
    /**
Method Name : updateLeadwithIndividual
Date : 29th April 2021
created By : Surendar
description : updates lead with Individual Id in beofre Insert event, if individual record already preset with email.
**/
    public static void updateLeadwithIndividual(List<Lead> newLeads){
        Set<String> emails = new Set<String>();
        Map<String, Individual> IndividualMap = new Map<String, Individual>();
        for(Lead ld : newLeads){
            emails.add(ld.Email);
        }
        for(Individual ind : [SELECT Id, Email__c 
                              FROM Individual 
                              WHERE Email__c IN :emails]){
                                  IndividualMap.put(ind.Email__c, ind);
                              }
        for(Lead ld : newLeads){
            if(IndividualMap.containsKey(ld.email)){
                ld.IndividualId = IndividualMap.get(ld.Email).Id;
            }
        }
    }
    /**
Method Name : createNewIndividual
Date : 29th April 2021
created By : Surendar
description : updates lead with Individual Id in after Insert event, 
creates new records & map with lead, if Individual record not present in system.
**/
    public static void createNewIndividual(List<Lead> newLeads){
        Map<String, Individual> IndividualMap = new Map<String, Individual>();
        List<Lead> updateLeads = new List<Lead>();
        for(Lead ld : newLeads){
            if(ld.IndividualId == null){
                Individual newInd = new Individual();
                newInd.FirstName = ld.FirstName;
                newInd.LastName = ld.LastName;
                newInd.Email__c = ld.Email;
                newInd.Country__c = ld.Country;
                IndividualMap.put(ld.Email, newInd);
            }
        }
        if(IndividualMap != null && !IndividualMap.isEmpty()){
            insert IndividualMap.values();
            
            for(Lead ld: newLeads){
                if(ld.IndividualId == null && IndividualMap.containsKey(ld.Email)){
                    updateLeads.add(new Lead(Id = ld.Id, IndividualId = IndividualMap.get(ld.Email).Id));
                }
            }
            if(updateLeads != null && !updateLeads.isEmpty()){
                String jsonString = json.serialize(updateLeads);
                updateLeads(jsonString);
            }
        }
    }
    
    /**
Method Name: updateLeads
Description: updates leads in after insert event.
**/
    @future
    public static void updateLeads(String leads){
        List<Lead> leadList = (List<Lead>)Json.deserialize(leads, List<Lead>.class);
        database.update(leadList, false) ;
    }
}