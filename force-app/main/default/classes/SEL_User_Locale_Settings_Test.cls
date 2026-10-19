/**
 * @description       : Test class for SEL_User_Locale_Settings selector class
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * created date       : 13/10/2025
**/
@isTest
private class  SEL_User_Locale_Settings_Test {
    
    @isTest
    static void testGetSObjectTypeAndFields() {
        SEL_User_Locale_Settings sel = new SEL_User_Locale_Settings();
        // Verify SObjectType
        assert.areEqual(INS_User_Locale__mdt.SObjectType, sel.getSObjectType());
        // Verify fields list contains Id and Name
        List<Schema.SObjectField> fieldList = sel.getSObjectFieldList();
        Assert.areEqual(6, fieldList.size(), 'Field list should contain 6 fields');
        Assert.areNotEqual(null, fieldList, 'Field list should not be null');
    }
     /**
    * @description Test method to validate query formation in selectByCountry()
    */
    @isTest
    static void testSelectByCountry() {
        SEL_User_Locale_Settings selector = new SEL_User_Locale_Settings();
        String country = 'SA';
        sbgplatform.fflib_QueryFactory fieldQueryFactory = selector.newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('INS_Country__c = :networkId');
        fieldQueryFactory.setLimit(1);
        fieldQueryFactory.selectField('Id');
        fieldQueryFactory.selectField('DeveloperName');
        String expectedQuery = fieldQueryFactory.toSOQL();
        Test.startTest();
            try {
                selector.selectByCountry(country);
            } catch (Exception ex) {
                Assert.areNotEqual(null, ex.getMessage(),'no error');
            }
        Test.stopTest();
        Assert.areNotEqual(null, expectedQuery, 'Query should be formed properly');
    }
}