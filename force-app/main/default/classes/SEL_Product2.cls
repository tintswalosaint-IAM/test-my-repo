/**
* @description Selector layer class for Product2 SObject
*
* Story:SFP-31259
*
* @author Narendra Teja
*
* @date May 2022
* @last modified on  : 29-02-2024
* @last modified by  : Narendra Teja
* @ Modification Description : SFP-31259, used new field signing arrangement SBO-UK
*/
public inherited sharing class SEL_Product2 extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{
        'id',  
        'Name',
        'ProductCode',
        'AOB_Memo_Code__c',
        'IsActive',
        'Product_Image__c',
        'AOB_Pricing_Option__c',
        'Description',
        'AOB_Product_Details__c',
        'AOB_Scheme_Type__c',
        'Country__c',
        'AOB_Account_Type__c',
         'RecordTypeId'
    };
    /**
     * @description This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public override Schema.SObjectType getSObjectType(){
        return Product2.SObjectType;
    }

    /**
     * @description This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Name,
            Product2.ProductCode,
            Product2.AOB_Memo_Code__c,
            Product2.IsActive,
            Product2.Country__c,
            Product2.Product_Image__c,
            Product2.AOB_Pricing_Option__c,
            Product2.Description,
            Product2.AOB_Product_Details__c,
            Product2.AOB_Scheme_Type__c,
            Product2.AOB_Account_Type__c,
            Product2.RecordTypeId
        };
    }        
    
   
    /**
     * @description Select by ProductCode
     * @param productCode
     * @return List<Product2>
     */
    public List<Product2> selectMemoProduct(String productCode ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_Memo_Code__c=:productCode');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productCode
     * @return List<Product2>
     */
    public List<Product2> fetchICSProduct(String productCode ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('productCode=:productCode');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productCodeList
     * @return List<Product2>
     */
    public List<Product2> fetchICSProductList(List<String> productCodeList ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('productCode in:productCodeList');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
   /**
 * @description Select by ProductCode for SBO-UK Project
 * @param productCodeList
 * @return List<Product2>
 */
    public List<Product2> fetchPPBProductList(List<String> productCodeList, String country) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        List<String> conditions = new List<String>();
        for (String memocode : productCodeList) {
            if (String.isNotBlank(memocode)) {
                conditions.add('AOB_Memo_Code__c != \'' + memocode + '\'');
            }
        }
        String combinedCondition = String.join(conditions, ' AND ');
        String finalCondition = combinedCondition + ' AND IsActive = True AND Country__c = :country';
        fieldQueryFactory.setCondition(finalCondition);
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
     /**
     * @description Select by Product Name for SBO-UK Project
     * @param productNameList
     * @return List<Product2>
     */
    public List<Product2> selectByProductNames(List<String> productNameList ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Name in:productNameList');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
        /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productCodeList
     * @return List<Product2>
     */
    public List<Product2> selectByProductCodes(List<String> productCodeList ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('productCode in:productCodeList');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
      /**
     * @description Select by ProductCode
     * @param productCode
     * @return List<Product2>
     */
    public List<Product2> selectMemoProductByProductCode(String productCode ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AOB_Memo_Code__c=:productCode');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productCode
     * @return List<Product2>
     */
    public List<Product2> selectByProductCode(String productCode ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('productCode=:productCode');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
        /**
     * @description Select by ProductCode for SBO-UK Project
     * @param productCode
     * @return List<Product2>
     */
    public List<Product2> selectByProductName(String productName ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Name=:productName');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
            
    /**
     * @description Select by ProductCode ID for SBO-UK Project
     * @param Id
     * @return List<Product2>
     */
    public List<Product2> selectById(String Id ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id=:Id');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
 
    /**
     * @description Select by ProductCode ID for SBO-UK Project
     * @param Id
     * @return List<Product2>
     */
    public List<Product2> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id in : ids');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}