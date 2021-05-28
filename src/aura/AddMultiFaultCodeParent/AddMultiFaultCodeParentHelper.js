({
    createObjectData: function(component, event,helper) {
        var RowItemList = component.get("v.FaultCodeList");
        RowItemList.push({
            'sobjectType': 'Failure_Modes__c',
            'FAFV_Analysis__c': component.get("v.recID"),
            'FAFV_Analysis__r': '',
            'Fault_Specification__c': '',
            'PDC_Level_1__c': '',
            'PDC_Level_2__c': '',
            'PIC_Level_1__c':'',
            'PIC_Level_2__c':'',
            'Site__c':'',
            'Traceability_Information__c' : '',
            'Component_Description__c' : ''
            
        });
        component.set("v.FaultCodeList", RowItemList);
        component.set("v.addRow", 'True');
    }
})