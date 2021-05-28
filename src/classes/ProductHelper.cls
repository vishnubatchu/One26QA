public class ProductHelper {
    public static void checkGenericPNs(List<Loaner_Line__c> newList, Map<Id,Loaner_Line__c> oldMap){
        for(Loaner_Line__c line : newList){
            system.debug('line.Marketing_P_N__c'+line.Marketing_P_N__c + '  '+oldMap.get(line.Id).Marketing_P_N__c);
            Boolean samePart = compareMarketigPNs(line.Marketing_P_N__c, oldMap.get(line.Id).Marketing_P_N__c);
            if(samePart != null && !samePart){
                line.addError('Product not match');
            }
        }
        //Marketing_P_N__c
    }
    public static Boolean compareMarketigPNs(String mp2, String mp1){
        if(mp1.length() == mp2.length()){
            if(mp1.endsWithIgnoreCase('xxxx')){
                if(mp1.subString(0, mp1.indexOfIgnoreCase('xxxx')).contains('xx')){
                    String str = '10TRAAU5SPLXXX';
                    system.debug('size '+str.length());
                    system.debug('index ' + str.indexOfIgnoreCase('xxx'));
                    system.debug('sub string '+str.subString(0,str.indexOfIgnoreCase('xxx')));
                    return compareMiddlestr(mp1.removeEndIgnoreCase('xxxx'), mp2);
                }else {
                    return compareSubString(mp1.subString(0, mp1.indexOfIgnoreCase('xxxx')),mp2);
                }
            } else if(mp1.endsWithIgnoreCase('xxx')){
                if(mp1.subString(0, mp1.indexOfIgnoreCase('xxx')).contains('xx')){
                    return compareMiddlestr(mp1.removeEndIgnoreCase('xxx'), mp2);
                } else {
                    return compareSubString(mp1.subString(0, mp1.indexOfIgnoreCase('xxx')),mp2);
                }
                
            } else if(mp1.endsWithIgnoreCase('xx')){
                if(mp1.subString(0, mp1.indexOfIgnoreCase('xx')).contains('xx')){
                    return compareMiddlestr(mp1.removeEndIgnoreCase('xx'), mp2.removeEndIgnoreCase('xx'));
                } else {
                    return compareSubString(mp1.subString(0, mp1.indexOfIgnoreCase('xx')),mp2);
                }
            } else if(mp1.contains('xx')){
                return compareMiddlestr(mp1, mp2);
            } else{
                system.debug('test');
                return null;
            }
        } else{
            system.debug('different part');
            return null;
        }
        
    }
    public static Boolean compareSubString(String str1, String str2){
        if(str1.equals(str2.substring(0, str1.length()))){
            system.debug('sdfs : '+str2.substring(0, str1.length()));
            system.debug('same generic part');
            return null;
        } else {
            system.debug('different part');
            return false;
        }
    }
    public static Boolean compareMiddlestr(String str1, String str2){
        system.debug('str1 '+str1);
        str1 = str1.removeEndIgnoreCase('xx');
        system.debug('str1 '+str1);
        system.debug('str1 '+str2);
        str2 = str2.substring(0, str1.length());
        system.debug('str1 '+str2);
        system.debug('index of xx '+str1.indexOf('xx'));
        system.debug('index of xx '+str1.substring(0, str1.indexOf('xx')) );
        system.debug('index of xx '+str1.substring(str1.indexOf('xx')+2,str1.length()) );
        if(str1.substring(0, str1.indexOf('xx')).equals(str2.substring(0, str1.indexOf('xx'))) && 
           str1.substring(str1.indexOf('xx')+2,str1.length()).equals(str2.substring(str1.indexOf('xx')+2,str1.length()))){
               system.debug('same generic part');
               return null;
           } else {
               system.debug('different part');
               return false;
           }
    }
    @auraEnabled
    public static productdetails getProducts(String productCode, String produtFamily, String marketingFamily){
        List<Product2> products = new List<Product2>();
        string prdStatus ='Active';
        system.debug('productCode '+productCode+ ' produtFamily '+produtFamily+' marketingFamily' +marketingFamily);
        String query = 'Select Id, Name,Lead_Time__c,Product_Group__c,Marketing_P_N__c,Product_Family__c,Marketing_Family__c from Product2 where ';
        if(String.isNotBlank(productCode)){
            query = query+ 'Product_Group__c =:productCode';
            if(String.isNotBlank(produtFamily)){
                query = query+ ' And Product_Family__c =:produtFamily';
            }
            if(String.isNotBlank(marketingFamily)){
                query = query+ ' And Marketing_Family__c =:marketingFamily';
            }
        } else if(String.isNotBlank(produtFamily)){
            query = query+ ' Product_Family__c =:produtFamily';
            if(String.isNotBlank(marketingFamily)){
                query = query+ ' And Marketing_Family__c =:marketingFamily';
            }
        } else if(String.isNotBlank(marketingFamily)){
            query = query+ ' Marketing_Family__c =:marketingFamily';
        }
        system.debug('query '+query);
        products = database.query(query);
        system.debug('products'+products);
        productdetails prdDet = new productdetails();
        prdDet.count = products.size();
        prdDet.productList = products;
        return prdDet;
    }
    @auraEnabled
    public static List<Product2> updateProductsData(String leadTime, String products){
        system.debug('products '+products);
        List<Product2> productlst = (List<Product2>)JSON.deserialize(products, List<product2>.class) ;
        if(String.isNotBlank(leadTime)){
            for(Product2 prd :productlst){
               // prd.Lead_Time__c = leadTime;
            }
        }
        system.debug('products'+products);
        if(productlst != null && !productlst.isEmpty()){
            update productlst;
        }
            return productlst;
    }
    public class productdetails{
        @auraEnabled
        public Integer count;
        @auraEnabled
        public List<Product2> productList;
        public productdetails(){
            
        }
    }
}