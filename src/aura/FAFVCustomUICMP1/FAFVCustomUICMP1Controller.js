({
    doInit : function(component, event, helper) {
        
        console.log('FAFV Custom UI CMP 1');
        helper.getFAFVList(component,event);
        $A.util.addClass(component.find('openExistingFA'), 'slds-hide');
        // $A.util.addClass(component.find('openDisposition'), 'slds-hide');
        $A.util.addClass(component.find('showTab'), 'slds-hide');
        $A.util.removeClass(component.find('openExistingFA'), 'slds-show');
        $A.util.removeClass(component.find('showTab'), 'slds-show');
        //default select 
        window.setTimeout(
            $A.getCallback(function() { 
                var ids = component.get('v.FAFVList')[0];
                
                if(ids != null)
                    component.set("v.myBool", false);
            }), 1300
        );
        
    },
    selectDefault : function(component, event, helper){
        var childCmp = component.find('childCmp2');
        var ids = component.get('v.FAFVList')[0].Id;
        component.set('v.DefaultValue',ids);
        component.set('v.currentFVFAID',ids);
        var child2 = document.getElementById(ids);
        $A.util.addClass(child2, 'selected');
        var mapObject= component.get('v.SerialNoMap');
        component.set('v.AssignedSNoList' , mapObject[ids]);
        component.set('v.ShowRelatedSno' , 'True');
        $A.util.removeClass(component.find('showTab'), 'slds-hide');
        $A.util.addClass(component.find('showTab'), 'slds-show');
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        $A.util.addClass(ids, 'selected'); 
        childCmp.getFARecID(ids,component.get('v.FAFVList')[0].RecordType.Name,component.get('v.FAFVList')[0].FA_FV_Status__c);
    },
    refresh : function(component, event, helper) {
        component.set("v.eventMessage", 'select');
        $A.util.addClass(component.get('v.previousRow'), 'selected');
        var action = component.get('c.getFAFVRecord');
        action.setParams({
            'orderID' : component.get("v.orderId"),
        });
        action.setCallback(this, function(response) {
            $A.util.addClass(component.get('v.previousRow'), 'selected');
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.SerialNoList", response.getReturnValue().sNoFinalList);
                component.set("v.FAFVList", response.getReturnValue().fafvAnalysisList);
                component.set("v.SerialNoMap", response.getReturnValue().fafvSerialNoMap);
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.util.addClass(document.getElementById(component.get('v.previousRow')), 'selected');
                    }), 1000
                );
            }
        });
        $A.enqueueAction(action);
    },
    showDisposition : function(component, event, helper) {
        var Disposition  = event.currentTarget.dataset.value; 
        // console.log(JSON.stringify(event.currentTarget.dataset.value)+'serial number clicked');
        component.set("v.DispositionID" ,Disposition );
        console.log('idsREc' + component.get('v.DispositionID'));
        if(component.get('v.DispositionID') != null){
            component.set('v.ShowDispositionID','true');
            console.log('idsREc' + component.get('v.DispositionID'));
            // $A.util.removeClass(component.find('openDisposition'), 'slds-hide');
            //     $A.util.addClass(component.find('openDisposition'), 'slds-show');
        }
    }, 
    openModel: function(component, event, helper) {
        var cmpTarget2 = component.find('openExistingFA');
        $A.util.removeClass(cmpTarget2, 'slds-hide');
        $A.util.addClass(cmpTarget2, 'slds-show');
    },
    closeModel: function(component, event, helper) {
        var message = event.getParam("message");
        if(message == 'Record Saved' || message == '' || message == null ||  message == 'Steps Saved' ||  message =='Fault Code Saved' || message =='Steps Deleted' || message =='FailureMode Deleted' || message =='Serial Number Deleted')
            var action = component.get('c.getFAFVRecord');
        action.setParams({
            'orderID' : component.get("v.orderId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                
                component.set("v.SerialNoMap", response.getReturnValue().SerialNoMap);
                var mapObject= component.get('v.SerialNoMap');
                component.set('v.AssignedSNoList' ,response.getReturnValue().SerialNoMap[component.get('v.currentFVFAID')] );
            }
        });
        $A.enqueueAction(action);
        var cmpTarget = component.find('openExistingFA'); 
        component.set('v.ShowDispositionID','false');
        $A.util.removeClass(cmpTarget, 'slds-show');
        $A.util.addClass(cmpTarget, 'slds-hide');
        // $A.util.removeClass(component.find('openDisposition'), 'slds-show');
        //  $A.util.addClass(component.find('openDisposition'), 'slds-hide');
    },
    saveFAFVRecord : function(component,event,helper){
        var action = component.get('c.saveFAFV');
        var idss =   component.get('v.orderId');
        action.setParams({
            'newfafvRec' : component.get('v.FADetail'),
            'oldfafvRec' : component.get('v.FAFVList')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.FAFVList", response.getReturnValue());
                var cmpTarget = component.find('openExistingFA'); 
                $A.util.removeClass(cmpTarget, 'slds-show');
                $A.util.addClass(cmpTarget, 'slds-hide');
                
                //default select 
                window.setTimeout(
                    $A.getCallback(function() {        
                        var childCmp = component.find('childCmp2');
                        var ids = component.get('v.FADetail').FA_FV__c;
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
        });
        $A.enqueueAction(action);
    },
    getFVFVDetails : function(component,event,helper){
        component.set('v.FAFVFields',component.get('v.DummyFAFVFields'));
        var count ;
        var spin = component.find('sps');
        $A.util.toggleClass(spin,'slds-hide');
        var childCmp = component.find('childCmp2');
        var ids = event.currentTarget.dataset.value;
        component.set('v.currentFVFAID',ids); 
        if(ids != null || ids == ''){
            $A.util.removeClass(document.getElementById(component.get('v.DefaultValue')), 'selected');                 
        }
        if(component.get('v.previousRow') === ''){
            component.set('v.previousRow',ids);
            $A.util.addClass(document.getElementById(ids), 'selected'); 
        }else{
            $A.util.removeClass(document.getElementById(component.get('v.previousRow')), 'selected'); 
            component.set('v.previousRow',ids);
            $A.util.addClass(document.getElementById(ids), 'selected'); 
        }
        var child2 = document.getElementById(ids);
        $A.util.addClass(child2, 'selected');
        var mapObject= component.get('v.SerialNoMap');
        component.set('v.AssignedSNoList' , mapObject[ids]);
        component.set('v.ShowRelatedSno' , 'True');
        $A.util.removeClass(component.find('showTab'), 'slds-hide');
        $A.util.addClass(component.find('showTab'), 'slds-show');
        var recordType ;
        var Status   ; 
        for(var analysis in component.get('v.FAFVList') ){
            if(component.get('v.FAFVList')[analysis].Id == ids){
                recordType =  component.get('v.FAFVList')[analysis].RecordType.Name; 
                Status   = component.get('v.FAFVList')[analysis].FA_FV_Status__c;
            }
            
        }
        
        childCmp.getFARecID(ids,recordType,Status); 
    },
    StopSpinner  : function(component,event,helper){
        var message = event.getParam("message");
        if(message ='Hide Spinner'){
            $A.util.toggleClass(component.find('sps'),'slds-hide'); 
        }
    },
    CloneFAFV : function(component,event,helper){
        helper.cloneFAFVRecordhelper(component,event,helper, component.get('v.currentFVFAID'), component.get('v.FAFVList') );
      /*  var getFAFVRecordAction = component.get('c.cloneFAFV');
        getFAFVRecordAction.setParams({
            'FAFVRecId' :component.get('v.currentFVFAID')
        });
        getFAFVRecordAction.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                alert("Clone Successfully Record Name is "+response.getReturnValue());
            }
        });
        
        $A.enqueueAction(getFAFVRecordAction);
        */
    },
    cloneFAFVRecord : function(component,event,helper){
        var fafv = component.get('v.FADetail');
      helper.cloneFAFVRecordhelper(component,event,helper, fafv.FA_FV__c, component.get('v.FAFVList') );
        /* var action = component.get('c.cloneFAFVRec');
        var idss =   component.get('v.orderId');
        var fafv = component.get('v.FADetail');
        action.setParams({
            //'newfafvRec' : component.get('v.FADetail'),
            'fafvID' : fafv.FA_FV__c,
            'oldfafvRec' : component.get('v.FAFVList')
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
                        var ids = component.get('v.FADetail').FA_FV__c;
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
        */
    },
})