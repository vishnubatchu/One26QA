public class ForecastShareTriggerHelper {
     public static void accessToPLMS(Map<Id,Forecast__c> forecastMap){
         List<Forecast__Share> fctsharelist = new List<Forecast__Share>();
         for(Forecast__c fct : forecastMap.values()){
             if(fct.PLM__c!=null && fct.PLM_User_Active__c){
                 Forecast__Share fctshare = new Forecast__Share();
                 fctshare.parentId = fct.Id;
                 fctshare.AccessLevel ='Read';
                 fctshare.UserOrGroupId = fct.PLM__c;
                 fctsharelist.add(fctshare);
             }
             if(fct.RSM__c!=null && fct.RSM_User_Active__c){
                 Forecast__Share fctshare = new Forecast__Share();
                 fctshare.parentId = fct.Id;
                 fctshare.AccessLevel ='Read';
                 fctshare.UserOrGroupId = fct.RSM__c;
                 fctsharelist.add(fctshare);
             }
         }
         If(fctsharelist!=null && fctsharelist.size()>0){
            upsert fctsharelist;
        }
     }
}