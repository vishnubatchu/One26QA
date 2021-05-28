/*************************************************************************************************************************************************************
@ Class:          FAFVCustomUI
@ Version:        1.0
@ Author:         Akhilesh Das (adas@huronconsultinggroup.com)
@ Purpose:        Custom UI Controller 
--------------------------------------------------------------------------------------------------------------------------------------------------------------
@ Change history: 25.01.2019 / Akhilesh Das / Created the Class.
**************************************************************************************************************************************************************/


public class FAFVCustomUI {
    @AuraEnabled
    public static faDetailWrapper getFAFVRecord(String orderID) {
        list<Serial_Number__c> sNoList = [select id,Name,Order_Line__c,Customer_Serial_Number__c,Date_Code__c 
                                          from Serial_Number__c 
                                          where Order_Line__c =: orderID];
        list<FA_FV_Detail__c> fafvDetailList = [select id,Suppliers__c,FA_FV__c,Serial_Number__r.id, Lane__c, OperatingTime__c,
                                                Serial_Number__r.Customer_Serial_Number__c,Serial_Number__r.Disposition__c,
                                                Serial_Number__r.Name from FA_FV_Detail__c 
                                                where Serial_Number__c in : sNoList ];
        
        map<id,list<FA_FV_Detail__c>> SerialNomap = new map<id,list<FA_FV_Detail__c>>();
        list<string> faIDList  = new list<string>();
        list<string> sNoIDList  = new list<string>();
        faDetailWrapper faWrapper = new faDetailWrapper();
        for(FA_FV_Detail__c fa : fafvDetailList){
            if(!faWrapper.fafvSerialNoMap.containsKey(fa.FA_FV__c)){
                faWrapper.fafvSerialNoMap.put(fa.FA_FV__c,new list<FA_FV_Detail__c>{fa});
            }else{
                faWrapper.fafvSerialNoMap.get(fa.FA_FV__c).add(fa);
            }
            faIDList.add(fa.FA_FV__c);
            sNoIDList.add(fa.Serial_Number__r.id);
        }
        list<Serial_Number__c> sNoListFinal = [select id,Disposition__c,Status__c,Name,Order_Line__c,Customer_Serial_Number__c,Date_Code__c 
                                               from Serial_Number__c 
                                               where id in : sNoIDList];
        for(FA_FV_Detail__c fas : fafvDetailList){
            for(Serial_Number__c fa : sNoListFinal){
                if(fas.Serial_Number__r.id == fa.id){
                    if(!faWrapper.SerialNoMap.containsKey(fas.FA_FV__c)){
                        faWrapper.SerialNoMap.put(fas.FA_FV__c,new list<Serial_Number__c>{fa});
                    }else{
                        faWrapper.SerialNoMap.get(fas.FA_FV__c).add(fa);
                    }
                }
            }
        }
        faWrapper.fafvAnalysisList = [select id,LastModifiedBy.Name,LastModifiedDate,Name,FA_FV_Status__c,FA_FV_Type__c,RecordTypeId,RecordType.Name,Findings__c,Quantity__c,Received_Date__c,FV_Report_Status__c 
                                      from FA_FV_Analysis__c 
                                      where id in :faIDList  ];
        faWrapper.sNoFinalList = [select id,Customer_Serial_Number__c,Name,Order_Line__c,Date_Code__c 
                                  from Serial_Number__c 
                                  where id Not in : sNoIDList AND Order_Line__c =: orderID];
        return faWrapper;
    }
    @AuraEnabled
    public static string deleteRow(string ids) {
        list<FA_FV_Detail__c> FaFv =  [select id from FA_FV_Detail__c where id =: ids] ;
        list<Steps__c> step =  [select id from Steps__c where id =: ids] ;
        list<Failure_Modes__c> fModes =  [select id from Failure_Modes__c where id =: ids] ;  
        if(FaFv.size() > 0 || FaFv != null ){
            delete FaFv;   
        }
        if(step.size() > 0 || step != null){
            delete step;   
        }
        if(fModes.size() > 0 || fModes != null){
            delete fModes;   
        }
        string abc = 'ac';
        return abc;
    }
    @AuraEnabled
    public static list<FA_FV_Analysis__c>  saveFAFV(FA_FV_Detail__c newfafvRec,list<FA_FV_Analysis__c> oldfafvRec){
        string fafvID = newfafvRec.FA_FV__c;
        
        list<FA_FV_Analysis__c> newRec = new list<FA_FV_Analysis__c>();
        
        newRec.add([select id,Name,FA_FV_Type__c,FA_FV_Status__c,LastModifiedDate,Findings__c,RecordType.Name,Quantity__c,Received_Date__c,FV_Report_Status__c from FA_FV_Analysis__c where id =:fafvID]);
        if(oldfafvRec != null || oldfafvRec.size() > 0){
            newRec.addAll(oldfafvRec);
        }
        return newRec;
    }
    @AuraEnabled
    public static string  savefCodeRec(list<Failure_Modes__c> fcode){
        List<Failure_Modes__c> lstRecordToInsert =  new List<Failure_Modes__c>();
        List<Failure_Modes__c> lstRecordToUpdate =  new List<Failure_Modes__c>();  
        
        for(Failure_Modes__c obj : fcode){
            if(obj.Id != null){
                lstRecordToUpdate.add(obj);
            } else{
                Failure_Modes__c fd = new Failure_Modes__c();
                fd.FAFV_Analysis__c   = obj.FAFV_Analysis__c;
                fd.Fault_Specification__c = obj.Fault_Specification__c;
                fd.PDC_Level_2__c   = obj.PDC_Level_2__c;
                fd.PIC_Level_1__c =obj.PIC_Level_1__c;
                fd.PDC_Level_1__c  = obj.PDC_Level_1__c;
                fd.PIC_Level_2__c = obj.PIC_Level_2__c;
                fd.Site__c     = obj.Site__c;
                //   fd.Component_Description__c = obj.Component_Description__c;
                //   fd.Traceability_Information__c = obj.Traceability_Information__c; 
                lstRecordToInsert.add(fd);  
            }
        }
        
        if( !lstRecordToUpdate.isEmpty() )
            update lstRecordToUpdate;
        if( !lstRecordToInsert.isEmpty() )
            insert lstRecordToInsert;
        
        string ids = 'abc';
        return ids;
    }
    
