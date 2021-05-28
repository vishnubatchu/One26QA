public class SendReminderEmailToRSMPLM {
	public class QuoteParameters 
    {@InvocableVariable(required = true)
		public Id quoteId;
     @InvocableVariable(required = true)
		public String TemplateName;
     @InvocableVariable(required = true)
		public String Status;
	}

	@InvocableMethod
	public static void sendEmailsToRSMandPLM(QuoteParameters[] quoteParamters) {
		set < id > userIds = New Set < id > ();
		List < String > statusList = quoteParamters.get(0).Status.split(',');
		List < Quote_item__c > quoteItemsList = RecordApprovalDao.getLineItemsRecordsForApprovalEmail(quoteParamters.get(0).quoteId, statusList);
		Map < Id,set < id >> mapOfApprovalPending = New Map < Id,set < id >> ();
		for (ProcessInstanceWorkitem piwObj: [Select Id, ActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in :quoteItemsList]) {
			if (mapOfApprovalPending.containskey(piwObj.ProcessInstance.TargetObjectId)) {
				mapOfApprovalPending.get(piwObj.ProcessInstance.TargetObjectId).add(piwObj.ActorId);
			}
			else {
				mapOfApprovalPending.put(piwObj.ProcessInstance.TargetObjectId, New Set < Id > {
					piwObj.ActorId
				});
			}
		}

		if (quoteItemsList.size() > 0) {
			for (Quote_item__c qitemObj: quoteItemsList) {
				IF(mapOfApprovalPending.containskey(qitemObj.id)) {
					If(qitemObj.RSM_Approver__c != Null && mapOfApprovalPending.get(qitemObj.id).contains(qitemObj.RSM_Approver__c)) {
						userIds.add(qitemObj.RSM_Approver__c);
					}
					If(qitemObj.PLM_Approver__c != Null && mapOfApprovalPending.get(qitemObj.id).contains(qitemObj.PLM_Approver__c)) {
						userIds.add(qitemObj.PLM_Approver__c);
					}
				}
			}

			RecordsLineItemApprovalHelper.sendEmailwithTemplete(userIds, quoteParamters.get(0).quoteId, quoteParamters.get(0).TemplateName);
		}
	}
}