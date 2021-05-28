({
    doInit: function(component, event, helper) {
         $A.util.removeClass(component.find('openExistingFA1'), 'slds-show');
        $A.util.addClass(component.find('openExistingFA1'), 'slds-hide');
         $A.util.removeClass(component.find('openExistingFA2'), 'slds-show');
         $A.util.addClass(component.find('openExistingFA2'), 'slds-hide');
        var val =  event.getParam('arguments');
        component.set('v.editAccess',val.param4);
        component.set('v.editMode',val.param5);
    },
    saveFcode : function(component, event, helper){
              var event = component.getEvent("lightningEvent");
event.setParam("message", "Fault Code Saved" );
event.fire();
       component.set('v.faultCodeNewShow',false); 
     //    $A.util.removeClass(component.find('openExistingFA1'), 'slds-show');
//        $A.util.addClass(component.find('openExistingFA1'), 'slds-hide');
  
 //          $A.util.removeClass(component.find('openExistingFA2'), 'slds-show');
   //      $A.util.addClass(component.find('openExistingFA2'), 'slds-hide');
    },
    addNewRow: function(component, event, helper) {
       
     
        component.set('v.faultCodeNewShow',true);
        // $A.util.removeClass(component.find('openExistingFA1'), 'slds-hide');
       //  $A.util.addClass(component.find('openExistingFA1'), 'slds-show');
      //  helper.createObjectData(component, event);
    },
    onRecordSubmit:function(component, event, helper) {
  var eventFields = event.getParam("fields");
  eventFields["FAFV_Analysis__c"] = component.get('v.recID');
  component.find('recordForm1').submit(eventFields);
    },
    removeDeletedRow: function(component, event, helper) {
       // var index = event.getParam("indexVar");
         var deletRow = event.currentTarget.dataset.value;
        var action = component.get('c.deleteRow');
         action.setParams({
            'ids' : deletRow,
        });
         action.setCallback(this, function(response) {
              var state = response.getState();
            if (state === "SUCCESS"){
                var event = component.getEvent("lightningEvent");
        event.setParam("message", "FailureMode Deleted" );
        event.fire();

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
       /** var AllRowsList = component.get("v.FaultCodeList");
        AllRowsList.splice(index, 1);
        component.set("v.FaultCodeList", AllRowsList); **/
    },
    Cancel :function(component, event, helper){
         component.set('v.faultCodeNewShow',false);
         component.set('v.faultCodeEdit',false);
        //commented below code to
        //$A.util.removeClass(component.find('openExistingFA1'), 'slds-show');
       //  $A.util.addClass(component.find('openExistingFA1'), 'slds-hide');
      //     $A.util.removeClass(component.find('openExistingFA2'), 'slds-show');
     //    $A.util.addClass(component.find('openExistingFA2'), 'slds-hide');
    },
    EditRecord : function(component,event,helper){
         var idsss = event.currentTarget.dataset.value;
        component.set('v.faultCodeId',idsss);
   		 component.set('v.faultCodeEdit',true);
    //     $A.util.removeClass(component.find('openExistingFA2'), 'slds-hide');
    //     $A.util.addClass(component.find('openExistingFA2'), 'slds-show');
   
}
})