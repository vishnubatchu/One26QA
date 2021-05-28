public with sharing class FileUploadController {
    
    
    @AuraEnabled
    public static String  parseCSV(String contents,Boolean skipHeaders,string caseID) 
    {
        
        List<String> errorMsgList = new List<String>();
        id uId = userinfo.getuserid() ;
        UserRecordAccess aurc =   [SELECT RecordId, HasReadAccess,HasAllAccess,HasEditAccess, HasTransferAccess, MaxAccessLevel
                                   FROM UserRecordAccess
                                   WHERE UserId =: uId
                                   AND RecordId =: caseID];
        boolean Access = aurc.HasAllAccess;
        if(Access)
        {
             List<List<String>> allFields = new List<List<String>>();
            contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            contents = contents.replaceAll('""','DBLQT');
            List<String> lines = new List<String>();
            try {
                lines = contents.split('\n');
                Integer num = 0;
                for(String line : lines) {
                    System.debug('  line'+line);
                    if (line.replaceAll(',','').trim().length() == 0) break;
                    List<String> fields = line.split(',');  
                    List<String> cleanFields = new List<String>();
                    String compositeField;
                    Boolean makeCompositeField = false;
                    for(String field : fields) {
                        system.debug('field'+field);
                        if (field.startsWith('"') && field.endsWith('"')) {
                            cleanFields.add(field.replaceAll('DBLQT','"'));
                        } else if (field.startsWith('"')) {
                            makeCompositeField = true;
                            compositeField = field;
                        } else if (field.endsWith('"')) {
                            compositeField += ',' + field;
                            cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                            makeCompositeField = false;
                        } else if (makeCompositeField) {
                            compositeField +=  ',' + field;
                        } else {
                            cleanFields.add(field.replaceAll('DBLQT','"'));
                        }
                    }
                    system.debug('cleanFields ' + cleanFields);
                    allFields.add(cleanFields);
                    
                }             
                if (skipHeaders) allFields.remove(0);
                system.debug('allFields after removing header ' + allFields);
                list<RMA_Request_Line__c> upsertRMALines = new list<RMA_Request_Line__c>();  
              case RMAHeader = [select id, CaseNumber from case where id =:  caseID];
                for(list<string> sn : allFields){
                  
                    RMA_Request_Line__c newRMARequestLine = new RMA_Request_Line__c(); 
  		           if(sn[0] == '')
                    {
                         String serialNoMsg  ='Serial Number shouldn’t leave as blank at Row '+ (allFields.indexOf(sn)+2) +'\n';
                        errorMsgList.add(serialNoMsg);
                    }
                    else if(sn[0] != '')
                    {
                           newRMARequestLine.Name = sn[0];
					}
                    
                    if(sn[1] == '')
                    {
                         String DescripMsg  ='Description shouldn’t leave as blank at Row '+ (allFields.indexOf(sn)+2) +'\n';
                        errorMsgList.add(DescripMsg);
                    }
                    else if(sn[1] != '')
                    {
                         newRMARequestLine.Brief_description_of_the_failure__c  = sn[1];
					}
                    if(sn[2] != '' && ValidatepicklistValues('Return_Reason__c',sn[2]))
                    {
                        newRMARequestLine.Return_Reason__c = sn[2];
                    }
                    else
                    {
                        
                        String ReturnreasonMsg  ='Wrong Return Reason at Row  '+ (allFields.indexOf(sn)+2) +' \n ' ;
                        errorMsgList.add(ReturnreasonMsg);
                    }
                    if(sn[3] != '' && ValidatepicklistValues('PO_Price__c',sn[3]))
                    {
                        newRMARequestLine.PO_Price__c = sn[3];
                    }
                    else
                    {
                        
                        String PoPriceMsg  = 'Wrong PO Price Type at Row  '+(allFields.indexOf(sn)+2) +'\n';
                        errorMsgList.add(PoPriceMsg);
                    }
					if( newRMARequestLine.Name != null)
                    {
                        newRMARequestLine.Special_Instructions__c = sn[4];
                        newRMARequestLine.RMA_Request__c = RMAHeader.Id;
                        newRMARequestLine.SerialNumber__c = RMAHeader.CaseNumber +  newRMARequestLine.Name;
                        upsertRMALines.add(newRMARequestLine);
                    }
                }
                if(errorMsgList.size()==0 && upsertRMALines.size()>0)
                {
                 /*   case cs = [select id, CaseNumber from case where id =:  caseID];
                    for(RMRequestWrapper sn : upsertRMALines){
                        
                        RMA_Request_Line__c rn = new RMA_Request_Line__c(); 
                        rn.Name     = sn.sNo;
                        rn.Brief_description_of_the_failure__c     = sn.Description;
                        rn.Return_Reason__c     = sn.ReturnReason;
                        rn.PO_Price__c     = sn.POPriceType;
                        rn.Special_Instructions__c     = sn.SpecialInstructions;
                        rn.RMA_Request__c = caseID;
                        rn.SerialNumber__c = cs.CaseNumber +  sn.sNo ;       
                        rmList.add(rn);
                     
                    }*/
                    Schema.SObjectField SerialNumberField = RMA_Request_Line__c.Fields.SerialNumber__c;
                    Database.UpsertResult[] ErrorFile = Database.upsert(upsertRMALines,SerialNumberField, true);
                    System.debug('**********Records not inserted'+ErrorFile);
                    return 'SUCCESS';
                }
                else
                {
                    String errorMsg = String.join(errorMsgList,' , ');
                    return errorMsg;
                }
            }
            catch(ListException e)
            {
                errorMsgList = new List<String>();
                errorMsgList.add(e.getMessage());
                System.debug('****************'+e.getStackTraceString());
            }
            catch(DmlException e) {
                errorMsgList = new List<String>();
                System.debug('Stack trace String : ' + e.getStackTraceString());
                String dmlMessage =e.getMessage();
                if(dmlMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && dmlMessage.contains('Pending RMA Admin Review'))
                    errorMsgList.add('New Line Items can not be added when Status is in Pending RMA Admin Review');
                else
                    errorMsgList.add(dmlMessage);
                
            }
            catch(NoAccessException e)
            {
                errorMsgList = new List<String>();
                errorMsgList.add('You don\'t have permission to insert /update certain fields');
                System.debug('Access Exception: ' + e.getMessage());
            }
            catch(LimitException e)
            {
                
                System.debug('Apex CPU Limit Exception '+e.getMessage());
                return ' Salesforce CPU Time Exceeded .Please reduce file and try again';
            }
            
        }
        else 
        {
            errorMsgList = new List<String>();
            errorMsgList.add('Error! You don\'t have permission to insert RMA Lines For Case Record');
        }
        return String.join(errorMsgList, '\n'); 
    }
    
    public static Boolean  ValidatepicklistValues(String fieldApiName,String fieldvalue)
    {
        
        Schema.DescribeFieldResult fieldresult = Schema.getGlobalDescribe().get('RMA_Request_Line__c').getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> plelist = fieldresult.getPicklistValues();
        for(Schema.PicklistEntry picklistentry:plelist)
        {
            if(fieldvalue.equalsIgnoreCase(picklistentry.getValue()) && picklistentry.isActive())
                return true;
            
        }
        return false;
    }
    
   /* public class RMRequestWrapper{
        /* @AuraEnabled public string FinisarPartNumber;
@AuraEnabled public string Amount;
@AuraEnabled public string Quantity;

        @AuraEnabled public string sNo;
        @AuraEnabled public string Description;
        @AuraEnabled public string ReturnReason;
        @AuraEnabled public string POPriceType;
        @AuraEnabled public string SpecialInstructions;
        
    }*/
}