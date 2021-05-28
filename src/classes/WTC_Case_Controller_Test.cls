@isTest
public class WTC_Case_Controller_Test {
	@isTest
    public static void testWTC_Controller(){
        PageReference WTCpageRef = new PageReference('apex/WebToCaseFileAttachments');
       	WTCpageRef.getParameters().put('caseID', '122131233123');
        
        WTC_FileAttachments_Controller WTC_ConrollerObj	= new WTC_FileAttachments_Controller();
        WTC_ConrollerObj.setupMetadataType();
        WTC_ConrollerObj.checkCaseParam();
        WTC_ConrollerObj.doSave();
        WTC_ConrollerObj.isExtensionValid('Title');
        
    }
}