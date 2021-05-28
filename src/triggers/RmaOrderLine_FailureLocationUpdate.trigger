//Failure Location update on Order line object from Case object based on RMAID field in Serial object
trigger RmaOrderLine_FailureLocationUpdate on Order_Line__c (after insert,after update) {
 if(Trigger.isAfter &&  Trigger.isUpdate)
 {
     RmaOrderLine_FailureLocationupdate.failureLocationupdate(Trigger.newMap);
     system.debug('RmaOrderLine_FailureLocationUpdate');
 }
   
}