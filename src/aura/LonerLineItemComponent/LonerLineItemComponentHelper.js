({
    getLoanerheaderStatus :function(component, event,helper) {
       var recId = component.get("v.recordId");
        var action = component.get("c.getLoanerStatus");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
          
            if (result != null && state =='SUCCESS' ) {
                component.set("v.headerStatus",result);
            }
            helper.getUserCustomPermission(component, event,helper);
        });
        $A.enqueueAction(action); 
    },
    getUserCustomPermission :function(component, event,helper) {
        var action = component.get("c.getUserPermission");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
           console.log('result---'+result);
            if (result != null && state =='SUCCESS' ) {
                component.set("v.userPermission",result);
            }
            helper.getLineItem(component, event,helper);
        });
        $A.enqueueAction(action); 
    },
    getLineItem :function(component, event,helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getLoanerLineItem");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
          
            if (result != null) {
                component.set("v.LonerLineItemList",result);
            }
            //helper.createObjectData(component, event,helper);
        });
        $A.enqueueAction(action);
        
    },
    createObjectData: function(component, event,helper) {
        
        var RowItemList = component.get("v.LonerLineItemList");
        RowItemList.push({
            'sobjectType': 'Loaner_Line__c',
            'Product__c': '',
            'Loaner_Price_100_999_column_price__c': '',
            'Production_Price_ASP__c': '',
            'Est_Annual_Qty__c': '',
            'SOM__c': '',
            'Loaner_Qty__c': '',
            'Line_Total__c':'',
            'SAM__c':'',
            'Line_Status__c':'',
            'Serial_Number__c':'',
            'RSM__c':'',
            'VP__c':'',
            'SVP__c':'',
           'CPN_Description__c':'',
            'Other_Description__c':'',
            'User_Notes__c':'',
            'Part_Type_Notes__c':'',
            'Admin_Status__c':'',
            'Initial_Error_Message__c':'',
            'Order_Line__c':'',
            'SO_Line_Number__c':'',
            'Loaner_Return_Carrier__c':'',
            'Loaner_Return_Tracking_Number__c':''
            
            
           
            
            
        });
        component.set("v.LonerLineItemList", RowItemList);
    },
    
    SaveRecord : function(component, event, helper){
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.saveLoanerLineItem");
        console.log('Loine Item'+JSON.stringify(component.get("v.LonerLineItemList")));
        action.setParams({
            "ListLineItem": component.get("v.LonerLineItemList"),
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (result.loanerItemList != null) {
                component.set("v.LonerLineItemList",result.loanerItemList);
                $A.util.toggleClass(spin,'slds-hide');
                helper.ValidateRec(component, event, helper);
            } else if(result.errorMessage != null) {
                component.set("v.errorMessage",result.errorMessage);
                $A.util.toggleClass(spin,'slds-hide');
            }else if(result.loanerItemList == null && result.errorMessage == null) {
                $A.util.toggleClass(spin,'slds-hide');
            }
        });
        $A.enqueueAction(action);
    },
    
    ValidateRec :function(component, event, helper) {
        console.log('inside validate');
        component.set("v.errorMessage","");
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.sendRequesttoInformatica");
        action.setParams({
            "loanerid":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result---'+result);
           if(result != '') {
                component.set("v.errorMessage",result);
                 $A.util.toggleClass(spin,'slds-hide');
            }else if (result == '' || result == null ){
                $A.util.toggleClass(spin,'slds-hide');
                
            }
            helper.getLineItemRec(component, event, helper);
            console.log('eroor ----'+component.get("v.errorMessage"));
            
        });
        $A.enqueueAction(action);
        
    },
   ValidateRecOnSave :function(component, event, helper) {
       console.log('inside validate');
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.validateRecordsONSaveAndClose");
        action.setParams({
            recordId:recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result---'+result);
            if(result != '') {
                component.set("v.errorMessage",result);
                $A.util.toggleClass(spin,'slds-hide');
            }else if(result == '') {
                 $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                }
            
        });
        $A.enqueueAction(action);
        
    },    
    getLineItemRec :function(component, event,helper) {
        var recId = component.get("v.recordId");
        //component.set("v.recErrorMessage","");
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var action = component.get("c.getLoanerLineItem");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('resultresultresult---'+result);
            if (result != null) {
                component.set("v.LonerLineItemList",result);
            }
           /* var errorms =[];
            errorms = component.get("v.LonerLineItemList");
            for(var i=0; i<errorms.length; i++) {
                if(errorms[i].Initial_Error_Message__c != null) {
                    var errorMessage =errorms[i].Initial_Error_Message__c;
                    var recordname = errorms[i].Name; 
                    var errorMes = errorMessage+'in LoanerLineItem '+recordname;
                    component.set("v.recErrorMessage",errorMes);
                    
                }
            }*/
            $A.util.toggleClass(spin,'slds-hide');
            
        });
        $A.enqueueAction(action);
        
    }
    
})