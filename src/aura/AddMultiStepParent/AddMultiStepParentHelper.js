({
    createObjectData: function(component, event,helper) {
        var action = component.get('c.getFAFVrelatedList');
        action.setParams({
            'FAFVId' : component.get('v.recordId'),
            'order'  : component.get('v.orderID')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.StepList",response.getReturnValue().stepslList);  
                var RowItemList = component.get("v.StepList").reverse();
                RowItemList.push({
                    'sobjectType': 'Steps__c',
                    'Name'    : '',
                    'FA_FV__c': component.get('v.recordId'),
                    'FA_Steps_Description_FA_Steps__c': ''
                });
                component.set("v.StepList", RowItemList);
            }
        });
        $A.enqueueAction(action);  
    }
})