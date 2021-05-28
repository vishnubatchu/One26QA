({
    doInit: function(component, event, helper) {
        var SLA = '\xa0'+'SLA' + '\xa0' ;
        component.set('v.SLAFieldName',SLA);
        $A.util.addClass(component.find('openSelectSerialNo'), 'slds-hide');
    },
    saveRecord : function(component, event, helper) {
         $A.util.toggleClass(component.find('sps1'),'slds-hide');
        var action = component.get('c.saveSnoRec');
        action.setParams({
            'snoList' : component.get('v.serialList'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if(response.getReturnValue() == 'Passed'){
                var event = component.getEvent("lightningEvent");
                event.setParam("message", "Record Saved" );
                event.fire();
                 $A.util.toggleClass(component.find('sps1'),'slds-hide');
                }else{
                   $A.util.toggleClass(component.find('sps1'),'slds-hide');
                  var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message: response.getReturnValue(),
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 2000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action);
    },
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    openModel: function(component, event, helper) {
        var selectedSerialList = [];
        component.set("v.selectedSerialNo", selectedSerialList);
        $A.util.removeClass(component.find('openSelectSerialNo'), 'slds-hide');
        $A.util.addClass(component.find('openSelectSerialNo'), 'slds-show');
     
    },
    closeModel: function(component, event, helper) {
        $A.util.removeClass(component.find('openSelectSerialNo'), 'slds-show');
        $A.util.addClass(component.find('openSelectSerialNo'), 'slds-hide');
    },
    handleSerialNoChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedSerialNo", selectedValues);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.serialList");
        AllRowsList.splice(index, 1);
        component.set("v.serialList", AllRowsList);
    },
    Cancel :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    }
})