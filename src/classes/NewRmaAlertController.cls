public class NewRmaAlertController {
    public Id recordId {get;set;}
    public Boolean haslines {get;set;}
    public case getrmaDetails(){
        Case rmaCase = [SELECT Id, CaseNumber,createdBy.Name, CreatedDate,Account.Name, End_Customer__c,
                        (SELECT Id, Name,Product__r.Name,Brief_description_of_the_failure__c,
                         Marketing_PN__c,Return_Reason__c,Org_Code__c
                         FROM RMA_Request_Lines__r)
                        FROM Case
                        WHERE Id =:recordId];
        if(rmaCase.RMA_Request_Lines__r.size()>0){
            haslines = true;
        }else{
            haslines = false;
        }
        return rmaCase;
    }
    
}