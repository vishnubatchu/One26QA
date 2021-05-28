public class RmaOrderLine_FailureLocationupdate {
    
    public static void failureLocationupdate(Map<id,Order_Line__c> newordline)
    { 
        
            List<String> ordrmaid = new List<String>();
         system.debug(newordline);
          for(Id recordid:newordline.keySet())
          {
              
              system.debug(newordline.get(recordid).Failure_Location__c);
             if ((newordline.get(recordid).rmaid__c != null && newordline.get(recordid).Failure_Location__c == null)){
                  ordrmaid.add(newordline.get(recordid).rmaid__c);
                
          }
            
         
          }
         if(!ordrmaid.isEmpty())
           updateOrderLineLocation(newordline.keySet(),ordrmaid);
    }
    
    public static void updateOrderLineLocation(Set<id> ordline,List<String> rmaid){
        
          
           if(!rmaid.isEmpty())
                {

                 List<Order_Line__c> ordlinelist = [select id,Failure_Location__c,rmaid__c from Order_Line__c where id in :ordline];
                 List<Case> cs = [select id,casenumber,Failure_Location__c from Case where casenumber in :rmaid];
                 List<Order_Line__c> updateorderlist = new  List<Order_Line__c>();
                 Map<String,String> cs_Floc = new Map<String,String>();
                  for(Case c:cs)
                    {
                        cs_Floc.put(c.casenumber,c.Failure_Location__c);
                     }
                  for(Order_Line__c ordlnid:ordlinelist){
                                              
                  if(cs_Floc.containsKey(ordlnid.rmaid__c))
                       {
                           ordlnid.Failure_Location__c = cs_Floc.get(ordlnid.rmaid__c);
                           updateorderlist.add(ordlnid);
                    
                   }
                  
               
              }       

          if(!updateorderlist.isEmpty())
            update updateorderlist;
           }

    
    }

}