public class QuoteLineItemController {
    
    public static Boolean updateQuote = false;
    @AuraEnabled
    public static List<Quote_Item__c> getQuoteLineItem(Id recordId){ 
        List<Quote_Item__c> lineItemList =[Select id,Name,Quote__c,Product__c,Disti_Margin__c,Quantity__c,Target_Price__c,Line_Status__c,Competitor_Price__c,Competitor_Info__c,Marketing_PN__c,
                                           Agreed_Upon_Share__c,Std_List_Price__c,Product__r.Name,Product__r.Id,Std_Disti_Cost__c,Disti_Resale_Price__c,RSM_Approver__c,RSM_Min__c,PLM_Approver__c,REP_Min__c
                                           from Quote_Item__c where Quote__c =:recordId ORDER BY Name ASC LIMIT 200  ]; 
        if(lineItemList.size()>0) {
            return  lineItemList;
        }  
        
        return null;
    }
    
    //updated by Surendar on 15-10-2019 to add error messgae for duplicate lines
    @AuraEnabled
    public static WrapperClass saveQuoteLineItem(List<Quote_Item__c> ListLineItem,Id recordId){
        WrapperClass quoteWrapper = new WrapperClass();
        List<Quote_Item__c> inserLineItem = new List<Quote_Item__c>();  
        Map<String, List<Quote_Item__c>> prodLineMap = new Map<String, List<Quote_Item__c>>();
        Set<String> duplicateItems = new Set<String>();
        //Added for WSS 
        List<Id> products = new List<Id>();
        for(Quote_Item__c lItem :ListLineItem){
            products.add(lItem.Product__r.Id);
        }
        Set<String> wssBuCodes = new Set<String>();
        Set<String> nonWssBuCodes = new Set<String>();
        String errMessage ;
        system.debug('errMessage '+errMessage);
        system.debug('errMessage '+products);
        for(Product2 prd: [SELECT Id, BU_Code__c, BUDescription__c, Product_Family__c
                           FROM Product2 
                           WHERE Id IN :products]){
                               if(prd.BUDescription__c == 'FNSR WSS' &&
                                  prd.Product_Family__c != 'WSS-OIG' &&
                                  prd.Product_Family__c != 'WSS-OCM'){
                                      // && prd.BUDescription__c == 'FNSR WSS'
                                      wssBuCodes.add(prd.BUDescription__c);
                                  } else {
                                      nonWssBuCodes.add(prd.BUDescription__c);
                                  }
                               
                           }
        if(!nonWssBuCodes.isEmpty() && !wssBuCodes.isEmpty()){
            quoteWrapper.errorMessage = 'WSS & Non-WSS Items cannot be added on the same Quote.';
            return quoteWrapper;
        }
        //String rsmRole = [SELECT id, PrimarySalesperson__r.UserRole.Name FROM Quote WHERE Id = : recordId].PrimarySalesperson__r.UserRole.Name;
        Quote qteRec = [SELECT id, PrimarySalesperson__c, PrimarySalesperson__r.UserRole.Name FROM Quote WHERE Id = : recordId];
        if(qteRec.PrimarySalesperson__c != null){
            String rsmRole = qteRec.PrimarySalesperson__r.UserRole.Name;
            if(!rsmRole.contains('WSS') && !wssBuCodes.isEmpty()){
                quoteWrapper.errorMessage = 'Quote Primary sales person should be WSS User';
                return quoteWrapper;
            }
            
        } else {
            quoteWrapper.errorMessage = 'Quote Primary sales person should be provided';
            return quoteWrapper;
        }
        //system.debug('rsmRole'+rsmRole);
        //end
        for(Quote_Item__c lItem :ListLineItem){
            if(!prodLineMap.containsKey(lItem.Product__r.Name)){
                Quote_Item__c newlItem = new Quote_Item__c();
                newlItem = lItem;
                if( newlItem.Quote__c == null){
                    newlItem.Quote__c = recordId;
                }
                if(newlItem.Line_Status__c == null ||newlItem.Line_Status__c == ''){
                    newlItem.Line_Status__c ='Draft';
                }
                newlItem.Product__c = lItem.Product__r.Id;
                prodLineMap.put(lItem.Product__r.Name, New List<Quote_Item__c>{newlItem});
                inserLineItem.add(newlItem);
            } else {
                prodLineMap.get(lItem.Product__r.Name).add(lItem);
                duplicateItems.add(lItem.Product__r.Name);
            }
        }
        if(duplicateItems != null && !duplicateItems.isEmpty()){
            String errorMessage;
            for(String item : duplicateItems){
                if(string.isBlank(errorMessage)){
                    errorMessage = 'Duplicate lines found with Item '+item ;
                } else {
                    errorMessage = errorMessage +','+item ;
                }
            }
            quoteWrapper.errorMessage= errorMessage+';';
            return quoteWrapper;
        }
        if(inserLineItem.size()>0) {
            try{
                updateQuote = true;
                upsert inserLineItem;
                System.debug('testt=='+JSON.serialize(inserLineItem));
                // Calling method getPLMApprover to update PLM records on Insertion
                //getPLMApprover(inserLineItem);
                quoteWrapper.quoteItemList=inserLineItem;
            }catch(Exception e) {
                system.debug('Exception'+e.getMessage());
                String str = e.getMessage();
                String finalString = str.substringAfter('error:');
                quoteWrapper.errorMessage=finalString;
                return quoteWrapper;
            }                    
            
        }
        return quoteWrapper;
    }
    
