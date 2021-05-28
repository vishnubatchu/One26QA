public class ApexReportData {
    
    public  void getReportData(Id reportId){
        String ConcatOfReturnIds;
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId,true);
        Reports.ReportFilter RF = new Reports.ReportFilter('Id', 'notEqual', ConcatOfReturnIds);
        Reports.ReportMetadata RM = results.getReportMetadata();
        list<Reports.ReportFilter>allfilters = new list<Reports.ReportFilter> {RF};
        allfilters.addAll(RM.getReportFilters());
        RM.setReportFilters(allfilters);
        results = Reports.ReportManager.runReport(reportId, RM,true);
        System.debug(LoggingLevel.INFO,'res: '+results.getFactMap());
    }
}