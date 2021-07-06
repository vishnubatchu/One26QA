@isTest
private class EmailUtil_Test {
	@isTest static void testSendEmailHelperMethod() {
        Test.startTest();
        string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    	string mainContent = csvHeader;
		string errStr = '12345,Order,Update,Test Error occured\n';
        mainContent += errStr;
        EmailUtil.sendEmailWithAttachment(mainContent,'ErrorList.csv',System.Label.Global_Parent_Owner_Account_Update_Batch_Notification_EmaildId,'Batch Errors','PFA error file attached.');
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }
}