    @AuraEnabled
    public static string  saveStepsRec(list<Steps__c> stepLists){
        List<Steps__c> lstRecordToInsert =  new List<Steps__c>();
        List<Steps__c> lstRecordToUpdate =  new List<Steps__c>();  
        
        for(Steps__c obj : stepLists){
            if(obj.Id != null){
                lstRecordToUpdate.add(obj);
            } else{
                Steps__c fd = new Steps__c();
                fd.Name   = obj.Name;
                fd.FA_FV__c = obj.FA_FV__c;
                fd.FA_Findings__c   = obj.FA_Findings__c;
                fd.Comments__c =obj.Comments__c;
                fd.FA_Steps_Description_FA_Steps__c  = obj.FA_Steps_Description_FA_Steps__c;
                
                lstRecordToInsert.add(fd);  
            }
        }
        
        if( !lstRecordToUpdate.isEmpty() )
            update lstRecordToUpdate;
        if( !lstRecordToInsert.isEmpty() )
            insert lstRecordToInsert;
        
        string ids = 'abc';
        return ids;
    }
    @AuraEnabled
    public static string  saveSnoRec(list<FA_FV_Detail__c> snoList){
        List<FA_FV_Detail__c> lstRecordToInsert =  new List<FA_FV_Detail__c>();
        List<FA_FV_Detail__c> lstRecordToUpdate =  new List<FA_FV_Detail__c>();  
        
        for(FA_FV_Detail__c obj : snoList){
            if(obj.Id != null){
                
                lstRecordToUpdate.add(obj);
                system.debug('lstRecordToUpdate -- ' + lstRecordToUpdate);
            } else{
                FA_FV_Detail__c fd = new FA_FV_Detail__c();
                fd.FA_FV__c   = obj.FA_FV__c;
                fd.Serial_Number__c = obj.Serial_Number__c;
                fd.FA_FV_Notes__c   = obj.FA_FV_Notes__c;
                fd.FA_Completion_Date__c =obj.FA_Completion_Date__c;
                fd.FA_FV_Type_Col__c  = obj.FA_FV_Type_Col__c;
                fd.Relevant_Vendor_Contact__c = obj.Relevant_Vendor_Contact__c;
                fd.SLA__c     = obj.SLA__c;
                fd.Status__c   = obj.Status__c;
                fd.Vendor_Name__c = obj.Vendor_Name__c;
                fd.Vendor_Ship_to_addres__c = obj.Vendor_Ship_to_addres__c;
                fd.Traceability_Information__c = obj.Traceability_Information__c;
                fd.Component_Description__c = obj.Component_Description__c;
                fd.Suppliers__c             = obj.Suppliers__c;
                fd.OperatingTime__c             = obj.OperatingTime__c;
                lstRecordToInsert.add(fd);  
                system.debug('lstRecordToInsert -- ' + lstRecordToInsert);
            }
        }
        try {  
            if( !lstRecordToUpdate.isEmpty() ){
                Database.update(lstRecordToUpdate);  
            }
            if( !lstRecordToInsert.isEmpty() ){
                Database.insert(lstRecordToInsert); 
            }
            return 'Passed';
            
        }   catch(exception e) {
            String msg = e.getMessage();
            if(msg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                msg = msg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            }
            
            return msg;
            
        }
    }
    
