({
    AddNewRow : function(component, event, helper){
        component.getEvent("AddRowEvt").fire();     
    },
    removeRow : function(component, event, helper){
        var deletRow = event.currentTarget.dataset.value;
        var action = component.get('c.deleteRow');
         action.setParams({
            'ids' : deletRow,
        });
         action.setCallback(this, function(response) {
              var state = response.getState();
            if (state === "SUCCESS"){
                var event = component.getEvent("lightningEvent");
        event.setParam("message", "Steps Deleted" );
        event.fire();
       component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();

            }else{
                   var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: 'User do not have access to delete ',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleSubmit : function(component, event, helper){
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        if(eventFields["Name"] != '' && eventFields["Name"] != null){
        eventFields["FA_FV__c"] = component.get('v.StepInstance.FA_FV__c');
        component.find('recordForm').submit(eventFields);
        }else{
              var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: 'Steps Name Is Required Field',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 3000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
        }
    },
    refreshParent : function(component, event, helper){
        var event = component.getEvent("lightningEvent");
        event.setParam("message", "Steps Saved" );
        event.fire();
    },
 
})