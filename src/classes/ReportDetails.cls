@RestResource(urlMapping='/ReportsDetail/*')
global class ReportDetails {
    
    @HttpPost
    global static String doPost(String ReportName) {
        String Responce='';
        List<List<sobject>> combinedSobjectList = New List<List<sobject>>();
        List<Inbound_Report_Detail__mdt> inboundReportList = [Select id,MasterLabel,FieldsName__c,ObjectName__c,ReportName__c,FilterCriteria__c from Inbound_Report_Detail__mdt where ReportName__c=: ReportName];
        For(Inbound_Report_Detail__mdt reportDetailObj:inboundReportList){
            String query = 'Select '+reportDetailObj.FieldsName__c+' From '+reportDetailObj.ObjectName__c + ' ' + reportDetailObj.FilterCriteria__c;  
        	system.debug(query);
            List<sobject> sObjectList= Database.query(query);
            combinedSobjectList.add(sObjectList);
        }
        If(combinedSobjectList.size()>0){
            Responce = json.serialize(combinedSobjectList);
        }
        return Responce;
    }
}