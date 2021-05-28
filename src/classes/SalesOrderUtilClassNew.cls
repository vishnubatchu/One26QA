public with sharing class SalesOrderUtilClassNew {
    
    //This method returns a comma seperated string of all the standard fields of the object
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
    
    public static Order  getOrder(String sOrderId) {
        String sQuery = 'SELECT ';
        sQuery += 'Opportunity.Do_not_partial__c,Opportunity.Drop_Ship__c,Opportunity.End_Customer__c,Opportunity.End_Customer__r.Name,';
        sQuery += 'Opportunity.Partials_Permitted__c,Opportunity.PBCR__c,Opportunity.PO_Number__c,Opportunity.Shipping_Carrier__c,';
        sQuery += 'Opportunity.Shipping_Comments__c,Opportunity.Special_Instructions__c,Opportunity.Description,';
        sQuery += 'BillToContact.Phone,BillToContact.Name,Account.SAP_Customer_ID__c,Primary_Shipping_Contact__r.Name,Primary_Shipping_Contact__r.Phone,';
        sQuery += 'Opportunity.End_Customer__r.SAP_Customer_ID__c,Opportunity.Received_By__c,';
        sQuery += 'Opportunity.Ship_Method__c,Opportunity.Collect_Account_Number__c,Opportunity.IncoTerms__c,Opportunity.Named_Place__c,';
        sQuery += getObjectFields('Order');
        sQuery += ' FROM Order ';
        sQuery += ' WHERE Id =: sOrderId';
        sQuery = String.escapeSingleQuotes(sQuery);
        Order orderObject = Database.query(sQuery);
        return orderObject;
    }
    
    public static list<Order_Line__c>  getOrderProducts(String sOrderId) {
        String sQuery = 'SELECT Product2.Name, '+getObjectFields('Order_Line__c') +' FROM Order_Line__c WHERE OrderId =: sOrderId ORDER BY Order_Product_Sequence_Number__c ASC';
        sQuery = String.escapeSingleQuotes(sQuery);
        list<Order_Line__c> listOrderProduct = Database.query(sQuery);
        return listOrderProduct;
    }
    /**
* This method convertDateToString
* @return dateString
*/
    public static String convertDateToString(Date dateValue) {
        String dateString = '';
        if (dateValue != null) {
            Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
            dateString = dt.format('yyyy-MM-dd'); //formatting complies with SOQL
        }
        return dateString; 
    }
    public static User getUser(String sOwnerId) {
        User user = [select email,CommunityNickname from User where id =:sOwnerId];
        return user;
    }
}