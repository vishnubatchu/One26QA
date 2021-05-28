trigger RMARequestLine on RMA_Request_Line__c (before update,before delete) {
    
    If(Trigger.isDelete){
        for(RMA_Request_Line__c RMAlineobj:Trigger.old){
            if(RMAlineobj.RMA_Request__r.Status == 'Open' && RMAlineobj.RMA_Request__r.Validation_Status__c != 'Completed')
                RMAlineobj.addError('Serial Number Validation in progress. RMA Request Line cannot be deleted.');
        }
    }
    If(Trigger.isUpdate && Trigger.isBefore){
        for(RMA_Request_Line__c RMAlineobj:Trigger.old){
            if(RMAlineobj.RMA_Request__r.Status == 'In Progress' && RMAlineobj.RMA_Request__r.Validation_Status__c != 'Completed')
                RMAlineobj.addError('Serial Number Validation in progress. RMA Request Line cannot be updated.');
        }
    }
    
}