({
	doInit : function(component, event, helper) {
		console.log('Clone Function');
        helper.loadFAFVRecord(component,event);
      
        console.log('Clone Function helper');
	},
    fireToastMessage:function(component,event,helper){
        console.log('Inside Method');
        fireToastMessage2()
     
        
    },
    fireToastMessage2:function(){
        console.log('Inside Method');
        
     
        
    },
})