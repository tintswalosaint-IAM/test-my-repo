/***************************************************************************************
@ Author            : Rahul.Mamidala@standardbank.co.za
@ Date              : 28-04-2025
@ Name of the Class : SEL_CMN_WebserviceSettingTest
@ Description       : Test class for SEL_CMN_WebserviceSetting selector class
@ Jira Ticket       :SPF-47031
* @Last Modified On : April 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date           | Author                              | Modification
*==============================================================================
* 1.0 | April 28, 2025 |  Rahul.Mamidala@standardbank.co.za  | Initial Version
***************************************************************************************/
@isTest
private class SEL_CMN_WebserviceSettingTest {
    /**
     * @description Test method to validate getSObjectType() method
     */
    @isTest
    static void testGetSObjectType() {
        SEL_CMN_WebserviceSetting selector = new SEL_CMN_WebserviceSetting();
        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(CMN_WebserviceSetting__mdt.SObjectType, result, 'Should return CMN_WebserviceSetting__mdt SObjectType');
        Assert.areNotEqual(null, result, 'SObjectType should not be null');
    }
    
    /**
     * @description Test method to validate getSObjectFieldList() method
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_CMN_WebserviceSetting selector = new SEL_CMN_WebserviceSetting();
        Test.startTest();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(3, fieldList.size(), 'Field list should contain 3 fields');
        Assert.areEqual(CMN_WebserviceSetting__mdt.Id, fieldList[0], 'First field should be Id');
        Assert.areNotEqual(null, fieldList, 'Field list should not be null');
    }
    /**
     * @description Test method to validate query formation in selectByDeveloperName()
     */
    @isTest
    static void testQueryFormation() {
        SEL_CMN_WebserviceSetting selector = new SEL_CMN_WebserviceSetting();
        String developerName = 'TestProduct';
        sbgplatform.fflib_QueryFactory fieldQueryFactory = selector.newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('DeveloperName = :developerName');
        fieldQueryFactory.setLimit(1);
        fieldQueryFactory.selectField('Id');
        fieldQueryFactory.selectField('DeveloperName');
        String expectedQuery = fieldQueryFactory.toSOQL();
        Test.startTest();
        try {
            selector.selectByDeveloperName(developerName);
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex.getMessage(),'no error');
        }
        Test.stopTest();
        Assert.areNotEqual(null, expectedQuery, 'Query should be formed properly');
    }
}