public with sharing class CreateFVReport {

    public PageReference DownloadFV() {
        return new PageReference('/apex/FVDownload?selectedSerialNumber'+serialId );
    }

    
    public static String orderlineId {get;set;}
    public static String serialId {get;set;}
    public static boolean showAlert { get; set; }
    public static boolean showError { get; set; }
    public static String showMessage { get; set; }
    public static Order_line__c ol { get; set; }
    public CreateFVReport(){
        System.debug('Inside Constructor');
        orderlineId = ApexPages.currentPage().getParameters().get('orderLine');
        serialId =ApexPages.currentPage().getParameters().get('selectedSerialNumber');
        ol = [SELECT Id, Name FROM Order_line__c
              WHERE ID = :orderlineId];
        System.debug(orderlineId);
        System.debug(serialId);
    }
    
    public static void sendFVReportThroughEmail(){
        try{
            List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
            Order_line__c orderLineObj = New Order_Line__c(Id=ApexPages.currentPage().getParameters().get('orderLine'),SelectedSerialNumber__c= ApexPages.currentPage().getParameters().get('selectedSerialNumber'));
            update orderLineObj;
            Order_line__c RSMDetailsObj = [Select Id,RSM__c,RSM__r.Email,Ship_From_Inventory__c 
                                           from Order_line__c 
                                           where id =: orderLineObj.Id];    
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'FVReportEmailComponent'];
            FV_Report_Region_CC_Address_Mapping__mdt ccRegionMetaDataRecord;
            IF(RSMDetailsObj.Ship_From_Inventory__c!=Null){
                ccRegionMetaDataRecord =[Select id,masterlabel,region__c,CC_Address__c from FV_Report_Region_CC_Address_Mapping__mdt 
                                         where region__c=: RSMDetailsObj.Ship_From_Inventory__c Limit 1];   
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.id);
            mail.setToAddresses(New List < String > {
                RSMDetailsObj.RSM__r.Email
                    });
            mail.setTargetObjectId(RSMDetailsObj.RSM__c);
            mail.setSaveAsActivity(False);
            IF(ccRegionMetaDataRecord.CC_Address__c!=Null){
                mail.setCcAddresses(ccRegionMetaDataRecord.CC_Address__c.split(';'));
            }
            mail.setWhatId(RSMDetailsObj.Id);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'FinisarCRM'];
            mail.setOrgWideEmailAddressId(owea[0].id);
            mailList.add(mail);
            System.debug('MailList'+mailList );
            Messaging.sendEmail(mailList);
            showMessage ='Email sent Successfully';
            showAlert = True;
        }
        catch(Exception e){
            showMessage = e.getMessage();
            showError = true;
        }
    }
    
    public static pageReference downloadrep(){
        return new pageReference('apex/FVDownload');
    }
}