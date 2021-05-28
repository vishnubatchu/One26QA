({
	invoke : function(component, event, helper) {
		
        var redirectSobjectEvent= $A.get('e.force:navigateToSObject');
           console.log('fired redirectURL' +component.get("v.loanerRequest"));
        
        redirectSobjectEvent.setParams({
            "recordId" :component.get("v.loanerRequest")
        })
        console.log('fired redirectURL' +redirectSobjectEvent);
        redirectSobjectEvent.fire();
	}
})