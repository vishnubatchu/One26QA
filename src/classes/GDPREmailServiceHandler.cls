global class GDPREmailServiceHandler implements Messaging.InboundEmailHandler {

    public static ID headerID;
    public static String headerObjectName;
    public static String action;
    public static String emailAddressToChange;

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        List < String > plaintextbody = email.htmlBody!=Null ? email.htmlBody.split('\n', 0):New List<String>();
        List < GDPR_Notification__c > gdprNotificationList = New List < GDPR_Notification__c > ();
        List < Contact > contactList = New List < Contact > ();
        Boolean outbound = false;
        String contactID;
        Map<String,String> headerDetails = New Map<String,String>();
        Date dt ;
        for(Messaging.InboundEmail.header header:email.headers){
	     headerDetails.put(header.name,header.value);

        }
        System.debug('headerDetails'+headerDetails);
        system.debug('plaintextbody.size()=='+plaintextbody.size());
        if(plaintextbody.size()>0){
            System.debug('email.subject'+email.subject);
            System.debug(email.subject.containsIgnoreCase('Contact'));
             System.debug(email.subject.split('Contact \\['));
            //contactID = email.subject.containsIgnoreCase('Contact') ? email.subject.split('Contact \\[').get(1).remove(']').trim():'';
            //contactID = email.subject.containsIgnoreCase('For Finisar Use Only:') ? email.subject.split('For Finisar Use Only: \\[').get(1).remove(']').trim():'';
            
        for (String a: plaintextbody) {
            system.debug('a==='+a);
            if (a.containsIgnoreCase('Dear')) {
                outbound = true;
            }
            if(a.containsIgnoreCase('For Finisar Use Only:')) {
               contactID = a.split('For Finisar Use Only: \\[').get(1).split(']').get(0).trim();
                   }
        }
        system.debug('contactID==='+contactID);
        If(outbound && contactID!=Null) {
            system.debug('Inside Outbound==');
            GDPR_Notification__c gdprNotificationObj = New GDPR_Notification__c();
            gdprNotificationObj.Email_Body__c = email.plainTextBody;
            gdprNotificationObj.Email_BCC__c = Label.GDPR_Email_Service_Address+';'+ Label.dataservice;
            gdprNotificationObj.Email_Subject__c = email.subject;
            gdprNotificationObj.Email_Type__c = 'Outbound';
            gdprNotificationObj.Email_To__c = headerDetails.get('To');
            gdprNotificationObj.Contact__c =contactId;
            gdprNotificationObj.Email_Date__c = System.now();
            gdprNotificationList.add(gdprNotificationObj);
        }
        IF(!outbound && contactID!=Null) {
            system.debug('Inside Inbound==');
            system.debug('Email_CC__c==='+email.ccAddresses);
            GDPR_Notification__c gdprNotificationObj = New GDPR_Notification__c();
            gdprNotificationObj.Email_Body__c = email.plainTextBody;
            gdprNotificationObj.Email_BCC__c = Label.GDPR_Email_Service_Address;
            gdprNotificationObj.Email_Subject__c = email.subject;
            gdprNotificationObj.Email_Type__c = 'Inbound';
            gdprNotificationObj.Email_CC__c = String.join(email.ccAddresses,',');
            gdprNotificationObj.Email_To__c = headerDetails.get('To');
            gdprNotificationObj.Contact__c =contactId;
            gdprNotificationObj.Email_Date__c = System.now();
            gdprNotificationList.add(gdprNotificationObj);
            
            Contact conObj = New Contact();
            conObj.id = contactId;
            if(email.subject.containsIgnoreCase('Opt-In')){
                conObj.Marketing_Communication_Opt_Out__c = false;
            }else if(email.subject.containsIgnoreCase('Opt-Out')){
                 conObj.Marketing_Communication_Opt_Out__c = true;
            }
            
            contactList.add(conObj);
        }

       IF(gdprNotificationList.size() > 0) {
            insert gdprNotificationList;
        }
        IF(contactList.size()>0){
            system.debug('contactList=='+contactList);
            update contactList;
            system.debug('contactList1=='+contactList);
        } 
     }
        return null;
    }

}