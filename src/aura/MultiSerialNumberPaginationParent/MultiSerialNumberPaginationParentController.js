({
	  doInit : function(component, event, helper) {
          
        
    },
    setStartandEndPoint:function(component,event)
    {
       
        component.set('v.startPoint',event.getParam('startPoint'));
        component.set('v.endPoint',event.getParam('endPoint'));
    }
    
})