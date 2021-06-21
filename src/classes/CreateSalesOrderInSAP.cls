public with sharing class CreateSalesOrderInSAP {
    
    Apexpages.Standardcontroller stdController;
    public WebserviceClassSalesOrder.HTTPS_Port httpPort { get;set; }
    public Order orderObject ;
    //String sEndpoint = 'http://8.34.95.17:8104/XISOAPAdapter/MessageServlet?senderParty=&senderService=BS_SFDC&receiverParty=&receiverService=&interface=SI_SALES_SFDC_OUT&interfaceNamespace=http://ii-vi.com/sales/sfdc/ecc/salesorder';
    public boolean isConfirm {get;set;}
    
    public CreateSalesOrderInSAP() {
        
    }
    
    public CreateSalesOrderInSAP(ApexPages.StandardController controller) {
        this.stdController = controller;
        this.orderObject = (Order)stdController.getRecord();
        isConfirm = true;
    }
    
    public Pagereference createSalesOrderInSAP() {
        isConfirm = false;
        String sReturnMsg = '';
        String sReturnType = '';
        String sErrorCode ='';
        String sMessage = '';
        String sSAPOrderId = '';
        String sStatus = '';
        boolean isSuccess = false;
        String XMLRequest = '';
        String resultString = '';
        map<String,String> mapErrorCode_ErrorMessage;
        list<WebserviceClassSalesOrder.ORDER_element> listOrder = new  list<WebserviceClassSalesOrder.ORDER_element>();
        WebserviceClassSalesOrder.ORDER_element orderElement ;
        WebserviceClassSalesOrder.ORDER_element orderElementResponse;
        WebserviceClassSalesOrder.DT_SFDC_SALES_RESPONSE SAPResponse;
        list<WebserviceClassSalesOrder.ITEM_element> listItemElement ;
        WebserviceClassSalesOrder.ITEM_element itemElement ;
        try {
            //invoiceit_s__Job__c orderObj = SalesOrderUtilClass.getOrder(orderObject.Id);
            Order orderObj = SalesOrderUtilClassNew.getOrder(orderObject.Id);
            //list<invoiceit_s__Job_Rate_Plan_Charge__c>  listOrderRatePlanCharges = SalesOrderUtilClass.getChargesForOrder(orderObj.Id);
            list<Order_Line__c>  listOrderRatePlanCharges = SalesOrderUtilClassNew.getOrderProducts(orderObj.Id);
            //map<Id,Account>  mapId_Account  = SalesOrderUtilClass.getAccounts() ;   
            User user = SalesOrderUtilClassNew.getUser(orderObj.OwnerId);
            // mapping for the Order object elements
            // below this is just to form an XML Request
            XMLRequest = formXMLRequest(orderObj,listOrderRatePlanCharges,user);
            system.debug('the xml request--> '+XMLRequest);
            orderElement = new WebserviceClassSalesOrder.ORDER_element();
            orderElement.HEADER = new WebserviceClassSalesOrder.HEADER_element();
            
            if(orderObj.SAP_Order_Type__c != null) {
                orderElement.HEADER.SAPORDERTYPE  = orderObj.SAP_Order_Type__c; 
            }
            if(orderObj.SAP_Sales_Org_ID__c != null) {
                orderElement.HEADER.SALES_ORG  = orderObj.SAP_Sales_Org_ID__c; 
            }
            if(orderObj.SAP_Dist_Channel_ID__c != null) {
                orderElement.HEADER.DISTR_CHAN  = orderObj.SAP_Dist_Channel_ID__c; 
            }
            if(orderObj.SAP_Division_ID__c != null) {
                orderElement.HEADER.DIVISION  = orderObj.SAP_Division_ID__c; 
            }
            if(orderObj.Account_SAP_ID__c != null) {
                orderElement.HEADER.CUSTOMERID = orderObj.Account_SAP_ID__c;    
            }
            if(orderObj.Opportunity.Drop_Ship__c != null) {
                orderElement.HEADER.DROPSHIP  = orderObj.Opportunity.Drop_Ship__c;   
            }
            if(orderObj.Opportunity.PO_Number__c != null) {
                orderElement.HEADER.PONUM  = orderObj.Opportunity.PO_Number__c;
            }
            if(orderObj.ActivatedDate != null) {
                orderElement.HEADER.ORDERDATE = SalesOrderUtilClassNew.convertDateToString(Date.valueOf(orderObj.ActivatedDate) );
            }
            if(orderObj.EffectiveDate != null) {
                orderElement.HEADER.PODATE = SalesOrderUtilClassNew.convertDateToString(orderObj.EffectiveDate);    
            }
            if(orderObj.Opportunity.Received_By__c != null) {
                orderElement.HEADER.POMETHOD = orderObj.Opportunity.Received_By__c;    
            }
            if(orderObj.EndDate != null) {
                orderElement.HEADER.SVCENDDATE = SalesOrderUtilClassNew.convertDateToString(orderObj.EndDate);    
            }
            if(orderObj.Primary_Shipping_Contact__r.Name != null) {
                orderElement.HEADER.NAME = orderObj.Primary_Shipping_Contact__r.Name;  
            }
            if(orderObj.Primary_Shipping_Contact__r.Phone != null) {
                orderElement.HEADER.TELEPHONE = orderObj.Primary_Shipping_Contact__r.Phone;    
            }
            if(orderObj.Opportunity.Shipping_Carrier__c != null) {
                orderElement.HEADER.SHIPCARR = orderObj.Opportunity.Shipping_Carrier__c; 
            }           
            //orderElement.HEADER.STATUS = '';
            if(orderObj.Opportunity.Description != null) {
                orderElement.HEADER.DESCRIPTION = orderObj.Opportunity.Description;  
            }
            if(orderObj.Opportunity.Shipping_Comments__c != null) {
                orderElement.HEADER.SHIPPINGCOMMENTS = orderObj.Opportunity.Shipping_Comments__c;    
            }
            if(orderObj.Opportunity.Special_Instructions__c != null) {
                orderElement.HEADER.SPINSTR = orderObj.Opportunity.Special_Instructions__c;  
            }
            //orderElement.HEADER.SAPSOID = '';
            if(orderObj.Id != null) {
                orderElement.HEADER.SALESFORCEORDERID = orderObj.Id;    
            }
            if(orderObj.CurrencyIsoCode != null) {
                orderElement.HEADER.CURRENCY_x = orderObj.CurrencyIsoCode;   
            }
            
            if(orderObj.Opportunity.Ship_Method__c != null) {
                orderElement.HEADER.SHIPMETHOD = orderObj.Opportunity.Ship_Method__c;  
            }
            
            if(orderObj.Opportunity.Collect_Account_Number__c != null) {
                orderElement.HEADER.COLLECTACCTNUM = orderObj.Opportunity.Collect_Account_Number__c;  
            }
            
            if(orderObj.Opportunity.IncoTerms__c != null) {
                orderElement.HEADER.INCOTERMS1 = orderObj.Opportunity.IncoTerms__c;  
            }
            
            if(orderObj.Opportunity.Named_Place__c != null) {
                orderElement.HEADER.INCOTERMS2 = orderObj.Opportunity.Named_Place__c;  
            }
            
            if(orderObj.End_Customer_SAP_ID__c != null) {
                orderElement.HEADER.ENDCUSTOMER = orderObj.End_Customer_SAP_ID__c;  
            }
            
            if(user != null && user.CommunityNickname != null) {        
                orderElement.HEADER.SALESFORCEOWNERUSERNAME = user.CommunityNickname;   
            }
            
            orderElement.HEADER.PARTIALRULES = new WebserviceClassSalesOrder.PARTIALRULES_element();
            
            if(orderObj.Opportunity.Partials_Permitted__c != null) {
                orderElement.HEADER.PARTIALRULES.PERMITTED  = String.valueOf(orderObj.Opportunity.Partials_Permitted__c);
            }
            If (orderObj.SAP_Order_Type__c != 'Rush') {
                orderElement.HEADER.PARTIALRULES.NOTPERMITTED = 'false';
            }
            else {
                orderElement.HEADER.PARTIALRULES.NOTPERMITTED = 'true';
            }
            if(orderObj.Opportunity.PBCR__c != null) {
                orderElement.HEADER.PARTIALRULES.WITHCOMPLETERELEASE = String.valueOf(orderObj.Opportunity.PBCR__c);
            }
            
            // mapping for the Order Item elements
            listItemElement  = new list<WebserviceClassSalesOrder.ITEM_element>();
            for(Order_Line__c charge : listOrderRatePlanCharges) {
                //for(invoiceit_s__Job_Rate_Plan_Charge__c charge : listOrderRatePlanCharges) {
                itemElement = new WebserviceClassSalesOrder.ITEM_element();
                /* Sales Order Interface: Change Product Code to Product Name Modified by Dev on 28-01-2014
if(charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c != null) {
itemElement.PRODUCTID = charge.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c;  
}*/
                if(charge.Part_Number__c != null) {
                    itemElement.PRODUCTID = charge.Part_Number__r.Name;  
                }
                if(charge.Quantity__c != null) {
                    itemElement.QUANTITY = String.valueOf(charge.Quantity__c); 
                }
                if(charge.Unit_Selling_Price__c  != null) {
                    itemElement.UNITPRICE = String.valueOf(charge.Unit_Selling_Price__c);  
                }
                // if the request date is null, then assign the delivery date/ service activation date
                if(charge.Request_Date__c != null){
                    itemElement.REQUESTDATE = SalesOrderUtilClassNew.convertDateToString(charge.Request_Date__c);  
                }
                else if(orderObj.EffectiveDate != null) {
                    itemElement.REQUESTDATE =  SalesOrderUtilClassNew.convertDateToString(orderObj.EffectiveDate);
                }
                if(charge.PO_LI_NO__c != null) {
                    itemElement.POLINEITEMNUMBER = String.valueOf(charge.PO_LI_NO__c);  
                }
                if(charge.Order_Product_Sequence_Number__c != null) {
                    itemElement.ORDERPRODUCTSEQNUM = String.valueOf(charge.Order_Product_Sequence_Number__c);   
                }
                if(charge.Additional_Specifications__c != null) {
                    itemElement.ADDSPEC = charge.Additional_Specifications__c;    
                }
                
                if(charge.Free_of_Charge__c != null) {
                    itemElement.FREEOFCHARGEITEM =  String.valueOf(charge.Free_of_Charge__c);   
                }
                // adding the order item to the list and assigning to the orderelement object
                listItemElement.add(itemElement);
            }
            
            orderElement.HEADER.ITEM  =  listItemElement;
            listOrder.add(orderElement);
            
            // setting the credentials of SAP system
            httpPort = new WebserviceClassSalesOrder.HTTPS_Port();
            httpPort.inputHttpHeaders_x = new Map<string, string>();
            httpPort.outputHttpHeaders_x = new Map<string, string>();
            //String USERNAME = 'SFDC';
            //String PASSWORD = 'P@ssw0rd';
            //String PASSWORD = 'IT2Nov2013';
            String USERNAME = system.label.USERNAME;
            String PASSWORD = system.label.PASSWORD;
            Blob headerValue = Blob.valueOf(USERNAME + ':' + PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            httpPort.inputHttpHeaders_x.put('Authorization', authorizationHeader); 
            //httpPort.endpoint_x = sEndpoint;
            httpPort.endpoint_x = system.label.Endpoint;
            httpPort.timeout_x = 100000;
            
            // getting the response and set it to response object
            SAPResponse = new WebserviceClassSalesOrder.DT_SFDC_SALES_RESPONSE();
            SAPResponse.ORDER = new  WebserviceClassSalesOrder.ORDER_element();
            system.debug('the request string--> '+listOrder);
            if(!test.isRunningTest()){
                SAPResponse.ORDER = httpPort.SI_SALES_SFDC_OUT(listOrder);
            }
            
            system.debug('the response string '+SAPResponse.ORDER);
            system.debug('the response string ELEMENT '+SAPResponse.ORDER.RESULTS);
            
            String sSuccessString = '';
            boolean isError = false;
            for(WebserviceClassSalesOrder.RESULTS_element resultsElement : SAPResponse.ORDER.RESULTS) {
                system.debug('the response in for loop 1-->'+resultsElement.RESPONSE.RETURNMSG);    
                system.debug('the response in for loop 2-->'+resultsElement.RESPONSE.RETURNTYPE);
                if(!isSuccess && resultsElement.RESPONSE.RETURNTYPE == 'S') {
                    isSuccess = true;   
                    sSuccessString = 'Successfully Synced with SAP';
                    Apexpages.Message errorMessage1 =  new ApexPages.Message(ApexPages.Severity.Info,sSuccessString);
                    Apexpages.addMessage(errorMessage1);
                    String sSavedReturnMS = resultsElement.RESPONSE.RETURNMSG;
                    string sSavedReturnMSSubString =   sSavedReturnMS.substringBetween('(',')');
                    
                    if(sSavedReturnMSSubString != null) {
                        sSavedReturnMS = sSavedReturnMS.remove(sSavedReturnMSSubString);
                    }
                    sSAPOrderId = sSavedReturnMS.replaceAll('\\D', '');
                    sStatus = 'Sync Complete';
                }
                else if(!isError && (resultsElement.RESPONSE.RETURNTYPE == 'E' || resultsElement.RESPONSE.RETURNTYPE == 'A')){
                    isError = true;
                    sSuccessString = 'Failure during Integration';
                    sStatus = 'Sync Error';
                    Apexpages.Message errorMessage1 =  new ApexPages.Message(ApexPages.Severity.Info,sSuccessString);
                    Apexpages.addMessage(errorMessage1);
                }
                
                String sReturnType_Message = resultsElement.RESPONSE.RETURNTYPE+': '+resultsElement.RESPONSE.RETURNMSG;
                Apexpages.Message errorMessage =  new ApexPages.Message(ApexPages.Severity.Info,sReturnType_Message);
                Apexpages.addMessage(errorMessage); 
                sReturnMsg = sReturnMsg + resultsElement.RESPONSE.RETURNMSG + ', ';
                sReturnType = sReturnType + resultsElement.RESPONSE.RETURNTYPE + ', ';
                resultString = resultString + String.valueOf(resultsElement);
            }
            
            updateOrderFields(orderObject.Id,sSAPOrderId,sStatus);  
            sReturnMsg = sReturnMsg.substring(0,  sReturnMsg.length() - 2);
            sReturnType = sReturnType.substring(0,  sReturnType.length() - 2);
            
            // this method wil have the logging mechanism details
            logResponseFromSAP(sReturnMsg,sReturnType,orderObject.Id,isSuccess,XMLRequest,resultString);
            
        }
        catch(CalloutException ex1) {
            system.debug(ex1);
            Apexpages.Message errorMessage =  new ApexPages.Message(ApexPages.Severity.Error,'Exception occured -->'+ex1.getMessage());
            Apexpages.addMessage(errorMessage); 
            system.debug('exception message -> '+ex1.getMessage());
            sReturnMsg =  ex1.getMessage() +', '+ ex1.getCause() +', '+ ex1.getStackTraceString() +', '+ ex1.getTypeName() +', '+ ex1.getLineNumber();
            sReturnType = 'Exception';
            logResponseFromSAP(sReturnMsg,sReturnType,orderObject.Id,isSuccess,XMLRequest,resultString);
        } 
        catch(Exception ex) {
            system.debug(ex);
            Apexpages.Message errorMessage =  new ApexPages.Message(ApexPages.Severity.Error,'Exception occured -->'+ex.getMessage());
            Apexpages.addMessage(errorMessage); 
            system.debug('exception message -> '+ex.getMessage());
            sReturnMsg =  ex.getMessage() +', '+ ex.getCause() +', '+ ex.getStackTraceString() +', '+ ex.getTypeName() +', '+ ex.getLineNumber();
            sReturnType = 'Exception';
            logResponseFromSAP(sReturnMsg,sReturnType,orderObject.Id,isSuccess,XMLRequest,resultString);
        } 
        return null;
    }   
    // this method is to log the response from SAP to  Salesforce
    public void logResponseFromSAP(String sReturnMessage,String sReturnType , String sOrderId,boolean isSuccess,String XMLRequest,String resultString) {
        list<Response_Logger__c>  listResponseLogger = new list<Response_Logger__c>();
        Response_Logger__c  response = new Response_Logger__c();
        response.Export_By__c = Userinfo.getUserId();
        response.Export_Time__c = system.now();
        response.Response_Code__c = sReturnType;
        response.Response_Message__c = sReturnMessage;
        response.Response_Text__c = resultString;
        response.Order1__c = sOrderId;
        response.XMLRequest__c = XMLRequest;
        if(isSuccess) {
            response.Status__c = 'Success';     
        }
        else {
            response.Status__c = 'Failure'; 
        }
        upsert response;
    }
    
    public void updateOrderFields(String sOrderId,String sSAPOrderId,String status) {
        if(sSAPOrderId != null && sSAPOrderId != '') {
            Order orderObjUpdate = new Order(Id=sOrderId, Sent_to_SAP__c=true, SAP_Order_ID__c = sSAPOrderId, Status = status);
            update  orderObjUpdate; 
        } else if(status=='Sync Error'){
            Order orderObjUpdate = new Order(Id=sOrderId, Status = status);
            update  orderObjUpdate;     
        }
    }
    
    public Pagereference returnToOrder() {
        return new Pagereference('/'+orderObject.Id);
    }
    
    public String formXMLRequest(Order orderObj,list<Order_Line__c> listOrderRatePlanCharges, User user) {
        String sRequestXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sal=" '+ 'http://ii-vi.com/sales/sfdc/ecc/salesorder"> ' +
            
            + '<soapenv:Header/>'
            + '<soapenv:Body>'
            +  '<sal:MT_SFDC_SALES>' 
            +  '<ORDER>'
            +    '<HEADER>' ;
        
        
        if(orderObj.SAP_Order_Type__c != null) {
            sRequestXML = sRequestXML + '<SAPORDERTYPE>'+orderObj.SAP_Order_Type__c+'</SAPORDERTYPE>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<SAPORDERTYPE/>';
        }
        
        if(orderObj.SAP_Sales_Org_ID__c != null) {
            sRequestXML = sRequestXML + '<SALES_ORG>'+orderObj.SAP_Sales_Org_ID__c+'</SALES_ORG>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<SALES_ORG/>';
        }
        
        if(orderObj.SAP_Dist_Channel_ID__c != null) {
            sRequestXML = sRequestXML + '<DISTR_CHAN>'+orderObj.SAP_Dist_Channel_ID__c+'</DISTR_CHAN>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<DISTR_CHAN/>';
        }
        
        if(orderObj.SAP_Division_ID__c != null) {
            sRequestXML = sRequestXML + '<DIVISION>'+orderObj.SAP_Division_ID__c+'</DIVISION>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<DIVISION/>';
        }
        
        if(orderObj.Account_SAP_ID__c != null) {
            sRequestXML = sRequestXML + '<CUSTOMERID>'+orderObj.Account_SAP_ID__c+'</CUSTOMERID>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<CUSTOMERID/>';
        }
        
        if(orderObj.Opportunity.Drop_Ship__c != null) {
            sRequestXML = sRequestXML + '<DROPSHIP>'+orderObj.Opportunity.Drop_Ship__c+'</DROPSHIP>' ;   
        }
        else {
            sRequestXML = sRequestXML + '<DROPSHIP/>';
        }
        
        if(orderObj.Opportunity.PO_Number__c != null) {
            sRequestXML = sRequestXML + '<PONUM>'+orderObj.Opportunity.PO_Number__c+'</PONUM>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<PONUM/>';
        }
        
        if(orderObj.EffectiveDate != null) {
            sRequestXML = sRequestXML + '<ORDERDATE>'+SalesOrderUtilClassNew.convertDateToString(Date.valueOf(orderObj.EffectiveDate))+'</ORDERDATE>' ;    
        }
        else {
            sRequestXML = sRequestXML + '<ORDERDATE/>';
        }
        
        if(orderObj.EndDate != null) {
            sRequestXML = sRequestXML + '<SVCENDDATE>'+orderObj.EndDate+'</SVCENDDATE>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<SVCENDDATE/>';
        }
        
        if(orderObj.PoDate != null) {
            sRequestXML = sRequestXML + '<PODATE>'+orderObj.PoDate+'</PODATE>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<PODATE/>';
        }
        
        if(orderObj.Opportunity.Received_By__c != null) {
            sRequestXML = sRequestXML + '<POMETHOD>'+orderObj.Opportunity.Received_By__c+'</POMETHOD>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<POMETHOD/>';
        }
        
        if(orderObj.Primary_Shipping_Contact__r.Name != null) {
            sRequestXML = sRequestXML + '<NAME>'+orderObj.Primary_Shipping_Contact__r.Name+'</NAME>' ; 
        }
        else {
            sRequestXML = sRequestXML + '<NAME/>';
        }
        
        if(orderObj.Primary_Shipping_Contact__r.Phone != null) {
            sRequestXML = sRequestXML + '<TELEPHONE>'+orderObj.Primary_Shipping_Contact__r.Phone+'</TELEPHONE>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<TELEPHONE/>';
        }
        
        if(orderObj.Opportunity.Shipping_Carrier__c != null) {
            sRequestXML = sRequestXML + '<SHIPCARR>'+orderObj.Opportunity.Shipping_Carrier__c+'</SHIPCARR>' ;    
        }
        else {
            sRequestXML = sRequestXML + '<SHIPCARR/>';
        }
        
        sRequestXML = sRequestXML + '<STATUS/>' ;
        
        if(orderObj.Opportunity.Description != null) {
            sRequestXML = sRequestXML + '<DESCRIPTION>'+orderObj.Opportunity.Description+'</DESCRIPTION>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<DESCRIPTION/>';
        }
        
        if(orderObj.Opportunity.Shipping_Comments__c != null) {
            sRequestXML = sRequestXML + '<SHIPPINGCOMMENTS>'+orderObj.Opportunity.Shipping_Comments__c+'</SHIPPINGCOMMENTS>' ;   
        }
        else {
            sRequestXML = sRequestXML + '<SHIPPINGCOMMENTS/>';
        }
        
        if(orderObj.Opportunity.Special_Instructions__c != null) {
            sRequestXML = sRequestXML + '<SPINSTR>'+orderObj.Opportunity.Special_Instructions__c+'</SPINSTR>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<SPINSTR/>';
        }
        
        sRequestXML = sRequestXML + '<SAPSOID/>' ;
        
        if(orderObj.Id != null) {
            sRequestXML = sRequestXML + '<SALESFORCEORDERID>'+orderObj.Id+'</SALESFORCEORDERID>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<SALESFORCEORDERID/>';
        }
        
        if(orderObj.CurrencyIsoCode != null) {
            sRequestXML = sRequestXML + '<CURRENCY>'+orderObj.CurrencyIsoCode+'</CURRENCY>' ;    
        }
        else {
            sRequestXML = sRequestXML + '<CURRENCY/>';
        }
        
        if(orderObj.Opportunity.Ship_Method__c != null) {
            sRequestXML = sRequestXML + '<SHIPMETHOD>'+orderObj.Opportunity.Ship_Method__c+'</SHIPMETHOD>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<SHIPMETHOD/>';
        }
        
        if(orderObj.Opportunity.Collect_Account_Number__c != null) {
            sRequestXML = sRequestXML + '<COLLECTACCTNUM>'+orderObj.Opportunity.Collect_Account_Number__c+'</COLLECTACCTNUM>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<COLLECTACCTNUM/>';
        }
        
        if(orderObj.Opportunity.IncoTerms__c != null) {
            sRequestXML = sRequestXML + '<INCOTERMS1>'+orderObj.Opportunity.IncoTerms__c+'</INCOTERMS1>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<INCOTERMS1/>';
        }
        
        if(orderObj.Opportunity.Named_Place__c != null) {
            sRequestXML = sRequestXML + '<INCOTERMS2>'+orderObj.Opportunity.Named_Place__c+'</INCOTERMS2>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<INCOTERMS2/>';
        }
        
        if(orderObj.End_Customer_SAP_ID__c != null) {
            sRequestXML = sRequestXML + '<ENDCUSTOMER>'+orderObj.End_Customer_SAP_ID__c+'</ENDCUSTOMER>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<ENDCUSTOMER/>';
        }
        
        if(user != null && user.CommunityNickname != null) {
            sRequestXML = sRequestXML + '<SALESFORCEOWNERNICKNAME>'+user.CommunityNickname+'</SALESFORCEOWNERNICKNAME>' ;   
        }
        else {
            sRequestXML = sRequestXML + '<SALESFORCEOWNERNICKNAME/>';
        }
        
        sRequestXML = sRequestXML + '<PARTIALRULES>' ;
        
        if(orderObj.Opportunity.Partials_Permitted__c != null) {
            sRequestXML = sRequestXML + '<PERMITTED>'+String.valueOf(orderObj.Opportunity.Partials_Permitted__c)+'</PERMITTED>' ;    
        }
        else {
            sRequestXML = sRequestXML + '<PERMITTED/>';
        }
        
        if(orderObj.SAP_Order_Type__c != 'Rush') {
            sRequestXML = sRequestXML + '<NOTPERMITTED>'+'false'+'</NOTPERMITTED>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<NOTPERMITTED>'+'true'+'</NOTPERMITTED>';
        }
        
        if(orderObj.Opportunity.PBCR__c != null) {
            sRequestXML = sRequestXML + '<WITHCOMPLETERELEASE>'+String.valueOf(orderObj.Opportunity.PBCR__c)+'</WITHCOMPLETERELEASE>' ;  
        }
        else {
            sRequestXML = sRequestXML + '<WITHCOMPLETERELEASE/>';
        }
        
        sRequestXML = sRequestXML + '</PARTIALRULES>' ;
        
        for(Order_Line__c charge : listOrderRatePlanCharges) {
            sRequestXML = sRequestXML + '<ITEM>' ;
            if(charge.Part_Number__c != null) {
                sRequestXML = sRequestXML + '<PRODUCTID>'+charge.Part_Number__r.Name+'</PRODUCTID>' ;    
            }
            else {
                sRequestXML = sRequestXML + '<PRODUCTID/>';
            }
            
            if(charge.Quantity__c != null) {
                sRequestXML = sRequestXML + '<QUANTITY>'+String.valueOf(charge.Quantity__c)+'</QUANTITY>' ;    
            }
            else {
                sRequestXML = sRequestXML + '<QUANTITY/>';
            }
            
            if(charge.Unit_Selling_Price__c != null) {
                sRequestXML = sRequestXML + '<UNITPRICE>'+String.valueOf(charge.Unit_Selling_Price__c)+'</UNITPRICE>' ;    
            }
            else {
                sRequestXML = sRequestXML + '<UNITPRICE/>';
            }
            
            if(charge.Request_Date__c != null){
                sRequestXML = sRequestXML + '<REQUESTDATE>'+SalesOrderUtilClassNew.convertDateToString(charge.Request_Date__c)+'</REQUESTDATE>' ;
            }
            else if(orderObj.ActivatedDate != null) {
                sRequestXML = sRequestXML + '<REQUESTDATE>'+SalesOrderUtilClassNew.convertDateToString(Date.valueOf(orderObj.ActivatedDate))+'</REQUESTDATE>' ;
            }
            else {
                sRequestXML = sRequestXML + '<REQUESTDATE/>';
            }
            
            if(charge.PO_LI_NO__c != null) {
                sRequestXML = sRequestXML + '<POLINEITEMNUMBER>'+String.valueOf(charge.PO_LI_NO__c)+'</POLINEITEMNUMBER>' ; 
            }
            else {
                sRequestXML = sRequestXML + '<POLINEITEMNUMBER/>';
            }
            
             if(charge.Order_Product_Sequence_Number__c != null) {
               sRequestXML = sRequestXML + '<ORDERPRODUCTSEQNUM>'+String.valueOf(charge.Order_Product_Sequence_Number__c)+'</ORDERPRODUCTSEQNUM>' ;    
            }
             else {
               sRequestXML = sRequestXML + '<ORDERPRODUCTSEQNUM/>';
            }
            
            if(charge.Additional_Specifications__c != null) {
                sRequestXML = sRequestXML + '<ADDSPEC>'+charge.Additional_Specifications__c+'</ADDSPEC>' ;    
            }
            else {
                sRequestXML = sRequestXML + '<ADDSPEC/>';
            }
            
            if(charge.Free_of_Charge__c != null) {
                sRequestXML = sRequestXML + '<FREEOFCHARGEITEM>'+String.valueOf(charge.Free_of_Charge__c)+'</FREEOFCHARGEITEM>' ;   
            }
            else {
                sRequestXML = sRequestXML + '<FREEOFCHARGEITEM/>';
            }
            
            sRequestXML = sRequestXML + '</ITEM>' ;
        }
        sRequestXML = sRequestXML +  '</HEADER>' ;
        sRequestXML = sRequestXML+ '</ORDER>' ;
        sRequestXML = sRequestXML+ '</sal:MT_SFDC_SALES>' ;
        sRequestXML = sRequestXML+ '</soapenv:Body>' ;
        sRequestXML = sRequestXML+'</soapenv:Envelope>' ;
        return sRequestXML;
    }
}