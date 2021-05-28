@isTest(seeAllData = true)
public class ordersBatchTest {
    @isTest
    static void testordersBatch(){
        test.startTest();
        ordersBatch bat = new ordersBatch();
        database.executeBatch(bat);
        test.stopTest();
    }
}