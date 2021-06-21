public class ProductTriggerHelper {
   
    /*
     * Commenting the below code as the new pricebook structure is different 
		from this implementation*/
    
    /*public static void updateProductSharing(List<Product2> products){
        Set<String> segmentNumbers = new Set<String>();
        Set<String> tbdParts = new Set<String>();
        Map<String, String> segmentPriceBookMap = new Map<String, String>();
        Map<String, String> priceBookMap = new Map<String, String>();
        List<PricebookEntry> pbEntry = new List<PricebookEntry>();
        for(Product2 prd : products){
            segmentNumbers.add(prd.Segment_Number__c);
            if(prd.Name.startsWith('TBD') || prd.Name.startsWith('TOOL') || prd.Name.startsWith('MATRL'))
                tbdParts.add(prd.Id);
        }
        system.debug('segmentNumbers'+segmentNumbers);
        String standardPriceBookId;
        if(test.isRunningTest()){
            standardPriceBookId = Test.getStandardPricebookId();
        }else{
            standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;
        }
        //   Pricebook2 standardPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        for(Product_Configuration__mdt mtd : [SELECT Id, USMO__c, Segment_Number__c, Part_List_Name__c  
                                              FROM Product_Configuration__mdt]){
                                                  segmentPriceBookMap.put(mtd.Segment_Number__c, mtd.Part_List_Name__c);
                                              }
        system.debug('segmentPriceBookMap'+segmentPriceBookMap);
        for(Pricebook2 pb : [SELECT Id, Name, IsActive 
                             FROM Pricebook2 
                             WHERE Name = 'Military' OR Name IN : segmentPriceBookMap.values()]){
                                 priceBookMap.put(pb.Name, pb.Id);
                             }
        system.debug('priceBookMap'+priceBookMap);
        List<CurrencyType> curencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        for(product2 prd : products){
            PricebookEntry pbe;
            
            for(CurrencyType cny : curencies){
                pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId,
                                         Product2Id = prd.Id,
                                         UnitPrice = 0.00,
                                         UseStandardPrice = false,
                                         IsActive = true,
                                         CurrencyIsoCode = cny.IsoCode);
                pbEntry.add(pbe);
                if(tbdParts.contains(prd.Id)){
                    for(String pr : priceBookMap.keySet()){
                        pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = cny.IsoCode, 
                                                 PriceBook2Id = priceBookMap.get(pr));
                        pbEntry.add(pbe);
                    }
                }else{
                    if(prd.USMO__c){
                        pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Military'), CurrencyIsoCode = cny.IsoCode);
                        pbEntry.add(pbe);
                    } else if(String.isNotBlank(prd.Segment_Number__c) &&
                              segmentPriceBookMap.containsKey(prd.Segment_Number__c) && 
                              priceBookMap.containsKey(segmentPriceBookMap.get(prd.Segment_Number__c))){
                                  pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = cny.IsoCode, 
                                                           PriceBook2Id = priceBookMap.get(segmentPriceBookMap.get(prd.Segment_Number__c)));
                                  pbEntry.add(pbe);
                              }
                }
            }
            
        }
        system.debug('pbEntry'+pbEntry);
        if(pbEntry != null && !pbEntry.isEmpty()){
            insert pbEntry;
        }
    }*/
    
    /*
     * Commenting the below code as Corp II-VI has confirmed to not migrate
                Record types and to remove it's references*/
    /*public static void updateProductRecordType(List<Product2> products){
        Map<String, Schema.RecordTypeInfo> recordTypeInfo = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        system.debug('recordTypeInfo'+recordTypeInfo.get('AMD_Part').getRecordTypeId());
        Set<String> segmentNumbers = new Set<String>();
        Map<String, String> segmentRecordtypeMap = new Map<String, String>();
        for(Product2 prd : products){
            segmentNumbers.add(prd.Segment_Number__c);
        }
        system.debug('segmentNumbers'+segmentNumbers);
        for(Product_Configuration__mdt mtd : [SELECT Id, USMO__c, Segment_Number__c, RecordType__c  
                                              FROM Product_Configuration__mdt 
                                              WHERE Segment_Number__c IN :segmentNumbers]){
                                                  segmentRecordtypeMap.put(mtd.Segment_Number__c, mtd.RecordType__c);
                                              }
        for(Product2 prd: products){
            if(prd.USMO__c){
                prd.RecordTypeId = recordTypeInfo.get('Military_Part').getRecordTypeId();
            } else if(segmentRecordtypeMap.containsKey(prd.Segment_Number__c)){
                prd.RecordTypeId = recordTypeInfo.get(segmentRecordtypeMap.get(prd.Segment_Number__c)).getRecordTypeId();
            }
        }
    }*/
    
    /*
     * Commenting the below code as the new pricebook structure is different 
		from this implementation*/
    /*public static void updateProductSharingonSegmentChange(List<Product2> products){
        Set<String> segmentNumbers = new Set<String>();
        Set<String> tbdParts = new Set<String>();
        Map<String, String> segmentPriceBookMap = new Map<String, String>();
        Map<String, String> priceBookMap = new Map<String, String>();
        List<PricebookEntry> pbEntry = new List<PricebookEntry>();
        List<PricebookEntry> deletepbEntry = [SELECT Id FROM PricebookEntry 
                                              WHERE Product2Id IN : products AND PriceBook2.isStandard = false];
        if(deletepbEntry != null && !deletepbEntry.isEmpty()){
            database.delete(deletepbEntry, false);
        }
        for(Product2 prd : products){
            segmentNumbers.add(prd.Segment_Number__c);
        }
        system.debug('segmentNumbers'+segmentNumbers);
        for(Product_Configuration__mdt mtd : [SELECT Id, USMO__c, Segment_Number__c, Part_List_Name__c  
                                              FROM Product_Configuration__mdt 
                                              WHERE Segment_Number__c IN :segmentNumbers]){
                                                  segmentPriceBookMap.put(mtd.Segment_Number__c, mtd.Part_List_Name__c);
                                              }
        system.debug('segmentPriceBookMap'+segmentPriceBookMap);
        for(Pricebook2 pb : [SELECT Id, Name, IsActive 
                             FROM Pricebook2 
                             WHERE Name = 'Military' OR Name IN : segmentPriceBookMap.values()]){
                                 priceBookMap.put(pb.Name, pb.Id);
                             }
        system.debug('priceBookMap'+priceBookMap);
        List<CurrencyType> curencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        for(product2 prd : products){
            PricebookEntry pbe;
            
            for(CurrencyType cny : curencies){
                if(prd.USMO__c){
                    pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                             PriceBook2Id = priceBookMap.get('Military'), CurrencyIsoCode = cny.IsoCode);
                    pbEntry.add(pbe);
                } else if(String.isNotBlank(prd.Segment_Number__c) &&
                          segmentPriceBookMap.containsKey(prd.Segment_Number__c) && 
                          priceBookMap.containsKey(segmentPriceBookMap.get(prd.Segment_Number__c))){
                              pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true, CurrencyIsoCode = cny.IsoCode, 
                                                       PriceBook2Id = priceBookMap.get(segmentPriceBookMap.get(prd.Segment_Number__c)));
                              pbEntry.add(pbe);
                          }
            }
        }
        system.debug('pbEntry'+pbEntry);
        if(pbEntry != null && !pbEntry.isEmpty()){
            //insert pbEntry;
            database.insert(pbEntry, false);
        }
    }*/
    
    /**
     * Created by : Pooja U
     * Date : 18th May 2021
     * Description: This method has implemented as per the new pricebook structure.It assigns the product to pricebook on product create(after insert event) as below,
     * a) Each product is added to 'StandardPriceBook' irrespective of Source_System__c,USMO and SegmentNumber
     * b) Products where Source_System__c = ‘Oracle-EBS’ will get inserted into the “Legacy Finisar Products” Price Book.
     * c) Products where Source_System__c = ‘SAP-China’ will get get inserted into the “Legacy Photonics Products” Price Book. 
     * d) Products where Source_System__c = ‘Glovia’ will get inserted into the “Legacy Marlow Products” Price Book.
     * e) Products where Source_System__c = ‘SAP-US’ AND USMO__c = true will get inserted into the “Legacy II-VI Military Products" Price Book.
     * f) Products where Source_System__c = ‘SAP-US’ AND Segment_Number__c == 16 will get inserted into the “Legacy II-VI Epiworks Products" Price Book. 
     * g) Products where Source_System__c = ‘SAP-US’ AND Segment_Number__c != 16 AND USMO__c = false will get inserted into the “Legacy II-VI Products" Price Book.
     * 
     */
    public static void updateProductSharing(List<Product2> products){
        System.debug('updateProductSharing(List<Product2>) - start');
        System.debug('products==>'+products);
        Map<String, String> priceBookMap = new Map<String, String>();
        List<PricebookEntry> pbEntry = new List<PricebookEntry>();
         String standardPriceBookId;
        
            if(test.isRunningTest()){
                standardPriceBookId = Test.getStandardPricebookId();
            }else{
                standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;
            }


        List<String> pricebookNameList=new List<String>();
        pricebookNameList.add('Legacy Finisar Products');
        pricebookNameList.add('Legacy Photonics Products');
        pricebookNameList.add('Legacy Marlow Products');
        pricebookNameList.add('Legacy II-VI Products');
        pricebookNameList.add('Legacy II-VI Military Products');
        pricebookNameList.add('Legacy II-VI Epiworks Products');
        
       for(Pricebook2 pb : [SELECT Id, Name, IsActive 
                             FROM Pricebook2 
                             WHERE Name in: pricebookNameList]){
                                 priceBookMap.put(pb.Name, pb.Id);
                             }
        system.debug('priceBookMap'+priceBookMap);
        
        List<CurrencyType> currencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
        for(product2 prd : products){
            PricebookEntry pbe;
            
            for(CurrencyType cny : currencies){

                    pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId,
                                         Product2Id = prd.Id,
                                         UnitPrice = 0.00,
                                         UseStandardPrice = false,
                                         IsActive = true,
                                         CurrencyIsoCode = cny.IsoCode);
                	pbEntry.add(pbe);


                                
                if(prd.Source_System__c=='Oracle-EBS' && priceBookMap.containsKey('Legacy Finisar Products')){
                     pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy Finisar Products'), CurrencyIsoCode = cny.IsoCode);
                     pbEntry.add(pbe);
                }else if(prd.Source_System__c=='SAP-CHINA' && priceBookMap.containsKey('Legacy Photonics Products')){
                    pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy Photonics Products'), CurrencyIsoCode = cny.IsoCode);
                     pbEntry.add(pbe);
                }else if(prd.Source_System__c=='Glovia' && priceBookMap.containsKey('Legacy Marlow Products')){
                    pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy Marlow Products'), CurrencyIsoCode = cny.IsoCode);
                     pbEntry.add(pbe);
                }else if(prd.Source_System__c=='SAP-US'){
                      if(prd.USMO__c && priceBookMap.containsKey('Legacy II-VI Military Products')){
                          	pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy II-VI Military Products'),CurrencyIsoCode = cny.IsoCode);
                    		pbEntry.add(pbe);
                      }else if(String.isNotBlank(prd.Segment_Number__c) && prd.Segment_Number__c=='16'
                              && priceBookMap.containsKey('Legacy II-VI Epiworks Products')){ 
                                  pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy II-VI Epiworks Products'),CurrencyIsoCode = cny.IsoCode);
                    		pbEntry.add(pbe);
                      }else if(priceBookMap.containsKey('Legacy II-VI Products')){
                          	pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                 PriceBook2Id = priceBookMap.get('Legacy II-VI Products'),CurrencyIsoCode = cny.IsoCode);
                    		pbEntry.add(pbe);
                      }
                    
                }
            }
        }
        system.debug('pbEntry'+pbEntry);
        if(pbEntry != null && !pbEntry.isEmpty()){
           insert pbEntry;
        }
        System.debug('updateProductSharing(List<Product2>) - end');
    }
    
    
    /*
     * Created by : Pooja U
     * Date : 18th May 2021
     * Description: When Product USMO__c or Segment_Number__c changes,this method deactivates all custom pricebookentries of that product and
     * insert/activate the relevant pricebooks based on the product USMO__c/Segment_Number__c
     */
        public static void updatePrdctShrngOnUSMOOrSegmentChange(List<Product2> products){
            System.debug('updatePrdctShrngOnUSMOOrSegmentChange(List<Product2>) - start');
            System.debug('products==>'+products);
            Map<String, String> priceBookMap = new Map<String, String>();
            List<PricebookEntry> pbEntry = new List<PricebookEntry>();
            Map<String, PricebookEntry> existingPriceBookEntryMap = new Map<String, PricebookEntry>();    
            for(PricebookEntry eachExistingPbEntry : [SELECT Id,Product2Id,IsActive,PriceBook2Id,CurrencyIsoCode FROM PricebookEntry 
                                                      WHERE Product2Id IN : products]){
                                                          eachExistingPbEntry.IsActive=false;	                              
                                                          existingPriceBookEntryMap.put(eachExistingPbEntry.Product2Id+'_'+eachExistingPbEntry.PriceBook2Id+'_'+eachExistingPbEntry.CurrencyIsoCode,
                                                                                    eachExistingPbEntry);
                                                      }
            String standardPriceBookId;
            
            if(test.isRunningTest()){
                standardPriceBookId = Test.getStandardPricebookId();
            }else{
                standardPriceBookId = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1].Id;
            }
            
            
            List<String> pricebookNameList=new List<String>();
            pricebookNameList.add('Legacy Finisar Products');
            pricebookNameList.add('Legacy Photonics Products');
            pricebookNameList.add('Legacy Marlow Products');
            pricebookNameList.add('Legacy II-VI Products');
            pricebookNameList.add('Legacy II-VI Military Products');
            pricebookNameList.add('Legacy II-VI Epiworks Products');
            
            for(Pricebook2 pb : [SELECT Id, Name, IsActive 
                                 FROM Pricebook2 
                                 WHERE Name in: pricebookNameList]){
                                     priceBookMap.put(pb.Name, pb.Id);
                                 }
            system.debug('priceBookMap'+priceBookMap);
            
            List<CurrencyType> currencies = [SELECT Id, IsoCode FROM CurrencyType where IsActive = true];
            for(product2 prd : products){
                PricebookEntry pbe;
                String customPriceBookId='';
                String key='';
                for(CurrencyType cny : currencies){
                    if(existingPriceBookEntryMap.containsKey(prd.Id+'_'+standardPriceBookId+'_'+cny.IsoCode)){
                        pbe=existingPriceBookEntryMap.get(prd.Id+'_'+standardPriceBookId+'_'+cny.IsoCode);
                    	pbe.IsActive=true;
                        existingPriceBookEntryMap.put(prd.Id+'_'+standardPriceBookId+'_'+cny.IsoCode,pbe);
                    }else{
                        pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId,
                                                 Product2Id = prd.Id,
                                                 UnitPrice = 0.00,
                                                 UseStandardPrice = false,
                                                 IsActive = true,
                                                 CurrencyIsoCode = cny.IsoCode);
                        pbEntry.add(pbe);
                    }
                    
                    if(prd.Source_System__c=='SAP-US'){
                        if(prd.USMO__c && priceBookMap.containsKey('Legacy II-VI Military Products')){
                            customPriceBookId=priceBookMap.get('Legacy II-VI Military Products');
                            key=prd.Id+'_'+customPriceBookId+'_'+cny.IsoCode;
                            if(existingPriceBookEntryMap.containsKey(key)){
                                pbe=existingPriceBookEntryMap.get(key);
                                pbe.IsActive=true;
                                existingPriceBookEntryMap.put(key,pbe);
                            }else{
                                pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                         PriceBook2Id = customPriceBookId,CurrencyIsoCode = cny.IsoCode);
                                pbEntry.add(pbe);
                            }
                        }else if(String.isNotBlank(prd.Segment_Number__c) && prd.Segment_Number__c=='16'
                                 && priceBookMap.containsKey('Legacy II-VI Epiworks Products')){
                                     customPriceBookId=priceBookMap.get('Legacy II-VI Epiworks Products');
                                     key=prd.Id+'_'+customPriceBookId+'_'+cny.IsoCode;
                                     if(existingPriceBookEntryMap.containsKey(key)){
                                         pbe=existingPriceBookEntryMap.get(key);
                                         pbe.IsActive=true;
                                         existingPriceBookEntryMap.put(key,pbe);
                                     }else{
                                         pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                                  PriceBook2Id = customPriceBookId,CurrencyIsoCode = cny.IsoCode);
                                         pbEntry.add(pbe);
                                     }
                         }else if(priceBookMap.containsKey('Legacy II-VI Products')){
                             customPriceBookId=priceBookMap.get('Legacy II-VI Products');
                             key=prd.Id+'_'+customPriceBookId+'_'+cny.IsoCode;
                             if(existingPriceBookEntryMap.containsKey(key)){
                                 pbe=existingPriceBookEntryMap.get(key);
                                 pbe.IsActive=true;
                                 existingPriceBookEntryMap.put(key,pbe);
                             }else{
                                 pbe = new PricebookEntry(Product2Id = prd.Id, UnitPrice = 0, IsActive = true,
                                                          PriceBook2Id = customPriceBookId,CurrencyIsoCode = cny.IsoCode);
                                 pbEntry.add(pbe);
                             }
                         }
                        
                    }
                }
            }
            if(existingPriceBookEntryMap!=null && !existingPriceBookEntryMap.isEmpty()){
                pbEntry.addALL(existingPriceBookEntryMap.values());
            }
            system.debug('pbEntry'+pbEntry);
            if(pbEntry != null && !pbEntry.isEmpty()){
                upsert pbEntry;
            }
            System.debug('updatePrdctShrngOnUSMOOrSegmentChange(List<Product2>) - end');
        }
}