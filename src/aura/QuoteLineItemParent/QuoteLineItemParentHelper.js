({
    getLineItem :function(component, event,helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getQuoteLineItem");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (result != null) {
                component.set("v.QuoteLineItemList",result);
                //component.set('v.totalPages',Math.ceil(result.length/component.get('v.pageLimit')));
            }
            //helper.createObjectData(component, event,helper);
        });
        $A.enqueueAction(action);
        
    },
    createObjectData: function(component, event,helper) {
        var RowItemList = component.get("v.QuoteLineItemList");
        RowItemList.push({
            'sobjectType': 'Quote_Item__c',
            'Product__c': '',
            'Quantity__c': '',
            'Target_Price__c': '',
            'Line_Status__c': '',
            'Competitor_Price__c': '',
            'Competitor_Info__c': '',
            'Agreed_Upon_Share__c': '',
            'Std_List_Price__c': ''
            
            
        });
       
                      
        component.set("v.QuoteLineItemList", RowItemList);
        //component.set('v.totalPages',Math.ceil(RowItemList.length/component.get('v.pageLimit')));
    },
    
    SaveRecord : function(component, event, helper){
        var spin = component.find('sps');
        component.set("v.errorMessage","");
        component.set("v.errorMessage1","");
        //component.set("v.recErrorMessage","");
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.saveQuoteLineItem");
            
        action.setParams({
            "ListLineItem": component.get("v.QuoteLineItemList"),
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
           // console.log('result ' ,result);
            if (result.quoteItemList != null) {
                component.set("v.QuoteLineItemList",result.quoteItemList);
                $A.util.toggleClass(spin,'slds-hide');
                helper.ValidateRec(component, event, helper);
            } else if(result.errorMessage != null) {
         //       console.log('result ' ,result.errorMessage);
                component.set("v.errorMessage",result.errorMessage);
                $A.util.toggleClass(spin,'slds-hide');
            }else if(result.quoteItemList == null && result.errorMessage == null) {
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
            "Quoteid":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            if(result != '') {
                component.set("v.errorMessage",result);
                 $A.util.toggleClass(spin,'slds-hide');
            }else if (result == '' || result == null ){
                $A.util.toggleClass(spin,'slds-hide');
               
            }
             helper.getLineItemRec(component, event, helper);
        });
        $A.enqueueAction(action);        
    },
    ValidateRecOnSave :function(component, event, helper) {
        component.set("v.errorMessage","");
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.validateRecords");
        action.setParams({
            recordId:recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            if(result != '' ) {
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
        //component.set("v.recErrorMessage","");
        var recId = component.get("v.recordId");
        var spin = component.find('sps');
       $A.util.toggleClass(spin,'slds-hide');
    var action = component.get("c.getQuoteLineItem");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            if(response.getState()==='SUCCESS'){
                var result = response.getReturnValue();
                if (result != null) {
                     
                    component.set("v.QuoteLineItemList",result);
                }
                $A.util.toggleClass(spin,'slds-hide'); 
                if(result.length >0)
                    helper.getValidationRule(component, event,helper);
            }
       });
        $A.enqueueAction(action);
        
    },
    
    getValidationRule :function(component, event,helper) {
        component.set("v.errorMessage1","");
        var recId = component.get("v.recordId");
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
       var action = component.get("c.validateRulesRecords");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
             if(result != null) {
                component.set("v.errorMessage1",result);
             }
           $A.util.toggleClass(spin,'slds-hide'); 
            
        });
        $A.enqueueAction(action);
          
    },
    Save :function(component,event,helper)
    {
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        var action = component.get("c.saveQuoteLineItem");
         
         action.setParams({
            "ListLineItem": component.get("v.QuoteLineItemList"),
            "recordId":recId
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
             console.log(result.errorMessage);
            if (result.quoteItemList != null || result.quoteItemList != undefined) {
                component.set("v.QuoteLineItemList",result.quoteItemList);
                $A.util.toggleClass(spin,'slds-hide');
                helper.ValidateRecOnSave(component, event, helper);
            } else if(result.errorMessage != null) {
                console.log(result.errorMessage);
                var errMessage = result.errorMessage;
                var errMessage1 = errMessage.toString();
                component.set("v.errorMessage", errMessage1);
                $A.util.toggleClass(spin,'slds-hide');
            }else if( result.quoteItemList == null && (result.errorMessage == null ||result.errorMessage == '')) {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
      },
})