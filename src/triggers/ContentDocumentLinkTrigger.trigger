trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, after delete) {
    if(trigger.isInsert && trigger.isAfter){
        ContentDocumentLinkTriggerHelper.updateFilesCount(trigger.new);    
    }
    if(trigger.isAfter && trigger.isDelete){
        ContentDocumentLinkTriggerHelper.updateFilesCount(trigger.old);    
    }
    
}