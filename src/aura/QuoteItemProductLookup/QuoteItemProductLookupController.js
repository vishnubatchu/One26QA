({
	 doInit : function(component, event, helper){
        var quoteline =component.get("v.QuoteLineItem");
        console.log('quoteline--'+quoteline);
       component.set("v.dummyQuoteLineItem",quoteline);
      
    },
	ChangeProduct : function(component, event, helper) {
		var productid= component.get("v.dummyQuoteLineItem.Product__c");
        
        if(productid !== undefined && productid.length == 1) {
            console.log('product isd');
        	component.set("v.QuoteLineItem.Product__c", productid[0]);
        }else if(productid == null || productid=='')
        {
            component.set("v.QuoteLineItem.Product__c", "");
        }
	}
})