({
    doInit: function(component, event, helper){
        /*var recId = component.get("v.LineItemInstance.Id");
        console.log('recId=='+recId);
        var action = component.get("c.getRecordType");
        action.setParams({
            "recordId":recId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result--> '+JSON.stringify(result));
            var ResultMap= new Map();
            ResultMap = result;
            for(var k in ResultMap){
                if(k.includes('RecordType'))
                {
                    component.set("v.recordtypename",ResultMap[k]);
                    
                }
                if(k.includes('ProductName'))
                {
                    component.set("v.productname",ResultMap[k]);
                }
            }
            
        });
        $A.enqueueAction(action);*/
        
        console.log('recordtype'+component.get("v.recordtypename"));
            console.log('productname'+component.get("v.productname"));
    }, 
    AddNewRow : function(component, event, helper){
        component.getEvent("AddRowEvt").fire();     
    },
    
    removeRow : function(component, event, helper){
        var rec = component.get("v.LineItemInstance");
        var action = component.get("c.deleteLoanerLineItem");
        action.setParams({
            "lonerLine":rec
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result==='+result);
         });
        $A.enqueueAction(action);
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }
})