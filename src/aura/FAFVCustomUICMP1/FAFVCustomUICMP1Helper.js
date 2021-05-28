({
    getFAFVList : function(component, event) {
        console.log('get FAFV list');
        var action = component.get('c.getFAFVRecord');
        if(event.getParam('arguments').param1  ){
            component.set("v.orderId", event.getParam('arguments').param1);
        }
        action.setParams({
            'orderID' : component.get("v.orderId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
               
                component.set("v.SerialNoList", response.getReturnValue().sNoFinalList);
                component.set("v.FAFVList", response.getReturnValue().fafvAnalysisList);
                component.set("v.SerialNoMap", response.getReturnValue().SerialNoMap);
            }
        });
        $A.enqueueAction(action);
    },
    cloneFAFVRecordhelper : function(component,event,helper, fafvid, oldFaRec){
        var action = component.get('c.cloneFAFVRec');
        var idss =   component.get('v.orderId');
       // var fafv = component.get('v.FADetail');
        action.setParams({
            //'newfafvRec' : component.get('v.FADetail'),
            'fafvID' : fafvid,
            'oldfafvRec' : oldFaRec
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var res = response.getReturnValue();
                component.set("v.FAFVList", res.fafvList);
                var cmpTarget = component.find('openExistingFA'); 
                $A.util.removeClass(cmpTarget, 'slds-show');
                $A.util.addClass(cmpTarget, 'slds-hide');
                
                //default select 
                window.setTimeout(
                    $A.getCallback(function() {        
                        var childCmp = component.find('childCmp2');
                        //var ids = component.get('v.FADetail').FA_FV__c;
                        var ids = fafvid;
                        component.set('v.DefaultValue',ids);
                        var child2 = document.getElementById(ids);
                        $A.util.addClass(child2, 'selected');
                        var mapObject= component.get('v.SerialNoMap');
                        component.set('v.currentFVFAID',ids);              
                        component.set('v.AssignedSNoList' , mapObject[ids]);
                        component.set('v.ShowRelatedSno' , 'True');
                        $A.util.removeClass(component.find('showTab'), 'slds-hide');
                        $A.util.addClass(component.find('showTab'), 'slds-show');
                        var recordType  ;
                        var Status  ;
                        for(var analysis in component.get('v.FAFVList') ){
                            if(component.get('v.FAFVList')[analysis].Id == ids){
                                recordType =  component.get('v.FAFVList')[analysis].RecordType.Name; 
                                Status     =  component.get('v.FAFVList')[analysis].FA_FV_Status__c; 
                            }
                            
                        } 
                        childCmp.getFARecID(ids,recordType,Status);
                        var spin = component.find('sps');
                        $A.util.toggleClass(spin,'slds-hide');
                        $A.util.addClass(ids, 'selected');
                    }), 1000
                );
            }
            alert("Clone Successfully Record Name is "+res.cloneFaFvName);
        });
        $A.enqueueAction(action);
    },
 })