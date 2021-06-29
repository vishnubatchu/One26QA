@isTest
public class CloneFAFVRecordTest {

    public static testmethod void cloneFARecord()
    {
        FAFVCustomUITest.getFAFVDetail();
        String FAAnalysisfields = String.join(CommonConstants.FAAnalysisFields, ',');
        Test.startTest();
        String FAQuery  ='select '+FAAnalysisfields +' FROM FA_FV_Analysis__c WHERE RecordType.DeveloperName =\'FA_Analysis\''+' Limit 1';
        FA_FV_Analysis__c FAFVAnalysis = Database.query(FAQuery);
        CloneFAFVRecord.getFAFVRecord(FAFVAnalysis.Id);
        Test.stopTest();
    }
        public static testmethod void cloneFVRecord()
    {
        FAFVCustomUITest.getFAFVDetail();
        String FVAnalysisfields = String.join(CommonConstants.FAAnalysisFields, ',');
        Test.startTest();
        String FVQuery  ='select '+FVAnalysisfields +' FROM FA_FV_Analysis__c WHERE RecordType.DeveloperName =\'FV_Analysis\'' +' Limit 1';
        System.debug('******************'+FVQuery);
        FA_FV_Analysis__c FAFVAnalysis = Database.query(FVQuery);
        CloneFAFVRecord.getFAFVRecord(FAFVAnalysis.Id);
        Test.stopTest();
    }
}