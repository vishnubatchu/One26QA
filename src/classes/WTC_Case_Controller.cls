public with sharing class WTC_Case_Controller {

    public Case theCase { get; set; }

    // constructor
    public WTC_Case_Controller() {
        System.debug('[-] Constructor');
        theCase = new Case();
    }

    // Save action method
    public PageReference doSave() {
        System.debug('[-] 2');
        System.debug('[-] Save');

        System.debug('[-] Case name: ' + theCase.Subject);

        //Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'AdvMat Unconfirmed' AND SobjectType = 'Case' LIMIT 1].Id;
        //theCase.RecordTypeId = recordTypeId;
        theCase.Origin = 'Web';

        try {
            insert theCase;

            PageReference p = new PageReference('/apex/WebToCaseFileAttachments?caseID=' + theCase.Id);
            return p;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}