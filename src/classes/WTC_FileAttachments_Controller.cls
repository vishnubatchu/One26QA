public with sharing class WTC_FileAttachments_Controller {

    // The maximum number of file inputs that appear on the page
    final Integer NUM_FILE_INPUTS = 10;

    // How long until the file attachment form expires for a case, default 30 minutes
    private Decimal EXPIRATION_LIMIT;

    public List<ContentVersion> newAttachments { get; set; }    // List of new attachments to add, tied to inputs
    public List<String> whitelist = new List<String>();         // holds whitelisted file extensions from Custom Metadata Type
    public Boolean successfulUpload { get; set; }               // Used to drive the visibility of the form and success messages
    public Boolean validTimeframe { get; set; }                 // Used to make sure we aren't accepting attachments past expiration date

    public Custom_Web_to_Case_Settings__mdt config {get; set;}

    // constructor
    public WTC_FileAttachments_Controller() {
        System.debug('[-] Constructor');

        successfulUpload = false;
        resetFileInputs();

        // Get the file whitelist
        //if (!Test.isRunningTest()){
            config = [SELECT Id, File_Extension_Whitelist__c, File_Attachment_Form_Expiration_Limit__c FROM Custom_Web_to_Case_Settings__mdt LIMIT 1];
            setupMetadataType();
        //}

        if (ApexPages.currentPage().getParameters().get('caseID') != null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Case submitted successfully. You can use this page to add files if necessary.');
            ApexPages.addMessage(myMsg);
        }
    }

    public void setupMetadataType() {
        if (config != null) {
            String[] split = config.File_Extension_Whitelist__c.split(',');
            for (String s : split) {
                whitelist.add('.' + s.toLowerCase());
                System.debug('[-] Whitelisting file extension .' + s);
            }

            // set the expiration limit
            if (config.File_Attachment_Form_Expiration_Limit__c != null && config.File_Attachment_Form_Expiration_Limit__c >= 0) {
                EXPIRATION_LIMIT = 1000 * 60 * config.File_Attachment_Form_Expiration_Limit__c;
            } else {
                EXPIRATION_LIMIT = 100 * 60 * 30;
            }
            System.debug('[-] Expiration Limit is : ' + EXPIRATION_LIMIT);
        } else {
            System.debug('[-] Config is null, no files will be accepted');
        }

        // Get the creation time of the case - If it was created too long ago, do not let the user upload files
        validTimeframe = isValidTimeframe();
    }

    // Get the case ID from the URL
    public PageReference checkCaseParam() {
        if (ApexPages.currentPage().getParameters().get('caseID') == null) {
            System.debug('[-] We have no case parameter');
            return new PageReference('/apex/WebToCaseHomepage');
        }
        return null;
    }

    // Handle saving attachments
    public void doSave() {
        List<String> Errors = new List<String>();

        System.debug('[-] Processing attachments');
        List<ContentVersion> toInsert = new List<ContentVersion>();
        for (ContentVersion newAtt : newAttachments) {
            if (newAtt.VersionData != null) {
                System.debug('Title: ' + newAtt.Title);
                // check if this extension is on the whitelist
                if (isExtensionValid(newAtt.Title)) {
                    newAtt.PathOnClient = newAtt.Title;
                    newAtt.Description = ApexPages.currentPage().getParameters().get('caseID');
                    toInsert.add(newAtt);
                } else {
                    System.debug('[-] This type of file is not allowed! [FileName = ' + newAtt.Title + ']');
                    Errors.add('File upload failed: ' + newAtt.Title + ' (This type of file is not allowed)');
                }
            } else {
                System.debug('[-] Body null');
            }
        }

        try {
            if (toInsert.size() > 0) {
                //insert toInsert;
                //Begin - In order to link the documents with case
               	set<Id> cvIds = new set<Id>();
                Database.SaveResult[] results = Database.insert(toInsert);
                for(Database.SaveResult result : results){
                    Id cvId = result.getId();
                    cvIds.add(cvId);
                }
                System.debug('>>>>> CVs' + cvIds);
                List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();
                List<ContentVersion> files = new List<ContentVersion>();
                files = [Select Id, ContentDocumentId From ContentVersion Where Id In: cvIds];
                Id caseId = ApexPages.currentPage().getParameters().get('caseID');
                
                for(ContentVersion cv : files){                    
                  cdLinks.add(new ContentDocumentLink (
                      				ContentDocumentId = cv.ContentDocumentId, 
                                   	LinkedEntityId = caseId));
                }
                insert cdLinks;
                //End - In order to link the documents with case
                System.debug('[-] Inserted ' + toInsert.size() + ' atts');
                toInsert = null;
                newAttachments = null;
            } else {
                resetFileInputs();
            }

            // Display errors
            if (Errors.size() > 0) {
                String combined = '';
                for (String s : Errors) {
                    combined += s + '<br/>';
                }
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, combined);
                ApexPages.addMessage(myMsg);

                resetFileInputs();
            } else {
                successfulUpload = true;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Upload successful! Thanks!');
                ApexPages.addMessage(myMsg);
            }
        } catch (Exception e) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry, something went wrong. We were not able to receive your files.');
            ApexPages.addMessage(myMsg);
        }
    }

    // Check if the extension of the file is in the whitelist
    public Boolean isExtensionValid(String s) {
        if (s.length() > 0) {
            for (String w : whitelist) {
                if (s.toLowerCase().endsWith(w)) {
                    return true;
                }
            }
        }
        return false;
    }

    // Add the file inputs into the page
    private void resetFileInputs() {
        newAttachments = new List<ContentVersion>();
        for (Integer i = 0; i < NUM_FILE_INPUTS; i++) {
            newAttachments.add(new ContentVersion());
        }
    }

    // Check if the current time - case creation time exceeds the limit
    public Boolean isValidTimeframe() {
        if (ApexPages.currentPage().getParameters().get('caseID') != null) {
            try {
                String left = ApexPages.currentPage().getParameters().get('caseID').substring(0, 15);
                Case c = [SELECT Id, CreatedDate FROM Case WHERE Id = :left];

                System.debug('[-] Time since case submitted: ' + (System.currentTimeMillis() - c.CreatedDate.getTime()));
                System.debug('[-] Time limit: ' + EXPIRATION_LIMIT);

                if ((System.currentTimeMillis() - c.CreatedDate.getTime()) > EXPIRATION_LIMIT) {
                    return false;
                } else {
                    return true;
                }
            } catch (Exception e) {
                // We couldn't query the case for some reason, return invalid
                System.debug(e.getMessage());
            }
        }
        return false;
    }
}