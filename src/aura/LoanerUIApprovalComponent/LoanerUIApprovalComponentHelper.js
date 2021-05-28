({
	ApproveSelectedHelper: function(component, event, ApproveRecordsIds) {
          //call apex class method
            var action = component.get('c.ApproveRecords');
          
          // pass the all selected record's Id's to apex method 
          action.setParams({
           "appRecordId": ApproveRecordsIds,"ObjId": component.get("v.LoanerId")
          });
          action.setCallback(this, function(response) {
           //store state of response
           var state = response.getState();
           if (state === "SUCCESS") {
            console.log(state);
            if (response.getReturnValue() != '') {
             // if getting any error while delete the records , then display a alert msg/
             console.log('The following records have been updated-->' + response.getReturnValue());
            } else {
             console.log('check it--> delete successful');
            }
            // call the onLoad function for refresh the List view    
            //this.onLoad(component, event);
           }
          });
  $A.enqueueAction(action);
 },
    RejectSelectedHelper: function(component, event, RejectRecordsIds) {
          //call apex class method
            var action = component.get('c.RejectRecords');
        
          // pass the all selected record's Id's to apex method 
          action.setParams({
           "rejRecordId": RejectRecordsIds
          });
          action.setCallback(this, function(response) {
           //store state of response
           var state = response.getState();
           if (state === "SUCCESS") {
            console.log(state);
            if (response.getReturnValue() != '') {
             // if getting any error while delete the records , then display a alert msg/
             console.log('The following records have been updated-->' + response.getReturnValue());
            } else {
             console.log('check it--> delete successful');
            }
            // call the onLoad function for refresh the List view    
            //this.onLoad(component, event);
           }
          });
  $A.enqueueAction(action);
 },
    ReassignSelectedHelper: function(component, event, ReassignRecordsIds) {
          //call apex class method
            var action = component.get('c.ReasignRecords');
        
          // pass the all selected record's Id's to apex method 
          action.setParams({
              "reassignRecordId": ReassignRecordsIds,"ReasignEmail":component.get("v.LeMail"),"ObjId": component.get("v.LoanerId")
          });
          action.setCallback(this, function(response) {
           //store state of response
           var state = response.getState();
           if (state === "SUCCESS") {
            console.log(state);
            if (response.getReturnValue() != '') {
             // if getting any error while delete the records , then display a alert msg/
             component.set("v.LOperationResult", response.getReturnValue());
                console.log('The following records have been Reassigned-->' + response.getReturnValue());
            } else {
             console.log('check it--> delete successful');
            }
            // call the onLoad function for refresh the List view    
            //this.onLoad(component, event);
           }
          });
  $A.enqueueAction(action);
 },
})