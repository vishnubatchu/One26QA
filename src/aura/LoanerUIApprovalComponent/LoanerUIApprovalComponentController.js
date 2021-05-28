({
    doInit : function(component, event, helper) {
       //change start
      var tempvar = decodeURIComponent(window.location.search.substring(1));
        var temp2 = tempvar.substr(4,30);
        component.set("v.LoanerId",temp2);
        //change end
        var action = component.get("c.LoanerQuery");
        action.setParams({ "loanerId": component.get("v.LoanerId") });
         action.setCallback( this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              
                component.set("v.RequiredLoaner", response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
      },
    RassignSelected : function(component, event, helper) {
      
        var Email = component.get("v.LeMail");
          var action = component.get('c.ReasignRecords');
          
          // pass the all selected record's Id's to apex method 
          action.setParams({
           "ReasignEmail": Email,"ObjId": component.get("v.LoanerId")
          });
          action.setCallback(this, function(response) {
           //store state of response
           var state = response.getState();
           if (state === "SUCCESS") {
            console.log(state);
            if (response.getReturnValue() != '') {
                component.set("v.LOperationResult", response.getReturnValue());
             // if getting any error while delete the records , then display a alert msg/
             //alert('The following records have been updated-->' + response.getReturnValue());
            } else {
             console.log('check it--> delete successful');
            }
            // call the onLoad function for refresh the List view    
            //this.onLoad(component, event);
           }
          });
  		$A.enqueueAction(action);
      },
    
    selectAll : function(component, event, helper){
        
        var selectedHeaderCheck = event.getSource().get("v.value");
  		// get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
  		// return the List of all checkboxs element 
  		var getAllId = component.find("boxPack");
  		// If the local ID is unique[in single record case], find() returns the component. not array   
                 if(! Array.isArray(getAllId)){
                   if(selectedHeaderCheck == true){ 
                      component.find("boxPack").set("v.value", true);
                      
                   }else{
                       component.find("boxPack").set("v.value", false);
                     
                   }
    	 }else{
               // check if select all (header checkbox) is true then true all checkboxes on table in a for loop  
               // and set the all selected checkbox length in selectedCount attribute.
               // if value is false then make all checkboxes false in else part with play for loop 
               // and select count as 0 
                    if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllId.length; i++) {
                      component.find("boxPack")[i].set("v.value", true);
                    
                    }
                    } else {
                      for (var i = 0; i < getAllId.length; i++) {
                        component.find("boxPack")[i].set("v.value", false);
                         
                        }
                       } 
             }  
    },
    ApproveSelected: function(component, event, helper) {
              // create var for store record id's for selected checkboxes  
              var ApproveId = [];
              // get all checkboxes 
              var getAllId = component.find("boxPack");
              // If the local ID is unique[in single record case], find() returns the component. not array
                 if(! Array.isArray(getAllId)){
                     if (getAllId.get("v.value") == true) {
                       ApproveId.push(getAllId.get("v.text"));
                     }
                 }else{
                 // play a for loop and check every checkbox values 
                 // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
                 for (var i = 0; i < getAllId.length; i++) {
                   if (getAllId[i].get("v.value") == true) {
                     ApproveId.push(getAllId[i].get("v.text"));
                   }
                  }
                 } 
               
                 // call the helper function and pass all selected record id's.    
                  helper.ApproveSelectedHelper(component, event, ApproveId);
       			 component.set("v.LOperationResult", 'Selected Line Items have been Approved!');
                    
 },
     RejectSelected: function(component, event, helper) {
              // create var for store record id's for selected checkboxes  
              var RejectId = [];
              // get all checkboxes 
              var getAllId = component.find("boxPack");
              // If the local ID is unique[in single record case], find() returns the component. not array
                 if(! Array.isArray(getAllId)){
                     if (getAllId.get("v.value") == true) {
                       RejectId.push(getAllId.get("v.text"));
                     }
                 }else{
                 // play a for loop and check every checkbox values 
                 // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
                 for (var i = 0; i < getAllId.length; i++) {
                   if (getAllId[i].get("v.value") == true) {
                     RejectId.push(getAllId[i].get("v.text"));
                   }
                  }
                 } 
               
                 // call the helper function and pass all selected record id's.    
                  helper.RejectSelectedHelper(component, event, RejectId);
         component.set("v.LOperationResult", 'Selected Line Items have been Rejected!');
                    
 },
    RassignSelected : function(component, event, helper) {
      // create var for store record id's for selected checkboxes  
              var ReassignId = [];
              // get all checkboxes 
              var getAllId = component.find("boxPack");
              // If the local ID is unique[in single record case], find() returns the component. not array
                 if(! Array.isArray(getAllId)){
                     if (getAllId.get("v.value") == true) {
                       ReassignId.push(getAllId.get("v.text"));
                     }
                 }else{
                 // play a for loop and check every checkbox values 
                 // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
                 for (var i = 0; i < getAllId.length; i++) {
                   if (getAllId[i].get("v.value") == true) {
                     ReassignId.push(getAllId[i].get("v.text"));
                   }
                  }
                 } 
               
                 // call the helper function and pass all selected record id's.    
                  helper.ReassignSelectedHelper(component, event, ReassignId);
       			 
      },

    
    
})