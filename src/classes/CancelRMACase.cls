public class CancelRMACase {
    
    @AuraEnabled
    public static String  getDetailsCondition(String recordId) {
        String returnMessage='';
        String endCustomer ='';
        Case caseRec = [select id,Return_Reason__c,RMA_PO__c,(select id,name,Error_Message__c,Return_Reason__c,PO_Price__c,Org_Code__c,Amount__c,End_Customer__c from 
                                                              RMA_Request_Lines__r) from case where id=:recordId];
        
        RMA_Request_Line__c rmaLine = new RMA_Request_Line__c();
        rmaLine = caseRec.RMA_Request_Lines__r[0];
        
        if(caseRec.RMA_Request_Lines__r.size()>1) {
            for(RMA_Request_Line__c rma :caseRec.RMA_Request_Lines__r){
                if(rmaLine.End_Customer__c != rma.End_Customer__c){
                    endCustomer = 'One or more serial number is having different end customer';
                    break;
                } 
                else {
                    system.debug('hello==');
                    caseRec.End_Customer__c = rmaLine.End_Customer__c;
                    
                }
                if (rmaLine.Return_Reason__c != rma.Return_Reason__c){
                    system.debug('hello1==');
                    endCustomer ='One or more serial number is having different Return Reason';
                    break;
                }
                if (rma.PO_Price__c == 'Other'){
                    system.debug('hello2==');
                    endCustomer ='One or more serial number is having POC price as Other';
                    break;
                }
                if (rma.Org_Code__c == 'KOR'){
                    system.debug('hello3==');
                    endCustomer ='One or more serial number is having Koria Organization';
                    break;
                } 
                if (rma.Error_Message__c != null && (rma.Error_Message__c.contains('Serial Number is not Valid') || rma.Error_Message__c.contains('PRODUCT CODE(External id)'))){
                    system.debug('hello4==');
                    endCustomer =rma.Error_Message__c;
                    break;
                }
                if(rma.Error_Message__c == null  && rma.Amount__c != rmaLine.Amount__c)
                {
                    caseRec.RMA_PO__c ='RMA/MISC';
                }
                else{
                    caseRec.RMA_PO__c = String.valueOf(rmaLine.Amount__c);
                }
            } 
        } else if(caseRec.RMA_Request_Lines__r.size() == 1) {
            system.debug('testttttttt====');
            if(rmaLine.End_Customer__c != null || rmaLine.End_Customer__c !='') {
                caseRec.End_Customer__c = rmaLine.End_Customer__c;
            }
            if (rmaLine.Error_Message__c != null && (rmaLine.Error_Message__c.contains('Serial Number is not Valid') || rmaLine.Error_Message__c.contains('PRODUCT CODE(External id)'))){
                system.debug('inside1');
                endCustomer =rmaLine.Error_Message__c;
                
            } else if (rmaLine.PO_Price__c == 'Other'){
                system.debug('inside2');
                endCustomer ='One or more serial number is having POC price as Other';
                
            }else if (rmaLine.Org_Code__c == 'KOR'){
                system.debug('inside3');
                endCustomer ='One or more serial number is having Koria Organization';
                
            }else if (rmaLine.Return_Reason__c != null || rmaLine.Return_Reason__c != '') {
                system.debug('inside4' +rmaLine.Return_Reason__c);
                caseRec.Return_Reason__c = String.valueOf(rmaLine.Return_Reason__c);
                
            }else{
                caseRec.RMA_PO__c = String.valueOf(rmaLine.Amount__c);
            }
        }
        
        system.debug('caseRec.End_Customer__c==='+caseRec.End_Customer__c);  
        System.debug('endCustomer==='+endCustomer);
        System.debug('rmaLine==='+rmaLine);
        if(caseRec.Return_Reason__c=='Other') {
            system.debug('hello5==');
            returnMessage= 'Case Can not be close because the Return Reason is Other';
        }else
            if(endCustomer !='' ) {
                system.debug('giisu--');
                returnMessage = endCustomer;
            } 
        else
        {
            caseRec.Status = 'Closed';
            system.debug('caseRec12=='+caseRec);
            try{
                update caseRec;
                system.debug('caseRec!!=='+caseRec+'---'+'Afterupdate' +caseRec.Return_Reason__c);
                returnMessage= 'Case is succesfully closed';
            }catch(Exception e){
                returnMessage= e.getMessage(); 
            }
            
        }
        System.debug('returnMessage==='+returnMessage); 
        return returnMessage;  
    }
}