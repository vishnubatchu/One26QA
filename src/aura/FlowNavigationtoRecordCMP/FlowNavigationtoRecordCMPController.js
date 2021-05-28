({
	invoke : function(component, event, helper) {
		console.log('1111'+component.get('v.newRecord'));
        var navigationEvt= $A.get('e.force:navigateToSObject');
          
        navigationEvt.setParams({
            "recordId" :component.get('v.newRecord')
        });
        
        navigationEvt.fire();
	}
})