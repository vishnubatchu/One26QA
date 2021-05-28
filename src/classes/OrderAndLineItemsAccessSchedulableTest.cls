@isTest(seeAllData= false)
private class OrderAndLineItemsAccessSchedulableTest {
    testMethod static void testSchedule(){
        List<Account> accList = TestDataUtilityClass.createAccounts();
        
        order ord = new order(AccountId = accList[0].Id, 
                              Type ='Sales Order',Legacy_Id__c = 'ordleg', 
                              Ordered_Date__c = Date.today(),
                              Status='Draft',
                              EffectiveDate = Date.today(),
                              Order_Changed__c = true,
                              Disti_Name__c = accList[0].Id,
                              RecordTypeId = Schema.SObjectType.order.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId());
        insert ord;
        Order_Line__c ordLine = new Order_Line__c(order__c = ord.Id);
        insert ordLine;
        Commisions__c commision = new Commisions__c(Order_Line__c = ordLine.Id,
                                                    Salesrep_Name1__c = accList[0].id,
                                                    Salesrep_Name2__c = accList[0].id,
                                                    Salesrep_Name3__c = accList[0].id,
                                                    Salesrep_Name4__c = accList[0].id,
                                                    Salesrep_Name5__c = accList[0].id,
                                                    Salesrep_Name6__c = accList[0].id,
                                                    Salesrep_Name7__c = accList[0].id,
                                                    Salesrep_Name8__c = accList[0].id,
                                                    Salesrep_Name9__c = accList[0].id);
        Commisions__c commision1 = new Commisions__c(Order_Line__c = ordLine.Id,
                                                     Salesrep_Name1__c = accList[0].id,
                                                     Salesrep_Name2__c = accList[0].id,
                                                     Salesrep_Name3__c = accList[0].id,
                                                     Salesrep_Name4__c = accList[0].id,
                                                     Salesrep_Name5__c = accList[0].id,
                                                     Salesrep_Name6__c = accList[0].id,
                                                     Salesrep_Name7__c = accList[0].id,
                                                     Salesrep_Name8__c = accList[0].id,
                                                     Salesrep_Name9__c = accList[0].id,
                                                     Salesrep_Name10__c = accList[0].id);
        insert commision;
        insert commision1;
        Test.StartTest();
        OrderAndLineItemsAccessSchedulable sh1 = new OrderAndLineItemsAccessSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}