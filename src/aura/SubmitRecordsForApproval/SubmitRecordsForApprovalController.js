({
    doInit: function(component, event) {
        var action = component.get("c.sendLineItemEmails");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnVal = response.getReturnValue();
            if (state === "SUCCESS") {
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                if (returnVal == "NoLineItem") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'There are no Line Items For Approval'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                } 
                    else if (returnVal == "processSucess") {
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            message: 'Line Items are sent for Approval',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent2.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                        else if (returnVal == "Exception") {
                            var toastEvent2 = $A.get("e.force:showToast");
                            toastEvent2.setParams({
                                message: 'Records can not be Submitted for Approval.Please validate Line Records and header Record before Submitting',
                                type: 'Error',
                                mode: 'dismissible',
                                duration:' 10000'
                               
                            });
                            toastEvent2.fire();
                            $A.get('e.force:refreshView').fire();
                        }
                            else{
                                var res = returnVal.replace(/<br\s*\/?>/gi,'\r\n');
                                var toastEvent2 = $A.get("e.force:showToast");
                                toastEvent2.setParams({
                                    message: res,
                                    type: 'Error',
                                    mode: 'dismissible',
                                    duration:' 15000'
                                  
                                });
                                toastEvent2.fire();
                                $A.get('e.force:refreshView').fire();
                            }
            } else {
                console.log('Record Can not be submitted for Approval ');
            }
        });
        $A.enqueueAction(action);
    },
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    doCancel: function(component, event) {
        $A.get("e.force:closeQuickAction").fire();
    },
})