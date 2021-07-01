@isTest
private class OrderAndOrderLineBatch_Test {
	 @testSetup static void setup() {
        Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile Clone' LIMIT 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        List<User>  testUserList=new List<User>();
        System.RunAs(usr)
        {
            UserRole usrRoleRec=new UserRole(Name= 'FAE'); 
            insert usrRoleRec; 
            
            for(Integer i=0;i<2;i++){
                String orgId = userInfo.getOrganizationId();
                String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                String uniqueName = orgId + dateString + randomInt;
                testUserList.add(new User(firstname = 'Test',
                                          lastName = 'User '+(i+1),
                                          email = uniqueName + '@test' + orgId + '.org',
                                          Username = uniqueName + '@test' + orgId + '.org',
                                          EmailEncodingKey = 'ISO-8859-1',
                                          Alias = uniqueName.substring(18, 23),
                                          TimeZoneSidKey = 'America/Los_Angeles',
                                          LocaleSidKey = 'en_US',
                                          LanguageLocaleKey = 'en_US',
                                          ProfileId = salesUserProfile.Id,
                                          isActive = True,
                                          UserRoleId = usrRoleRec.Id));  
            }
            testUserList.add(new User(LastName='Usrlast1111',ProfileId=[SELECT Id from Profile where Name ='System Administrator'].Id,alias ='trsysy',Legacy_Company__c ='Finisar',
                                      Email='standarduser1@testorg.com',EmailEncodingKey='UTF-8',  LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', UserName='testuser1@finisar.com'));
            insert testUserList;
            //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Change_Account_Ownership'];
            //insert new PermissionSetAssignment(AssigneeId = testUserList[2].id, PermissionSetId = ps.Id);
        }
        List<Account> globalParentAccList=new List<Account>();  
        globalParentAccList.add(new Account(Name='Global Parent Test Acc',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId(),OwnerId=testUserList[0].Id));
        globalParentAccList.add(new Account(Name='Global Parent Test Acc1',Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',ShippingCity = 'New York', ShippingCountry ='US',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Global Parent').getRecordTypeId(),OwnerId=testUserList[1].Id));
        insert globalParentAccList;  
        List<Account> accList=new List<Account>(); 
        for(Integer i=1;i<=6;i++){
            accList.add(new Account(Name='Test Acc '+i,Display_Shipping_Country__c ='United States',   Display_Billing_Country__c = 'United States',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Account').getRecordTypeId(),ShippingCity = 'New York', ShippingCountry ='US',
                                    ParentId=globalParentAccList[0].Id,Global_Ultimate_Parent__c=globalParentAccList[0].Id,Status__c='Active',Type='Customer'));
        }  
        insert accList;
        Integer index=1;
        List<Opportunity> oppList=new List<Opportunity>();
        for(Integer i=0;i<accList.size();i++){
            oppList.add(new Opportunity(CloseDate=System.today(),AccountId=accList[i].Id,ForecastCategoryName='Pipeline',
                                        Name='Test Opp '+index,StageName='Qualifying',Project_Name__c='Test',RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Aftermarket').getRecordTypeId()));
            index++;
        } 
        insert oppList;
        List<Order> orderList=new List<Order>();
        index=1;
        for(Opportunity eachOpp:oppList){
            orderList.add(new Order(Legacy_Id__c='12345'+index,OpportunityId=eachOpp.Id,AccountId=eachOpp.AccountId,Name='Test Quote '+index,
                                    EffectiveDate=System.today(),Status='Draft',Integration_Flag__c=true,Batch_Flag__c=false));
            index++;
        }
        insert orderList;
        List<Order_Line__c> orderLineList=new List<Order_Line__c>();
        for(Order eachOrder:orderList){
            orderLineList.add(new Order_Line__c(Order__c=eachOrder.Id,Customer_Name__c=eachOrder.AccountId,Integration_Flag__c=true,Batch_Flag__c=false));
        }
        insert orderLineList;
    }
    
    @isTest static void testOrderAndOrderLineBatch() {
        User testUser=[Select Id from User where lastName='User 1'];
        Test.startTest();
        OrderAndOrderLine_Batch batchObj = new OrderAndOrderLine_Batch();
        DataBase.executeBatch(batchObj);
        Test.stopTest();
        List<Order> orderList=[Select Id from Order where Integration_Flag__c=true and Global_Ultimate_Account__c!=null];
        List<Order_Line__c> orderLineList=[Select Id from Order_Line__c where Integration_Flag__c=true];
        List<Order_Line__Share> orderLineShrList=[Select Id from Order_Line__Share where UserOrGroupId=:testUser.Id and AccessLevel='Read'
                                         and RowCause='Manual' and ParentId in: orderLineList];
        
        System.assertEquals(6,orderList.size());
        System.assertEquals(orderLineList.size(),orderLineShrList.size());
    }
    
     @isTest static void testOrderAndOrderLineBatchScheduler() {
        Test.startTest();
        OrderAndOrderLineBatch_Scheduler schObj = new OrderAndOrderLineBatch_Scheduler();
        Date today=System.today();
        String CRON_EXP ='0 0 0 '+today.day()+' '+today.month()+' ? *'; 
        String jobId = System.schedule('Schedule to update Account Name',CRON_EXP,schObj);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
    
    @isTest static void testDoSubListHelperMethod() {
        Test.startTest();
        List<Order> orderList=[Select Id from Order where Integration_Flag__c=true];
        List<List<Sobject>> sObjectList=new List<List<Sobject>>();
        OrderAndOrderLineBatch_Helper.doSubList(orderList,2,sObjectList);
        System.assertEquals(3,sObjectList.size());
        Test.stopTest();
    }
    
      @isTest static void testSendEmailHelperMethod() {
        Test.startTest();
        string csvHeader = 'Record Id,Object Name,Operation, Error \n';
    	string mainContent = csvHeader;
		string errStr = '12345,Order,Update,Test Error occured\n';
        mainContent += errStr;
        OrderAndOrderLineBatch_Helper.sendEmail(mainContent);
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();
    }
}