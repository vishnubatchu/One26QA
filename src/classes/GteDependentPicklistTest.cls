@isTest
public class GteDependentPicklistTest {
    
    @isTest
    static void getDependentFields()
    {
        String sObjectName = 'Failure_Modes__c';
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName); // obtain sObject description from the schema
        SObject s = t.newSObject();
        system.debug('sObj===='+s);
        GteDependentPicklist.getDependentMap(s,'PDC_Level_1__c','PDC_Level_2__c');
    }
}