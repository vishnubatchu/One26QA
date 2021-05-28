({
    ShowProducts : function(component, event, helper) {
        component.set('v.Message', '');
         component.set('v.disBtn', "false");
        var ProductGrp = component.get('v.productGroup');
        var ProductFmly = component.get('v.productFamily');
        var MarketingFamily = component.get('v.MarketingPN');
        console.log('ProductGrp '+ProductGrp+' ProductFmly '+ProductFmly+'  MarketingPN '+MarketingFamily);
        console.log($A.util.isEmpty(ProductFmly));
        if($A.util.isEmpty(ProductGrp)  && $A.util.isEmpty(ProductFmly) && $A.util.isEmpty(MarketingFamily)){
            console.log($A.util.isEmpty(ProductGrp));
            component.set('v.Message', 'Please enter any one value');
        } else {
            var action = component.get('c.getProducts');
            action.setParams({
                'productCode' : ProductGrp,
                'produtFamily' : ProductFmly,
                'marketingFamily' :MarketingFamily
            });
            action.setCallback(this,function(response){
                console.log(response.getState());
                if(response.getState() === 'SUCCESS'){
                     component.set('v.disBtn', "true");
                    console.log(response.getReturnValue());
                    var prds = response.getReturnValue();
                    console.log(' no of products : '+prds.count);
                    
                    if(prds.count <= 50){
                        $A.util.removeClass(component.find('div1'), 'slds-hide');
                        $A.util.removeClass(component.find('tbl'), 'slds-hide');
                        $A.util.addClass(component.find('MessageDiv'), 'slds-hide');
                    } else {
                        $A.util.removeClass(component.find('div1'), 'slds-hide');
                        $A.util.removeClass(component.find('MessageDiv'), 'slds-hide');
                        $A.util.addClass(component.find('tbl'), 'slds-hide');
                        component.set('v.noOfprds', prds.count);
                    }
                    // component.find('tbl').removeClass('slds-hide');
                    
                    component.set('v.Products', prds.productList);
                }
                
            });
            $A.enqueueAction(action); 
        }
    },
    updateProducts : function(component, event, helper) {
        // event.getSource().set("v.disabled", true);
        component.set('v.disBtn', "false");
        var products = component.get('v.Products');
        console.log(products);
        var stringifyprd = JSON.stringify(products);
        console.log('stringifyprd '+stringifyprd);
        var leadtime = component.get('v.LeadTime');
        var action = component.get('c.updateProductsData');
        action.setParams({
            'leadTime' : leadtime,
            'products' : stringifyprd
        });
        
        action.setCallback(this, function(response){
            component.set('v.disBtn', "true");
            if(response.getState() === 'SUCCESS'){
                component.set('v.Products', response.getReturnValue());
                //$A.util.removeClass(component.find('div1'), 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Lead time has been updated successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})