({
    doInit: function(component, event, helper) {
        var action = component.get('c.getDetailsCondition');
        var idss = component.get('v.RecordId');
        console.log('idss=='+idss);
        action.setParams({
            'recordId' : idss,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                 console.log('test111=='+result);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: result,
                        type: 'info'
                    });
                    toastEvent.fire();
                component.set('v.errormessage',result);
                console.log('test111=='+component.get('v.errormessage'));
            }
        });
        $A.enqueueAction(action);
    }
})