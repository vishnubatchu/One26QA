({
    handleSearchRecords : function (component, event, helper) {
        var searchText = component.find("searchinput").get("v.value");
        if(searchText){
            helper.searchRecord(component,searchText);
        }else{
            helper.searchRecord(component, '');
        }
    },
    
    handleLookupSelectEvent : function (component, event, helper) {
        var selectedRecordId = event.getParam("recordId");
        var selectedrecordName = event.getParam("recordName");
        component.set("v.selectedRecordId", selectedRecordId);
        component.set("v.selectedRecordName", selectedrecordName);
        helper.toggleLookupList(component, false, 'slds-combobox-lookup', 'slds-is-open');
    },
    
    hideList :function (component,event,helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    helper.toggleLookupList(component, false, 'slds-combobox-lookup','slds-is-open');
                }
            }), 200
        );
    },
    doInit: function(component) {
        
        component.set("v.URLName", window.location.pathname);
        console.log('URL----'+component.get("v.URLName"));
        
    },
    Save :function(component, event, helper) {
        console.log('inside Save--> '+component.get('v.selectedRecordId'));
        var recinstance = component.get("v.QuoteInstance");
        var lAccountId = component.get("v.selectedRecordId");
        if(lAccountId != undefined){
            // console.log('recinstance----'+JSON.stringify(recinstance)); 
            console.log('lAccountId5----'+JSON.stringify(component.get('v.selectedRecordId'))); 
            var action = component.get("c.saveQuote");
            console.log("action"+action);
            action.setParams({
                "aAccountId":component.get('v.selectedRecordId')
            });
            console.log("action"+action);
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
                console.log('result---'+result);
                console.log('state---'+state);
                if(result != null && state==='SUCCESS') {
                    console.log('testtt record successful');
                    component.set("v.QuoteInstance",result);
                    var quoteId = component.get("v.QuoteInstance.Id");
                    console.log('quoteId---'+quoteId);
                    var URLVal = component.get("v.URLName");
                    console.log('URLVal---'+URLVal);
                    if(URLVal == '/apex/AccountLookupPage'){
                        var replyEvent = $A.get("e.c:QuoteNewButtonEvent");
                        replyEvent.setParams({ "recordIdRec" : quoteId});
                        console.log('replyEvent'+replyEvent);
                        replyEvent.fire();   
                    }
                    /*
                   	     var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": quoteId,
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                    window.location.reload();*/
                }
                
            });
            $A.enqueueAction(action);   
        } else {
            component.set("v.ErrorMessage", 'Please Choose Account to create Quote');
        }
    }
})