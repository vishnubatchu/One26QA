/*
ClassName : NewRmaAlertControllerTest
Created Date: 3-04-2019
Description: To test NewRmaAlertController
*/
@isTest(seeAllData = false)
public class NewRmaAlertControllerTest {
    
    /*
MethodName : testRmaController
Created Date: 3-04-2019
Description: To test NewRmaAlertController
*/
    @isTest
    static void testRmaController(){
        TestDataUtilityClass.createUsers();
       List<Account> accList =  TestDataUtilityClass.createAccounts();
        
        //Account custAcc = [select id from account where type='Customer'];
        TestDataUtilityClass.createRMAorCases(accList);
        Case rmacase = [Select id from case Limit 1];
       // insert rmacase;
        NewRmaAlertController rmacont = new NewRmaAlertController();
        rmacont.recordId = rmacase.Id;
        rmacont.getrmaDetails();
    }
}