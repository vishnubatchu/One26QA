({
    doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var recids = myPageRef.state.c__recID;
        var action = component.get("c.getSONumber");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "FAFV"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "action:new_task",
                iconAlt: "FAFV"
            });
        });
        action.setParams({"orderlineId": recids});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.soNumber", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        console.log('test!!!!!');
        
        var childCmp = component.find('childCmp1');
        childCmp.getRecID(recids);
        
    },
    closeUi : function(component, event,helper){
        //window.close();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    openFVFA : function(component, event,helper){
        component.find('childCmp1').OpenFVFAPopUp();
    },
    cloneFVFA : function(component, event,helper){
        component.find('childCmp1').CloneFAFV();
    },
})