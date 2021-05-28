global class ApprovalEmailServiceHandler implements Messaging.InboundEmailHandler {
    public static ID headerID;
    public static String headerObjectName;
    public static String action;
    public static String emailAddressToChange;
    public static String comments;
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String fromAddress = envelope.fromAddress;
        User user = [select id, name, UserRole.name from user where email = :fromAddress And isActive=True limit 1];
        System.debug('User'+user);
        List < String > plaintextbody = email.plainTextBody.split('\n', 0);
        System.debug('plaintextbody'+plaintextbody);
        if(plaintextbody.size()>0){
            System.debug('plaintextbody.get(0)'+ plaintextbody.get(0).split(':').size());
            action = plaintextbody.get(0).split(':').size()>1 ? plaintextbody.get(0).split(':').get(1).trim():'';
            System.debug('Action'+action);
            
            for (String bodyString: plaintextbody) {
                IF(bodyString.contains('Id : [')) {
                   //headerID = bodyString.substringAfter('Id : [').split(']').get(0).trim();
                   headerID = ID.valueOf(bodyString.substringAfter('Id : [').split(']').get(0).trim().replaceAll('[^a-zA-Z0-9]', ''));
                }
                If(bodyString.contains('Forward to:')){
                    String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';		
					Pattern myPattern = Pattern.compile(regex );	
					Matcher myMatcher = myPattern.matcher(bodyString);
					if (myMatcher.find()) {
    					 System.debug(myMatcher.group());
                        emailAddressToChange=myMatcher.group();
                        System.debug('My Email Adddresss String');
					}
                   // emailAddressToChange = bodyString.split('Forward to:').get(1).trim().remove('\'');
                }
                If(bodyString.contains('Comments:')){
                    comments = bodyString.split('Comments:').get(1).remove('\'').trim();
                    System.debug('Commecnts ---------->'+comments);
                }
            }	
            headerObjectName = headerID!=Null?headerId.getSObjectType().getDescribe().getName():'';
            System.debug('headerObjectName'+headerObjectName);
            System.debug('headerID'+headerID);
            System.debug('action'+action);
           
        }
        System.debug('CommonConstants.approvalActions.contains(action)'+CommonConstants.approvalActions.contains(action));
        
        if (CommonConstants.approvalActions.contains(action)) {
            System.debug('Inside Approve');
                Map < Id, sobject > sobjectMap = New Map < id, sobject > (
                    RecordApprovalDao.getLineItemsRecordsForApproval(headerID, user.Id)
                );
            System.debug('sobjectMap'+sobjectMap);
                if (sobjectMap.size() > 0) {
                    RecordsLineItemApprovalHelper.ApproveRecords(sobjectMap.keySet(), headerObjectName,headerID,user.Id);
                }
           
        }
        
        if (CommonConstants.rejectionActions.contains(action)) {
            Map < Id, sobject > sobjectMap = New Map < id, sobject > (
                RecordApprovalDao.getLineItemsRecordsForApproval(headerID, user.Id)
            );
            if (sobjectMap.size() > 0) {
                RecordsLineItemApprovalHelper.RejectRecords(sobjectMap.keySet(), headerObjectName,user.Id);
            }
        }
        
        if (CommonConstants.forwardAction.contains(action)) {
            
            RecordsLineItemApprovalHelper.reAssignUser(headerID,user,emailAddressToChange,New Set<id>());
        }
        return result;
    }
}