({
    doinit : function(component, event, helper){
        
    },
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
        event.setParam("message", "Serial Number Deleted" );
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
        
    }
})