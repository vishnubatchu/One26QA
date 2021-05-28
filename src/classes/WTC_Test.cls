@isTest
public with sharing class WTC_Test {

    public static testMethod void testController1() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';

        WTC_Case_Controller wtc = new WTC_Case_Controller();
        wtc.theCase = testCase;
        String nextPage = wtc.doSave().getUrl();

        // Verify that the success page displays
        System.assert(nextPage.contains('/apex/WebToCaseFileAttachments?caseID='));
    }

    public static Custom_Web_to_Case_Settings__mdt getCustomMetadataRecord(String myName) {
        Custom_Web_to_Case_Settings__mdt theRecord = new Custom_Web_to_Case_Settings__mdt();
        theRecord.DeveloperName = myName;
        return theRecord;
    }

    public static testMethod void testController2ValidTimeframe1() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Attachment_Form_Expiration_Limit__c = 10;
        mdt.File_Extension_Whitelist__c = 'jpeg';

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();


        System.assert(wtc.isValidTimeframe());
    }

    public static testMethod void testController2ValidTimeframe2() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Attachment_Form_Expiration_Limit__c = 0;
        mdt.File_Extension_Whitelist__c = 'jpeg';

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();


        System.assert(!wtc.isValidTimeframe());
    }

    public static testMethod void testController2Whitelist1() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'jpeg';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();

        System.assertEquals(true,wtc.isExtensionValid('.jpeg'));
        System.assertEquals(true,wtc.isExtensionValid('.JPEG'));
        System.assertEquals(true,wtc.isExtensionValid('.jPeG'));
        System.assertEquals(false,wtc.isExtensionValid('.test'));
    }

    public static testMethod void testController2Whitelist2() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'jpeg,jpg,png';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();

        System.assertEquals(true,wtc.isExtensionValid('.jpeg'));
        System.assertEquals(true,wtc.isExtensionValid('.JPEG'));
        System.assertEquals(true,wtc.isExtensionValid('.jPeG'));
        System.assertEquals(true,wtc.isExtensionValid('.jpg'));
        System.assertEquals(true,wtc.isExtensionValid('.JPG'));
        System.assertEquals(true,wtc.isExtensionValid('.jPg'));
        System.assertEquals(true,wtc.isExtensionValid('.png'));
        System.assertEquals(true,wtc.isExtensionValid('.PNG'));
        System.assertEquals(true,wtc.isExtensionValid('.PnG'));
        System.assertEquals(false,wtc.isExtensionValid('.test'));
    }

    public static testMethod void testController2Whitelist3() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'JPEG';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();

        System.assertEquals(true,wtc.isExtensionValid('.jpeg'));
        System.assertEquals(true,wtc.isExtensionValid('.JPEG'));
        System.assertEquals(true,wtc.isExtensionValid('.jPeG'));
        System.assertEquals(false,wtc.isExtensionValid('.test'));
    }

    public static testMethod void testController2NullCaseRedirect() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        String nextPage = wtc.checkCaseParam().getUrl();

        // Verify we redirect to homepage
        System.assert(nextPage.contains('/apex/WebToCaseHomepage'));
    }

    public static testMethod void testController2NullCaseRedirect2() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'JPEG';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();

        // Verify we get back no pagereference
        System.assert(wtc.checkCaseParam() == null);
    }


    public static testMethod void testController2Save() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'jpg';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();

        List<ContentVersion> v = new List<ContentVersion>();

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('Test');
        cv.Title = 'test.jpg';
        v.add(cv);
        wtc.newAttachments = v;

        wtc.doSave();
    }

    public static testMethod void testController2SaveBadFile() {
        PageReference pageRef = Page.WebToCaseHomepage;
        Test.setCurrentPage(pageRef);

        Custom_Web_to_Case_Settings__mdt mdt = getCustomMetadataRecord('Test');
        mdt.File_Extension_Whitelist__c = 'jpg';

        // Instantiate a new controller with all parameters in the page
        Case testCase = new Case();
        testCase.Status = 'New';
        testCase.Origin = 'Web';
        testCase.Subject = 'test';
        insert testCase;

        ApexPages.currentPage().getParameters().put('caseID', testCase.Id);
        WTC_FileAttachments_Controller wtc = new WTC_FileAttachments_Controller();
        wtc.config = mdt;
        wtc.setupMetadataType();

        List<ContentVersion> v = new List<ContentVersion>();

        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode('Test');
        cv.Title = 'test.exe';
        v.add(cv);
        wtc.newAttachments = v;

        wtc.doSave();
    }


    public static testMethod void testContactLinking() {
        User u = [SELECT Id FROM User WHERE UserName LIKE '%custom_web_to_case@%' LIMIT 1];
        Id r1 = [SELECT Id FROM RecordType WHERE Name = :'Advmat'].Id;

        Contact c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.Email = 'test@test.com';
        insert c;

        Case cc = new Case();
        cc.RecordTypeId = r1;
        cc.SuppliedEmail = 'test@test.com';
       // cc.OwnerId = u.Id;
        insert cc;

        cc = [SELECT Id, ContactId FROM Case WHERE Id = :cc.Id];
       // System.assert(cc.ContactId == c.Id);
    }
/*
    public static testMethod void testCDLLinking() {
        User u = [SELECT Id FROM User WHERE UserName LIKE '%custom_web_to_case@%' LIMIT 1];
        Id r1 = [SELECT Id FROM RecordType WHERE Name = :'Advmat'].Id;

        Case cc = new Case();
        cc.RecordTypeId = r1;
        cc.SuppliedEmail = 'test@test.com';
        //cc.OwnerId = u.Id;
        insert cc;

        System.runAs(u) {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode('Test');
            cv.Title = 'test.exe';
            cv.Description = cc.Id;
            cv.PathOnClient = 'C:\\test';
            insert cv;
        }

        List<ContentDocumentLink> cdls = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :cc.Id];
        //System.assert(cdls.size() > 0);

    }

*/

}