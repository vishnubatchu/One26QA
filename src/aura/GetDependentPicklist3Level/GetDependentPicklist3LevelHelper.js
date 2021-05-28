({
    fetchPicklistValues: function(component,objDetails,controllerField, dependentField,mapAttrName) {
        // call the server side function  
        var action = component.get("c.getDependentMap");
        // pass paramerters [object definition , contrller field name ,dependent field name] -
        // to server side function 
       var obj = objDetails;
        var cntrl =controllerField;
        var depnd = dependentField;
        action.setParams({
            'objDetail' : obj,
            'contrfieldApiName': cntrl,
            'depfieldApiName': depnd 
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set(mapAttrName,StoreResponse);
                   
                     if(mapAttrName == 'v.depnedentFieldMap'){

                    // create a empty array for store map keys(@@--->which is controller picklist values) 
                    var listOfkeys = []; // for store all map keys (controller picklist values)
                    var ControllerField = []; // for store controller picklist value to set on lightning:select. 
                    var DependentField = [];
                    var SubDependentField = [];     
                    // play a for loop on Return map 
                    // and fill the all map key on listOfkeys variable.
                    for (var singlekey in StoreResponse) {
                        listOfkeys.push(singlekey);
                    }
                    
                    //set the controller field value for lightning:select
                    if (listOfkeys != undefined && listOfkeys.length > 0) {
                         var index = ControllerField.indexOf(component.get('v.cntrolling'));
                    if (index > -1) {
                      ControllerField.splice(index, 1);
                    } 
                        ControllerField.push(component.get('v.cntrolling'));
                        DependentField.push(component.get('v.dependent'));
                        SubDependentField.push(component.get('v.subdependent'));
                    }
                    
                    for (var i = 0; i < listOfkeys.length; i++) {
                        ControllerField.push(listOfkeys[i]);
                    } 
                        
                         
                    // set the ControllerField variable values to country(controller picklist field)
                   
                         component.set("v.listControllingValues", ControllerField);
                         component.set("v.listDependingValues", DependentField);
                         component.set("v.listSubDependingValues", SubDependentField);
                
                  
                
            }
            }else{
                alert('Something went wrong..');
            }
            
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields,lstAttrName) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set(lstAttrName, dependentFields);
        
    },
    
})