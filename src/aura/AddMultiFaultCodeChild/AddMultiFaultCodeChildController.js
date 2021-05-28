({
    doInit : function(component, event, helper) { 
        var cntrFiled = '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0'+'SITE' + '\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0' ;
        component.set("v.cntrFieldName" , cntrFiled);
    },
    AddNewRow : function(component, event, helper){
        component.getEvent("AddRowEvt").fire();     
    },
    removeRow : function(component, event, helper){
        var deletRow = event.currentTarget.dataset.value;
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
    
})