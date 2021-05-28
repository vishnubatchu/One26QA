trigger ConversionDetailsTrigger on Conversion_Details__c (before insert,before update,after insert, after update ) {

    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
              ConversionDetailsHelper.beforeInsert(Trigger.New);          
        }
        if(Trigger.isUpdate)
        {
            ConversionDetailsHelper.beforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
       
    }
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            
        }
    }
    
}