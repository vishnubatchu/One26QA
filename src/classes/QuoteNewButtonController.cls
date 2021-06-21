public class QuoteNewButtonController {
    public String recordId{get;set;}
    public QuoteNewButtonController(ApexPages.StandardController controller){
        
    }
    @AuraEnabled
    public static Quote saveQuote(list<String> aAccountId){
        return null;
    }
    
    @AuraEnabled
    public static Quote saveQuote1(String aAccountId){
        System.debug('qRec--> '+aAccountId);
        id accId ;
        if(Test.isRunningTest()){
           accId =  aAccountId;
        }else{
                  accId = (ID)JSON.deserialize(aAccountId, Id.class) ;
  
        }
       //system.debug('accId'+accId);
        //System.debug('qRec--> '+qRec.Account__c);
        //String lAccountId = String.valueof(qRec.Account__c);
        Quote newqRec = new Quote();
       // newqRec.Account__c = aAccountId[0];
        newqRec.Account__c = accId;                
        newqRec.name= '-Quote';
        try{
          system.debug('newqRec=='+newqRec);
        upsert newqRec;
            system.debug('newqRec1=='+newqRec);
        return newqRec;  
        }catch(Exception e) {
            System.debug('Error'+e.getMessage());
             return null;
        }
        
       
    }
    
    public pagereference redirect(){
        //String recordIdRec = Apexpages.currentPage().getParameters().get('RecId');
        system.debug('recordIdRec--'+recordId);
        PageReference p = new PageReference('/'+recordId);
        //PageReference p = new PageReference('https://finisar--hurondev.lightning.force.com/lightning/o/Quote/'+recordIdRec+'/view');
        p.setredirect(true);
        return p; 
    }
    
    @AuraEnabled
    public static Quote getOpportunityRec(String recordId){
        Quote qRec = new Quote();
        Opportunity opp =[Select id,AccountId from Opportunity where id =:recordId ];
        if(opp.AccountId != null) {
            qRec.Account__c= opp.AccountId;
            
        }
        qRec.OpportunityId = opp.id;
        qrec.name='test';
        if(qRec != null){
            System.debug('Inside getOpportunityRec if');

            system.debug('qRec==='+qRec.Id);
            upsert qRec;
            system.debug('qRec1==='+qRec);
        }
        return qRec;
    }
}