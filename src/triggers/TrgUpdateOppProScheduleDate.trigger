trigger TrgUpdateOppProScheduleDate on OpportunityLineItem (before update) {
    Set<Id> ids = new Set<Id>();
    Set<Id> mapIds = new Set<Id>();
    Map<id,date> mapMinimumDate = new Map<id,date>();
    
    for(OpportunityLineItem o : trigger.new){
        ids.add(o.id);
    }
    
    List<OpportunityLineItem> lstOppLines = new List<OpportunityLineItem>();
    lstOppLines = [select id,name,(Select id,ScheduleDate from OpportunityLineItemSchedules order by ScheduleDate ASC) 
                        from OpportunityLineItem  where id in: ids];
    
    
    for(OpportunityLineItem o: lstOppLines){
        for(OpportunityLineItemSchedule a : o.OpportunityLineItemSchedules ){    mapMinimumDate.put(o.id,a.ScheduleDate);    break;
        }
    }
    
    List<OpportunityLineItem> lstOppLines2 = new List<OpportunityLineItem>();
    lstOppLines2 = [select id,name,(Select id,ScheduleDate from OpportunityLineItemSchedules order by ScheduleDate ASC) 
                        from OpportunityLineItem  where id in: ids];
                        
    Map<id,date> mapMinimumDate2 = new Map<id,date>();
    for(OpportunityLineItem o : trigger.new){
        mapIds.add(o.id);
    }
    
    system.debug('-----mapMinimumDate'+mapMinimumDate);
    
    for(OpportunityLineItem o : trigger.new){
        if(mapMinimumDate.containsKey(o.id))    o.Min_Schedule_Date_Product__c = mapMinimumDate.get(o.id);
    }
}