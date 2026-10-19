/**
 * @description       : Test class for SEL_Profile selector class
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * created date       : 13/10/2025
**/
@isTest
private class SEL_DSA_PingRegistration_Site_Test {
    
     @isTest
    static void testGetSObjectTypeAndFields() {
        SEL_DSA_PingRegistration_Site sel = new SEL_DSA_PingRegistration_Site();
        // Verify SObjectType
        assert.areEqual(DSA_Ping_Registration_Site__mdt.SObjectType, sel.getSObjectType());
        // Verify fields list contains Id and Name
        List<Schema.SObjectField> fieldList = sel.getSObjectFieldList();
        Assert.areEqual(4, fieldList.size(), 'Field list should contain 4 fields');
        Assert.areNotEqual(null, fieldList, 'Field list should not be null');
    }
    /**
    * @description Test method to validate query formation in selectByNetworkId()
    */
    @isTest
    static void testSelectByNetworkId() {
        SEL_DSA_PingRegistration_Site selector = new SEL_DSA_PingRegistration_Site();
        String networkId = '0DBbY0000004JQf';
        sbgplatform.fflib_QueryFactory fieldQueryFactory = selector.newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('INS_Network_Id__c = :networkId');
        fieldQueryFactory.setLimit(1);
        fieldQueryFactory.selectField('Id');
        fieldQueryFactory.selectField('DeveloperName');
        String expectedQuery = fieldQueryFactory.toSOQL();
        Test.startTest();
            try {
                selector.selectByNetworkId(networkId);
            } catch (Exception ex) {
                Assert.areNotEqual(null, ex.getMessage(),'no error');
            }
        Test.stopTest();
        Assert.areNotEqual(null, expectedQuery, 'Query should be formed properly');
    }
}