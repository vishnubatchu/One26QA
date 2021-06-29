public class RecordApprovalDao {
    
    public static List < sobject > getLineItemsRecords(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId,(Select Id,Approval_From__c,Line_Status__c,Std_List_Price__c,
                             Quantity__c,Disti_Resale_Price__c,Competitor_Price__c,Competitor_Info__c,Agreed_Upon_Share__c,
                             Disti_Margin__c,RSM_Approval__c,PLM_Approval__c,Product__r.Name,Product__r.Marketing_P_N__c,Target_Price__c,RSM_Approver__r.Name,
                             RSM_Approver__r.DelegatedApproverId,PLM_Approver__r.DelegatedApproverId,PLM_Approver__r.Name,
                             RSM_Approver__c, PLM_Approver__c, Name,CreatedById,Marketing_PN__c from Quote_Items__r 
                             where Line_Status__c not in:CommonConstants.approvalStatusSet) FROM Quote where id =: recordId];
            return quoteObj.Quote_Items__r;
        } else {
            Loaner__c loanerObj = [SELECT Id, RSM_PLM_Finisar__c,Inside_Sales_Sales_rep__r.Name,Inside_Sales_Finisar__r.Name,
                                   RSM_PLM_Approval__c ,VP_PLD_Finisar__c, Name, (Select Id, RSM__c, VP__c, SVP__c, Name,
                                   CreatedById,Recordtype.id from Loaner_Lines__r where Line_Status__c 
                                   not in: CommonConstants.approvalStatusSet) from Loaner__c where id =: recordId];
            return loanerObj.Loaner_Lines__r;
        }
    }
      public static sobject getHeaderRecord(Id recordId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if(sObjName.equalsIgnoreCase('Case')){
          case caseObj = [SELECT Id, AccountId,CaseNumber,Account.Name, Address__c,AssetId,BU_Data_Networking_Amount_Sum__c,
                          BU_Optical_Interconnect_Amount_Sum__c,BU_Wavelength_Management_Amount_Sum__c,
                          BU_3D_Sensing_Amount_Sum__c,Origin,Reason,Case_Status__c,ContactEmail,ContactMobile,ContactPhone,
                          Contract_Manufacturer__c,Count_of_RMA_Request_Lines__c,Cust_Acc_ID__c,Cust_PO_Number__c,
                          CustomerRef_RMANo__c,ClosedDate,CreatedDate,Description,DistributorFirmGroupName__c,Ec_Party_ID__c,
                          End_Customer__c,Error_Message__c,Fault_Location__c,FNSR_Engr__c,Found_By__c,Integration_Status__c,
                          Is_Disti_Order__c,Batch_Lot_Return__c,Issue_with__c,Order_Number__c,Order_Type__c,Part_Numbers_s__c,
                          Product_Family__c,Requested_Service__c,Return_Reason__c,Rolled_up_Amount__c,Sales_Manager_E_Mail__c,
                          Priority, (Select Id,Amount__c,Brief_description_of_the_failure__c,Business_Unit__c,
                          Customer_Part_Number__c,Customer_Serial_Number__c,Name,End_Customer__c,Error_Message__c,
                          Failure_Location__c,Finisar_Part_Number__c,Warranty_End_Date__c,Warranty_Indicator__c,
                          Warranty_Information__c,Warranty__c,Special_Instructions__c,Shipped_date__c,Return_Reason__c,
                          Quantity__c, PO_Price__c,Original_PO_Amount__c from RMA_Request_Lines__r) 
                          FROM Case where Id =: recordId];
            return caseObj;  
        }
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId,Status, S_D_End_Date__c,S_D_Start_Date__c,Ship_Debit__c,CreatedDate,
                              Integration_Status__c,Initial_Error_Message__c,Justification__c,VAR_SI_Disti_EC__c,ExpirationDate,
                              Pricing_Effective_End_Date__c,PrimarySalesperson__c,VAR_SI__c,Primary_Sales_Group__c,
                              Pricing_Effective_Start_Date__c,PrimarySalesperson__r.Name,Type_of_Pricing__c,Additional_CM__c,
                              Contract_Manufacturer__c,Price_List__c,Sales_Channel__r.Name ,Account__r.Name,Customer__r.Name,
                              Opportunity.Name,QuoteNumber, (Select Id,Approval_From__c,Line_Status__c,Std_List_Price__c,
                              Quantity__c,Disti_Resale_Price__c,Competitor_Price__c,Competitor_Info__c,Agreed_Upon_Share__c,
                              Disti_Margin__c,RSM_Approval__c,PLM_Approval__c,Product__r.Name,Product__r.Marketing_P_N__c,Target_Price__c,RSM_Approver__r.Name,
                              RSM_Approver__r.DelegatedApproverId,PLM_Approver__r.DelegatedApproverId,PLM_Approver__r.Name,
                              RSM_Approver__c, PLM_Approver__c,Std_Disti_Cost__c, Name,CreatedById,Marketing_PN__c from Quote_Items__r) 
                              FROM Quote where id =: recordId];
            return quoteObj;
        } else {
            Loaner__c loanerObj = [SELECT Id,CreatedDate,Inside_Sales_Finisar__r.Name,Inside_Sales_Sales_rep__r.Name,
                                  Date_reminder_date__c,Initial_Error_Message__c,Verified_with_Betty_Dea__c,
                                  Inside_Sales_Finisar__c,Loaner_Duration__c,Address_ship_to__c,Company_Name_Ship_To__c,
                                  recordTypeID,createdby.name,Status_Approval__c,SVP_Id_Created_By__c,City_ship_to__c,
                                   Loaner_Request__c,Loaner_Duration_In_Days__c,Loaner_Category__c,Firm_Name_Sales_rep__c,
                                   AC_Mgr_Sales_rep__c,Firm_Name_Distributor__c,AC_Mgr_Distributor__c,ECO_Number__c,
                                   Opportunity_Type__c,Opportunity__r.number__c,RSM_PLM_Finisar__r.name,RSM_PLM_Finisar__r.Email,SVP__c,
                                   Inside_Sales_Sales_rep__c,Firm_Name_Sales_rep__r.Name,Firm_Name_Distributor__r.Name,
                                   Qual_Sample_Finisar__c,Loaner_Ship_From_Finisar__c,Company_Name_End_Cust__c,
                                   Company_Name_End_Cust__r.Name,Project_Engineer__c,Contact_Text__c,Tel_Number_text__c,
                                   Project_Name__c,Est_Production_Date__c,Company_Name_Ship_To__r.name,Location_ship_to__c,
                                   State_ship_to__c,Postal_Code_ship_to__c,Country_ship_to__c,Shipping_Instructions__c,
                                   New_Customer_Address__c,Notes__c, RSM_PLM_Finisar__c,RSM_PLM_Approval__c, VP_PLD_Finisar__c, 
                                   Name, (Select Id, Line_Number__c,Part_Number__c,Marketing_P_N__c,Loaner_Total__c,line_total__c,
                                   Production_Price_ASP__c,RSM__c, VP__c, SVP__c, Name,Product__c,Line_Status__c, Return_Instructions__c,
                                   Loaner_Qty__c,Loaner_Price_100_999_column_price__c,Est_Annual_Qty__c,SOM__c,SAM__c,RecordTypeId,Extend_Date__c from Loaner_Lines__r ) 
                                   from Loaner__c where id =: recordId];
            return loanerObj;
        }
    }
    
    public static List < User > getUserVPSVPDetails(Set < Id > userIds) {
        List < User > userList = [select id, name, email, userrole.name, VP__c, SVP__c,isportalenabled from user 
                                  where id in: userIds AND isActive=True];
        return userList;
    }
    
    public static List < sobject > getLineItemsRecordsForApproval(Id recordId, Id userID) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId, (Select Id,Approval_From__c,RSM_Approver__c, PLM_Approver__c,
                                                             RSM_Approver__r.DelegatedApproverId,PLM_Approver__r.DelegatedApproverId, 
                                                             Name,Line_Status__c from Quote_Items__r where 
                                                             (RSM_Approver__c =: userID or PLM_Approver__c =: userID 
                                                              Or RSM_Approver__r.DelegatedApproverId =: userId 
                                                              Or PLM_Approver__r.DelegatedApproverId =:userId)) 
                              FROM Quote where id =: recordId];
            return quoteObj.Quote_Items__r;
        } else {
            User u = getUserVPSVPDetails(New Set < id > { userID }).get(0);
            System.debug('Before Query');
            System.debug('u.userrole.name'+u.userrole.name);
           // System.debug('CommonConstants.mapUserRoleToField.get(u.userrole.name) '+CommonConstants.mapUserRoleToField.get(u.userrole.name));
            String Query = 'SELECT Id, RSM_PLM_Finisar__c,RSM_PLM_Approval__c,VP_PLD_Finisar__c, Name, (Select Id, RSM__c, VP__c, SVP__c, Name from Loaner_Lines__r where (' + CommonConstants.mapUserRoleToField.get(u.userrole.name) + '=: userID Or '+CommonConstants.mapUserRoleToField.get(u.userrole.name).removeEnd('__c')+'__r.delegatedApproverId =: userID )) from Loaner__c where id =: recordId ';
            System.debug('Query'+Query);            
            Loaner__c loanerObj = Database.query(Query);
            return loanerObj.Loaner_Lines__r;
        }
    }
    
    public static List < sobject > getLineItemsRecordsForApprovalByLineItems(Id recordId,Id userID,Set<id> lineItemIds) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId, (Select Id, Line_Status__c,Approval_From__c,RSM_Approver__c, 
                                                             PLM_Approver__c, Name from Quote_Items__r where  id in :lineItemIds And 
                                                            (RSM_Approver__c =: userID or PLM_Approver__c =: userID)) 
                                                            FROM Quote where id =: recordId];
            return quoteObj.Quote_Items__r;
        } else {
            User u = getUserVPSVPDetails(New Set < id > { userID }).get(0);
            System.debug('Before Query');
            String Query = 'SELECT Id, RSM_PLM_Finisar__c,RSM_PLM_Approval__c,VP_PLD_Finisar__c, Name, (Select Id, RSM__c, VP__c, SVP__c, Name from Loaner_Lines__r where ID in :lineItemIds AND (' + CommonConstants.mapUserRoleToField.get(u.userrole.name) + '=: userID Or '+CommonConstants.mapUserRoleToField.get(u.userrole.name).removeEnd('__c')+'__r.delegatedApproverId =: userID )) from Loaner__c where id =: recordId ';
            System.debug('Query'+Query);
            Loaner__c loanerObj = Database.query(Query);
            return loanerObj.Loaner_Lines__r;
        }
    }
    
    public static List<ProcessInstanceWorkitem> getProcessItemWorkList(set<Id> recordIds){
        return [Select Id,actorid,ProcessInstance.TargetObjectId from ProcessInstanceWorkitem 
                where ProcessInstance.TargetObjectId in: recordIds];
    }
    
    public static List < sobject > getLineItemsRecordsForApprovalEmail(Id recordId,Id userId) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId, (Select Id,Std_List_Price__c,Quantity__c,RSM_Approval__c,
                             PLM_Approval__c,Disti_Resale_Price__c,Approval_From__c,Competitor_Price__c,Competitor_Info__c,
                             Agreed_Upon_Share__c,Disti_Margin__c,Product__r.Name,Product__r.Marketing_P_N__c,Target_Price__c,
                             RSM_Approver__r.Name,PLM_Approver__r.Name,RSM_Approver__c, PLM_Approver__c, Name,CreatedById,
                             Line_Status__c from Quote_Items__r where (RSM_Approver__c =: userID or PLM_Approver__c =: userID 
                                                                       or RSM_Approver__r.delegatedapproverId =:userid 
                                                                       or PLM_Approver__r.delegatedapproverId =:userId) 
                             AND Line_Status__c in:CommonConstants.approvalPendingSet) FROM Quote where id =: recordId];
            return quoteObj.Quote_Items__r;
        } else {
            Loaner__c loanerObj = [SELECT Id, RSM_PLM_Finisar__c, RSM_PLM_Approval__c ,VP_PLD_Finisar__c, Name, 
                                 (Select Id,Line_Number__c,Part_Number__c,Marketing_P_N__c,Loaner_Qty__c,
                                  Loaner_Price_100_999_column_price__c,Production_Price_ASP__c,Est_Annual_Qty__c,SOM__c,
                                  Loaner_Total__c,Line_Status__c, RSM__c, VP__c, SVP__c, Name,CreatedById from Loaner_Lines__r
                                  where (RSM__c =: userID OR VP__c =: userId OR SVP__c=:userId OR RSM__r.delegatedapproverId =: userId 
                                         OR VP__r.delegatedapproverId =: userId OR SVP__r.delegatedapproverId =: userId) 
                                  AND Line_Status__c in:CommonConstants.approvalPendingSet) from Loaner__c where id =: recordId];            
            return loanerObj.Loaner_Lines__r;
        }
    }
    
    public static List < sobject > getLineItemsRecordsForApprovalEmail(Id recordId,List<String> status) {
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if (sObjName.equalsIgnoreCase('Quote')) {
            Quote quoteObj = [SELECT Id, Name,RecordTypeId, (Select Id,Line_Status__c,Approval_From__c,RSM_Approval__c,
                             PLM_Approval__c,Std_List_Price__c,Quantity__c,Disti_Resale_Price__c,Competitor_Price__c,
                             Competitor_Info__c,Agreed_Upon_Share__c,Disti_Margin__c,Product__r.Name,
                             Product__r.Marketing_P_N__c,Target_Price__c,RSM_Approver__r.Name,PLM_Approver__r.Name,
                             RSM_Approver__c, PLM_Approver__c, Name,CreatedById from Quote_Items__r where Line_Status__c  
                             in:status) FROM Quote where id =: recordId];
            return quoteObj.Quote_Items__r;
        } else {
            Loaner__c loanerObj = [SELECT Id, RSM_PLM_Finisar__c, RSM_PLM_Approval__c ,VP_PLD_Finisar__c, Name, 
                                  (Select Id,Line_Number__c,Part_Number__c,Marketing_P_N__c,Loaner_Qty__c,
                                   Loaner_Price_100_999_column_price__c,line_total__c,Production_Price_ASP__c,
                                   Est_Annual_Qty__c,SOM__c,Loaner_Total__c,Line_Status__c, RSM__c, VP__c, SVP__c, Name,
                                   CreatedById from Loaner_Lines__r where Line_Status__c  in:status) 
                                   from Loaner__c where id =: recordId];
            return loanerObj.Loaner_Lines__r;
        }
    }
    public static set<id> getDelegatedApprovedID(set<id> userIds){
        set<id> delegatedApproverSet = New Set<id>();
        for(User u:[select id,delegatedapproverId from user where id in :userIds]){
            delegatedApproverSet.add(u.delegatedapproverId);
        }
        return delegatedApproverSet;
    }
    
    public static set<id> getUserFromDelegatedApproverID(id userID){
        set<id> userIdSet = New Set<id>{userID};
            for(user u :[select id,delegatedapproverId from user where delegatedapproverId =: userID]){
                userIdSet.add(u.id);
            }
            return userIdSet;
    }
    
    // Getting all line Items With IncorrectLineItems
    
        public static List < sobject > getInvalidLoanersLineItemsRecords(Id recordId) {
            List<Loaner_line__c> LoanerLineList = New List<Loaner_line__c>();
            FOR(Loaner_line__c loanerLineob :[Select Id,Initial_Error_Message__c,Line_Number__c,Part_Number__c,Marketing_P_N__c,Return_Instructions__c,
                                              Loaner_Total__c,Production_Price_ASP__c,RSM__c, VP__c, SVP__c, Name,Product__c,Line_Status__c,
                                              line_total__c,Loaner_Qty__c,Loaner_Price_100_999_column_price__c,Est_Annual_Qty__c,SOM__c,
                                              SAM__c from Loaner_Line__c  where Loaner__c =: recordId]){
                If(loanerLineob.Initial_Error_Message__c!=Null){
                    LoanerLineList.add(loanerLineob);
                }
            }
            return LoanerLineList;
        }
    
}