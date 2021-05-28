({
    doInit: function(component, event, helper) {
         var values =  event.getParam('arguments');
        component.set('v.editAccess',values.param2);
        component.set('v.editMode',values.param3);
      
        
    },
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    removeDeletedRow: function(component, event, helper) {
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.StepList");
        AllRowsList.splice(index, 1);
        component.set("v.StepList", AllRowsList);
    },
    Cancel :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    },
})