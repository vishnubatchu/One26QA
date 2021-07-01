trigger trgRollUpToAccount on Opportunity (after insert, after update, after delete) {
    if(Label.OneTimeBatchDeactivation  == 'False'){
    Set<String> ids = new Set<String>();
    if(trigger.IsInsert)
        for(Opportunity o : trigger.New){
            ids.add(o.AccountId);
        }
    
    if(trigger.IsUpdate){
        for(Opportunity o : trigger.New){
            ids.add(o.AccountId);
        }
        for(Opportunity o : trigger.Old){
            ids.add(o.AccountId);
        }
    }      
    if(trigger.IsDelete)
        for(Opportunity o : system.trigger.old){
            ids.add(o.AccountId);
        }
    
    List<Account> Result = new List<Account>();
    
    //Added where condition in inner query 
    Result = [SELECT id,Opportunities_Business_Unit_s__c from Account where id in:ids];      
    
    List<Opportunity> oppLst = [select id,Business_Unit_Name_Product_Rollup__c,Amount,CreatedDate  from Opportunity where AccountId in:ids order by Amount,createddate ];
    
    map<string,string> finalmap = new map<string,string>();
    for(Account o : Result){
        map<string,integer> myMap1 = new map<string,integer>();    
        map<Integer,set<string>> myMap2 = new map<Integer,set<string>>();
        
        for(Opportunity a :oppLst){  
            if(a.Business_Unit_Name_Product_Rollup__c!=null && a.Business_Unit_Name_Product_Rollup__c!=''){
                if(myMap1.containskey(a.Business_Unit_Name_Product_Rollup__c)){
                    integer i=myMap1.get(a.Business_Unit_Name_Product_Rollup__c); 
                    i=i+1;
                    myMap1.put(a.Business_Unit_Name_Product_Rollup__c,i);       
                }else{
                    myMap1.put(a.Business_Unit_Name_Product_Rollup__c,1);       
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
        set<string> dupset;
        dupset= myMap2.get(i);
        if(dupset!=null){
            if(dupset.size()>0){
                decimal max=-1;
                datetime mydate;
                string currentVal;
                for(string d : dupset){
                    for(Opportunity a : oppLst){
                        if(a.Business_Unit_Name_Product_Rollup__c!=null && a.Business_Unit_Name_Product_Rollup__c!=''){
                            if(d==a.Business_Unit_Name_Product_Rollup__c ){
                                if(max==-1){
                                    max=a.Amount;
                                    mydate=a.createddate;
                                    currentVal=a.Business_Unit_Name_Product_Rollup__c;
                                    continue;
                                }
                                else{
                                    if(max<a.Amount){
                                        max=a.Amount;
                                        mydate=a.createddate;
                                        currentVal=a.Business_Unit_Name_Product_Rollup__c;
                                    }
                                    else if(max==a.Amount){
                                        if(mydate<a.createddate){
                                            mydate=a.createddate;
                                            max=a.Amount;
                                            currentVal=a.Business_Unit_Name_Product_Rollup__c;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                finalmap.put(o.id,currentVal);
            }
            else{for(string s :dupset) finalmap.put(o.id,s);}
        }
        else{
            finalmap.put(o.id,'');
        }
    }
    list<Account> accToUpdate = new list<Account>();
    for(Account o : Result){
        if(finalmap.containsKey(o.id)){
            o.Opportunities_Business_Unit_s__c=finalmap.get(o.id);
            accToUpdate.add(o);
        }
    }
    if(accToUpdate.size() > 0)  Update accToUpdate;
    }  
}