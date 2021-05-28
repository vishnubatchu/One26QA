({
     doInit: function(component, event, helper){
       /* var recId = component.get("v.QuoteItemInstance.Id");
        //console.log('recId=='+recId);
        /*var action = component.get("c.getLineStatus");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var ResultMap= new Map();
            ResultMap = result;
            for(var k in ResultMap){
                if(k.includes('LineStatus'))
                {
                    component.set("v.LineStatus",ResultMap[k]);
                    
                }
                if(k.includes('ProductName'))
                {
                    component.set("v.productname",ResultMap[k]);
                }
            }
            console.log('LineStatus'+component.get("v.LineStatus"));
            console.log('productname'+component.get("v.productname"));
           
        });
        $A.enqueueAction(action);*/
         console.log('LineStatus'+component.get("v.LineStatus"));
            console.log('productname'+component.get("v.productname"));
    }, 
	  AddNewRow : function(component, event, helper){
       component.getEvent("AddRowEvt").fire();     
    },
    
    removeRow : function(component, event, helper){
         var rec = component.get("v.QuoteItemInstance");
        var action = component.get("c.deleteLoanerLineItem");
        action.setParams({
            "quoteLine":rec
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result==='+result);
         });
        $A.enqueueAction(action);
      component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    } 
})