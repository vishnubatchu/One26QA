public class RMARequestLineHelper {
    /*
Method Name : updateCasePLM
Input parameters: List of RMA Line items
Output parameter : None
Description: updates PLM Approver on case based on PLM approver Matrix.
*/ 
    public static void updateCasePLM(List<RMA_Request_Line__c> rmas){
        Set<Id> rmaIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        //Set<String> usersSet = new Set<String>();
        Map<Id, Set<Id>> rmaProductMap = new Map<Id, Set<Id>>();
        Map<Id, String> productPlmMap = new Map<Id, String>();
        Map<String, Id> userMap = new Map<String, Id>();
        List<PLM_Approval_Matrix__mdt> getAllPLMBYGroup = new List<PLM_Approval_Matrix__mdt>();
        Map<String, List<PLM_Approval_Matrix__mdt>>  productPLMApprover = new  Map<String, List<PLM_Approval_Matrix__mdt>>();
        for(RMA_Request_Line__c line : rmas){
            rmaIds.add(line.RMA_Request__c);
        }
        for(RMA_Request_Line__c allLine : [SELECT Id,Product__c,RMA_Request__c 
                                           FROM RMA_Request_Line__c
                                           WHERE RMA_Request__c IN : rmaIds]){
                                               if(rmaProductMap.containsKey(allLine.RMA_Request__c)){
                                                   rmaProductMap.get(allLine.RMA_Request__c).add(allLine.Product__c);
                                               } else {
                                                   rmaProductMap.put(allLine.RMA_Request__c, new Set<Id>{allLine.Product__c});
                                               }
                                               productIds.add(allLine.Product__c);
                                           }
        for(PLM_Approval_Matrix__mdt plmRec : [select id,Product_Group_Segment1__c,Family_Segment2__c,FamilySegmentNotOperator__c,Configuration_Segment4__c,ConfigurationNotOperator__c,FormFactorNotOperator__c,
                                               Market_Application_Segment5__c,Form_Factor_Segment3__c,MarketAppNotOperator__c,LaserNotOperator__c,Laser_Segment6__c,Detector_Segment7__c,DetectorNotOperator__c,Approver__c,Upper_Approval_Level__c
                                               from PLM_Approval_Matrix__mdt ]) {
                                                   plmRec.Product_Group_Segment1__c = plmRec.Product_Group_Segment1__c == null?'Blank':plmRec.Product_Group_Segment1__c;
                                                   if(!productPLMApprover.containsKey(plmRec.Product_Group_Segment1__c)){
                                                       productPLMApprover.put(plmRec.Product_Group_Segment1__c,new List<PLM_Approval_Matrix__mdt>{plmRec});
                                                   }else {
                                                       productPLMApprover.get(plmRec.Product_Group_Segment1__c).add(plmRec);
                                                   }
                                                  // usersSet.add(plmRec.Approver__c);                                           
                                               }
        for(Product2 prd: [SELECT Id,Name,Product_Group__c,Product_Family_Text__c, 
                           Form_Factor__c,Product_Config__c,Mkt_Application__c, Laser__c, Detector__c 
                           FROM Product2 
                           WHERE Id IN :productIds]){
                               getAllPLMBYGroup.clear();
                               if(prd.Product_Group__c != null && 
                                  productPLMApprover.containsKey(prd.Product_Group__c)){
                                      getAllPLMBYGroup.addall(productPLMApprover.get(prd.Product_Group__c));
                                      getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
                                  }else {
                                      getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
                                  }
                               
                               for(PLM_Approval_Matrix__mdt plmRec: getAllPLMBYGroup) {
                                   if(plmRec.Family_Segment2__c != null && 
                                      plmRec.Family_Segment2__c != '' && 
                                      (String.isNotBlank(prd.Product_Family_Text__c) && 
                                       plmRec.Family_Segment2__c.contains(prd.Product_Family_Text__c)) &&
                                      plmRec.FamilySegmentNotOperator__c == true ){
                                          continue;
                                      } else if (plmRec.Family_Segment2__c == null || 
                                                 (String.isNotBlank(prd.Product_Family_Text__c) && 
                                                  plmRec.Family_Segment2__c.contains(prd.Product_Family_Text__c))  || 
                                                 plmRec.FamilySegmentNotOperator__c == true) {
                                                     if(plmRec.Form_Factor_Segment3__c != null && 
                                                        (String.isNotBlank(prd.Form_Factor__c) && 
                                                         plmRec.Form_Factor_Segment3__c.contains(prd.Form_Factor__c)) && 
                                                        plmRec.FormFactorNotOperator__c == true){
                                                            continue;
                                                        } else if (plmRec.Form_Factor_Segment3__c == null || 
                                                                   (String.isNotBlank(prd.Form_Factor__c) &&
                                                                    plmRec.Form_Factor_Segment3__c.contains(prd.Form_Factor__c)) ||  
                                                                   plmRec.FormFactorNotOperator__c == true) { 
                                                                       if(plmRec.Configuration_Segment4__c != null && 
                                                                          (String.isNotBlank(prd.Product_Config__c) && 
                                                                           plmRec.Configuration_Segment4__c.contains(prd.Product_Config__c)) && 
                                                                          plmRec.ConfigurationNotOperator__c == true){
                                                                              continue;
                                                                          } else if (plmRec.Configuration_Segment4__c == null || 
                                                                                     (String.isNotBlank(prd.Product_Config__c) && 
                                                                                      plmRec.Configuration_Segment4__c.contains(prd.Product_Config__c)) ||  
                                                                                     plmRec.ConfigurationNotOperator__c == true) {
                                                                                         if(plmRec.Market_Application_Segment5__c !=null && 
                                                                                            (String.isNotBlank(prd.Mkt_Application__c) && 
                                                                                             plmRec.Market_Application_Segment5__c.contains(prd.Mkt_Application__c)) && 
                                                                                            plmRec.MarketAppNotOperator__c == true){
                                                                                                continue;
                                                                                            }else if (plmRec.Market_Application_Segment5__c == null || 
                                                                                                      (String.isNotBlank(prd.Mkt_Application__c) &&
                                                                                                       plmRec.Market_Application_Segment5__c.contains(prd.Mkt_Application__c)) ||
                                                                                                      plmRec.MarketAppNotOperator__c == true) {
                                                                                                          if(plmRec.Laser_Segment6__c != null && 
                                                                                                             (String.isNotBlank(prd.Laser__c) && 
                                                                                                              plmRec.Laser_Segment6__c.contains(prd.Laser__c)) && 
                                                                                                             plmRec.LaserNotOperator__c == true){
                                                                                                                 continue;
                                                                                                             } else if (plmRec.Laser_Segment6__c == null || 
                                                                                                                        (String.isNotBlank(prd.Laser__c) && 
                                                                                                                         plmRec.Laser_Segment6__c.contains(prd.Laser__c)) ||  
                                                                                                                        plmRec.LaserNotOperator__c == true) { 
                                                                                                                            if(plmRec.Detector_Segment7__c !=null && 
                                                                                                                               (String.isNotBlank(prd.Detector__c) && 
                                                                                                                                plmRec.Detector_Segment7__c.contains(prd.Detector__c)) && 
                                                                                                                               plmRec.DetectorNotOperator__c == true){
                                                                                                                                   continue;
                                                                                                                               } else if(plmRec.Detector_Segment7__c == null || 
                                                                                                                                         (String.isNotBlank(prd.Detector__c) && 
                                                                                                                                          plmRec.Detector_Segment7__c.contains(prd.Detector__c)) || 
                                                                                                                                         plmRec.DetectorNotOperator__c == true) {
                                                                                                                                             productPlmMap.put(prd.id, plmRec.Approver__c);
                                                                                                                                             // prodrec.PLM_Approver__c = userNameIdMap.get(plmRec.Approver__c);
                                                                                                                                             //  prodrec.Approver_3M__c = userNameIdMap.get(plmRec.Upper_Approval_Level__c);
                                                                                                                                             //  newQuoteMap.put(prodrec.id, prodrec);
                                                                                                                                         }
                                                                                                                        } else  {
                                                                                                                            continue;
                                                                                                                        }
                                                                                                          
                                                                                                      } else {
                                                                                                          continue;
                                                                                                      }
                                                                                     }else {
                                                                                         continue;
                                                                                     }
                                                                       
                                                                   } else {
                                                                       continue;
                                                                   }
                                                 }
                                   else {
                                       continue;
                                   }
                                   
                               }
                           }
        Map<Id, string> casePlmMap = new Map<Id, String>();
        system.debug('rmaProductMap'+rmaProductMap);
        for(Id caseId : rmaProductMap.keySet()){
            String plm = '';
            for(Id productId : rmaProductMap.get(caseId)){
                if(productPlmMap.containsKey(productId) && String.isEmpty(plm)){
                    plm = productPlmMap.get(productId);
                } else if(productPlmMap.containsKey(productId) && plm != productPlmMap.get(productId)){
                    plm = 'Steffen Koehler';
                }
            }
            casePlmMap.put(caseId, plm);
        }
        for(User usr :[SELECT Id, Name FROM User WHERE Name IN :casePlmMap.values()]){
            userMap.put(usr.Name, usr.Id);
        }
        List<Case> updateCasePLM = new List<Case>();
        for(id caseId : casePlmMap.keySet()){
            Case cs = new Case(Id = caseId, PLM__c = userMap.get(casePlmMap.get(caseId)));
            updateCasePLM.add(cs);
        }
        system.debug('updateCasePLM'+updateCasePLM);
        if(updateCasePLM != null && !updateCasePLM.isEmpty()){
            update updateCasePLM;
        }
    }
    
}