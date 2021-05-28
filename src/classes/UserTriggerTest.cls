@isTest(seeAllData = false)
public class UserTriggerTest {
    @isTest
    static void testUserTrigger(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Profile']; 
        UserRole uRole = [SELECT Id FROM UserRole where DeveloperName ='RSM_of_AMERICAS_EASTERN_WSS'];
        User rsm = new User(Alias = 'rsmU', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, DataVisibility__c = 'Both',
                            TimeZoneSidKey='America/Los_Angeles', UserName='rsmstandarduser@testorg.com', UserRoleId = uRole.Id);
        insert rsm;
        rsm.DataVisibility__c = 'WSS';
        update rsm;
    }
}