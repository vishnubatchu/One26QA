public class OpportunityProductHandler {

    public List<OpportunityLineItem> olist = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE Id IN: trigger.newmap.keyset() ];


    public OpportunityProductHandler(){
    
    }
    
    Public static void updateBUNOnOpportunityProduct(List<OpportunityLineItem> OpportunityLineItems){
        
        Set<String> ids = new Set<String>();
        for(OpportunityLineItem o : OpportunityLineItems){
            ids.add(o.Product2Id);
        }
        Map<id,Product2> myProducts = new Map<Id,Product2>([select id,Business_Unit_Name__c from product2 where id in:ids]);
        for(OpportunityLineItem o : OpportunityLineItems){
            o.Business_Unit_Name__c = myProducts.get(o.Product2Id).Business_Unit_Name__c;
        }
    }
    
    public static void RollUpBUN(List<OpportunityLineItem> OpportunityLineItems){
        if(OpportunityLineItems!=null){
            Set<String> ids = new Set<String>();
            for(OpportunityLineItem o : OpportunityLineItems){
                ids.add(o.OpportunityId);
            }
            
            List<Opportunity> Result = new List<Opportunity>();
    
            Result = [SELECT id,Business_Unit__c,(select id,OpportunityId ,Business_Unit_Name__c,TotalPrice,createddate from OpportunityLineItems  where OpportunityId  in: ids order by TotalPrice,createddate) from opportunity where id in:ids ];       
            
            map<string,string> finalmap = new map<string,string>();
            for(opportunity o : Result){
                map<string,integer> myMap1 = new map<string,integer>();    
                map<Integer,set<string>> myMap2 = new map<Integer,set<string>>();
                
                for(OpportunityLineItem a : o.OpportunityLineItems){  
                    if(a.Business_Unit_Name__c!=null && a.Business_Unit_Name__c!=''){
                        if(myMap1.containskey(a.Business_Unit_Name__c)){
                            integer i=myMap1.get(a.Business_Unit_Name__c); 
                            i=i+1;
                            myMap1.put(a.Business_Unit_Name__c,i);       
                        }else{
                            myMap1.put(a.Business_Unit_Name__c,1);       
                        }
                    }
                }
                
                for(string s : myMap1.keyset()){
                    if(myMap2.containsKey(myMap1.get(s))){
                        set<string> str = myMap2.get(myMap1.get(s));
                        str.add(s);
                        myMap2.put(myMap1.get(s),str);
                    }else{
                        set<string> str = new set<string>();
                        str.add(s);
                        myMap2.put(myMap1.get(s),str);
                    }
                }
                
                integer i=-1;
                for(integer s : myMap2.keyset()){
                    if(i==-1)   i=s;
                    else{
                        if(s>i) i=s;
                    }
                }
                set<string> dupset ;
                dupset= myMap2.get(i);
                if(dupset!=null){
                if(dupset.size()>0){
                    decimal max=-1;
                    datetime mydate;
                    string currentVal;
                    for(string d : dupset){
                        for(OpportunityLineItem a : o.OpportunityLineItems){
                            if(a.Business_Unit_Name__c!=null && a.Business_Unit_Name__c!=''){
                                if(d==a.Business_Unit_Name__c ){
                                    if(max==-1){
                                        max=a.TotalPrice;
                                        mydate=a.createddate;
                                        currentVal=a.Business_Unit_Name__c;
                                        continue;
                                    }
                                    else{
                                        if(max<a.TotalPrice){
                                            max=a.TotalPrice;
                                            mydate=a.createddate;
                                            currentVal=a.Business_Unit_Name__c;
                                        }
                                        else if(max==a.TotalPrice){
                                            if(mydate<a.createddate){
                                                mydate=a.createddate;
                                                max=a.TotalPrice;
                                                currentVal=a.Business_Unit_Name__c;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    finalmap.put(o.id,currentVal);
                }
                else{ for(string s :dupset) finalmap.put(o.id,s); }
                }
                else{
                    finalmap.put(o.id,'');
                }
            
            }
            list<opportunity> oppToUpdate = new list<opportunity>();
            for(opportunity o : Result){
                if(finalmap.containsKey(o.id)){
                    o.Business_Unit__c=finalmap.get(o.id);
                    oppToUpdate.add(o);
                }
            }
            
            if(oppToUpdate.size() > 0) {
                try {
                    Update oppToUpdate;
                } catch (Exception e) {

                    for(OpportunityLineItem ol : [SELECT Id FROM OpportunityLineItem WHERE Id IN: trigger.new]) {
                        Trigger.newMap.get(ol.Id).addError(e);                    
                    }

                }
            }

        }
    }    
}