    /* Method for RealTime Integration Call . validateRecords is called first to check for Empty required field first. 
All error messages are concatenated and return in end. */
    @AuraEnabled    
    public static String  sendRequesttoInformatica(String Quoteid)
    {
        String validation = validateRecords(Quoteid);
        if(validation!=''){
            return validation.removeEnd('<br/>');
        }
        
        String callOutError ='';
        Quote lRec =[select QuoteNumber from Quote where id=:Quoteid];
        try{
            servicesInformaticaComRtPrcCaiQuot QuoteRequestInf = new servicesInformaticaComRtPrcCaiQuot();
            servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_main_Service Quoteservicesend = new  servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_main_Service();
            system.debug('test '+lRec);
            servicesInformaticaComRtPrcCaiQuot.prc_cai_quote_mainResponse_element response =Quoteservicesend.prc_cai_quote_main(Quoteid);
            system.debug('test '+lRec);
            List<Quote_Item__c> newQuoteList =[Select id,Initial_Error_Message__c,Name from Quote_Item__c where Quote__c =:Quoteid];
            if(newQuoteList.size()>0) {
                Boolean isInitialErrorPresent = False;
                String errromsg = '';
                For(Quote_Item__c quoteLineObj:newQuoteList){
                    if(quoteLineObj.Initial_Error_Message__c != null) {
                        System.debug('quoteLineObj.Initial_Error_Message__c'+quoteLineObj.Initial_Error_Message__c);
                        isInitialErrorPresent = True;
                        errromsg = errromsg+quoteLineObj.Initial_Error_Message__c +' in Line Item # '+ quoteLineObj.Name + '.<br/>'; 
                        System.debug('errromsg'+errromsg);
                    }
                }
                IF(isInitialErrorPresent && validation!=''){
                    return errromsg.removeEnd('<br/>')+validation;
                }
                IF(isInitialErrorPresent && validation==''){
                    return errromsg.removeEnd('<br/>');
                }
            }
        }catch(Exception e)
        {
            System.debug('errprmessage=='+e.getMessage());
            callOutError = e.getMessage();
        }
        if(callOutError != null || callOutError !=''){
            return callOutError;
        }
        return '';
    }
    
    @AuraEnabled
    public static String validateRecords(String recordId){
        
        sobject loanerObj = RecordApprovalDao.getHeaderRecord(recordId);
        for(String fieldName : CommonConstants.QuoteRequiredFields){
            If(loanerObj.get(fieldName)==Null){
                String fieldlabel = CommonConstants.QuoteRequiredFieldsLable.get(fieldName);
            }
        }
        if(loanerObj.getSObjects('Quote_Items__r')!=Null){
            Boolean validationError = False;
            String errromsg = '';
            for(sobject sobj:loanerObj.getSObjects('Quote_Items__r')){
                For(String fieldName :CommonConstants.QuoteLineRequiredFields){
                    If(sobj.get(fieldName)==Null){
                        validationError = True;
                        String fieldlabel = CommonConstants.QuoteLineRequiredFieldsLabel.get(fieldName);
                        errromsg=errromsg + ' Required Field '+fieldlabel+ ' Must be Filled For Line Item '+sobj.get('Name')+'.<br/>';
                    } 
                }
            }
            IF(validationError){
                return errromsg;
            }
        }
        return '';
    }
    
