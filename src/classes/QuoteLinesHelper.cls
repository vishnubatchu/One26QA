public class QuoteLinesHelper {
    public static Boolean isUpdatedQuoteSDEndDate = False;
    public static void updatedQuoteSDEnddate(List<Quote_Item__c> quoteItems, Map<Id,Quote_Item__c> oldMap){
        IF(!isUpdatedQuoteSDEndDate){
            isUpdatedQuoteSDEndDate =True;
            List<Id>quoteIds = new List<Id>();
            Map<Id, Date> quoteEndateMap = new Map<Id, Date>();
            Set<Id> noEndDateQuotes = new Set<Id>();
            List<Quote> updateQuotes = new List<Quote>();
            for(Quote_Item__c quoteItm : quoteItems){
                if(quoteItm.S_D_Line_End_Date__c != null && 
                   oldMap.get(quoteItm.Id).S_D_Line_End_Date__c != quoteItm.S_D_Line_End_Date__c)
                    quoteIds.add(quoteItm.Quote__c);
            }
            if(quoteIds != null && !quoteIds.isEmpty()){
                for(Quote_Item__c qItem : [SELECT Id, Quote__c,S_D_Line_End_Date__c 
                                           FROM Quote_Item__c 
                                           WHERE Quote__c IN :quoteIds]){
                                               if(qItem.S_D_Line_End_Date__c != null){
                                                   if(!noEndDateQuotes.contains(qItem.Quote__c)){
                                                       if(quoteEndateMap.containsKey(qItem.Quote__c)){
                                                           if(quoteEndateMap.get(qItem.Quote__c) < qItem.S_D_Line_End_Date__c)
                                                               quoteEndateMap.put(qItem.Quote__c, qItem.S_D_Line_End_Date__c);
                                                       } else{
                                                           quoteEndateMap.put(qItem.Quote__c, qItem.S_D_Line_End_Date__c);
                                                       }
                                                   } else {
                                                       if(quoteEndateMap.containsKey(qItem.Quote__c))
                                                           quoteEndateMap.remove(qItem.Quote__c);
                                                   }
                                               } else {
                                                   noEndDateQuotes.add(qItem.Quote__c);
                                               }
                                           }
                system.debug('noEndDateQuotes'+noEndDateQuotes);
                system.debug('quoteEndateMap'+quoteEndateMap);
                for(Quote qte :[SELECT Id,S_D_End_Date__c 
                                FROM Quote
                                WHERE Id IN :quoteEndateMap.keyset()]){
                                    if(qte.S_D_End_Date__c != quoteEndateMap.get(qte.Id)){
                                        qte.S_D_End_Date__c = quoteEndateMap.get(qte.Id);
                                        updateQuotes.add(qte);
                                    }
                                }
                system.debug('updateQuotes'+updateQuotes);
                if(updateQuotes != null && !updateQuotes.isEmpty()){
                    try{
                        update updateQuotes;
                    } catch(Exception ex){
                        system.debug('error message'+ex.getMessage());
                    }
                }
            }
        }
    }
    
    /*
Method Name : getPLMApprover
Input parameters: List of Quote Line items
Output parameter : None
Description: updates PLM Approver on quote lines based on PLM approver Matrix.
*/
    public static void getPLMApprover(List<Quote_Item__c> quoteItemList) {
        Set<String> usersSet = new Set<String>();
        Map<String, String> userNameIdMap = new Map<String, String>();
        Map<String, List<PLM_Approval_Matrix__mdt>>  productPLMApprover = new  Map<String, List<PLM_Approval_Matrix__mdt>>();
        Map<Id, Quote_Item__c> newQuoteMap = New Map<Id, Quote_Item__c>();
        Set<Id> productIdSet = new Set<Id>();  
        
        for(PLM_Approval_Matrix__mdt plmRec : [select id,Product_Group_Segment1__c,Family_Segment2__c,FamilySegmentNotOperator__c,Configuration_Segment4__c,ConfigurationNotOperator__c,FormFactorNotOperator__c,
                                               Market_Application_Segment5__c,Form_Factor_Segment3__c,MarketAppNotOperator__c,LaserNotOperator__c,Laser_Segment6__c,Detector_Segment7__c,DetectorNotOperator__c,Approver__c,Upper_Approval_Level__c
                                               from PLM_Approval_Matrix__mdt ]) {
                                                   plmRec.Product_Group_Segment1__c = plmRec.Product_Group_Segment1__c == null?'Blank':plmRec.Product_Group_Segment1__c;
                                                   if(!productPLMApprover.containsKey(plmRec.Product_Group_Segment1__c)){
                                                       productPLMApprover.put(plmRec.Product_Group_Segment1__c,new List<PLM_Approval_Matrix__mdt>{plmRec});
                                                   }else {
                                                       productPLMApprover.get(plmRec.Product_Group_Segment1__c).add(plmRec);
                                                   }
                                                   usersSet.add(plmRec.Approver__c);                                           
                                               }
        usersSet.add(Label.Default_PLM_User_Email);
        for(User uRec : [select id,name from User where isActive =: true AND Name IN :usersSet]) {
            userNameIdMap.put(uRec.Name, uRec.Id);
        }
        for(Quote_Item__c qRec:quoteItemList) {
            productIdSet.add(qRec.product__c);
        }
        Map<Id, Product2> prdMap = new Map<Id, Product2>();
        for(Product2 prd: [SELECT Id,Name,Product_Group__c,Product_Family_Text__c, 
                           Form_Factor__c,Product_Config__c,Mkt_Application__c, Laser__c, Detector__c 
                           FROM Product2 
                           WHERE Id IN :productIdSet]){
                               prdMap.put(prd.Id, prd);
                           }
        
        List<PLM_Approval_Matrix__mdt> getAllPLMBYGroup = new List<PLM_Approval_Matrix__mdt>();    
        for(Quote_Item__c prodrec :quoteItemList) {
            System.debug('prodrec'+prodrec);
            //Added product null check to avoid null pointer exception
            Product2 prd2 = new Product2();
            if(prodrec.Product__c != null){
               prd2 = prdMap.get(prodrec.Product__c); 
            }
            //list<String> userNameList = new list<String>();
            getAllPLMBYGroup.clear();
            //Added productPLMApprover map null check to avoid null pointer exception
          if(prd2.Product_Group__c != null && productPLMApprover != null && productPLMApprover.containsKey(prd2.Product_Group__c)  ){
                if(productPLMApprover.get(prd2.Product_Group__c) != null){
                getAllPLMBYGroup.addall(productPLMApprover.get(prd2.Product_Group__c));
            
               }
                
                //May22 Changes addition of all blank Records into Map also.So they could be taken for calculation 
                
                getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
            }else {
                getAllPLMBYGroup.addall(productPLMApprover.get('Blank'));
            }
            
            if(getAllPLMBYGroup.size()>0) {
                for(PLM_Approval_Matrix__mdt plmRec: getAllPLMBYGroup) {
                    if(plmRec.Family_Segment2__c != null && 
                       plmRec.Family_Segment2__c != '' && 
                       (String.isNotBlank(prd2.Product_Family_Text__c) && plmRec.Family_Segment2__c.contains(prd2.Product_Family_Text__c)) &&
                       plmRec.FamilySegmentNotOperator__c == true ){
                           continue;
                       } else if (plmRec.Family_Segment2__c == null || 
                                  (String.isNotBlank(prd2.Product_Family_Text__c) && plmRec.Family_Segment2__c.contains(prd2.Product_Family_Text__c))  || 
                                  plmRec.FamilySegmentNotOperator__c == true) {
                                      if(plmRec.Form_Factor_Segment3__c != null && 
                                         (String.isNotBlank(prd2.Form_Factor__c) && plmRec.Form_Factor_Segment3__c.contains(prd2.Form_Factor__c)) && 
                                         plmRec.FormFactorNotOperator__c == true){
                                             continue;
                                         } else if (plmRec.Form_Factor_Segment3__c == null || 
                                                    (String.isNotBlank(prd2.Form_Factor__c) && plmRec.Form_Factor_Segment3__c.contains(prd2.Form_Factor__c)) ||  
                                                    plmRec.FormFactorNotOperator__c == true) { 
                                                        if(plmRec.Configuration_Segment4__c != null && 
                                                           (String.isNotBlank(prd2.Product_Config__c) && plmRec.Configuration_Segment4__c.contains(prd2.Product_Config__c)) && 
                                                           plmRec.ConfigurationNotOperator__c == true){
                                                               continue;
                                                           } else if (plmRec.Configuration_Segment4__c == null || 
                                                                      (String.isNotBlank(prd2.Product_Config__c) && plmRec.Configuration_Segment4__c.contains(prd2.Product_Config__c)) ||  
                                                                      plmRec.ConfigurationNotOperator__c == true) {
                                                                          if(plmRec.Market_Application_Segment5__c !=null && 
                                                                             (String.isNotBlank(prd2.Mkt_Application__c) && plmRec.Market_Application_Segment5__c.contains(prd2.Mkt_Application__c)) && 
                                                                             plmRec.MarketAppNotOperator__c == true){
                                                                                 continue;
                                                                             }else if (plmRec.Market_Application_Segment5__c == null || 
                                                                                       (String.isNotBlank(prd2.Mkt_Application__c) && plmRec.Market_Application_Segment5__c.contains(prd2.Mkt_Application__c)) ||
                                                                                       plmRec.MarketAppNotOperator__c == true) {
                                                                                           if(plmRec.Laser_Segment6__c != null && 
                                                                                              (String.isNotBlank(prd2.Laser__c) && plmRec.Laser_Segment6__c.contains(prd2.Laser__c)) && 
                                                                                              plmRec.LaserNotOperator__c == true){
                                                                                                  continue;
                                                                                              } else if (plmRec.Laser_Segment6__c == null || 
                                                                                                         (String.isNotBlank(prd2.Laser__c) && plmRec.Laser_Segment6__c.contains(prd2.Laser__c)) ||  
                                                                                                         plmRec.LaserNotOperator__c == true) { 
                                                                                                             if(plmRec.Detector_Segment7__c !=null && 
                                                                                                                (String.isNotBlank(prd2.Detector__c) && plmRec.Detector_Segment7__c.contains(prd2.Detector__c)) && 
                                                                                                                plmRec.DetectorNotOperator__c == true){
                                                                                                                    continue;
                                                                                                                } else if(plmRec.Detector_Segment7__c == null || 
                                                                                                                          (String.isNotBlank(prd2.Detector__c) && plmRec.Detector_Segment7__c.contains(prd2.Detector__c)) || 
                                                                                                                          plmRec.DetectorNotOperator__c == true) {
                                                                                                                              prodrec.PLM_Approver__c = userNameIdMap.get(plmRec.Approver__c);
                                                                                                                              prodrec.Approver_3M__c = userNameIdMap.get(plmRec.Upper_Approval_Level__c);
                                                                                                                              newQuoteMap.put(prodrec.id, prodrec);
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
                //May22 Changes defaulting to betty when no Plm is there.Label contains betty's name       
                IF(!newQuoteMap.containskey(prodrec.Id) && userNameIdMap.containskey(Label.Default_PLM_User_Email)){
                    prodrec.PLM_Approver__c = userNameIdMap.get(Label.Default_PLM_User_Email);
                    newQuoteMap.put(prodrec.id, prodrec);
                }
            }
        }
    }
    public static void updateBuonQuote(List<Quote_Item__c> deletedLines){
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, String> quoteMap = new Map<Id, String>();
        for(Quote_Item__c line : deletedLines){
            quoteIds.add(line.Quote__c);
            quoteMap.put(line.Quote__c, null);
        }
        for(Quote_Item__c lin : [SELECT Id,Product__r.BU_Code__c, Quote__c, Product__r.Product_Family__c
                                 FROM Quote_Item__c 
                                 WHERE Quote__c IN :quoteMap.keySet()]){
                                     if(lin.Product__r.BU_Code__c == '0040' &&
                                        lin.Product__r.Product_Family__c != 'WSS-OIG' && 
                                        lin.Product__r.Product_Family__c != 'WSS-OCM'){
                                            quoteMap.put(lin.Quote__c, 'WSS');
                                        } else{
                                            quoteMap.put(lin.Quote__c, 'Non WSS');
                                        }
                                 }
        List<Quote> updateQuotes = new List<Quote>();
        for(Id quoteId :quoteMap.keySet()){
            updateQuotes.add(new Quote(Id = quoteId, BusinessUnit__c = quoteMap.get(quoteId)));
        }
        if(updateQuotes != null && !updateQuotes.isEmpty()){
            update updateQuotes;
        }
    }
}