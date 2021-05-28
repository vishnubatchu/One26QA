({
    doInit: function(component, event, helper) {
        helper.getLineItem(component, event,helper);

    },
   Validate: function(component, event, helper) {
        var quotelineitems = component.get('v.QuoteLineItemList');
        var errorMsg ='';
        var productIdSet = new Set();
        for(var i=0;i<quotelineitems.length;i++)
        {
            var quotelineobj= quotelineitems[i];
            console.log(JSON.stringify(quotelineobj));
            console.log('Line 15 ',quotelineobj.Product__c);
            if(quotelineobj.Product__r == null)
            {
                if(errorMsg !== '')
                    errorMsg +=','+(i+1);
                else
                    errorMsg ='Required Field Product is required At Rows '+(i+1);  
            } /*else {
                console.log('quotelineobj.Product__c',quotelineobj.Product__c);
                if(productIdSet.has(quotelineobj.Product__c)){
                    if(errorMsg !== '')
                    errorMsg +=','+(i+1);
                else
                    errorMsg ='Duplicate Line found with same product '+quotelineobj.Product__c +(i+1); 
                } else {
                    productIdSet.add(quotelineobj.Product__c);
                }
            }*/
            
            
        }
        component.set('v.errorMessage1',errorMsg);
        if(!errorMsg)
            helper.SaveRecord(component, event, helper);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event,helper);
    },
 
    removeDeletedRow: function(component, event, helper) {
       var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.QuoteLineItemList");
        AllRowsList.splice(index, 1);
        component.set("v.QuoteLineItemList", AllRowsList);
    },
    Cancel :function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire(); 
    },
     Save :function(component, event, helper){
     	var quotelineitems = component.get('v.QuoteLineItemList');
         var errorMsg ='';
        for(var i=0;i<quotelineitems.length;i++)
        {
            var quotelineobj= quotelineitems[i];
            if(quotelineobj.Product__r == null)
              {
                  if(errorMsg !== '')
                      errorMsg +=','+(i+1);
                  else
                      errorMsg ='Required Field Product is required At Row '+(i+1);  
              }
           
            
        }
         component.set('v.errorMessage1',errorMsg);
         if(!errorMsg)
     		helper.Save(component, event, helper);
     },
})