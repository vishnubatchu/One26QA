public class createFAReports {
    public static List<serialNumberFAAnalysisWrapper> serialNumbertable {get;set;}
    public static Order_line__c ol { get; set; }
    public static List<Serial_Number__c> sN { get; set; }
    public static List<FA_FV_Analysis__c> fA { get; set; }
    public static Map<Id,set<String>> FAtoSNMap { get; set; }
    public createFAReports() {
        Id orderlineId = ApexPages.currentPage().getParameters().get('orderLine');
        String serialId =ApexPages.currentPage().getParameters().get('selectedSerialNumber');
        system.debug('serialId ===='+serialId);
        List<String> lstserialId = serialId.split(',');
        ol=getOrderlineData(orderlineId);
        sN = getSerialNumberData(lstserialId);
        fA = getFAFVData(lstserialId);
        serialNumbertable= prepareMapforSerialNumberTable(lstserialId);
    }
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }
                        }
    public static Order_line__c getOrderlineData(Id orderlineId)
    {
        Order_line__c orderLine = [select id,Name,order__r.RMA_Request__r.CaseNumber,order__r.PoNumber,RMA_Received_Date__c,Owner.name,FA_FV_Completion_Date__c,order__r.Account.name,Part_Number__r.name,order__r.End_Customer__c,Marketing_Part__c
                                   from Order_line__c where id=:orderlineId];
        return orderLine;
    }
    public static List<serialNumberFAAnalysisWrapper> prepareMapforSerialNumberTable(List<String> lstserialId)
    {
        List<serialNumberFAAnalysisWrapper> snWrapper = new  List<serialNumberFAAnalysisWrapper>();
        sN = getSerialNumberData(lstserialId);
        Map<Id,FA_FV_Detail__c> FAFVDetailMap = new Map<Id,FA_FV_Detail__c>([select Id,FA_FV__c,FA_FV__r.Name,FA_FV__r.FA_Findings__c,Serial_Number__c,Serial_Number__r.Order_Line__r.Return_Reason__c, Serial_Number__r.Name,Serial_Number__r.Date_Code__c From FA_FV_Detail__c where Serial_Number__c in :lstserialId and FA_FV__r.RecordType.DeveloperName='FA_Analysis']);
        Integer count=0;
        for(FA_FV_Detail__c FAFVDetail :FAFVDetailMap.values())
        {
            count++;
            serialNumberFAAnalysisWrapper serialNumberMap = new serialNumberFAAnalysisWrapper();
            serialNumberMap.rowindex =count;
            serialNumberMap.serialNumber=FAFVDetail.Serial_Number__r.Name;
            serialNumberMap.DateCode=FAFVDetail.Serial_Number__r.Date_Code__c;
            serialNumberMap.CustomerReportedFailure=FAFVDetail.Serial_Number__r.Order_Line__r.Return_Reason__c;
            serialNumberMap.FAFindings=FAFVDetail.FA_FV__r.FA_Findings__c;
            serialNumberMap.FAAnalysis=FAFVDetail.FA_FV__r.Name;
            snWrapper.add(serialNumberMap);
            
        }
        
        return snWrapper;
    }
    
    public static List<Serial_Number__c> getSerialNumberData(List<String> lstserialId){
        List<Serial_Number__c> lstSerial =[Select id,Name,Customer_Serial_Number__c,Date_Code__c,Order_Line__r.Return_Reason__c
                                           from Serial_Number__c where id IN:lstserialId];
        system.debug('lstSerial'+lstSerial);
        return lstSerial;
    }
    
    public static List<FA_FV_Analysis__c> getFAFVData(List<String> lstserialId){ 
        FAtoSNMap = new Map<Id,set<String>>();
        Id recordType = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId();
        Set<Id> FAFVId = new Set<Id>();
        Map<Id,List<String>> FAPam = new  Map<Id,List<String>>();
        List<FA_FV_Detail__c> FADetail =[select Serial_Number__c,Serial_Number__r.Name,Serial_Number__r.Customer_Serial_Number__c,FA_FV__c from FA_FV_Detail__c where Serial_Number__c IN:lstserialId ];
        system.debug('FADetail==='+FADetail);
        for(FA_FV_Detail__c fD:FADetail){
            FAFVId.add(fD.FA_FV__c);
            if(!FAtoSNMap.containsKey(fD.FA_FV__c)){
                FAtoSNMap.put(fD.FA_FV__c,new set<string>{fD.Serial_Number__r.Name});
            }else{
                FAtoSNMap.get(fD.FA_FV__c).add(fD.Serial_Number__r.Name);
            }
            
        } 
        System.debug('FAFVId=='+FAFVId);
        system.debug('FAPam==='+FAPam);
        system.debug('FAtoSNMap==='+FAtoSNMap);
        List<FA_FV_Analysis__c> fA = [select id,RC_Analysis__c,Conclusion__c,Failure_Mechanism__c,Containment__c,Corrective_Action__c,Risk_Assessment__c,
                                      (select id,name ,FA_Findings__c,FA_Steps_Description_FA_Steps__c from Steps__r ORDER BY Name) from FA_FV_Analysis__c where id IN:FAFVId AND recordtypeId=:recordType]; 
        System.debug('fA=='+fA);
        return fA;
    }
    
    @AuraEnabled
    public static List <Serial_Number__c> getSerialNumber(String orderID) {
        list<string> abcList = new list<string>();
        // public static list<Serial_Number__c> getSerialNumber(String orderID){
        list<Serial_Number__c> serialNoList = [select id,Name,Customer_Serial_Number__c,Order_Line__c from Serial_Number__c where Order_Line__c=:orderID ];
        for(Serial_Number__c sc : serialNoList){
            abcList.add(sc.Name) ; 
        }
        system.debug('orderID ' + orderID);
        return  serialNoList;   
    }
    
    /* @AuraEnabled
public static list<FA_FV_Analysis__c> getFADetails(list<String> serialNoID) {
list<FA_FV_Detail__c> faList = [select id,Serial_Number__c,FA_FV__c from FA_FV_Detail__c where Serial_Number__c IN : serialNoID];
list<string> faIDList = new list<string>();
for(FA_FV_Detail__c fa : faList){
faIDList.add(fa.FA_FV__c);
}
list<FA_FV_Analysis__c> faAnalysisList = [select id,Name,(select id,Name from Steps__r),(select id,Name from Failure_Modes__r) from FA_FV_Analysis__c where id IN : faIDList];

return faAnalysisList;

}*/
    
    public class serialNumberFAAnalysisWrapper
    {
        public Integer rowindex{get;set;}
        public String serialNumber{get;set;}
        public String DateCode{get;set;}
        public String CustomerReportedFailure{get;set;}
        public String  FAFindings{get;set;}
        public String FAAnalysis{get;set;}
    }
    
    
}