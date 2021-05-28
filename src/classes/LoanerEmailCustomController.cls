public class LoanerEmailCustomController {
    public Id recordId { get;set; }
    public String recordObject { get;set; }
    public String templateName { get;set; }
  // public String recordTemplate { get;set; }
    
    public Loaner__c getLoaner(){
        Loaner__c sobj;
        
        sobj = [select Id,Name,Loaner_Extension_Created_On__c,CreatedDate,Status_Approval__c,(select Line_Status__c,Loaner_Total__c,SAM__c,SOM__c,Est_Annual_Qty__c,Production_Price_ASP__c,Loaner_Line__r.Balance_to_be_returned__c,SO_Number__c,Marketing_P_N__c,Part_Number__c,Line_Number__c ,Loaner_Line_Shipped_Date__c,Loaner_Line__r.Number_of_Extensions__c,Total_Extended_Days__c from Loaner_Lines__r),Inside_Sales_Sales_rep__c,Company_Name_Ship_To__c,Loaner_Ship_From_Finisar__c,Qual_Sample_Finisar__c,Company_Name_Ship_To__r.name,Opportunity__r.number__c,ECO_Number__c,AC_Mgr_Distributor__c,Loaner_Category__c,Location_ship_to__c,State_ship_to__c,City_ship_to__c,Postal_Code_ship_to__c,Notes__c,New_Customer_Address__c,Country_ship_to__c,Shipping_Instructions__c,Opportunity_Type__c,Loaner_Duration_In_Days__c,createdby.name,RSM_PLM_Finisar__r.name,Loaner_Request__c,Firm_Name_Sales_rep__r.name,VP_PLD_Finisar__r.name,Since_receiving_loaners_what_have_we_d__c,What_is_the_real_expected_date_for_quali__c,What_engineering_tests_still_need_to_be__c,What_engineering_tests_have_been_done__c,Additional_Details_and_or_Comments__c,Company_Name_End_Cust__r.name,RSM_PLM_Approval__r.name,Firm_Name_Sales_rep__c,AC_Mgr_Sales_rep__c,Firm_Name_Distributor__c,Company_Name_End_Cust__c,Est_Production_Date__c,Project_Engineer__c,Project_Name__c,FAE_Distributor__c ,Contact_Text__c,Tel_Number_text__c from Loaner__c where Id = :recordId];
       // System.debug('sobj'+sobj);
        return sobj;
    }
    public Loaner__c getExtension()
    {
        String recId =recordId;
        String querytofields = Label.Loaner_Fields;
        String extensionlinefields = Label.Extension_Lines_Fields;
        String query= 'SELECT '+ querytofields +' ,( SELECT ' +extensionlinefields +' FROM Loaner_Lines__r ) FROM Loaner__c  WHERE Id = :recordId';
       
        Loaner__c loaner =Database.query(query);
        return loaner;
    }
}