@isTest(seeAllData = true)
private class OpportunityBUUpdateBatchTest {
@isTest
    static void testOpptyBatch(){
        test.startTest();
        OpportunityBUUpdateBatch bat = new OpportunityBUUpdateBatch();
        database.executeBatch(bat);
        test.stopTest();
    }    
}