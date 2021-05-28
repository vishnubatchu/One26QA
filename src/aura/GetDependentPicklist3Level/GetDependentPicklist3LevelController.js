({
    doInit : function(component, event, helper) {
        if(component.get('v.addRow') === 'True'){
            component.set('v.bDisabledDependentFld' , 'True');
            component.set('v.bDisabledSubDependentFld' , 'True');
        }
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var subDependingFieldAPI = component.get("v.subDependingFieldAPI");
        
        var objDetails = component.get("v.objDetail");
        // call the helper function
        helper.fetchPicklistValues(component,objDetails,controllingFieldAPI, dependingFieldAPI, "v.depnedentFieldMap");
        
        // 2nd and 3ed picklist 
        helper.fetchPicklistValues(component,objDetails,dependingFieldAPI, subDependingFieldAPI, "v.subDepnedentFieldMap");
 // this.onControllerFieldChange(component, event, helper);
    },
    
    onControllerFieldChange: function(component, event, helper) { 
        
        var a = [];
       // component.set('v.listDependingValues',a);
                 component.set('v.listSubDependingValues',a);
component.set('v.listDependingValues',a);
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
       console.log('cntrlVAL ' + controllerValueKey);
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        console.log('depnedentFieldMap ' + depnedentFieldMap);
        if (controllerValueKey != '--- None ---') {
            // disable and reset sub dependent field 
           
           
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,"v.listDependingValues");    
            }else{
                component.set("v.bDisabledDependentFld" , true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
        
        component.set("v.bDisabledSubDependentFld" , true);
        component.set("v.listSubDependingValues", ['--- None ---']);
    },
    
    
    onSubControllerFieldChange : function(component, event, helper) {   
        
        var controllerValueKey = event.getSource().get("v.value"); // get selected sub controller field value
        var depnedentFieldMap = component.get("v.subDepnedentFieldMap");
       
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            if(ListOfDependentFields.length > 0){
                component.set("v.bDisabledSubDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields,"v.listSubDependingValues");    
            }else{
                component.set("v.bDisabledSubDependentFld" , true); 
                component.set("v.listSubDependingValues", ['--- None ---']);
            }  
            
        } else {
            component.set("v.listSubDependingValues",['--- None ---']);
            component.set("v.bDisabledSubDependentFld" , true);
        }
    },
})