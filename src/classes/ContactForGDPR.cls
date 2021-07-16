public class ContactForGDPR {
    /* 
public static void checkCountry(List<Contact> conlist){
List<Schema.PicklistEntry>  countryfieldResult = Contact.GDPR_Country__c.getDescribe().getPicklistValues();
Map<string,string> options = new Map<string,string>();
for( Schema.PicklistEntry f : countryfieldResult )
{   
options.put(f.getLabel(),f.getLabel());
}
system.debug('options===='+options);
for(Contact c:conlist) {
system.debug('c.MailingCountry===='+c.MailingCountry);
if(c.MailingCountry != null && !options.containsKey(c.MailingCountry.toupperCase())){
c.MailingCountry.addError('Please Insert the Valid Value in Mailing Country field');
}else if (c.MailingCountry != null && options.containsKey(c.MailingCountry.toupperCase())) {
c.GDPR_Country__c = c.MailingCountry.toupperCase();
}
}
}
*/
    
    public static List<Contact> checkMarketingCommunication(List<Contact> conlist) { 
        Map<String,String> accountToTypeMap = new Map<String,String>();
        List<Contact> newContactList = new List<Contact>();
        Set<Id> accountId = new Set<Id>();
        Set<String> countries = new Set<String>();
        for(Contact c:conlist) {
            accountId.add(c.accountId);
            countries.add(c.Display_Mailing_Country__c);
        }
        Map<String, Map<String, String>> gdprCountryCatMap = getEmailCategory(countries);
        for(Account acc: [SELECT id,Type FROM Account WHERE Id IN:accountId]) {
            if(acc.Type != null) {
                accountToTypeMap.put(acc.id,acc.Type); 
            }
        }
        for(Contact c:conlist) {
            String contactCategory='';
            String category='';
            String accountType = accountToTypeMap.get(c.AccountId);
            if(accountType == 'Distributor' || accountType == 'Reseller') {
                contactCategory='PARTNER';
            }else {
                contactCategory = accountType;
            }
            system.debug('gdprCountryCatMap'+gdprCountryCatMap);
            system.debug('c.Display_Mailing_Country__c'+c.Display_Mailing_Country__c);
            if(c.Display_Mailing_Country__c != null && gdprCountryCatMap.containskey(c.Display_Mailing_Country__c.toupperCase()) &&
               String.isNotBlank(contactCategory) ){
                system.debug('In if');
                category = gdprCountryCatMap.get(c.Display_Mailing_Country__c.toupperCase()).get(contactCategory.toupperCase());
            }
            system.debug('category'+category);
            if(c.Party_Account__c == true && category == 'OPT IN') {
                c.Marketing_Communication_Opt_Out__c = true;
            }else if(c.Party_Account__c == true && category == 'OPT OUT') {
                c.Marketing_Communication_Opt_Out__c = false;
            }else if(c.Party_Account__c == false && category == 'OPT OUT') {
                c.Marketing_Communication_Opt_Out__c = false;
            }else if(c.Party_Account__c == false && category == 'OPT IN') {
                c.Marketing_Communication_Opt_Out__c = true;
            }
            newContactList.add(c);
        } 
        return newContactList;
    }
    /*  public static string getEmailCategory(string contry ,string cntctCategory){
List<GDPR_Country_Email_Opt_In_Opt_Out__mdt> emailList = [select id,CONTACT_CATEGORY__c,Email__c,Country__c from GDPR_Country_Email_Opt_In_Opt_Out__mdt];
Map<String,list<GDPR_Country_Email_Opt_In_Opt_Out__mdt>> countrytoCategoryMap = new Map<String,list<GDPR_Country_Email_Opt_In_Opt_Out__mdt>>();
for(GDPR_Country_Email_Opt_In_Opt_Out__mdt elist : emailList){
if(!countrytoCategoryMap.containsKey(elist.Country__c)){
countrytoCategoryMap.put(elist.Country__c,new list<GDPR_Country_Email_Opt_In_Opt_Out__mdt>{elist});
}else{
countrytoCategoryMap.get(elist.Country__c).add(elist);
}
}
Map<String,String> CategorytoEmailMap = new Map<String,String>();

for(GDPR_Country_Email_Opt_In_Opt_Out__mdt elist2 : countrytoCategoryMap.get(contry)){
CategorytoEmailMap.put(elist2.CONTACT_CATEGORY__c,elist2.Email__c);
} 
string emailCategory = CategorytoEmailMap.get(cntctCategory.toUpperCase());
//  boolean emails = true;
if(emailCategory != null){
return emailCategory;
}else {
return null;
}

} */
    public static Map<String, Map<String, String>> getEmailCategory(Set<String> countries){
        Map<String, Map<String, String>> gdprCateMap = new Map<String, Map<String, String>>();
        for(GDPR_Country_Email_Opt_In_Opt_Out__mdt mdt : [SELECT id,CONTACT_CATEGORY__c,Email__c,Country__c 
                                                          FROM GDPR_Country_Email_Opt_In_Opt_Out__mdt
                                                          WHERE Country__c IN :countries]){
                                                              if(gdprCateMap.containsKey(mdt.Country__c)){
                                                                  gdprCateMap.get(mdt.Country__c).put(mdt.CONTACT_CATEGORY__c, mdt.Email__c);
                                                              }else {
                                                                  Map<String, String> tempMap = new Map<String, String>();
                                                                  tempMap.put(mdt.CONTACT_CATEGORY__c, mdt.Email__c);
                                                                  gdprCateMap.put(mdt.Country__c, tempMap);
                                                              }       
                                                          }
        return gdprCateMap;
    }
    public static void sendMailUponDeletion(List<Contact> conlist) { 
        IF(Label.Contact_Email_Trigger_Condition.equalsIgnoreCase('True')){
            set<id> creatorId = new set<id>();
            set<String> emailIds = new set<String>();
            Map<Id,String> idToContactCreatorMap = new Map<Id,String>();
            Map<String, Individual> individualMap = new Map<String, Individual>();
            List<Individual> updateIndividual = new List<Individual>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            // EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Email_Template_Upon_Deletion'];
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Contact_Deletion_Templete'];
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where DisplayName = 'FinisarCRM'];
            for(Contact con :conlist){
                creatorId.add(con.CreatedById);
                emailIds.add(con.Email);
            }
            for(Individual ind : [SELECT Id, ConsentDate__c,Email__c FROM Individual WHERE Email__c IN : emailIds]){
                individualMap.put(ind.Email__c, ind);
            }
            // List<User> userList = [select id,name,email from user where id IN:creatorId]; 
            for(User u :[SELECT id,name,email FROM user WHERE id IN:creatorId]){
                idToContactCreatorMap.put(u.id,u.Email);
            }
            for(Contact c:conlist) {
                if(individualMap.containsKey(c.Email) &&
                   individualMap.get(c.Email) != null ){
                       String contactCreatorEmail = idToContactCreatorMap.get(c.createdbyId);
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       mail.setTemplateId(et.id);
                       mail.setToAddresses(New List <String> {contactCreatorEmail});
                       mail.setWhatId(c.Id);
                       mail.setTargetObjectId(c.CreatedById);
                       mail.setSaveAsActivity(false);
                       mail.setOrgWideEmailAddressId(owea.get(0).Id);
                       mailList.add(mail);
                       individualMap.get(c.Email).ConsentDate__c = DateTime.now();
                       updateIndividual.add(individualMap.get(c.Email));
                   }
            }
            if(mailList != null && !mailList.isEmpty())
                Messaging.sendEmail(mailList, false);
            if(updateIndividual != null && !updateIndividual.isEmpty()){
                update updateIndividual;
            }
        }
        
    }
    
    
    public static void updateAccountContact(Set<Id> accountId)
    {
        Map<Id,List<Contact>> accountContactMap = new Map<Id,List<Contact>>();
        List<Contact> contactlist = new List<Contact>();
        List<Account> acclist = [select id,(Select id,AccountId,Display_Mailing_Country__c,Account.Type,Party_Account__c,GDPR_Country__c,Marketing_Communication_Opt_Out__c 
                                            from contacts) 
                                 from account
                                 where id IN:accountId];
        for(Account acc:acclist){
            if(acc.contacts.size()>0) {
                accountContactMap.put(acc.id,acc.contacts);
                contactlist.addAll(acc.contacts);
            }
        }
        system.debug('contactlist---'+contactlist);
        List<Contact> newcontactlist= checkMarketingCommunication(contactlist);
        if(newcontactlist.size()>0){
            update newcontactlist;
        }
    }
    
    public static void sendMailUponCreation(List<Contact> conlist) {
        set<id> creatorId = new set<id>();
        Map<Id,String> idToContactCreatorMap = new Map<Id,String>();
        Map<Id,String> idToContactEmailMap = new Map<Id,String>();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        // EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Email_Template_Upon_Deletion'];
        EmailTemplate etforOptIn = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Contact_Email_OptIn'];
        EmailTemplate etforOptOut = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Contact_Email_OptOut'];
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where DisplayName = 'FinisarCRM']; 
        for(Contact c:conlist){
            creatorId.add(c.CreatedById);
            if(c.Email != null) {
                idToContactEmailMap.put(c.id,c.Email); 
            }
            
        }
        System.debug('creatorId'+creatorId);
        List<User> userList = [select id,name,email from user where id IN:creatorId]; 
        System.debug('userList'+userList);
        for(User u :userList){
            idToContactCreatorMap.put(u.id,u.Email);
        }
        Map<String, Individual> individualMap = new Map<String, Individual>();
        List<Individual> updateIndividual = new List<Individual>();
        for(Individual ind : [SELECT Id, ConsentDate__c,Email__c FROM Individual 
                              WHERE Email__c IN : idToContactEmailMap.values()]){
                                  individualMap.put(ind.Email__c, ind);
                              }
        System.debug('idToContactCreatorMap'+idToContactCreatorMap);
        for(Contact c:conlist) {
            system.debug('c==='+c+'owner==='+c.CreatedBy.email);
            //String contactCreatorEmail = idToContactCreatorMap.get(c.createdbyId);
            String contactCreatorEmail = idToContactEmailMap.get(c.id);
            System.debug('contactCreatorEmail---'+contactCreatorEmail);
            System.debug('individualMap---'+individualMap);
            System.debug('c.Email---'+c.Email);
            //system.debug('individualMap.get(c.Email).ConsentDate__c == null'+individualMap.get(c.Email).ConsentDate__c == null);
            if(c.Display_Mailing_Country__c != null && c.Email != null &&
               Label.Contact_Email_Trigger_Condition.equalsIgnoreCase('True') &&
               individualMap.containsKey(c.Email) &&
               individualMap.get(c.Email).ConsentDate__c == null){
                   system.debug('in ');
                   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                   if(!c.Marketing_Communication_Opt_Out__c){
                       mail.setTemplateId(etforOptIn.id);
                   }else if(c.Marketing_Communication_Opt_Out__c){
                       mail.setTemplateId(etforOptOut.id);
                   }
                   mail.setToAddresses(New List <String> {contactCreatorEmail});
                   mail.setWhatId(c.Id);
                   mail.setTargetObjectId(c.Id);
                   mail.setSaveAsActivity(false);
                   mail.setOrgWideEmailAddressId(owea.get(0).Id);
                  // mail.setBccAddresses(new String[] {Label.dataservice,Label.GDPR_Email_Service_Address});
                   System.debug('mail==='+mail);
                   mailList.add(mail);
                   individualMap.get(c.Email).ConsentDate__c = DateTime.now();
                   updateIndividual.add(individualMap.get(c.Email));
               }
        }
        if(mailList != null && !mailList.isEmpty()){
            Messaging.sendEmail(mailList, true);
        }
        if(updateIndividual!= null && !updateIndividual.isEmpty()){
            update updateIndividual;
        }
    }
    
    public static void handleEmailChange(Map<Id, Contact> oldMap, Map<Id, Contact> newMap){
        List<Contact> emailUpdatedContacts = new List<Contact>();
        List<Contact> newIndiContacts = new List<Contact>();
        for(contact con : newMap.values()){
            if(con.Email != null && con.Email != oldmap.get(con.Id).Email){
                emailUpdatedContacts.add(con);
            }
        }
        for(Contact con : [SELECT id, Individual.Email__c, individualId, Email 
                           FROM Contact WHERE Id IN : emailUpdatedContacts]){
                               if(con.Email != con.Individual.Email__c)
                                   newIndiContacts.add(newMap.get(con.Id));
                           }
        if(newIndiContacts != null && !newIndiContacts.isEmpty()){
            IndividualRecordHelper.createNewIndividual(newIndiContacts);
            sendMailUponCreation(newIndiContacts);
        }
    }
}