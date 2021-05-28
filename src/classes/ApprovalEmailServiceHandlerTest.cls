@istest(seeAllData = false)
private class ApprovalEmailServiceHandlerTest {
    
    testMethod static void testhandleInboundEmail(){
        Id profileId =[SELECT Id FROM Profile Where Name ='System Administrator'].Id;
            TestDataUtilityClass.createTestUser(null, profileId, 'fName121', 'lName');
        User testUsr = [Select id,Email from User Where FirstName = 'fName121'];
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.plainTextBody = 'Approve Forward to: test123@test.com Comments: comments';
        Messaging.Inboundenvelope envelope = new Messaging.Inboundenvelope();
        envelope.fromAddress = testUsr.Email;
        ApprovalEmailServiceHandler handler = new ApprovalEmailServiceHandler();
        handler.handleInboundEmail(email, envelope);
        CaseApprovalEmailServicehandler caseHand = new CaseApprovalEmailServicehandler();
        caseHand.handleInboundEmail(email, envelope);
    }
}