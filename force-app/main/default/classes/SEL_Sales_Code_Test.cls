/**
 * @description SFP-36390 Selector Test class for Sales_Codes__c object.
 * This class provides methods to retrieve Sales_Codes__c records.
 * author: Ofentse Sacha
 * @date 02 November 2023
 */
@IsTest
public class SEL_Sales_Code_Test {

    @TestSetup
    static void setupTestData() {
        ICS_DAL_TestFactory.createTestDataSalesCode();
    }

    /**
    * @description Verify that the SObjectType returned is Sales_Codes__c.SObjectType
    */
    @IsTest
    static void testGetSObjectType() {
        SEL_Sales_Code salesCodeSelector = new SEL_Sales_Code();
        Test.startTest();
        Schema.SObjectType sObjectType = salesCodeSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Sales_Codes__c.SObjectType, sObjectType, 'The returned SObjectType does not match Sales_Codes__c.SObjectType');
    }

    /**
    * @description Verify that the SObjectFieldList returned is not empty and contains valid fields
    */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Sales_Code salesCodeSelector = new SEL_Sales_Code();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = salesCodeSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = Sales_Codes__c.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(fieldMap.size(), sObjectFieldList.size(), 'Unexpected field count in the SObjectFieldList');
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in Sales_Codes__c field map');
        }
    }

    /**
    * @description Verify that Sales_Codes__c records are returned for a given ID
    */
    @IsTest
    static void testSelectById() {
        Sales_Codes__c testSalesCode = [SELECT Id FROM Sales_Codes__c LIMIT 1];
        SEL_Sales_Code sales = new SEL_Sales_Code();
        Test.startTest();   
        List<Sales_Codes__c> salesCodeList = sales.selectById(testSalesCode.Id);
        Test.stopTest();
        Assert.areEqual(1, salesCodeList.size(), 'Expected 1 Sales_Codes__c record for Sales_Codes__c ID: ' + testSalesCode.Id + ' but got ' + salesCodeList.size());
    }

    /**
    * @description Verify that Sales_Codes__c records are returned for given name
    */
    @IsTest
    static void testSelectByName() {
        SEL_Sales_Code sales = new SEL_Sales_Code();
        Test.startTest();
        List<Sales_Codes__c> salesCodeList = sales.selectByName('028NP');
        Test.stopTest();
        Assert.areEqual(true, salesCodeList.size() > 0, 'Expected at least 1 Sales_Codes__c record for given name but got ' + salesCodeList.size());
    }

    /**
    * @description Verify that Sales_Codes__c records are returned for given name and country
    */
    @IsTest
    static void testSelectByNameAndSalesCodeCountry() {
        SEL_Sales_Code sales = new SEL_Sales_Code();
        Test.startTest();   
        List<Sales_Codes__c> salesCodeList = sales.selectByNameAndSalesCodeCountry('028NP', 'ZA');
        Test.stopTest();
        Assert.areEqual(true, salesCodeList.size() > 0, 'Expected at least 1 Sales_Codes__c record for given name and country but got ' + salesCodeList.size());
    }

    /**
    * @description Verify that no Sales_Codes__c records are returned for given country, region, and area
    */
    @IsTest
    static void testSelectByCountryRegion() {
        SEL_Sales_Code sales = new SEL_Sales_Code();
        Test.startTest();   
        List<Sales_Codes__c> salesCodeList = sales.selectByCountryRegion('IN', 'TS', 'SA');
        sales.selectByCountryRegion('ZA', 'TS', 'SA');
        Test.stopTest();
        Assert.areEqual(0, salesCodeList.size(), 'Expected 0 Sales_Codes__c records for given country, region, and area but got ' + salesCodeList.size());
    }
}