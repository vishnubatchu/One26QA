({
    getOpportunity :function(component, event,helper) {
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var recId = component.get("v.recordId");
        console.log('recId---'+recId);
        var action = component.get("c.getOpportunityRec");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (result != null && state == 'SUCCESS') {
                console.log('result---'+JSON.stringify(result));
                component.set("v.QuoteInstance",result);
                $A.util.toggleClass(spin,'slds-hide');
                var sObjectEvent = $A.get("e.force:navigateToSObject");
                sObjectEvent.setParams({
                    "recordId": component.get("v.QuoteInstance.Id"),
                    "slideDevName": "detail"
                });
                sObjectEvent.fire();
            }
            else if(state=="ERROR"){
                var errors = response.getError();  
                console.log('Error in Create Quote Cmp==>'+errors[0].message);
        }
        });
        $A.enqueueAction(action);
        
    }
})