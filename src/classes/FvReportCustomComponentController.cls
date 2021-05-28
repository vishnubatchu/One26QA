public class FvReportCustomComponentController {
    
    public static String orderlineId {get;set;}
    public String SelectedSerialNo {get;set;}
    public Order_line__c orderline { get; set; }
    public List<Serial_Number__c> serialnumberList { get; set; }
    public  List<FA_FV_Detail__c> fafvdetaillist {get;set;}
    public static List<FA_FV_Analysis__c> fvAnalysisList { get; set; }
    public static Map<Id,set<String>> fatosnMap { get; set; }
    public static Boolean displaySendEmailButton {get;set;} 
    public static String serialId {get;set;} 
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }
                        }
    public FvReportCustomComponentController()
    {
        displaySendEmailButton = True;
        //this.serialnumberList = getSerialNumberData(lstserialId);
        //this.fvAnalysisList = getFAFVData(lstserialId);
        //this.serialNumbertable= prepareMapforSerialNumberTable(lstserialId);
    }
    
    public static Order_line__c getOrderlineData()
    {
       IF(String.isBlank(orderlineId)){
            orderlineId = ApexPages.currentPage().getParameters().get('orderLine');
        }
        
        Order_line__c orderLine = [select id,Reported_Problem__c,Order_Line_Request_Type__c,SO_Number_Formula__c ,Name,order__r.RMA_Request__r.CaseNumber,order__r.PoNumber,RMA_Received_Date__c,Owner.name,FA_FV_Completion_Date__c,order__r.Account.name,Part_Number__r.name,order__r.End_Customer__c,Marketing_Part__c
                                   from Order_line__c where id=:orderlineId];
        System.debug(orderLine);
        return orderLine;
    }
    public static List<Serial_Number__c> getSerialNumberData(List<String> lstserialId){
        List<Serial_Number__c> lstSerial =[Select id,Name,Customer_Serial_Number__c,Date_Code__c,Order_Line__r.Return_Reason__c
                                           from Serial_Number__c where id IN:lstserialId];
        system.debug('lstSerial'+lstSerial);
        return lstSerial;
    }
    public static List<FA_FV_Analysis__c> getFAFVData(){ 
        IF(String.isBlank(serialId)){
            serialId =ApexPages.currentPage().getParameters().get('selectedSerialNumber');
        }
        List<String> lstserialId = serialId.split(',');
        fatosnMap = new Map<Id,set<String>>();
        Id fvRecordType = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId();
        Set<Id> fvids = new Set<Id>();
        Map<Id,List<String>> fvMap = new  Map<Id,List<String>>();
        List<FA_FV_Detail__c> fvdetailList =[select Serial_Number__c,Serial_Number__r.Name,Serial_Number__r.Customer_Serial_Number__c,FA_FV__c 
                                             from FA_FV_Detail__c 
                                             where Serial_Number__c IN:lstserialId ];
        system.debug('FADetail==='+fvdetailList);
        for(FA_FV_Detail__c fD:fvdetailList){
            fvids.add(fD.FA_FV__c);
            if(!fatosnMap.containsKey(fD.FA_FV__c)){
                fatosnMap.put(fD.FA_FV__c,new set<string>{fD.Serial_Number__r.Name});
            }else{
                fatosnMap.get(fD.FA_FV__c).add(fD.Serial_Number__r.Name);
            }
            
        } 
        System.debug('FAFVId=='+fvids);
        
        system.debug('FAtoSNMap==='+fatosnMap);
        List<FA_FV_Analysis__c> fvAnalysisList = [select id,Final_Function_Test__c,Temp_BERT__c, RC_Analysis__c,Failure_Mechanism__c,Containment__c,Corrective_Action__c ,Risk_Assessment__c ,Conclusion__c ,
                                                  (select id,name ,FA_Findings__c,FA_Steps_Description_FA_Steps__c from Steps__r ORDER BY CREATEDDATE)
                                                   FROM FA_FV_Analysis__c where Id in :fvids AND RecordtypeId = :fvRecordType];
        
        return fvAnalysisList;
    }
    public static List<FA_FV_Detail__c> getFVDetail()
        
    {
        IF(String.isBlank(serialId)){
            serialId =ApexPages.currentPage().getParameters().get('selectedSerialNumber');
        }
        List<String> lstserialId = serialId.split(',');
        System.debug('*********FA Detail Records**************');
        Id recordType = Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId();
        return [select Serial_Number__r.Name,Serial_Number__r.Date_Code__c,FA_FV__r.Name,FA_FV__r.Owner.Name,FA_FV__r.FV_Findings__c,FA_FV__r.Final_Functional_Comments__c,FA_FV__r.VMI__c,FA_FV__r.Final_Function_Test__c,FA_FV__r.Temp_BERT__c  
                From FA_FV_Detail__c 
                where Serial_Number__c in :lstserialId  and FA_FV__r.RecordTypeId =:recordType ];
    }
    
    public static void sendFVReportThroughEmail(){
        displaySendEmailButton = False;
        List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
        Order_line__c orderLineObj = New Order_Line__c(Id=ApexPages.currentPage().getParameters().get('orderLine'),SelectedSerialNumber__c= ApexPages.currentPage().getParameters().get('selectedSerialNumber'));
        update orderLineObj;
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'FVReportEmailComponent'];
        System.debug('After Email');
        List< Id > userList = New List < Id > {UserInfo.getUserId()};
            for (Id u : userList) {
                System.debug('User Object'+ u);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(et.id);
                mail.setToAddresses(New List < String > {
                    UserInfo.getUserEmail()
                        });
                mail.setTargetObjectId(u);
                mail.setSaveAsActivity(false);
                mail.setWhatId(ApexPages.currentPage().getParameters().get('orderLine'));
                //Added by surendar for SAL-3576
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'FinisarCRM'];
                mail.setOrgWideEmailAddressId(owea[0].id);
                //end
                mailList.add(mail);
            }
        System.debug('MailList'+mailList );
        Messaging.sendEmail(mailList);
    }
}