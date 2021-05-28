({
    doInit : function(component, event, helper) {
      
        $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
        $A.util.removeClass(component.find('Steps'), 'slds-is-active');
        $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
        // $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
        //$A.util.addClass(component.find('FA/FV'), 'slds-is-active');
        $A.util.addClass(component.find('SerialNumber'), 'slds-is-active');
        //show data
        $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
        $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
       // $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
       // $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
        $A.util.removeClass(component.find('showSerialNumber'), 'slds-hide');
        $A.util.addClass(component.find('showSerialNumber'), 'slds-show');
        $A.util.removeClass(component.find('showSteps'), 'slds-show');
        $A.util.addClass(component.find('showSteps'), 'slds-hide');
       // $A.util.removeClass(component.find('showFA/FV'), 'slds-hide');
       // $A.util.addClass(component.find('showFA/FV'), 'slds-show');
        $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
        $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
        var message = event.getParam("message");
        if(message != 'Record Saved' && message != 'Steps Saved' &&  message !='Fault Code Saved' &&  message !='Steps Deleted' &&  message !='FailureMode Deleted' &&  message !='Serial Number Deleted'){
            var idss =  event.getParam('arguments');
             var Step = component.find('steps');
            var FailureMode = component.find('FModes');
            component.set('v.fafvID' , idss.param2);
            if(idss.param4 == 'Finalized'){
              component.set('v.viewMode' , 'readonly'); 
                component.set('v.showAddBtn','false');
                component.find('FModes').makeReadonly('readonly','false');
            Step.SmakeReadonly('readonly','false');
            }else{
               
                component.set('v.viewMode' , 'view'); 
                component.set('v.showAddBtn','true');
                component.find('FModes').makeReadonly('view','true');
                Step.SmakeReadonly('view','true');
            }
           
            
            if(idss.param3 == 'FA Analysis'){
                component.set('v.ShowFV','false');
            component.set('v.ShowFA','true');

        }else if(idss.param3 == 'FV Analysis'){
            component.set('v.ShowFA','false');
           component.set('v.ShowFV','true');
        } 
        }
        var action = component.get('c.getFAFVrelatedList');
        action.setParams({
            'FAFVId' : component.get('v.fafvID'),
            'order'  : component.get('v.orderLineID')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.StepssList",response.getReturnValue().stepslList);  
                component.set("v.serialNoList",response.getReturnValue().sNoFinalList); 
                component.set("v.FailureModeList",response.getReturnValue().failureModeList);
                var result = response.getReturnValue().allSerialnolList;
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i].Name,
                        value: result[i].Id
                    });
                }
                component.set("v.allRelatedSerialNoList",plValues);
                var event = component.getEvent("hideSpinnerEvent");
                event.setParam("message", "Hide Spinner" );
                if(message != 'Record Saved' && message != 'Steps Saved' &&  message !='Fault Code Saved' &&  message !='Steps Deleted' &&  message !='FailureMode Deleted' && message !='Serial Number Deleted')
                event.fire();
                if(message == 'Record Saved'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('Steps'), 'slds-is-active');
                    $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
                    $A.util.addClass(component.find('SerialNumber'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-show');
                    $A.util.addClass(component.find('showSteps'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-show');
                    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: message,
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }
                 if(message == 'Serial Number Deleted'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('Steps'), 'slds-is-active');
                    $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
                    $A.util.addClass(component.find('SerialNumber'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-show');
                    $A.util.addClass(component.find('showSteps'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-show');
                    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Record Deleted',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }
                if(message == 'Steps Saved'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
                    $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
                    $A.util.addClass(component.find('Steps'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-hide');
                    $A.util.addClass(component.find('showSteps'), 'slds-show');
                      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Record Saved',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }  
             if(message == 'Steps Deleted'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
                    $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
                    $A.util.addClass(component.find('Steps'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-hide');
                    $A.util.addClass(component.find('showSteps'), 'slds-show');
                      var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Record Deletd',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }     
                if(message == 'Fault Code Saved'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('Steps'), 'slds-is-active');
                    $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
                    $A.util.addClass(component.find('FailureMode'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-show');
                    $A.util.addClass(component.find('showSteps'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-show'); 
                         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Record Saved',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }
                
                if(message == 'FailureMode Deleted'){
                    $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
                    $A.util.removeClass(component.find('Steps'), 'slds-is-active');
                    $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
                    $A.util.addClass(component.find('FailureMode'), 'slds-is-active');
                    //show data
                    $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
                    $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
                    $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
                    $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
                    $A.util.removeClass(component.find('showSteps'), 'slds-show');
                    $A.util.addClass(component.find('showSteps'), 'slds-hide');
                    $A.util.removeClass(component.find('showFailureMode'), 'slds-hide');
                    $A.util.addClass(component.find('showFailureMode'), 'slds-show'); 
                         var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Record Deleted',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 500',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleSubmit : function(component, event, helper) {
        var event = component.getEvent("lightningEvent1");
        event.setParam("message", "FAFV Record Saved" );
        event.fire();
    },
    showDetail : function(component, event, helper) {
        var target = event.currentTarget.dataset.value;
        if(target === 'Steps'){
            $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
            $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
            $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
            $A.util.addClass(component.find('Steps'), 'slds-is-active');
            //show data
            $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
            $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
            $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
            $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
            $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
            $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
            $A.util.removeClass(component.find('showSteps'), 'slds-hide');
            $A.util.addClass(component.find('showSteps'), 'slds-show');
        } else if(target === 'SerialNumber'){
            $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
            $A.util.removeClass(component.find('Steps'), 'slds-is-active');
            $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
            $A.util.addClass(component.find('SerialNumber'), 'slds-is-active');
            //show data
            $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
            $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
            $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
            $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
            $A.util.removeClass(component.find('showSteps'), 'slds-show');
            $A.util.addClass(component.find('showSteps'), 'slds-hide');
            $A.util.removeClass(component.find('showSerialNumber'), 'slds-hide');
            $A.util.addClass(component.find('showSerialNumber'), 'slds-show');
        }else if(target === 'FailureMode'){
            $A.util.removeClass(component.find('FA/FV'), 'slds-is-active');
            $A.util.removeClass(component.find('Steps'), 'slds-is-active');
            $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
            $A.util.addClass(component.find('FailureMode'), 'slds-is-active');
            //show data
            $A.util.removeClass(component.find('showFA/FV'), 'slds-show');
            $A.util.addClass(component.find('showFA/FV'), 'slds-hide');
            $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
            $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
            $A.util.removeClass(component.find('showSteps'), 'slds-show');
            $A.util.addClass(component.find('showSteps'), 'slds-hide');
            $A.util.removeClass(component.find('showFailureMode'), 'slds-hide');
            $A.util.addClass(component.find('showFailureMode'), 'slds-show');
        }else if(target === 'FA/FV'){
            $A.util.removeClass(component.find('FailureMode'), 'slds-is-active');
            $A.util.removeClass(component.find('Steps'), 'slds-is-active');
            $A.util.removeClass(component.find('SerialNumber'), 'slds-is-active');
            $A.util.addClass(component.find('FA/FV'), 'slds-is-active');
            //show data
            $A.util.removeClass(component.find('showFailureMode'), 'slds-show');
            $A.util.addClass(component.find('showFailureMode'), 'slds-hide');
            $A.util.removeClass(component.find('showSerialNumber'), 'slds-show');
            $A.util.addClass(component.find('showSerialNumber'), 'slds-hide');
            $A.util.removeClass(component.find('showSteps'), 'slds-show');
            $A.util.addClass(component.find('showSteps'), 'slds-hide');
            $A.util.removeClass(component.find('showFA/FV'), 'slds-hide');
            $A.util.addClass(component.find('showFA/FV'), 'slds-show');
        }
    },
    
   
    
})