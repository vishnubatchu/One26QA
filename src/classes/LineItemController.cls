public class LineItemController {
    
    @AuraEnabled
    public static List<Loaner_Line__c> getLoanerLineItem(Id recordId){ 
        Id devRecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId();
        Id devReadRecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item Pending Sales Record Type').getRecordTypeId();
        Id devReadOnlyRecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item Read Only').getRecordTypeId();
        List<Loaner_Line__c> lineItemList =[Select id,Name,Loaner__c,Loaner__r.Status_Approval__c,Product__c,Product__r.Name,Product__r.Id,Line_Total__c,Loaner_Price_100_999_column_price__c,Production_Price_ASP__c,Est_Annual_Qty__c,
                                            SOM__c,SAM__c,Generic_Product_Family__c,Line_Status__c,Loaner_Qty__c,RSM__c,VP__c,SVP__c,CPN_Description__c,Other_Description__c,Loaner_Return_Carrier__c,
                                            User_Notes__c,Part_Type_Notes__c,Manual_Return_Due_Date__c,Part_Type__c,Admin_Status__c,Manual_Update__c,Error_Message__c,Integration_Status__c,Initial_Error_Message__c,Order_Line__c,Process_Date__c,Loaner_Ship_From__c,Admin_Extn_Reason__c,Number_of_Extensions__c,Total_Extended_Days__c,
                                            Extend_Line__c,SO_Line_Number__c,Marketing_P_N__c,Loaner_Total__c,recordtypeid,Recordtype.Name,Loaner_Return_Ship_Date__c,Loaner_Return_Tracking_Number__c,RSM__r.name,VP__r.name,SVP__r.name,order_line__r.name 
                                            from Loaner_Line__c where Loaner__c =:recordId and (recordtypeid =:devRecordTypeId OR recordtypeid =:devReadRecordTypeId OR recordtypeid =:devReadOnlyRecordTypeId )]; 
        if(lineItemList.size()>0) {
            return lineItemList;
        }    
        return null;
    }
    
    @AuraEnabled
    public static  Map<String,String> getRecordType(Id recordId){ 
        Map<String,String> lineItemLableValue = new Map<String,String>();
        Loaner_Line__c lc = [select recordtype.name,Product__c,Product__r.name from Loaner_Line__c where id=:recordId];
        lineItemLableValue.put('RecordType',lc.recordtype.name);
        lineItemLableValue.put('ProductName',lc.Product__r.name);
        System.debug('recordtype=='+lineItemLableValue);
        return lineItemLableValue;
    } 
    
    @AuraEnabled
    public static  String getLoanerStatus(Id recordId){ 
        loaner__c lc = [select status_approval__c from loaner__c where id=:recordId];
        return lc.status_approval__c;
    }
    
    @AuraEnabled
    public static Boolean getUserPermission(){ 
        Boolean hasPermission = FeatureManagement.checkPermission('Loaner_Line_Permission');
        system.debug('hasPermission----'+hasPermission);
        return hasPermission;
    }
    
    
    @AuraEnabled
    public static WrapperClass saveLoanerLineItem(List<Loaner_Line__c> ListLineItem, String recordId){
        system.debug('ListLineItem=='+ListLineItem);
        WrapperClass loanerWrapper = new WrapperClass();
        List<String> wssProducts = new List<String>();
        List<String> nonWssProducts = new List<String>();
        List<Id> ProductIds = new List<Id>();
        for(Loaner_Line__c line : ListLineItem){
            //ProductIds.add(line.Product__c);//20200805_ramprakash: Commented to fix the product selection issue
            ProductIds.add(line.Product__c);//20200805_ramprakash: Added to fix the product selection issue
        }
        system.debug('ProductIds'+ProductIds);
        for(Product2 prd : [SELECT Id, BU_Code__c, Product_Family__c 
                            FROM Product2 
                            WHERE Id IN :ProductIds]){
                                if(prd.BU_Code__c == '0040' && 
                                   prd.Product_Family__c != 'WSS-OIG' &&
                                   prd.Product_Family__c != 'WSS-OCM' ){
                                       wssProducts.add(prd.Id); 
                                   }  else {
                                       nonWssProducts.add(prd.Id);
                                   }
                            }
        if(!wssProducts.isEmpty() && !nonWssProducts.isEmpty()){
            loanerWrapper.errorMessage = 'WSS & Non-WSS Items cannot be added on the same Loaner Request.';
            return loanerWrapper;
        }
        system.debug('wssProducts@@' + wssProducts);
         system.debug('Role.oducts@@' + [ SELECT id, RSM_PLM_Finisar__c,Project_Name__c FROM Loaner__c WHERE Id = : recordId]);
        String rsmRole = [SELECT id, RSM_PLM_Finisar__r.UserRole.Name FROM Loaner__c WHERE Id = : recordId].RSM_PLM_Finisar__r.UserRole.Name;
        system.debug('rsmrole@@' + rsmRole);
        if(!rsmRole.contains('WSS') && !wssProducts.isEmpty()){
            loanerWrapper.errorMessage = 'Header RSM should be WSS User';
            return loanerWrapper;
        }
        Id devRecordTypeId = Schema.SObjectType.Loaner_Line__c.getRecordTypeInfosByName().get('Loaner Item').getRecordTypeId();
        List<Loaner_Line__c> insertLineItem = new List<Loaner_Line__c>();
        for(Loaner_Line__c lItem :ListLineItem){
            Loaner_Line__c newlItem = new Loaner_Line__c();
            newlItem=lItem;
            if( newlItem.Loaner__c == null){
                newlItem.Loaner__c = recordId;
                newlItem.RecordTypeId=devRecordTypeId;
                
            }
            if(newlItem.Line_Status__c == null ||newlItem.Line_Status__c == ''){
                newlItem.Line_Status__c ='Draft';
                
            }    
            newlItem.Product__c =lItem.Product__r.Id;//20200805_ramprakash: Added to fix the product selection issue
            newlItem.Product__r = null;
            //newlItem.Product__c = lItem.Product__c; //20200805_ramprakash: Commented to fix the product selection issue
            insertLineItem.add(newlItem);
        }
        if(insertLineItem.size()>0) {
            try{
                upsert insertLineItem;
                loanerWrapper.loanerItemList=insertLineItem;
            }catch(Exception e) {
                String str = e.getMessage();
                String finalString = str.substringAfter('error:');
                loanerWrapper.errorMessage = finalString;
                
            } 
        }
        System.debug('loanerWrapper1===='+loanerWrapper);
        return loanerWrapper;
    }
    
    @AuraEnabled    
    public static String  sendRequesttoInformatica(String loanerid)
    {   
        String callOutError ='';
        //Loaner__c lRec =[select name from Loaner__c where id=:loanerid];
        try{
            servicesInformaticaComRtPrcCaiLoan LoanerRequestInf = new servicesInformaticaComRtPrcCaiLoan();
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_main_Service Loanerservicesend = new  servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_main_Service();
            servicesInformaticaComRtPrcCaiLoan.Prc_cai_loaner_mainResponse_element response =Loanerservicesend.Prc_cai_loaner_main(loanerid); 
            if(response.error_message != null){
                return response.error_message;
            }
            
            String validation ='';
            System.debug('validation before'+validation);
            validation = validateRecords(loanerid);
            System.debug('validation after'+validation);
            if(validation!=''){
                return validation;
            }
            
        }
        catch(Exception e)
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
          system.debug('loanerObj@@@ ' + loanerObj.getSObjects('Loaner_Lines__r'));
          if(loanerObj.getSObjects('Loaner_Lines__r')!=Null){
            for(sobject sobj:loanerObj.getSObjects('Loaner_Lines__r')){
                For(String fieldName :CommonConstants.LoanerLineRequiredFields){
                    system.debug('fieldName====='+fieldName);
                    If(sobj.get(fieldName)==Null){
                        system.debug('sobj.get(fieldName)====='+sobj.get(fieldName));
                        String fieldlabel = CommonConstants.LoanerLineRequiredFieldsLable.get(fieldName);
                        system.debug('fieldlabel====='+fieldlabel);
                        return ' Required Field '+fieldlabel+ ' Must be Filled For Line Item '+sobj.get('Name');
                    } 
                }
            }
        }
        for(String fieldName : CommonConstants.LoanerRequiredFields){
            If(loanerObj.get(fieldName)==Null){
                String LoanerOpportunityType =(String) loanerObj.get('Opportunity_Type__c');
                if(fieldName.equalsIgnoreCase('Opportunity__c') && LoanerOpportunityType.equalsIgnoreCase('New Opportunity'))
                {
                    String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    return ' Required Field '+fieldlabel+ ' Must be Filled As Opportunity Type is ' +loanerObj.get('Opportunity_Type__c');
                }
                else if(!fieldName.equalsIgnoreCase('Opportunity__c'))
                { 
                    String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    return ' Required Field '+fieldlabel+ ' Must be Filled';
                }
            }
        }
      
      
        return '';
    }
    
    @AuraEnabled
    public static String validateRecordsONSaveAndClose(String recordId){
        sobject loanerObj = RecordApprovalDao.getHeaderRecord(recordId);
          
        if(loanerObj.getSObjects('Loaner_Lines__r')!=Null){
            for(sobject sobj:loanerObj.getSObjects('Loaner_Lines__r')){
                For(String fieldName :CommonConstants.LoanerLineRequiredFields){
                    system.debug('fieldName====='+fieldName);
                    If(sobj.get(fieldName)==Null && fieldName !='Loaner_Price_100_999_column_price__c'){
                        system.debug('sobj.get(fieldName)====='+sobj.get(fieldName));
                        String fieldlabel = CommonConstants.LoanerLineRequiredFieldsLable.get(fieldName);
                        system.debug('fieldlabel====='+fieldlabel);
                        return ' Required Field '+fieldlabel+ ' Must be Filled For Line Item '+sobj.get('Name');
                    } 
                }
            }
        }
        for(String fieldName : CommonConstants.LoanerRequiredFields){
            If(loanerObj.get(fieldName)==Null){
                String LoanerOpportunityType =(String) loanerObj.get('Opportunity_Type__c');
                if(fieldName.equalsIgnoreCase('Opportunity__c') && LoanerOpportunityType.equalsIgnoreCase('New Opportunity'))
                {
                    String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    return ' Required Field '+fieldlabel+ ' Must be Filled As Opportunity Type is ' +loanerObj.get('Opportunity_Type__c');
                }
                else if(!fieldName.equalsIgnoreCase('Opportunity__c'))
                { 
                    String fieldlabel = Schema.getGlobalDescribe().get('Loaner__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel();
                    return ' Required Field '+fieldlabel+ ' Must be Filled';
                }
            }
        }
      
        return '';
    }
    public class WrapperClass {
        @AuraEnabled public List<Loaner_Line__c> loanerItemList;
        @AuraEnabled public String errorMessage;
    }
    
    @AuraEnabled
    public static String deleteLoanerLineItem(Loaner_Line__c lonerLine){ 
        system.debug('lonerLine'+lonerLine);
        String messageRec ='';
        try {
            delete lonerLine;
            messageRec ='Record deleted Succesfully';
        }catch (Exception e){
            messageRec = e.getMessage();
        }
        system.debug('messageRec=='+messageRec);
        return messageRec;
    }
}