public with sharing class ReportNotification implements Reports.NotificationAction {
    
    public void execute(Reports.NotificationActionContext context) {
       // Reports.ReportResults results = context.getReportInstance().getReportResults();
        // In the above subscription case this is the 'Record Count'
        //System.debug(context.getThresholdInformation().getEvaluatedConditions()[0].getValue());
        // You can also access the report definition!
        //System.debug(results.getReportMetadata().getId());
        //Id reportId2 = results.getReportMetadata().getId();
        //sendemail(reportId2, results.getReportMetadata().getName());
    }
    /*
    @future(callout=true)
    public static void sendemail(Id reportId, String rptName){
        ApexPages.PageReference report = new ApexPages.PageReference('/'+reportId+'?csv=1');
        system.debug('report'+report);
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(rptName+'.csv');
        attachment.setBody(report.getContent());
        attachment.setContentType('text/csv');
        system.debug('attachment'+attachment);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        message.setSubject('Report : '+rptName);
        message.setHtmlBody('Dear,<br></br>The report is attached.');
        message.setTargetObjectId(userinfo.getUserId());
        message.setSaveAsActivity(false);
        system.debug(message);
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }*/
}