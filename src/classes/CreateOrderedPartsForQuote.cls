public with sharing class CreateOrderedPartsForQuote {
    public Quote_Item__c quoteProduct{get;set;}
    public list<ClassBOMProdWrapper> listOfClassBOMProdWrapper{get;set;}    
    public boolean isRender{get;set;}
    public list<Ordered_BOM_Parts__c> listOfBOMParts{get;set;}
    
    public CreateOrderedPartsForQuote(ApexPages.StandardController controller) {
        listOfBOMParts = new list<Ordered_BOM_Parts__c>();
        
        quoteProduct= (Quote_Item__c)controller.getRecord();
        quoteProduct= [SELECT Id, Name , Product__c, Quote__c , Quote__r.Name  
                       FROM Quote_Item__c  
                       WHERE id =:quoteProduct.id ];
        listOfClassBOMProdWrapper = new list<ClassBOMProdWrapper>();
        setOfBOMProdIds = new set<id>();        
        isRender = true;
        
        
        list<BOM_Product_Part__c> listfProdParts = [SELECT Name,Quantity__c,BOM_Part__c,English_Description__c,BOM_Part__r.Name,BOM_Part__r.Quantity__c, 
                                                    BOM_Part__r.Deutch_Description__c,BOM_Part__r.English_Description__c,BOM_Part__r.English_Rich_Text_Description__c,
                                                    BOM_Part__r.Deutsch_Rich_Text_Description__c,Sequence__c                                                                                                    
                                                    from BOM_Product_Part__c 
                                                    WHERE Product__c =: quoteProduct.Product__c
                                                    order by Sequence__c
                                                    ASC NULLS LAST];
        
        if(listfProdParts.size() == 0){
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.Info,'No parts are available.');
            Apexpages.addMessage(errorMessage);
            isRender = false;
        }else{
            list<Ordered_BOM_Parts__c> listOfOrderPars = [SELECT Name, Quantity__c, BOM_Product_Part__c, 
                                                          Deutch_Description__c, Deutch_Rich_Text_Description__c,
                                                          English_Description__c, English_Rich_Text_Description__c,
                                                          OpportunityProduct__c, OrderProduct__c, Position__c, QuoteLineItem__c    
                                                          from Ordered_BOM_Parts__c where QuoteLineItem__c  =: quoteProduct.id 
                                                          order by Sequence__c];
            
            listOfBOMParts.addall(listOfOrderPars);
            for(Ordered_BOM_Parts__c ord : listOfOrderPars){
                setOfBOMProdIds.add(ord.BOM_Product_Part__c);
            }
            
            ClassBOMProdWrapper classBOMProdWrapperLocal;
            for(BOM_Product_Part__c bom :listfProdParts){  
                classBOMProdWrapperLocal = new ClassBOMProdWrapper();
                if(setOfBOMProdIds.contains(bom.id)){
                    classBOMProdWrapperLocal.isAdded = 'Added';
                }
                classBOMProdWrapperLocal.bomProd = bom;
                classBOMProdWrapperLocal.isSelected = false;
                listOfClassBOMProdWrapper.add(classBOMProdWrapperLocal);
            }
        }
    }
    
    public pagereference cancel(){    
        return new pagereference('/'+quoteProduct.Quote__c);
    }
    
    
    public set<id> setOfBOMProdIds;
    public pagereference addParts(){
        for(ClassBOMProdWrapper classBOMProdWrapperLocal : listOfClassBOMProdWrapper){
            if(classBOMProdWrapperLocal.isSelected){        
                classBOMProdWrapperLocal.isAdded = 'Added';
                classBOMProdWrapperLocal.isSelected = false;
                Ordered_BOM_Parts__c ordPart = new Ordered_BOM_Parts__c();
                ordPart.QuoteLineItem__c = quoteProduct.id;
                ordPart.BOM_Product_Part__c = classBOMProdWrapperLocal.bomProd.id;
                ordPart.Name = classBOMProdWrapperLocal.bomProd.BOM_Part__r.Name;
                ordPart.Quantity__c = classBOMProdWrapperLocal.bomProd.BOM_Part__r.Quantity__c;
                ordPart.Deutch_Description__c = classBOMProdWrapperLocal.bomProd.BOM_Part__r.Deutch_Description__c;
                ordPart.English_Description__c = classBOMProdWrapperLocal.bomProd.BOM_Part__r.English_Description__c;
                ordPart.English_Rich_Text_Description__c = classBOMProdWrapperLocal.bomProd.BOM_Part__r.English_Rich_Text_Description__c;
                ordPart.Deutch_Rich_Text_Description__c = classBOMProdWrapperLocal.bomProd.BOM_Part__r.Deutsch_Rich_Text_Description__c;
                ordPart.Sequence__c = classBOMProdWrapperLocal.bomProd.Sequence__c;
                listOfBOMParts.add(ordPart);
            }
        }          
        return null;
    }
    
    public pagereference sortListByName(){
        listOfBOMParts.sort();
        return null;
    }    
    
    public pagereference sortListByPostion(){
        
        listOfBomPartWrapper = new list<BomPartWrapper>();
        BomPartWrapper BomPartWrapperLocal;
        for(Ordered_BOM_Parts__c ord : listOfBOMParts){
            setOfBOMProdIds.add(ord.BOM_Product_Part__c);
            
            BomPartWrapperLocal = new BomPartWrapper(ord);
            BomPartWrapperLocal.orderedPart = ord;
            listOfBomPartWrapper.add(BomPartWrapperLocal);
        }
        listOfBomPartWrapper.sort();
        listOfBOMParts.clear();
        
        
        for(BomPartWrapper wrap :  listOfBomPartWrapper){
            listOfBOMParts.add(wrap.orderedPart);
        }
        return null;
    }
    
    // to remove the added product
    public pagereference removeBOMOrderedProduct(){
        string bomProdRemoveLocal = ApexPages.currentPage().getParameters().get('BOMProductId');        
        for(ClassBOMProdWrapper classBOMProdWrapperLocal : listOfClassBOMProdWrapper){
            if(classBOMProdWrapperLocal.bomProd.id == bomProdRemoveLocal){
                classBOMProdWrapperLocal.isAdded = 'Available';
                break;
            }
        }
        
        
        Ordered_BOM_Parts__c ordToDelete = new Ordered_BOM_Parts__c();
        
        for(integer i=0; i <listOfBOMParts.size();i++ ){
            Ordered_BOM_Parts__c ordPart = listOfBOMParts[i];
            if(ordPart.BOM_Product_Part__c  == bomProdRemoveLocal){
                listOfBOMParts.remove(i);
                setOfBOMProdIds.remove(bomProdRemoveLocal);
                if(ordPart.id != null)
                    ordToDelete.id = ordPart.id;
                break;    
            }  
        }            
        
        if(ordToDelete.id != null){
            delete ordToDelete;
        }
        return null;
    }
    
    
    public pagereference save(){
        savepoint sp;
        try{
            sp = DataBase.setSavepoint();
            
            upsert listOfBOMParts;
            
            return new pagereference('/'+quoteProduct.id);
            
        }catch(exception ex){
            DataBase.RollBack(sp); 
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,'Exception occured==>>' + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);
            return null;
        }
        //  return null;
    }
    
    
    public class ClassBOMProdWrapper{
        public BOM_Product_Part__c bomProd{get;set;}
        public String isAdded{get;set;}
        
        public boolean isSelected{get;set;}
        public ClassBOMProdWrapper(){
            isSelected = false; 
            bomProd =  new BOM_Product_Part__c();
            isAdded = 'Available';
        }
    }
    
    public list<BomPartWrapper> listOfBomPartWrapper{get;set;} 
    public class BomPartWrapper implements Comparable {
        public Ordered_BOM_Parts__c orderedPart;
        public BomPartWrapper(Ordered_BOM_Parts__c orderedPartRecord) {
            orderedPart = orderedPartRecord;
        }
        public Integer compareTo(Object compareTo) {
            BomPartWrapper compareToProdPosition = (BomPartWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (orderedPart.Position__c > compareToProdPosition.orderedPart.Position__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (orderedPart.Position__c < compareToProdPosition.orderedPart.Position__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
}