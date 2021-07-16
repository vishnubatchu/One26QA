/*
* Created by : Pooja U
* Date : 5th July 2021
* Description: Test class for EmailUtil class
*/
@isTest
private class EmailUtil_Test {
    //This method tests the sendEmailWithAttachment method 
	@isTest static void testSendEmailHelperMethod() {
        Test.startTest();
        string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    	string mainContent = csvHeader;
		string errStr = '12345,Order,Update,Test Error occured\n';
        mainContent += errStr;
        EmailUtil.sendEmailWithAttachment(mainContent,'ErrorList.csv','test@gmail.com','Batch Errors','PFA error file attached.');
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }
}