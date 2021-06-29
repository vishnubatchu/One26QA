public class createIndividulforOldRecordsBatch implements Database.Batchable <sObject>,Database.Stateful {
    public String query;
    public Boolean stopBatch = false;
    public string contactId ;
    public createIndividulforOldRecordsBatch(String nxtQuery, Boolean runBatch){
        if(nxtQuery != null){
            query = nxtQuery;
            stopBatch = runBatch;
        } else {
            contactId = '0032f00000W8vV5AAJ';
            //query = 'SELECT Id, Email, IndividualId,Display_ISO_Country__c, FristName, LastName FROM Contact WHERE IndividualId = null';
           //  query = 'SELECT Id, Email, IndividualId FROM Contact WHERE id = :contactId';
        }
    }
    public Database.QueryLocator  start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        system.debug('scope'+scope);
        List<sObject> objList = new List<sObject>();
        List<sObject> newList = new List<sObject>();
        List<Individual> indList = new List<Individual>();
        Map<String, Individual> individualmap = new Map<String, individual>();
        Map<String, Individual> newIndividualmap = new Map<String, individual>();
        Set<String> emails = new Set<String>();
        for(sObject obj :scope){
            emails.add(String.valueOf(obj.get('Email')));
        }
        for(Individual ind : [SELECT Id, Email__c, ConsentDate__c 
                              FROM Individual
                              WHERE Email__c IN :emails]){
                                  individualmap.put(ind.Email__c, ind);
                              }
        for(sObject obj : scope){
            String email = (String)obj.get('Email');
            Id recId = (Id)Obj.get('Id');
            if(String.isNotBlank(email) && individualmap.containsKey(email)){
                obj.put('IndividualId', individualmap.get(email).Id);
                objList.add(obj);
            } else if(String.isNotBlank(email)){
                newList.add(obj);
                Individual newInd = new Individual();
                newInd.FirstName = (String)Obj.get('FirstName');
                newInd.LastName = (String)Obj.get('LastName');
                newInd.Email__c = (String)Obj.get('Email');
                if(recId.getSObjectType().getDescribe().getName() == 'Lead')
                    newInd.Country__c = (String)Obj.get('Display_ISO_Country__c');
                else
                    newInd.Country__c = (String)Obj.get('Display_Mailing_Country__c');
                newIndividualmap.put(newInd.Email__c, newInd);
            }
        }
        if(newIndividualmap != null && !newIndividualmap.isEmpty()){
            insert newIndividualmap.values();
            for(sObject sObj : newList){
                String email = (String)sObj.get('Email');
                sObj.put('IndividualId', newIndividualmap.get(email).Id);
                objList.add(sObj);
            }
        }
        if(objList != null && !objList.isEmpty()){
            update objList;
        }
    }
    public void finish(Database.BatchableContext BC) {
        if(!stopBatch){
           String leadQuery = 'SELECT Id, Name,FirstName, LastName, Email,IndividualId, Display_ISO_Country__c FROM Lead WHERE IndividualId = null ';
            createIndividulforOldRecordsBatch bat = new createIndividulforOldRecordsBatch(leadQuery, true);
            database.executeBatch(bat);
        }
    }
}