@isTest(seeAllData= false)
private class servicesInformaticaComRtPrcSfOraRTest {
    testMethod static void servicesInformaticaComRtPrcSfOraRtest(){
        servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINResponse_element res = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINResponse_element();
        servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINRequest_element req = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINRequest_element();
        servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service main = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service();
        //main.PRC_SF_ORA_RMA_MAIN('test');
    }
    testMethod static void testRInvoke(){
        servicesInformaticaComRtPrcSfOraRInvoke.RMAParameter param = new servicesInformaticaComRtPrcSfOraRInvoke.RMAParameter();
        List<servicesInformaticaComRtPrcSfOraRInvoke.RMAParameter> RMAParameters = new List<servicesInformaticaComRtPrcSfOraRInvoke.RMAParameter>();
        param.RMAID = 'Test';
        RMAParameters.add(param);
        servicesInformaticaComRtPrcSfOraRInvoke.invokeService(RMAParameters);
        
    }
}