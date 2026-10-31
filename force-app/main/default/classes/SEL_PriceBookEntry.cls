/**
* @description Selector layer class for PricebookEntry SObject
*
* Story:SFP-36380
*
* @author Ikyatha Naidu
*
* @date May 2022
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @ Modification Description : SFP-36380, used new field signing arrangement SBO UK
* @Modification  Description: SFP-58241: Added selectByProductNameAndPBName method
* @LastModifiedBy : SFP-55635: NoPbeSharing class created for guest user this must run without sharing
*/
public inherited sharing class SEL_PriceBookEntry extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{
        'id',  
        'Pricebook2Id',
        'Product2Id',
         'product2.productcode',
         'UnitPrice'
        
    };
    /**
     *@description This is used to retrieve the sObject name when building the SOQL queries.
     *
     * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType(){
        return PricebookEntry.SObjectType;
    }

    /**
     *@description This is used to retrieve a specific set of SObject fields
     *
     * @return List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PricebookEntry.Id,
            PricebookEntry.Pricebook2Id,
            PricebookEntry.Product2Id,
            PricebookEntry.product2.productcode,
            PricebookEntry.UnitPrice
        };
    }        
    
   
   
    /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productIds
     * @param pBName
     * @param currencycode
     * @return List<PricebookEntry>
     */
    public List<PricebookEntry> selectByProductcodeAndName(List<string> productIds,string pBName,string currencycode ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Product2.productcode=:productIds and Pricebook2.Name=:pBName and CurrencyIsoCode=:currencycode');
        fieldQueryFactory.selectFields(fields);  
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
        * @description Method to fetch   list of PricebookEntry based on PricebookName and productId
        * @param Product2Id
        * @param pBName
        * @return PricebookEntry
        **/
        public PricebookEntry selectByProductIdAndPBName(String Product2Id ,string pBName,string currencycode ) {                                  
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('Product2Id=:Product2Id  and Pricebook2.Name =:pBName and CurrencyIsoCode=:currencycode');
            fieldQueryFactory.selectFields(fields);
            return Database.query(fieldQueryFactory.toSOQL());
        }
        /**
        * @description Method to fetch  PricebookEntry based on productName and PricebookName
        * @param Product2Id
        * @param pBName
        * @return PricebookEntry
        **/
        public PricebookEntry selectByProductNameAndPBName(String ProductName ,string pBName,string currencycode ) {                                  
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
            fieldQueryFactory.setCondition('Product2.Name =:ProductName  and Pricebook2.Name =:pBName and CurrencyIsoCode=:currencycode');
            fieldQueryFactory.selectFields(fields);
            return Database.query(fieldQueryFactory.toSOQL());
        }
        
        /**
        * @description Method to fetch  PricebookEntry based on productName and PricebookName for Guest user
        * @param Product2Id
        * @param pBName
        * @return PricebookEntry
        **/
        public PricebookEntry selectByProdNameAndPBNameWOSharing(String productName ,string pBName) {
            return new NoPbeSharing().selectByProdNameAndPBNameWOSharing(this,productName,pBName);
        }

    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class NoPbeSharing {

       /**
        * @description Method to fetch  PricebookEntry based on productName and PricebookName
        * @param Product2Id
        * @param pBName
        * @return PricebookEntry
        **/
        public PricebookEntry  selectByProdNameAndPBNameWOSharing(SEL_PriceBookEntry selPbe,String ProductName ,string pBName) {         
            
            sbgplatform.fflib_QueryFactory fieldQueryFactory = selPbe.newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('Product2.Name =:ProductName  and Pricebook2.Name =:pBName');
            fieldQueryFactory.selectFields(fields);
            return Database.query(fieldQueryFactory.toSOQL());
            
        }  

    }
}