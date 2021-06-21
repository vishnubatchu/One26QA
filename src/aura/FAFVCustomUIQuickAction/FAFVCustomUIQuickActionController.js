({
    init : function(component, event, helper) {
        //  console.log('recordId'+component.get('v.recordId'));
        // var pgref = component.get('v.pageReference');
        let workspaceAPI = component.find("workspace");
        let recId = component.get('v.recordId');
        let tabId ;
        if($A.util.isEmpty(recId) ){
            recId = component.get("v.pageReference").state.c__recordId;
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
              //  workspaceAPI.closeTab({tabId: focusedTabId});
            })
        }
        // Added by surendar
	//var workspaceAPI1 = component.find("workspace");        
        //  console.log('recordId'+component.get('v.recordId'));
        
        workspaceAPI.openTab({
            url: '/lightning/r/Order_Line__c/'+recId+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/cmp/c__FAFVCustomUI?c__recID='+recId,
                focus: true,
                customTitle : 'customTitle'
            });
           // workspaceAPI.getFocusedTabInfo().then(function(response) {
           // workspaceAPI.isSubtab({
           //console.log('response',response);
             //   tabId: response.tabId
            //})
            //});
            console.log('tabId'+tabId);
            console.log('test');
          /*  workspaceAPI.getFocusedSubtabInfo().then(function(response) {
            var focusedTabId = response.tabId;
                console.log('focusedTabId'+focusedTabId);
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Focused Tab"
            });
        })*/
        })
        .catch(function(error) {
            console.log('error '+error);
        });
        //  console.log('pgref 1 '+pgref);
        //console.log('pgref 1 '+pgref.state);
        //  var statepg =  json.Stringify(pgref.state);
        //console.log('pgref 1 '+statepg);
        //console.log('pgref '+component.get("v.pageReference").state.uid);
        //console.log('pgref '+component.get("v.pageReference").state.c__recordId);
        //component.set('v.recordId', component.get("v.pageReference").state.c__recordId);
        /*  var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__FAFVCustomUI',
            },
            state: {
                "c__recID": component.get('v.recordId')
            }
        };
        component.set("v.pageReference", pageReference);*/
        //  component.set("v.myBool", false);
    },
  //  handleClick: function(component, event, helper) {
        // var navService = component.find("navService");
        // var pageReference = component.get("v.pageReference");
        //	 var defaultUrl = "#";
        /* navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                 console.log('navService');
                 console.log('URL',url);
               window.open(url, '_parent ');
            }), $A.getCallback(function(error) {
            }));*/
         // location.reload();
         // 
         // Added by surendar
        /* var workspaceAPI = component.find("workspace");
         console.log('recordId'+component.get('v.recordId'));
         workspaceAPI.openTab({
             url: '/lightning/r/Order_Line__c/'+component.get('v.recordId')+'/view',
             focus: true
         }).then(function(response) {
             workspaceAPI.openSubtab({
                 parentTabId: response,
                 url: '/lightning/cmp/c__FAFVCustomUI?c__recID='+component.get('v.recordId'),
                 focus: true
             });
         })
         .catch(function(error) {
             console.log(error);
         });
     }*/
})