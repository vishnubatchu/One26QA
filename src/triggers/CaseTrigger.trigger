trigger CaseTrigger on Case (before insert) {

    // Link the Contact to the Case for the custom web to case feature
    // This is done via trigger to avoid exposing Contact access perms to Guest Site user
    User u = [SELECT Id FROM User WHERE UserName LIKE '%custom_web_to_case@%' LIMIT 1];
    Id a = [SELECT Id FROM RecordType WHERE Name = 'AdvMat' LIMIT 1].Id;
    Id b = [SELECT Id FROM RecordType WHERE Name = 'AdvMat Unconfirmed' LIMIT 1].Id;

    Set<String> contactEmails = new Set<String>();
    for (Case c : Trigger.new) {
        if (c.SuppliedEmail != null && c.OwnerId == u.Id) {
            contactEmails.add(c.SuppliedEmail);
        }
    }

    List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email IN :contactEmails];
    Map<String, Id> mapEmailToContactId = new Map<String, Id>();
    for (Contact c : contacts) {
        mapEmailToContactId.put(c.Email, c.Id);
    }

    for (Case c : Trigger.new) {
        if ((c.RecordTypeId == a || c.RecordTypeId == b) && (c.SuppliedEmail != null) && (c.OwnerId == u.Id)) {
            //if ((c.RecordTypeId == a) && (c.SuppliedEmail != null) && (c.OwnerId == u.Id)) {
            if (mapEmailToContactId.keySet().contains(c.SuppliedEmail)) {
                c.ContactId = mapEmailToContactId.get(c.SuppliedEmail);
            }
        }
    }
    // End linking Contact to the Case for custom web to case feature

}