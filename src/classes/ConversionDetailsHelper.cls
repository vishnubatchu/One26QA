public with sharing class ConversionDetailsHelper {
    
    public static void beforeUpdate(Map<Id,Conversion_Details__c> newConversionDetails,Map<Id,Conversion_Details__c> OLDConversionDetails)
    {
        Set<Id> DispositionTransferIds = new Set<Id>();
        for(Conversion_Details__c cdobj :newConversionDetails.values())
        {
            if(cdobj.Conversion_Qty__c != OLDConversionDetails.get(cdobj.Id).Conversion_Qty__c)
               DispositionTransferIds.add(cdobj.Disposition_Transfer_Detail__c);
        } 
        
		if(DispositionTransferIds.size() > 0)        
        validateConversionQtyForUpdate(DispositionTransferIds,newConversionDetails,OLDConversionDetails);
    }
    public static void beforeInsert(List<Conversion_Details__c> newConversionDetails)
    {
        Set<Id> DispositionTransferIds = new Set<Id>();
        Map<Id,List<Conversion_Details__c> > newconversionTransferMap = new Map<Id,List<Conversion_Details__c> >();
        List<Conversion_Details__c> conversiondetaillist;
        
        for(Conversion_Details__c conversionobj :newConversionDetails)
        {
            DispositionTransferIds.add(conversionobj.Disposition_Transfer_Detail__c);
        } 
		if(DispositionTransferIds != null || DispositionTransferIds.size() > 0  )          
         validateConversionQty(DispositionTransferIds,newConversionDetails);
        
    }
    
    public static void validateConversionQtyForUpdate(set<Id> DispositionTransferIds,Map<Id,Conversion_Details__c>  newConversionDetails,Map<Id,Conversion_Details__c> oldconversionDetails)
    {
        Map<Id,Disposition_Transfer_Details__c> transferslist = new Map<Id,Disposition_Transfer_Details__c> ([select Id,Quantity__c from Disposition_Transfer_Details__c where Id in :DispositionTransferIds]);
        Map<String,Integer> conversionDetailCountMap = new Map<String,Integer>();
        List<AggregateResult> conversionDetailCount = [select Disposition_Transfer_Detail__c, SUM(Conversion_Qty__c) from Conversion_Details__c  Group By Disposition_Transfer_Detail__c];
        
        for(Conversion_Details__c  conversionObj:newConversionDetails.values())
        {
            
            for(AggregateResult ar :conversionDetailCount)
            {
                String transferid =String.valueOf(ar.get('Disposition_Transfer_Detail__c'));
                
                if(transferid.equalsIgnoreCase(conversionObj.Disposition_Transfer_Detail__c))
                {
                    
                    if(!conversionDetailCountMap.containsKey(transferid))
                    {
                        
                        if(oldconversionDetails != null)
                        {  
                            
                            Integer count =   Integer.valueOf(ar.get('expr0'));
		                    count = count - (Integer) oldconversionDetails.get(conversionObj.Id).Conversion_Qty__c + (Integer) newConversionDetails.get(conversionObj.Id).Conversion_Qty__c ;
                            conversionDetailCountMap.put(newConversionDetails.get(conversionObj.Id).Disposition_Transfer_Detail__c,count);
                        }
                       else
                        {
                            Integer count =  Integer.valueOf(conversionDetailCountMap.get(newConversionDetails.get(conversionObj.Id).Disposition_Transfer_Detail__c));
                            count = count + Integer.valueOf(newConversionDetails.get(conversionObj.Id).Conversion_Qty__c) ;
                            conversionDetailCountMap.put(newConversionDetails.get(conversionObj.Id).Disposition_Transfer_Detail__c,count); 
                        }
                    }
                }
                
            }
        }
        System.debug(' Conversion Detail Count  '+conversionDetailCountMap);
        for(String conversionobj:newConversionDetails.keySet())
        {
            System.debug(conversionDetailCountMap.get(newConversionDetails.get(conversionobj).Disposition_Transfer_Detail__c));
            if(transferslist.get(newConversionDetails.get(conversionobj).Disposition_Transfer_Detail__c).Quantity__c < conversionDetailCountMap.get(newConversionDetails.get(conversionobj).Disposition_Transfer_Detail__c)) 
                newConversionDetails.get(conversionobj).addError('Disposition Quantity should be greater than Conversion Qty');
        }
        
        
    }
    
    public static void validateConversionQty(set<Id> DispositionTransferIds,List<Conversion_Details__c>  newConversionDetails)
    {
        Map<Id,Disposition_Transfer_Details__c> transferQuantityMap = new Map<Id,Disposition_Transfer_Details__c> ([select Id,Quantity__c from Disposition_Transfer_Details__c where Id in :DispositionTransferIds]);
        Map<String,Integer> conversionQtyMap = new Map<String,Integer>();
        List<AggregateResult> conversionQuantitySumList = [select Disposition_Transfer_Detail__c, SUM(Conversion_Qty__c) from Conversion_Details__c  Group By Disposition_Transfer_Detail__c];
        System.debug(' aggregate '+conversionQuantitySumList);
        for(Conversion_Details__c conversionobj:newConversionDetails)
        {          
            for(AggregateResult cdAggreResult :conversionQuantitySumList)
            {
                String transferid =String.valueOf(cdAggreResult.get('Disposition_Transfer_Detail__c'));
                if(transferid.equalsIgnoreCase(conversionobj.Disposition_Transfer_Detail__c))
                {
                    if(!conversionQtyMap.containsKey(transferid))
                    {
                        
                        Integer count  =  Integer.valueOf(cdAggreResult.get('expr0'))+ (Integer)  conversionobj.Conversion_Qty__c;
                        conversionQtyMap.put(conversionobj.Disposition_Transfer_Detail__c,count);
                        
                    }
                    
                    
                }
                /*else
                {
                    if(conversionobj.Conversion_Qty__c > transferQuantityMap.get(conversionobj.Disposition_Transfer_Detail__c).Quantity__c)
                        conversionobj.addError('Disposition Quantity '+transferQuantityMap.get(conversionobj.Disposition_Transfer_Detail__c).Quantity__c+' should be greater or equal to Conversion Qty'+ ' '+conversionobj.Conversion_Qty__c);
                }*/
            }
            /* if it does not contain in conversionQuantitySumList  then put new conversion qty */
            if(!conversionQtyMap.containsKey(conversionobj.Disposition_Transfer_Detail__c))
            {
                conversionQtyMap.put(conversionobj.Disposition_Transfer_Detail__c,(Integer) conversionobj.Conversion_Qty__c);
            }
        }
        System.debug(' Conversion Detail Count  '+conversionQtyMap);
        for(Conversion_Details__c conversionobj:newConversionDetails)
        {
            System.debug(conversionQtyMap.get(conversionobj.Disposition_Transfer_Detail__c));            
            if(transferQuantityMap.get(conversionobj.Disposition_Transfer_Detail__c).Quantity__c < conversionQtyMap.get(conversionobj.Disposition_Transfer_Detail__c) ) 
                conversionobj.addError('Disposition Quantity'+ transferQuantityMap.get(conversionobj.Disposition_Transfer_Detail__c).Quantity__c +'should be greater or equal to  Conversion Qty '+conversionobj.Conversion_Qty__c);
        }
        
        
    }
    
    
}