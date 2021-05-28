/*
  Created By Rajavardhan 
  To Query Duplicate  Opportunities Which needs to be displayed in DR Submission CMP 
  To Query Opportunity Fields to be displayed in Loaner Approval Email Template 
 
*/

public class OpportunityEmailCustomComponent {

    
    public Opportunity currOpportunity{get;set;}
    public Id OpportunityId {get;set;}
    public String getInstanceurl()
    {
        return System.url.getSalesforceBaseUrl().toExternalForm();
    }
    public Opportunity getOpportunityRecord()
    {
        String query ='SELECT Id,Number__c,NextStep,Next_12_Months_Revenue__c,Lost_Cancelled_Rejected_Reason__c,Lost_To__c,StageName,Project_Name__c,RSM__r.Name,Type,Rep_Firm_Name__r.Name,Market_Segment__c,Sales_Channel__r.Name,Design_Registration__c,CreatedBy.Name,Region__c,Company__c,Account.Name FROM Opportunity where Id= :OpportunityId';
        Opportunity Opp =Database.query(query);
        return opp;
        
    }
    public List<Opportunity> getduplicateOpportunities()
    {
        List<Opportunity> duplicateOpportunities;
        if(currOpportunity != null){
         duplicateOpportunities=[SELECT Id,Name,Duplicate_Design_Registration__c,Number__c,Project_Name__c,Company__c,Sales_Channel__r.Name,Sales_Channel__c,TotalOpportunityQuantity,SumofASP__c,Sum_of_SAM__c FROM Opportunity WHERE Duplicate_Design_Registration__c =:currOpportunity.Id and Duplicate_Design_Registration__c != null ];
        
            return duplicateOpportunities;
        }
        else
        return duplicateOpportunities;
    }
}