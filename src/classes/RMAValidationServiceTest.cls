@isTest(seeAllData = false)
private class RMAValidationServiceTest {
    testMethod static void testRMAValidationService(){
        List<RMAValidationService.RMAParameter> params = new List<RMAValidationService.RMAParameter>();
        RMAValidationService.RMAParameter param = new RMAValidationService.RMAParameter();
        param.RMAID = 'Test';
        params.add(param);
        RMAValidationService.invokeService(params);
    }
}