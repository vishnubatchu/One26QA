public class RMAValidationService {
    public Class RMAParameter {
        @InvocableVariable(label='RMAID' required='true')
        public String RMAID;
    }
    
    @InvocableMethod(label='RMAService' description='Call Webservice From in This Class')
    public static  List<String> invokeService(List<RMAParameter> RMAParameters){  
        List<String> errormessages = new List<String>();
        
        System.debug('************invokeservice******* ');
        for( RMAParameter  rma : RMAParameters){
               errormessages.add(sendRequesttoInformatica(rma.RMAID));
                      
        }
        
        return errormessages;
        
    }
    public static String  sendRequesttoInformatica(String rMAId){
        try{
            servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service  Req = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service ();
            servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINResponse_element res  = Req.PRC_SF_ORA_RMA_MAIN(rMAId);
            System.debug(res.OUT_ERR_STATUS+'<<<<<>>>>>'+res.OUT_ERR_MSG);
            return res.OUT_ERR_STATUS + res.OUT_ERR_MSG ;
        }
        catch(Exception e)
        {
            System.debug(' Message  '+e.getMessage()+' Line Number' +e.getLineNumber() );
            return e.getMessage();
        }
    }    
}