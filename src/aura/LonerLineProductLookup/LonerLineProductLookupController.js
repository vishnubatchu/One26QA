({
    doInit : function(component, event, helper){
        var lonerline =component.get("v.lonerLineItem");
        console.log('lonerline--'+lonerline);
        console.log('lonerlineitem--'+component.get("v.lonerLineItem.Product__c"));
       component.set("v.dummyLonerLineItem",lonerline);
      
    },
	ChangeProduct : function(component, event, helper) {
		var productid= component.get("v.lonerLineItem.Product__c");
        console.log('productid---'+productid);
        if(productid !== undefined && productid.length == 1) {
        	component.set("v.lonerLineItem.Product__c", productid[0]);
        }else if(productid == null || productid=='')
        {
            component.set("v.lonerLineItem.Product__c", "");
        }
	}
})