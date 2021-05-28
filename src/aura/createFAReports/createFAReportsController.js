({
    doInit: function(component, event, helper) {
        component.set("v.showDiv1", 'true');
        
        var action = component.get('c.getSerialNumber');
        var idss = component.get('v.recordId');
        action.setParams({
            'orderID' : idss,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i].Name,
                        value: result[i].Id
                    });
                }
                component.set("v.GenreList", plValues);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleGenreChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.selectedGenreList", selectedValues);
    },
    
    /*getSelectedGenre : function(component, event, helper){
        component.set("v.showDiv1", 'false');
        console.log('divv ' + component.get('v.showDiv1'));
        var selectedValues = component.get("v.selectedGenreList");
        var action = component.get('c.getFADetails');
        action.setParams({
            'serialNoID' : selectedValues,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                
                component.set("v.showDiv2", 'True');
                console.log('divv2 ' + component.get('v.showDiv2'));
                
                component.set("v.faList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },*/
    generateReport :function(component, event, helper){
        var selectedValues = component.get("v.selectedGenreList");
        helper.downloadPdfFile(component,event,helper);
    }
})