    // Validate Rule is called later as some fields are updated from Integration. So these rules should always be evaluated
    // after Integration call.
    
    @AuraEnabled
    public static String validateRulesRecords(String recordId){
        sobject loanerObj = RecordApprovalDao.getHeaderRecord(recordId);
        String ErrorMessage ='';
        //Added by Surendar on 17th Oct 2019
        if(loanerObj.get('Type_of_Pricing__c') != null && loanerObj.get('PrimarySalesperson__c') != null){
            if(loanerObj.get('Type_of_Pricing__c') == 'Blanket Price Agreement' && 
               (loanerObj.get('Price_List__c') == 'FNSR REP PRICE LIST' || 
                loanerObj.get('Price_List__c') == 'FNSR RSM PRICE LIST') ) {
                    ErrorMessage = ErrorMessage+  ' Select a valid customer-specific price list for Blanket Price Agreement Quote';
                } else {
                    if(loanerObj.getSObjects('Quote_Items__r')!=Null){
                        for(sobject sobj:loanerObj.getSObjects('Quote_Items__r')){
                            Decimal targetPrice = (Decimal)sobj.get('Target_Price__c');
                            Decimal distPrice = (Decimal)sobj.get('Std_Disti_Cost__c');
                            Decimal stdlistprice =(Decimal)sobj.get('Std_List_Price__c');
                            //  if(loanerObj.get('Type_of_Pricing__c') != null && loanerObj.get('PrimarySalesperson__c') != null){
                            if(loanerObj.get('Type_of_Pricing__c') =='Dist Quote' && distPrice == null) {
                                ErrorMessage = ErrorMessage+ 'Line# '+sobj.get('Name') +' Part Number '+sobj.get('Marketing_PN__c')+ ' is not eligible for Ship and Debit. No Disti Cost is set up. <br/>';
                            }    
                            if(loanerObj.get('Type_of_Pricing__c') =='Dist Quote' && targetPrice >= distPrice ) {
                                ErrorMessage = ErrorMessage+ 'Line# '+sobj.get('Name') + ' Target Price should be less than Disti Cost for Disti Quotes. <br/>';
                            }
                            if(	loanerObj.get('Type_of_Pricing__c') =='Dist Quote' && sobj.get('Disti_Resale_Price__c') == null ) {
                                ErrorMessage = ErrorMessage+  'For Distributor quotes Dist Resale price is required on Line Item '+sobj.get('Name')+'.<br/>';
                            }
                            if(	loanerObj.get('Type_of_Pricing__c') =='Blanket Price Agreement' && ((targetPrice == stdlistprice) )) {
                                ErrorMessage = ErrorMessage+  'There is a line with Quote Name '+ loanerObj.get('Name')+' - Line# '+sobj.get('Name')+' with Target Price is equal to Std List Price, Please check before Continuing. <br/>';
                            }
                            if(	loanerObj.get('Type_of_Pricing__c') =='Fixed - One Time Order' && ((targetPrice == stdlistprice) )) {
                                ErrorMessage = ErrorMessage+  'There is a line with Quote Name '+ loanerObj.get('Name')+' - Line# '+sobj.get('Name')+' with Target Price is equal to Std List Price, Please check before Continuing. <br/>';
                            }
                        }
                    } else {
                        ErrorMessage = ErrorMessage+  'NoLineItem';
                    }
                }
            
        }else{
            ErrorMessage = ErrorMessage+  'Type of pricing & Primary sales person should be Provided. <br/>';
        }
        return ErrorMessage;
    }
    public class WrapperClass {
        @AuraEnabled public List<Quote_Item__c> quoteItemList;
        @AuraEnabled public String errorMessage;
    }
    @AuraEnabled
    public static String deleteLoanerLineItem(Quote_Item__c quoteLine){ 
        String messageRec ='';
        try {
            delete quoteLine;
            messageRec ='Record deleted Succesfully';
        }catch (Exception e){
            messageRec = e.getMessage();
        }
        system.debug('messageRec=='+messageRec);
        return messageRec;
    }
    
