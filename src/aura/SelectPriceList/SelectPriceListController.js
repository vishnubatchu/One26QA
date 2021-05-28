({
	doInit : function(component, event, helper) {
        var temp = component.get("v.recordId");
        component.set("v.QuoteId",temp);
        var action = component.get("c.PriceListQuery");
        action.setParams({ "quoteId": component.get("v.QuoteId") });
        action.setCallback( this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              var result = response.getReturnValue();
              if(result.errorMessage != null) {
                component.set("v.ErrorMessage",result.errorMessage);
                }  else if(result.AccountPriceListOutput != null) {
                component.set("v.AccountPickLists",result.AccountPriceListOutput);
                }
               	// component.set("v.AccountPickLists", response.getReturnValue());
                //console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
      },
    UpdatePriceList : function(component, event, helper) {
       		  var UpdateValue = [] ;
  			 var SelectedRecords = 0 ;
              // get all checkboxes 
              var getAllId = component.find("boxPack");
              // If the local ID is unique[in single record case], find() returns the component. not array
                 if(! Array.isArray(getAllId)){
                     if (getAllId.get("v.value") == true) {
                       UpdateValue.push(getAllId.get("v.text"));
                        SelectedRecords += 1;
                     }
                 }else{
                 // play a for loop and check every checkbox values 
                 // if value is checked(true) then add those Id (store in Text attribute on checkbox) in delId var.
                 for (var i = 0; i < getAllId.length; i++) {
                   if (getAllId[i].get("v.value") == true) {
                     UpdateValue.push(getAllId[i].get("v.text"));
                     SelectedRecords += 1;
                   }
                  }
                 } 
        			
        			var TempPValue = UpdateValue[0];
        
                    var action = component.get("c.PriceListUpdate");
        if(SelectedRecords == 1){
        			action.setParams({ "quoteId": component.get("v.QuoteId"),"pricelist": TempPValue});
                    action.setCallback( this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                           console.log(response.getReturnValue());
                            $A.get("e.force:closeQuickAction").fire();
                			$A.get('e.force:refreshView').fire();
                        }
                    });
                    $A.enqueueAction(action);
        }else{component.set("v.ErrorMessage",'Please Select one of the available Pricelists');}   
        
      },
		
	
})