trigger ContentVersionTrigger on ContentVersion (after insert) {

    User u = [SELECT Id FROM User WHERE UserName LIKE '%custom_web_to_case@%' LIMIT 1];
    List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
    for (ContentVersion v : Trigger.new) {
        if (v.CreatedById == u.Id) {
            try {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = v.ContentDocumentId;
                System.debug('[-] Description is : ' + v.Description);
                cdl.LinkedEntityId = Id.valueOf(v.Description);
                cdl.ShareType = 'V';
                linksToInsert.add(cdl);
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug('Description doesn\'t appear to be an ID');
            }
        }
    }
    if (linksToInsert.size() > 0) {
        insert linksToInsert;
    }
}