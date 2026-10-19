/**
* @description Selector layer class for Product2 SObject Test Class
*
* Story:SFP-3025
*
* @author Narendra Teja
*
* @date May 2022
**************************************
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @ Modification Description : SFP-36380 Added  methods to fecth products based on productCode
*/
@IsTest
private class SEL_Product2_Test {
    @TestSetup
    static void setupTestData() {
       ICS_DAL_TestFactory.createProduct2();
    }
    @IsTest
    static void testGetSObjectType() {
        SEL_Product2 accountSelector = new SEL_Product2();
        Schema.SObjectType sObjectType = accountSelector.getSObjectType();
        
        Assert.areEqual(Product2.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Product2 accountSelector = new SEL_Product2();
        List<Schema.SObjectField> sObjectFieldList = accountSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = Product2.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(true, sObjectFieldList.size()>0, 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
    @IsTest
    static void testGetPartyProfileList() {
       Product2 prd=new Product2();
       list<String> productMemoCode = new list<String>{'OD005'};
       string countryCode= 'UG';
        prd.ProductCode='SOCTY';
        prd.AOB_Memo_Code__c='SOCTY';
        prd.Name='test test';
        prd.CurrencyIsoCode = 'BWP';
        insert prd;
        List<string> prdCodeList= new List<string>();
        prdCodeList.add(prd.ProductCode);
        SEL_Product2 prodQueryList = new SEL_Product2();
    	prodQueryList.selectMemoProduct(prd.AOB_Memo_Code__c);
        prodQueryList.fetchICSProduct(prd.ProductCode);
        prodQueryList.fetchICSProductList(prdCodeList);
        List<Product2> prdCodeListPPB = prodQueryList.fetchPPBProductList(productMemoCode,countryCode);
        Assert.areEqual(1, prdCodeList.size(), 'Unexpected Account count');
        
    }
 
    /**
     * @description Verify that the SObjectType returned is Product2.SObjectType
     */
    @IsTest
    static void testGetSObjectTypes() {
        SEL_Product2 productSelector = new SEL_Product2();
        Test.startTest();
        Schema.SObjectType sObjectType = productSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Product2.SObjectType, sObjectType, 'The returned SObjectType does not match Product2.SObjectType');
    }
 
    /**
     * @description Verify that the SObjectFieldList returned is not empty and contains valid fields
     */
    @IsTest
    static void testGetSObjectFieldLists() {
        SEL_Product2 productSelector = new SEL_Product2();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = productSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = Product2.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in Product2 field map');
        }
    }
 
    /**
     * @description Verify that a Product2 record is returned for the given product code
     */
    @IsTest
    static void testSelectMemoProductByProductCode() { 
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectMemoProductByProductCode(prd.AOB_Memo_Code__c);
        Assert.areEqual(2, productList.size(), 'Expected 2 Product2 record for the product code: ' + prd.AOB_Memo_Code__c);
    }
 
    /**
     * @description Verify that a Product2 record is returned for the given product code
     */
    @IsTest
    static void testSelectByProductCode() {
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectByProductCode(prd.ProductCode);
        Assert.areEqual(2, productList.size(), 'Expected 2 Product2 record for the product code: ' + prd.ProductCode);
    }
 
    /**
     * @description Verify that a list of Product2 records is returned for the given list of product codes
     */
    @IsTest
    static void testSelectByProductCodes() {
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        List<String> prdCodeList = new List<String>{prd.ProductCode};
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectByProductCodes(prdCodeList);
        Assert.areEqual(2, productList.size(), 'Expected 2 Product2 record for the list of product codes');
    }
 
    /**
     * @description Verify that a Product2 record is returned for the given product name
     */
    @IsTest
    static void testSelectByProductName() {
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectByProductName(prd.Name);
        Assert.areEqual(2, productList.size(), 'Expected 2 Product2 record for the product name: ' + prd.Name);
    }
 
    /**
     * @description Verify that a Product2 record is returned for the given product ID
     */
    @IsTest
    static void testSelectById() {
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectById(prd.Id);
        selProduct.selectByIds(new set<Id>{prd.Id});
        Assert.areEqual(1, productList.size(), 'Expected 1 Product2 record for the product ID: ' + prd.Id);
    }
 
    /**
     * @description Verify that a list of Product2 records is returned for the given list of product names
     */
    @IsTest
    static void testSelectByProductNames() {
        Product2 prd = ICS_DAL_TestFactory.createProduct2();
        List<String> prdNameList = new List<String>{prd.Name};
        SEL_Product2 selProduct = new SEL_Product2();
        List<Product2> productList = selProduct.selectByProductNames(prdNameList);
        Assert.areEqual(2, productList.size(), 'Expected 2 Product2 record for the list of product names');
    }
    
}