    @AuraEnabled
    public static fafvDetailWrapper  getFAFVrelatedList(string FAFVId,string order){
        system.debug('FAFVId ' + FAFVId);
        Order_line__c orderLine = [SELECT Id, Ship_From_Inventory__c FROM order_line__c WHERE Id = :order ];
        FA_FV_Analysis__c fafv = [SELECT Id, FA_FV_Type__c FROM FA_FV_Analysis__c WHERE Id = :FAFVId];
        list<Serial_Number__c> sNoList = [select id,Name,Traceability_Information__c,Component_Description__c,Order_Line__c,Customer_Serial_Number__c ,Date_Code__c 
                                          from Serial_Number__c 
                                          where Order_Line__c =: order]; 
        system.debug('sNoList___ ' + sNoList);
        List<Steps__c> stepsList =[Select id,Name,FA_FV__c,FA_Findings__c,FA_Steps_Description_FA_Steps__c,Comments__c 
                                   from Steps__c where FA_FV__c =:FAFVId ORDER BY CREATEDDATE ASC];
        system.debug('stepsList ' + stepsList);
        List<Failure_Modes__c> failureList =[Select id,Name,FAFV_Analysis__c,Fault_Specification__c,PDC_Level_1__c,PDC_Level_2__c,PIC_Level_1__c,
                                             PIC_Level_2__c,Site__c,Traceability_Information__c,Component_Description__c from Failure_Modes__c where FAFV_Analysis__c =:FAFVId ];
        list<FA_FV_Detail__c> fafvDetailList = [select id,Traceability_Information__c,Component_Description__c,FA_FV__c,Serial_Number__r.Name, OperatingTime__c,
                                                Serial_Number__r.Customer_Serial_Number__c,FA_FV_Notes__c,Suppliers__c,FA_Completion_Date__c,
                                                FA_FV_Type_Col__c,Serial_Number__c,Relevant_Vendor_Contact__c,SLA__c,Status__c,Vendor_Name__c,
                                                Vendor_Ship_to_addres__c,Lane__c from FA_FV_Detail__c 
                                                where Serial_Number__c In : sNoList AND FA_FV__c =: FAFVId  ];
        //where Serial_Number__c In : sNoList ];
        system.debug('availList--- ' + fafvDetailList);
        list<string> availSerialNo = new list<string>();
        if(orderLine.Ship_From_Inventory__c == 'SYD'){
            for(FA_FV_Detail__c fa : fafvDetailList){
                availSerialNo.add(fa.Serial_Number__c);
            }
        } else{
            for(FA_FV_Detail__c fa : [select id,Serial_Number__c
                                      from FA_FV_Detail__c 
                                      where Serial_Number__c In : sNoList 
                                      AND FA_FV__r.FA_FV_Type__c = :fafv.FA_FV_Type__c]){
                                          availSerialNo.add(fa.Serial_Number__c);
                                      }
        }
        list<Serial_Number__c> availsNoList = [select id,Order_Line__c,Name,Disposition__c,Customer_Serial_Number__c ,Date_Code__c 
                                               from Serial_Number__c  
                                               where id not in: availSerialNo and Order_Line__c =: order ORDER BY NAME ASC]; 
        
        fafvDetailWrapper faWrapper = new fafvDetailWrapper();
        if(failureList.size() > 0 || failureList <> null){
            faWrapper.failureModeList   = failureList; 
        }else{
            list<Failure_Modes__c> fmList = new list<Failure_Modes__c>();
            faWrapper.failureModeList   = fmList; 
        }
        if(fafvDetailList.size() > 0 || fafvDetailList <> null){
            faWrapper.sNoFinalList   = fafvDetailList; 
        }else{
            list<FA_FV_Detail__c> fdList = new list<FA_FV_Detail__c>();
            faWrapper.sNoFinalList   = fdList; 
        }
        if(stepsList.size() > 0 || stepsList <> null){
            faWrapper.stepslList   = stepsList; 
        }else{
            list<Steps__c> stList = new list<Steps__c>();
            faWrapper.stepslList   = stList; 
        }
        if(availsNoList.size() > 0 || availsNoList <> null){
            faWrapper.allSerialnolList   = availsNoList; 
        }else{
            list<Serial_Number__c> snList = new list<Serial_Number__c>();
            faWrapper.allSerialnolList   = snList; 
        }
        return faWrapper;
    }
    public class faDetailWrapper{
        @AuraEnabled public list<FA_FV_Analysis__c>  fafvAnalysisList = new list<FA_FV_Analysis__c>();
        @AuraEnabled public list<Serial_Number__c>  sNoFinalList = new list<Serial_Number__c>();
        @AuraEnabled public map<id,list<FA_FV_Detail__c>>  fafvSerialNoMap = new map<id,list<FA_FV_Detail__c>>();
        @AuraEnabled public map<id,list<Serial_Number__c>>  SerialNoMap = new map<id,list<Serial_Number__c>>();
    }
    public class fafvDetailWrapper{
        @AuraEnabled public list<Failure_Modes__c>  failureModeList = new list<Failure_Modes__c>();
        @AuraEnabled public list<FA_FV_Detail__c>  sNoFinalList = new list<FA_FV_Detail__c>();
        @AuraEnabled public list<Steps__c>  stepslList = new list<Steps__c>();
        @AuraEnabled public list<Serial_Number__c>  allSerialnolList = new list<Serial_Number__c>();
    }
    
