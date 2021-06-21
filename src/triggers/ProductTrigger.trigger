trigger ProductTrigger on Product2 (before insert, after insert, after update) {
    String integrationUserIdStr=System.Label.Integration_UserId;
    List<String> integrationUserIdLst=new List<String>();
    if(integrationUserIdStr!=null && integrationUserIdStr.trim()!=''){
        if(integrationUserIdStr.contains(',')){
            integrationUserIdLst=integrationUserIdStr.split(',');
        }else{
            integrationUserIdLst.add(integrationUserIdStr);
        }
    }
    //bypass trigger for Integration user
    if(integrationUserIdLst.isEmpty() || (!integrationUserIdLst.isEmpty() && !integrationUserIdLst.contains(UserInfo.getUserId()))){
        if(trigger.isInsert && trigger.isAfter){
            ProductTriggerHelper.updateProductSharing(trigger.new); 
        }
        if(trigger.isBefore && trigger.isInsert){
            /*Commenting the below code as Corp II-VI has confirmed to not migrate
			*Record types and to remove it's references
			*/
            //ProductTriggerHelper.updateProductRecordType(trigger.new);
        }
        if(trigger.isUpdate && trigger.isAfter){
            List<Product2> updatedProducts = new List<Product2>();
            for(Product2 prd : trigger.new){
                if(prd.Segment_Number__c != trigger.oldMap.get(prd.id).Segment_Number__c ||
                   prd.USMO__c != trigger.oldMap.get(prd.id).USMO__c){
                       updatedProducts.add(prd);
                   }
            }
            if(updatedProducts != null && !updatedProducts.isEmpty()){
                //ProductTriggerHelper.updateProductSharingonSegmentChange(updatedProducts);  
                ProductTriggerHelper.updatePrdctShrngOnUSMOOrSegmentChange(updatedProducts);  
            }
        }
    }
}