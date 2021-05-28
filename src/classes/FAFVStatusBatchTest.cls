@isTest(seeAllData=false)
private class FAFVStatusBatchTest {
    testMethod static void testBatch(){
        List<Account> accList = TestDataUtilityClass.createAccounts();
        
        order ord = new order(AccountId = accList[0].Id, 
                              Type ='Sales Order',Legacy_Id__c = 'ordleg', 
                              Ordered_Date__c = Date.today(),
                              Status='Draft',
                              EffectiveDate = Date.today(),
                             RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId());
        insert ord;
        Order_Line__c ordLine = new Order_Line__c(order__c = ord.Id);
        insert ordLine;
        List<Serial_Number__c> serLst = new List<Serial_Number__c>();
        Serial_Number__c serialnum = new Serial_Number__c(Name = 'abcded',Order_Line__c = ordLine.Id, Status__c = 'Closed');
        insert serialnum;
        Serial_Number__c serialnum1 = new Serial_Number__c(Name = 'abcded',Order_Line__c = ordLine.Id, Status__c = 'Closed');
        insert serialnum1;
        FA_FV_Analysis__c fafv= new FA_FV_Analysis__c(Name = 'Fa Analysis',
                                                      FA_FV_Status__c = 'Finalized',
                                                      RecordTypeId =  Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FA Analysis').getRecordTypeId()
                                                     );
        FA_FV_Analysis__c fafv1= new FA_FV_Analysis__c(Name = 'Fv Analysis',
                                                       FA_FV_Status__c = 'Finalized',
                                                      RecordTypeId =  Schema.SObjectType.FA_FV_Analysis__c.getRecordTypeInfosByName().get('FV Analysis').getRecordTypeId()
                                                     );
        insert fafv;
        insert fafv1;
        FA_FV_Detail__c fafvde = new FA_FV_Detail__c(RecordTypeId = Schema.SObjectType.FA_FV_Detail__c.getRecordTypeInfosByName().get('FA/FV Detail').getRecordTypeId(),
                                                    	FA_FV__c = fafv.Id, Serial_Number__c = serialnum.Id,
                                                    Status__c = 'Complete');
        FA_FV_Detail__c fafvde1 = new FA_FV_Detail__c(RecordTypeId = Schema.SObjectType.FA_FV_Detail__c.getRecordTypeInfosByName().get('FA/FV Detail').getRecordTypeId(),
                                                    	FA_FV__c = fafv1.Id, Serial_Number__c = serialnum1.Id,
                                                     Status__c = 'Complete');
        insert fafvde;
        insert fafvde1;
        test.startTest();
        FAFVStatusBatch bat = new FAFVStatusBatch();
        database.executeBatch(bat);
        test.stopTest();
    }
}