public class Opportunity_Handler
{   
    public void beforeUpdate(list<Opportunity> newList)
    {
        for(Opportunity o : newList)
        {
            {
                o.cloneCount__c = o.Product_Record_Count_Text_Copy_2__c;
            }    
     
        }
           
    }
}