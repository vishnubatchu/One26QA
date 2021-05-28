({
	doInit : function(component, event, helper) {
		
        var tempvar = decodeURIComponent(window.location.search.substring(1));
        var temp1 = tempvar.substr(0,3);
        var temp2 = tempvar.substr(4,30);
        component.set("v.ObjType",temp1);
        component.set("v.ObjRec",temp2);
        
		
	}
})