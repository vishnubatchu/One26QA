@isTest
global class LoanerIntegrationMockResponse Implements WebServiceMock{

    global void doInvoke(Object stub,Object request, Map<String, Object> response,String endpoint,String requestName,String responseName,String responseType,String soapAction,String respNS)
    {
        servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element errorresponse_x  = new  servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element();
        errorresponse_x.status ='ERROR';
        errorresponse_x.error_message ='Price list not available for loaner request';
        response.put('errorresponse_x', errorresponse_x);
        
        servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element successresp_x  = new  servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element();
        successresp_x.status ='SUCCESS';
        response.put('SUCCESS', successresp_x);
        
    }
}