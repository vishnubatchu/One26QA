/**
 * @Author		:		Rajavardhan 
 * @Date		:		31-March-2019
 * @Desc		:		Controller for Lookup Lightning Component
 * */
public class Lookup {

    /**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Text - API name of field to display to user while searching
     * @fld_API_Val - API name of field to be returned by Lookup COmponent
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * */
    @AuraEnabled(cacheable=true)
    public static String searchDB(String objectName, String fld_API_Text, String fld_API_Val,String field_API_search_marketingPN,
                                  Integer lim,String fld_API_Search,String searchText ){
        system.debug('in searchDB');
        system.debug('in searchDB'+lim);
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';

        //String marketingPNApiName = 'Marketing_P_N__c';
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+' , '+field_API_search_marketingPN+
            			' FROM '+objectName+
            				' WHERE ('+fld_API_Search+' LIKE '+searchText+ ' OR '+field_API_search_marketingPN +' LIKE '+ searchText + ' )'+
            					' AND  Available__c =' +'true ORDER BY '+field_API_search_marketingPN+ ' ASC  LIMIT '+lim;
            					//' AND  Available__c =' +'true ORDER BY '+field_API_search_marketingPN+ ' ASC ' ;
        
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            obj.Name = String.valueOf(s.get(fld_API_Text)) ;
            obj.Id = String.valueOf(s.get(fld_API_Val))  ;
            obj.marketingPN =String.valueOf(s.get(field_API_search_marketingPN));
            lstRet.add(obj);
        } 
         return JSON.serialize(lstRet) ;
    }
	/*@AuraEnabled(cacheable=true)
    public static List<Product2> searchProducts(String searchKeyword,Integer offst,Integer lim)
    {
        String searchword = '\'%'+String.escapeSingleQuotes(searchKeyword)+'%\'';
        String searchQuery ='select Id,Name,Marketing_P_N__c,Available__c,ProductCode,Description from Product2 where Available__c=true'
                                    +' and (Name  like '+searchword+' or Marketing_P_N__c like '+searchword+' ) AND Available__c=true LIMIT '+lim;
        List<Product2> products = Database.query(searchQuery);
        return products;
    }*/
    public class ResultWrapper{
        public String objName {get;set;}
        public String Name{get;set;}
        public String Id{get;set;}
        public String marketingPN {get;set;}
    }
}