({
    doInit : function(component, event, helper) {
        $A.util.addClass(component.find('showMsg'), 'slds-text-body_small slds-text-color_error');
        component.set("v.recID" ,component.get('v.recordId'));
    },
    handleFilesChange: function(component, event, helper) {
        $A.util.removeClass(component.find('showMsg'), 'slds-text-body_small slds-text-color_error');
        $A.util.addClass(component.find('showMsg'), 'slds-text-body_small slds-text-color_success');
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        
        component.set("v.fileName", fileName);
    },
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files") != null) {
            if (component.find("fileId").get("v.files").length > 0) {
                helper.uploadHelper(component, event);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    type: 'error',
                     duration:5000,
                    message: 'Please Select a Valid File'
                });
                toastEvent.fire();
            }  
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                type: 'error',
                 duration:5000,
                message: 'Please Select a Valid File'
            });
            toastEvent.fire();
        }
    }
})