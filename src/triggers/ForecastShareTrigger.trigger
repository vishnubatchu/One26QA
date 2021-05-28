trigger ForecastShareTrigger on Forecast__c (After insert,After update) {
    
    ForecastShareTriggerHelper.accessToPLMS(Trigger.NewMap);
    
}