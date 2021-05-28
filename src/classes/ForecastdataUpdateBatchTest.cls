@isTest(seeAllData = true)
public class ForecastdataUpdateBatchTest {
    
    @isTest
    static void testForecastdataUpdateBatch(){
        test.startTest();
        ForecastdataUpdateBatch bat = new ForecastdataUpdateBatch();
        database.executeBatch(bat);
        test.stopTest();
    }
}