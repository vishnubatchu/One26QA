public without Sharing class RecordApprovalController {
    
    @AuraEnabled
    public static String sendLineItemEmails(Id recordId) {
        Try {
            String Integration_Error_Msg;
            String validation_Msg;
            sobject headerObject = RecordApprovalDao.getHeaderRecord(recordId);
            system.debug('Label.Enable_and_Disable_validations_on_Loaner_Submit_For_Approval '+Label.Enable_and_Disable_validations_on_Loaner_Submit_For_Approval);
            system.debug('recordId.getSObjectType().getDescribe().getName() '+recordId.getSObjectType().getDescribe().getName());
            // Validations Specific To Loaner Class
            If(recordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Loaner__c')) {
                If(CommonConstants.LoanerRequestRecordtypeId == headerObject.get('recordTypeId') && headerObject.get('Status_Approval__c') == 'Pending Sales Order') {
                    return CommonConstants.pendingSalesorder;
                }
                
                IF(CommonConstants.LoanerRequestRecordtypeId == headerObject.get('recordTypeId')){
                    List<User> UserObj = RecordApprovalDao.getUserVPSVPDetails(New Set<ID>{UserInfo.getUserId()});
                    Boolean Userrole = False;
                    For(String role:Label.Loaner_Aproval_Roles_Allowed.split(',')){
                        If(UserObj.get(0).userrole.name.containsIgnoreCase(role)||UserObj.get(0).isportalenabled){
                            Userrole = True;
                        }
                    }
                    
                    IF(!Userrole){
                        return CommonConstants.invaliduserRole;
                    }}
                If(Label.Enable_and_Disable_validations_on_Loaner_Submit_For_Approval.equalsignorecase('True') && CommonConstants.LoanerRequestRecordtypeId == headerObject.get('recordTypeId')) {
                    String responce = LoanerIntegration_Wsdl.sendRequesttoInformatica(recordId);
                    If (!String.isEmpty(responce) && !responce.equalsIgnoreCase('Validation Successfull')) {
                        If(responce.containsIgnoreCase('Required Field')){
                            return responce;
                        }
                        Else{
                            Integration_Error_Msg = responce;
                        }
                    }
                }
                If(CommonConstants.LoanerExtensiontypeId == headerObject.get('recordTypeId') && headerObject.get('VP_PLD_Finisar__c') != Null) {
                    List<User> userList = RecordApprovalDao.getUserVPSVPDetails(New Set<ID>{(Id)headerObject.get('VP_PLD_Finisar__c')});
                    IF(userList.size()==0){
                        return CommonConstants.vpInactivereturnMessage;
                    }}
                
                If(CommonConstants.LoanerExtensiontypeId == headerObject.get('recordTypeId') && headerObject.get('VP_PLD_Finisar__c') == Null) {
                    return CommonConstants.vpEmptyreturnMessage;
                }
                If(headerObject.get('Loaner_Ship_From_Finisar__c') != Null && (headerObject.get('Loaner_Ship_From_Finisar__c') == 'Returned Loaner Stock' || headerObject.get('Loaner_Ship_From_Finisar__c') == 'Other')) {
                    IF(CommonConstants.LoanerExtensiontypeId != headerObject.get('recordTypeId') && 
                       headerObject.get('Verified_with_Betty_Dea__c') == False) {
                           return CommonConstants.VerifyWithBettyDeareturnMessage;
                       }
                }
                
                If(CommonConstants.LoanerRequestRecordtypeId != headerObject.get('recordTypeId')  && CommonConstants.LoanerExtensiontypeId != headerObject.get('recordTypeId')) {
                    return CommonConstants.recordTypeError;
                }
                
            }
            If(Label.Enable_and_Disable_validations_on_Loaner_Submit_For_Approval.equalsignorecase('True') && 
               recordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Quote')) {
                   String errMessage = checkDuplicateLineswithSameProd(recordId);
                   if(String.isBlank(errMessage)){
                       String validateRule = QuoteLineItemController.validateRulesRecords(recordId);
                       String responce = QuoteLineItemController.sendRequesttoInformatica(recordId);
                       If (!String.isEmpty(responce) && !responce.equalsIgnoreCase('Validation Successfull')
                           &&!String.isEmpty(validateRule) && !validateRule.equals('')) {
                               return responce+'\r\n'+validateRule;
                           }
                       If(!String.isEmpty(responce) && !responce.equalsIgnoreCase('Validation Successfull')) {
                           return responce;
                       }
                       If (!String.isEmpty(validateRule) && !validateRule.equals('')) {
                           return validateRule;
                       } 
                   } else {
                       return errMessage;
                   }
               }
            
            // Updating SVP,VP,RSM fields at child level for Loaner    
            String valResult = updateChildRecords(recordId, headerObject);
            
            // Common Approval Process for Quote,Loaner,Loaner Extension    
            Set < id > ApprovalEmailToIdSet = New Set < id > ();
            IF(valResult.equalsIgnoreCase('Success')) {
                Map < id, sobject > sobjectMap = New Map < id, Sobject > (RecordApprovalDao.getLineItemsRecords(recordId));
                System.debug('sobjectMap in controller' + sobjectMap);
                if (sobjectMap.values().size() > 0) {
                    List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                    for (sobject recordObj: sobjectMap.values()) {
                        IF(Approval.isLocked((ID) recordObj.get('id'))) {
                            Approval.unlock((ID) recordObj.get('id'));
                        }
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId((ID) recordObj.get('id'));
                        requests.add(req1);
                        // Approval.ProcessResult result = Approval.process(req1);
                    }
                    Approval.process(requests);
                    List < ProcessInstanceWorkitem > pItemList = RecordApprovalDao.getProcessItemWorkList(sobjectMap.keyset());
                    if (pItemList.size() > 0) {
                        for (ProcessInstanceWorkitem piwObj: pItemList) {
                            ApprovalEmailToIdSet.add(piwObj.actorid);
                        }
                        System.debug('ApprovalEmailToIdSet' + ApprovalEmailToIdSet);
                        Set < id > delegatedApproverSet = RecordApprovalDao.getDelegatedApprovedID(ApprovalEmailToIdSet);
                        ApprovalEmailToIdSet.addall(delegatedApproverSet);
                        RecordsLineItemApprovalHelper.sendEmail(ApprovalEmailToIdSet, recordId);
                        IF(recordId.getSObjectType().getDescribe().getName().equalsIgnoreCase('Loaner__c')){
                            updateDateReminderDateonLoaner(recordId);
                        }
                        If(CommonConstants.LoanerRequestRecordtypeId == headerObject.get('recordTypeId')){
                            unlockLoanerLineRecords(recordId);
                        }
                    }
                    valResult = 'processSucess';
                    System.debug('Final Integration_Error_Msg'+Integration_Error_Msg);
                    IF(!String.isEmpty(Integration_Error_Msg)){
                        return 'Line Items are sent for Approval with Error :'+Integration_Error_Msg;
                    }
                    return valResult;
                } else {
                    valResult = 'NoLineItem';
                    return valResult;
                }
            }
            else {
                return valResult;
            }
        }
        Catch(Exception e) {
            System.debug('Exception Email' + e.getMessage());
            return e.getMessage();
        }
    }
    
    public static String updateChildRecords(Id recordId, sobject sobj) {
        String validation = 'Success';
        if (sobj.getSObjectType().getDescribe().getName().equalsIgnoreCase('Loaner__c')) {
            list < sobject > sobjectsToUpdate = New List < sobject > ();
            if (sobj.getSObjects('Loaner_Lines__r') != NULL) {
                for (sobject sobjLineItems: sobj.getSObjects('Loaner_Lines__r')) {
                    if(CommonConstants.LoanerExtensionRecordtypeId == sobjLineItems.get('recordTypeId') &&
                       sobjLineItems.get('Extend_Date__c') == null){
                           validation = 'Extend to Date should be provided for '+sobjLineItems.get('Name');
                           return validation;
                       }
                    IF(sobj.get('RSM_PLM_Approval__c') != Null) {
                        sobjLineItems.put('RSM__c', sobj.get('RSM_PLM_Approval__c'));
                    }
                    IF(sobj.get('VP_PLD_Finisar__c') != NULL) {
                        sobjLineItems.put('VP__c', sobj.get('VP_PLD_Finisar__c'));
                    }
                    IF(sobj.get('SVP_Id_Created_By__c') != NULL) {
                        sobjLineItems.put('SVP__c', sobj.get('SVP__c'));
                    }
                    sobjectsToUpdate.add(sobjLineItems);
                }
                
                if (sobjectsToUpdate.size() > 0) {
                    update sobjectsToUpdate;
                }
            }
        }
        return validation;
    }
    
    @future
    public static void updateDateReminderDateonLoaner(Id RecordId){
        sobject headerObject = RecordApprovalDao.getHeaderRecord(recordId);
        System.debug('headerObject'+headerObject);
        headerObject.put('Date_Reminder_DateTime__c', System.now());
        System.debug('headerObject'+headerObject);
        update headerObject;
    }
    
    @future
    public static void unlockLoanerLineRecords(Id RecordId){
        Map < id, sobject > sobjectMap = New Map < id, Sobject > (RecordApprovalDao.getLineItemsRecords(recordId));
        If(sobjectMap.size()>0){
            for(id Id:sobjectMap.keyset()){
                IF(Approval.isLocked(Id)) {
                    Approval.unlock(Id);
                }
            }
        }
    }
    /**
Method Name : checkDuplicateLineswithSameProd
Input Parameters : String recordId- quote Id
return Parameter : String - error message
Lastupdated: Surendar - 15-10-2019
**/
    public static String checkDuplicateLineswithSameProd(String recordId){
        String errorMessage ='';
        Map<String, List<String>> prodLineMap = new Map<String, List<String>>();
        for(Quote_Item__c qtline : [SELECT Id, Name, Product__c, Product__r.Name
                                    FROM Quote_Item__c
                                    WHERE Quote__c = :recordId]){
                                        if(prodLineMap.containsKey(qtline.Product__r.name)){
                                            prodLineMap.get(qtline.Product__r.Name).add(qtline.Name);
                                        } else {
                                            prodLineMap.put(qtline.Product__r.Name, new List<String>{qtline.Name});
                                        }
                                    }
        for(String prdId :prodLineMap.keySet()){
            if(prodLineMap.get(prdId).size() >1){
                if(string.isBlank(errorMessage)){
                    errorMessage = 'Record Can not be submitted for Approval<br/>Duplicate lines found with Item '+prdId + ' for Lines :';
                } else {
                    errorMessage = errorMessage+'<br/> Duplicate lines found with Item '+prdId + ' for Lines : ';
                }
                for(String qlne : prodLineMap.get(prdId)){
                    errorMessage = errorMessage+qlne+',';
                }
                errorMessage = errorMessage.substringBeforeLast(',')+';';
            }
        }
        return errorMessage;
    }
}