public class servicesInformaticaComRtPrcSfOraRInvoke {
    public Class RMAParameter {
        @InvocableVariable(label='RMAID' required='true')
        public String RMAID;
    }
    
    @InvocableMethod(label='RMAService' description='Call Webservice From in This Class')
    public static  List<String> invokeService(List<RMAParameter> RMAParameters){  
        List<String> errormessages = new List<String>();
        System.debug('Inside invokeMethod');
        
        for( RMAParameter  rma : RMAParameters){System.debug(rma.RMAID);
                                                try{
                                                    errormessages.add(sendRequesttoInformatica(rma.RMAID));
                                                } catch(exception e){
                                                    errormessages.add('Service Exception Occured: '+e);
                                                    break;
                                                }
                                                
                                               }
        
        return errormessages;
        
    }
    public static String  sendRequesttoInformatica(String rMAId){
        servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service  Req = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAIN_Service ();
        servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINResponse_element res;
      //  if(!test.isRunningTest()){
            res  = Req.PRC_SF_ORA_RMA_MAIN(rMAId);
       /* } else {
            res = new servicesInformaticaComRtPrcSfOraR.PRC_SF_ORA_RMA_MAINResponse_element();
            res.OUT_ERR_STATUS ='Sucuss';
            res.OUT_ERR_MSG = '';
        }  */ 
        
        System.debug(res.OUT_ERR_STATUS+'<<<<<>>>>>'+res.OUT_ERR_MSG);
        return res.OUT_ERR_STATUS + res.OUT_ERR_MSG ;
    }    
}