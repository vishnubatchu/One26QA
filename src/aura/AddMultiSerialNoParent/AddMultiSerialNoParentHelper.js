({
    createObjectData: function(component, event,helper) {
        var selectedSno = component.get("v.selectedSerialNo");
        var RowItemList = component.get("v.serialList");
        var AllserialList = component.get('v.AllserialList');
        var AllserialListMap = new Map();
        var selectedSnoLength = selectedSno.length;
        for(var i=0;i<AllserialList.length;i++)
        {
            AllserialListMap.set(AllserialList[i].value ,AllserialList[i]);
            
        }
        
        for (var i = 0; i < selectedSnoLength; i++) {
            
            AllserialListMap.delete(selectedSno[i]);
            
            RowItemList.push({
                'sobjectType': 'FA_FV_Detail__c',
                'FA_FV__c': component.get("v.recID"),
                'Serial_Number__c': selectedSno[i],
                'FA_FV_Notes__c': '',
                'Suppliers__c' : '',
                'FA_Completion_Date__c': '',
                'FA_FV_Type_Col__c': '',
                'Relevant_Vendor_Contact__c':'',
                'SLA__c':'',
                'Status__c':'Complete',
                'Vendor_Name__c':'',
                'Vendor_Ship_to_addres__c':'',
                'Date_Code__c' : '' ,
                'OperatingTime__c' : ''
            });
        }
        
        component.set("v.serialList", RowItemList);
        $A.util.removeClass(component.find('openSelectSerialNo'), 'slds-show');
        $A.util.addClass(component.find('openSelectSerialNo'), 'slds-hide');
        var notselectedserialnos = [];
        for(var notselectedserialno of AllserialListMap.values())
        {
            notselectedserialnos.push(notselectedserialno);
        }
        component.set('v.AllserialList',notselectedserialnos);
       
        
    },
})