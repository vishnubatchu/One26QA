({
    doInit: function(component, event, helper) {
        helper.getLoanerheaderStatus(component, event,helper);
    },
    
    
    Validate: function(component, event, helper) {
     helper.SaveRecord(component, event, helper);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.LonerLineItemList");
        AllRowsList.splice(index, 1);
        component.set("v.LonerLineItemList", AllRowsList);
    },
    Cancel :function(component, event, helper){
         $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    },
    Save :function(component, event, helper){
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
                helper.ValidateRecOnSave(component, event, helper);
            } else if(result.errorMessage != null) {
                component.set("v.errorMessage",result.errorMessage);
                $A.util.toggleClass(spin,'slds-hide');
            }else if(result.loanerItemList == null && result.errorMessage == null) {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})