trigger RMARequestLineTrigger on RMA_Request_Line__c (after insert, after update) {
    RMARequestLineHelper.updateCasePLM(trigger.new);
}