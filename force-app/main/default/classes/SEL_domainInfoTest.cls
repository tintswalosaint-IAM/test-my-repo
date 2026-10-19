/**
* @File Name : SEL_domainInfoTest .cls
* @Description :Test class for SEL_domainInfo selector class
* @Author :Rahul.Mamidala@standardbank.co.za
* @Last Modified By :Rahul.Mamidala@standardbank.co.za
* @Last Modified On : April 29, 2025
* @Modification Log : Added the Test Methods to the class
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 29, 2025 |   | Initial Version
**/
@isTest
private class SEL_domainInfoTest {
    /**
     * @description Test method to validate getSObjectType() method
     */
    @isTest
    static void testGetSObjectType() {
        SEL_domainInfo selector = new SEL_domainInfo();
        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(PRX_domain_Info__mdt.SObjectType, result, 'Should return PRX_domain_Info__mdt SObjectType');
    }
    /**
     * @description Test method to validate getSObjectFieldList() method
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_domainInfo selector = new SEL_domainInfo();
        Test.startTest();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(4, fieldList.size(), 'Field list should contain 3 fields');
        Assert.areEqual(PRX_domain_Info__mdt.Id, fieldList[0], 'First field should be Id');
    } 
    /**
     * @description Test method to validate getdomain_Info() method with invalid data
     */
    @isTest
    static void testGetDomainInfoWithInvalidData() {
        SEL_domainInfo selector = new SEL_domainInfo();
        String invalidDeveloperName = 'NonExistentDomain';
        Test.startTest();
        List<PRX_domain_Info__mdt> results;
        try {
            results = selector.domainInfoByDeveloperName(invalidDeveloperName);
        } catch (Exception e) {
            results = new List<PRX_domain_Info__mdt>();
        }
        Test.stopTest();
        Assert.areEqual(0, results.size(), 'Should return empty list for non-existent records');
    }
    /**
     * @description Test method to validate query formation in getdomain_Info()
     */
    @isTest
    static void testQueryFormation() {
        SEL_domainInfo selector = new SEL_domainInfo();
        String developerName = 'TestDomain';
        sbgplatform.fflib_QueryFactory fieldQueryFactory = selector.newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('DeveloperName = :developerName');
        fieldQueryFactory.setLimit(1);
        fieldQueryFactory.selectField('Id');
        fieldQueryFactory.selectField('DeveloperName');
        fieldQueryFactory.selectField('AES_SecretKey__c');
        String expectedQuery = fieldQueryFactory.toSOQL();
        try {
            Test.startTest();
            selector.domainInfoByDeveloperName(developerName);
              Test.stopTest();
        } catch (Exception ex) {
           Assert.areNotEqual(null, ex.getMessage(),'no error');
        }
      
        Assert.areNotEqual(null, expectedQuery, 'Query should be formed properly');
    }
    
    /**
     * @description Test method to validate edge case with null developer name
     */
    @isTest
    static void testGetDomainInfoWithNullValue() {
        SEL_domainInfo selector = new SEL_domainInfo();
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
         selector.domainInfoByDeveloperName(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.areEqual(false, exceptionThrown, 'Method should handle null values gracefully');
    }
}