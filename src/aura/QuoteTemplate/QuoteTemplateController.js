({
    doInit : function(component, event) {
        var action = component.get("c.getQuoteDetails");
        console.log('component.get("v.qteId")'+component.get("v.qteId"));
        action.setParams({
            "recId":component.get("v.qteId")
        });
        action.setCallback(this, function(a) {
            console.log('return values',a.getReturnValue());
            component.set("v.qteRec", a.getReturnValue());
            console.log(component.get("v.qteRec"));
        });
        $A.enqueueAction(action);
    }
})