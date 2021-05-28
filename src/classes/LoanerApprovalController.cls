public without sharing class LoanerApprovalController {
@AuraEnabled
    public static Loaner__c LoanerQuery(ID loanerId) {
        	string LoginUser = UserInfo.getUserId();
         if(loanerId != null) {
                              return [SELECT Id, Name, Request__c,Status_Approval__c,ECO_Number__c,Loaner_Category__c,Opportunity__r.Name,Opportunity_Type__c,Loaner_Duration_In_Days__c,Company_Name_End_Cust__r.Name, CreatedDate,
                                              (SELECT Id, Name,Product__r.Name,Marketing_P_N__c,Loaner_Qty__c,
                                               Loaner_Price_100_999_column_price__c,Production_Price_ASP__c,Est_Annual_Qty__c,
                                               	SOM__c,SAM__c,Line_Total__c,Loaner_Total__c,Line_Status__c
                                               FROM Loaner_Lines__r
                                              )
                                     FROM Loaner__c where ID = :loanerId];
            				 }
        else{
            return null;
        	}
    }

    @AuraEnabled
    public static List<string> ApproveRecords(List<String> appRecordId, String ObjId) {
        String ObjName = 'Loaner__c';
        string LoginUser = UserInfo.getUserId();
        Set < id > LineItemsApprove = New Set < id > ();
        for(String AppId: appRecordId){
            LineItemsApprove.add(AppId);  
             }
        RecordsLineItemApprovalHelper.ApproveRecords(LineItemsApprove, ObjName, ObjId,LoginUser);
        return appRecordId;
    }
     @AuraEnabled
    public static List<string> RejectRecords(List<String> rejRecordId) {
        String ObjName = 'Loaner__c';
        string LoginUser = UserInfo.getUserId();
        Set < id > LineItemsReject = New Set < id > ();
        for(String RejId: rejRecordId){
            LineItemsReject.add(RejId);  
             }
        RecordsLineItemApprovalHelper.RejectRecords(LineItemsReject, ObjName,LoginUser);
        return rejRecordId;
    }
    
     @AuraEnabled
    public static string ReasignRecords(List<String> reassignRecordId,String ReasignEmail, Id ObjId) {
        User currentuser=new User();
        string Result = 'Success';
        String ReassignRole = 'No Role';
        Set < id > LineItemsReAssign = New Set < id > ();
        for(String ReAssignId: reassignRecordId){
            LineItemsReAssign.add(ReAssignId);  
             }
        system.debug(ReasignEmail);system.debug(ObjId);system.debug(Result);
     	currentuser=[Select Id,Name,Email,UserRole.name from User where Id=:userinfo.getuserId()];
        User[] ReassignUserRole = [Select UserRole.name from User where Email=:ReasignEmail];
        if (ReassignUserRole.size() > 0){
           ReassignRole = ReassignUserRole[0].UserRole.name; 
        }
		System.debug('currentuser'+currentuser);
        System.debug('ReassignRole'+ReassignRole);
        Boolean Reassignment = False;
        if(CommonConstants.mapOfRolesReassignment.get('Loaner__c').get(currentuser.UserRole.name).contains(ReassignRole)){
            Reassignment = True;
           RecordsLineItemApprovalHelper.reAssignUser(ObjId, currentuser,ReasignEmail,LineItemsReAssign);
        }
        if(!Reassignment)
        {Result = 'Please enter valid email!' ;}
        system.debug(currentuser.UserRole.name);system.debug(ReassignRole);system.debug(Result);
    	
        return Result;
    }
}