    @auraEnabled
    public static string cloneFAFV(String FAFVRecId){
        return CloneFAFVRecord.getFAFVRecord(FAFVRecId);
    }
    @AuraEnabled
    //public static cloneFafvWrapper  cloneFAFVRec(FA_FV_Detail__c newfafvRec,list<FA_FV_Analysis__c> oldfafvRec){
      //  string fafvID = newfafvRec.FA_FV__c;
    public static cloneFafvWrapper  cloneFAFVRec(String fafvID,list<FA_FV_Analysis__c> oldfafvRec){
     //   string fafvID = newfafvRec.FA_FV__c;
        String newFaName = CloneFAFVRecord.getFAFVRecord(fafvID);
        list<FA_FV_Analysis__c> newRec = new list<FA_FV_Analysis__c>();
        FA_FV_Analysis__c clonedFafv = [select id,Name,FA_FV_Type__c,FA_FV_Status__c,LastModifiedDate,Findings__c,RecordType.Name,Quantity__c,Received_Date__c,FV_Report_Status__c 
                                        from FA_FV_Analysis__c 
                                        where Id =:newFaName LIMIT 1];
        newRec.add(clonedFafv);
        if(oldfafvRec != null || oldfafvRec.size() > 0){
            newRec.addAll(oldfafvRec);
        }
        cloneFafvWrapper wrp = new cloneFafvWrapper();
        wrp.fafvList = newRec;
        wrp.cloneFaFvName = clonedFafv.Name;
        return wrp;
    }
    public class cloneFafvWrapper{
        @AuraEnabled public list<FA_FV_Analysis__c>  fafvList = new list<FA_FV_Analysis__c>();
        @AuraEnabled public String cloneFaFvName ;
    }
    @AuraEnabled
    public static String getSONumber(String orderlineId){
       return [SELECT Id, SO_Number_Formula__c FROM Order_Line__c WHERE Id = :orderlineId].SO_Number_Formula__c;
    }
}