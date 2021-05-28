/**
Class Name : IndividualRecordHelper
Date : 29th April 2021
created By : Surendar
Description : Individual Record Helper
**/
public class IndividualRecordHelper {
    /**
Method Name : updatewithIndividual
Date : 29th April 2021
created By : Surendar
description : updates lead/Contact with Individual Id in beofre Insert event, if individual record already preset with email.
**/
    public static void updatewithIndividual(List<sObject> newRecords){
        Set<String> emails = new Set<String>();
        Map<String, Individual> IndividualMap = new Map<String, Individual>();
        for(sObject sobj : newRecords){
            emails.add((String)sobj.get('Email'));
        }
        for(Individual ind : [SELECT Id, Email__c 
                              FROM Individual 
                              WHERE Email__c IN :emails]){
                                  IndividualMap.put(ind.Email__c, ind);
                              }
        for(sObject sObj : newRecords){
            if(IndividualMap.containsKey((String)sobj.get('Email'))){
                sObj.put('IndividualId', IndividualMap.get((String)sobj.get('Email')).Id);
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
    public static void createNewIndividual(List<sObject> newRecords){
        Map<String, Individual> IndividualMap = new Map<String, Individual>();
        List<sObject> updateRecords = new List<sObject>();
        for(sObject sObj : newRecords){
            Id recId = (Id)sObj.get('Id');
            if(sObj.get('IndividualId') == null){
                Individual newInd = new Individual();
                newInd.FirstName = (String)sObj.get('FirstName');
                newInd.LastName = (String)sObj.get('LastName');
                newInd.Email__c = (String)sObj.get('Email');
                if(recId.getSObjectType().getDescribe().getName() == 'Lead')
                    newInd.Country__c = (String)sObj.get('Display_ISO_Country__c');
                else
                    newInd.Country__c = (String)sObj.get('Display_Mailing_Country__c');
                IndividualMap.put(newInd.Email__c, newInd);
            }
        }
        if(IndividualMap != null && !IndividualMap.isEmpty()){
            insert IndividualMap.values();
            
            for(sObject sObj: newRecords){
                if(sObj.get('IndividualId') == null && IndividualMap.containsKey((String)sObj.get('Email'))){
                    sObject newRec; 
                    Id recId = (Id)sObj.get('Id');
                    if(recId.getSObjectType().getDescribe().getName() == 'Lead'){
                        newRec = new Lead();
                        newRec.put('id', recId);
                        newrec.put('IndividualId', IndividualMap.get((String)sObj.get('Email')).Id);
                    }else {
                        newRec = new Contact();
                        newRec.put('id', recId);
                        newrec.put('IndividualId', IndividualMap.get((String)sObj.get('Email')).Id);
                    }
                    updateRecords.add(newrec);
                }
            }
            if(updateRecords != null && !updateRecords.isEmpty()){
                String jsonString = json.serialize(updateRecords);
                updateSobjRecords(jsonString);
            }
        }
    }
    
    /**
Method Name: updateSobjRecords
Description: updates leads in after insert event.
**/
    @future
    public static void updateSobjRecords(String leads){
        List<sObject> sObjectList = (List<sObject>)Json.deserialize(leads, List<Lead>.class);
        database.update(sObjectList, false) ;
    }
}