    // This is used to update PLm at QuoteLine Item Level. This method is called for both insert and update of product
    public static void getPLMApprover(List<Quote_Item__c> quoteItemList) {
        String ApproverUsername ='';
        String Approver3MUsername ='';
        Map<String,String> userNameIdMap = new Map<String,String>();
        Map<String,List<PLM_Approval_Matrix__mdt>>  productPLMApprover = new  Map<String,List<PLM_Approval_Matrix__mdt>>();
        Map<String,List<String>>  productToUserName = new   Map<String,List<String>>();
        Map<Id,Id> quoteToProductMap = new  Map<Id,Id>();
        Map<Id,Quote_Item__c> newQuoteMap = New Map<Id,Quote_Item__c>();
        Set<Id> productIdSet = new Set<Id>();  
        
        List<PLM_Approval_Matrix__mdt> PLMList = [select id,Product_Group_Segment1__c,Family_Segment2__c,FamilySegmentNotOperator__c,Configuration_Segment4__c,ConfigurationNotOperator__c,FormFactorNotOperator__c,
                                                  Market_Application_Segment5__c,Form_Factor_Segment3__c,MarketAppNotOperator__c,LaserNotOperator__c,Laser_Segment6__c,Detector_Segment7__c,DetectorNotOperator__c,Approver__c,Upper_Approval_Level__c
                                                  from PLM_Approval_Matrix__mdt ];
        for(PLM_Approval_Matrix__mdt plmRec :PLMList) {
            plmRec.Product_Group_Segment1__c = plmRec.Product_Group_Segment1__c == null?'Blank':plmRec.Product_Group_Segment1__c;
            if(!productPLMApprover.containsKey(plmRec.Product_Group_Segment1__c)){
                productPLMApprover.put(plmRec.Product_Group_Segment1__c,new List<PLM_Approval_Matrix__mdt>{plmRec});
            }
            else {
                productPLMApprover.get(plmRec.Product_Group_Segment1__c).add(plmRec);
            }
        }
        
        List<User> ulist =[select id,name from User where isActive =: true];
        for(User uRec : ulist) {
            userNameIdMap.put(uRec.Name, uRec.Id);
        }
        
        for(Quote_Item__c qRec:quoteItemList) {
            quoteToProductMap.put(qRec.id,qRec.product__c);
            productIdSet.add(qRec.product__c);
        }
        List<Quote_Item__c> newQuoteItemlIst = [Select id,Name,Quote__c,Product__c,Product__r.Name,Product__r.Product_Group__c,Product__r.Product_Family_Text__c,Product__r.Form_Factor__c,Product__r.Product_Config__c,Product__r.Mkt_Application__c,Product__r.Laser__c,Product__r.Detector__c,PLM_Approver__c,Approver_3M__c 
                                                from Quote_Item__c where Id In :quoteItemList];
        
        
        
        List<PLM_Approval_Matrix__mdt> getAllPLMBYGroup = new List<PLM_Approval_Matrix__mdt>();    
        for(Quote_Item__c prodrec :newQuoteItemlIst) {
            System.debug('prodrec'+prodrec);
            list<String> userNameList = new list<String>();
            getAllPLMBYGroup.clear();
            if(prodrec.Product__r.Product_Group__c != null){
                getAllPLMBYGroup.addall(productPLMApprover.get(prodrec.Product__r.Product_Group__c));
                
                //May22 Changes addition of all blank Records into Map also.So they could be taken for calculation 
                
                getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
            }
            else {
                getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
            }
            
            if(getAllPLMBYGroup.size()>0) {
                for(PLM_Approval_Matrix__mdt plmRec: getAllPLMBYGroup) {
                    if(plmRec.Family_Segment2__c != null && plmRec.Family_Segment2__c != '' && (String.isNotBlank(prodrec.Product__r.Product_Family_Text__c) && plmRec.Family_Segment2__c.contains(prodrec.Product__r.Product_Family_Text__c)) && plmRec.FamilySegmentNotOperator__c == true ){
                        continue;
                        
                    }else if (plmRec.Family_Segment2__c == null || (String.isNotBlank(prodrec.Product__r.Product_Family_Text__c) && plmRec.Family_Segment2__c.contains(prodrec.Product__r.Product_Family_Text__c))  || plmRec.FamilySegmentNotOperator__c == true) {
                        if(plmRec.Form_Factor_Segment3__c != null && (String.isNotBlank(prodrec.Product__r.Form_Factor__c) && plmRec.Form_Factor_Segment3__c.contains(prodrec.Product__r.Form_Factor__c)) && plmRec.FormFactorNotOperator__c == true){
                            continue;
                        } else if (plmRec.Form_Factor_Segment3__c == null || (String.isNotBlank(prodrec.Product__r.Form_Factor__c) && plmRec.Form_Factor_Segment3__c.contains(prodrec.Product__r.Form_Factor__c)) ||  plmRec.FormFactorNotOperator__c == true) { 
                            if(plmRec.Configuration_Segment4__c != null && (String.isNotBlank(prodrec.Product__r.Product_Config__c) && plmRec.Configuration_Segment4__c.contains(prodrec.Product__r.Product_Config__c)) && plmRec.ConfigurationNotOperator__c == true){
                                continue;
                            } else if (plmRec.Configuration_Segment4__c == null || (String.isNotBlank(prodrec.Product__r.Product_Config__c) && plmRec.Configuration_Segment4__c.contains(prodrec.Product__r.Product_Config__c)) ||  plmRec.ConfigurationNotOperator__c == true) {
                                if(plmRec.Market_Application_Segment5__c !=null && (String.isNotBlank(prodrec.Product__r.Mkt_Application__c) && plmRec.Market_Application_Segment5__c.contains(prodrec.Product__r.Mkt_Application__c)) && plmRec.MarketAppNotOperator__c == true){
                                    continue;
                                }else if (plmRec.Market_Application_Segment5__c == null || (String.isNotBlank(prodrec.Product__r.Mkt_Application__c) && plmRec.Market_Application_Segment5__c.contains(prodrec.Product__r.Mkt_Application__c)) ||  plmRec.MarketAppNotOperator__c == true) {
                                    if(plmRec.Laser_Segment6__c != null && (String.isNotBlank(prodrec.Product__r.Laser__c) && plmRec.Laser_Segment6__c.contains(prodrec.Product__r.Laser__c)) && plmRec.LaserNotOperator__c == true){
                                        continue;
                                    } else if (plmRec.Laser_Segment6__c == null || (String.isNotBlank(prodrec.Product__r.Laser__c) && plmRec.Laser_Segment6__c.contains(prodrec.Product__r.Laser__c)) ||  plmRec.LaserNotOperator__c == true) { 
                                        if(plmRec.Detector_Segment7__c !=null && (String.isNotBlank(prodrec.Product__r.Detector__c) && plmRec.Detector_Segment7__c.contains(prodrec.Product__r.Detector__c)) && plmRec.DetectorNotOperator__c == true){
                                            continue;
                                        } else if(plmRec.Detector_Segment7__c == null || (String.isNotBlank(prodrec.Product__r.Detector__c) && plmRec.Detector_Segment7__c.contains(prodrec.Product__r.Detector__c)) ||  plmRec.DetectorNotOperator__c == true) {
                                            prodrec.PLM_Approver__c =userNameIdMap.get(plmRec.Approver__c);
                                            prodrec.Approver_3M__c=userNameIdMap.get(plmRec.Upper_Approval_Level__c);
                                            newQuoteMap.put(prodrec.id,prodrec);
                                        }
                                    } else  {
                                        continue;
                                    }
                                    
                                } else {
                                    continue;
                                }
                            }else {
                                continue;
                            }
                            
                        } else {
                            continue;
                        }
                        
                    }
                    else {
                        continue;
                    }
                    
                }
                
                //May22 Changes defaulting to betty when no Plm is there.Label contains betty's name       
                IF(!newQuoteMap.containskey(prodrec.Id) && userNameIdMap.containskey(Label.Default_PLM_User_Email)){
                    prodrec.PLM_Approver__c =userNameIdMap.get(Label.Default_PLM_User_Email);
                    newQuoteMap.put(prodrec.id,prodrec);
                }
            }
        }
        
        if(newQuoteMap.size()>0){
            update newQuoteMap.values();
        }
        
    }
    @InvocableMethod
    public static void updatePLM(List<id> recList){
        
        if(!updateQuote) {
            List<Quote_Item__c> newQuoteItemlIst = [Select id,Name,Quote__c,Product__c,Product__r.Name,Product__r.Product_Group__c,Product__r.Product_Family_Text__c,Product__r.Form_Factor__c,Product__r.Product_Config__c,Product__r.Mkt_Application__c,Product__r.Laser__c,Product__r.Detector__c,PLM_Approver__c,Approver_3M__c 
                                                    from Quote_Item__c where Id In :recList];
            getPLMApprover(newQuoteItemlIst); 
        }
        
    } 
}