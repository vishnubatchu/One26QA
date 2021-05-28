public without sharing class QuoteApprovalController {
@AuraEnabled
    public static Quote QuoteQuery(ID quoteId) {
        	//string LoginUser = UserInfo.getUserId();
        	Set<id> loginAndDelegatedUserSet = RecordApprovalDao.getUserFromDelegatedApproverID(UserInfo.getUserId());
         if(quoteId != null) {
                              return [SELECT Id, Name, QuoteNumber,Sales_Channel__r.Name,Account__r.Name,Customer__r.Name,ExpirationDate, CreatedDate,
                                              (SELECT Id, Name,Std_List_Price__c,Line_Total__c, Quantity__c,Product__r.Name ,
                                               Target_Price__c,Disti_Resale_Price__c,RSM_Approver__r.Name,PLM_Approver__r.Name,Approval_From__c
                                               FROM Quote_Items__r 
                                               where ((PLM_Approver__c In :loginAndDelegatedUserSet AND 
                                                      	(Approval_From__c =:'PLM' OR Approval_From__c = :'BothApprovers')
                                                      )
                                              			OR (RSM_Approver__c In :loginAndDelegatedUserSet AND 
                                                            (Approval_From__c =:'RSM' OR Approval_From__c = :'BothApprovers')
                                                            )
                                                     )
                                              )
                                     FROM Quote where ID = :quoteId];
            				 }
        else{
            return null;
        	}
    }

    @AuraEnabled
    public static List<string> ApproveRecords(List<String> appRecordId, String ObjId) {
        String ObjName = 'Quote';
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
        String ObjName = 'Quote';
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
		
        if((currentuser.UserRole.name == ReassignRole) || (currentuser.UserRole.name == 'Sales Admin')){
           RecordsLineItemApprovalHelper.reAssignUser(ObjId, currentuser,ReasignEmail,LineItemsReAssign);
        }
        if((currentuser.UserRole.name != ReassignRole) && (currentuser.UserRole.name != 'Sales Admin'))
        {Result = 'Please enter valid email!' ;}
        system.debug(currentuser.UserRole.name);system.debug(ReassignRole);system.debug(Result);
    	
        return Result;
    }
}