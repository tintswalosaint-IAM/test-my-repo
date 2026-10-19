/**
 * @description       : Test class for SEL_OrgWideEmailAddress
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 24-03-2026
 **/
@isTest
private class SEL_OrgWideEmailAddress_Test {
    /**
     * @description Test that getSObjectType returns the correct SObjectType
     */
    @isTest
    static void testGetSObjectType() {
        SEL_OrgWideEmailAddress selector = new SEL_OrgWideEmailAddress();

        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(OrgWideEmailAddress.SObjectType,result, 'getSObjectType should return OrgWideEmailAddress.SObjectType');
    }
    /**
     * @description Test that getSObjectFieldList returns the expected fields
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_OrgWideEmailAddress selector = new SEL_OrgWideEmailAddress();

        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        Assert.isNotNull(fields, 'Field list should not be null');
        Assert.areEqual(3, fields.size(), 'Field list should contain 3 fields');
        Assert.isTrue(fields.contains(OrgWideEmailAddress.Id), 'Field list should contain Id');
        Assert.isTrue(fields.contains(OrgWideEmailAddress.DisplayName), 'Field list should contain DisplayName');
        Assert.isTrue(fields.contains(OrgWideEmailAddress.Address), 'Field list should contain Address');
    }
    /**
     * @description Test selectOneByAddress returns a result when a matching OrgWideEmailAddress exists
     */
    @isTest
    static void testSelectOneByAddressReturnsRecord() {
        // OrgWideEmailAddress cannot be inserted via DML in tests.        
        List<OrgWideEmailAddress> existing = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress LIMIT 1];

        SEL_OrgWideEmailAddress selector = new SEL_OrgWideEmailAddress();

        Test.startTest();
        if (!existing.isEmpty()) {
            String targetAddress = existing[0].Address;
            OrgWideEmailAddress result = selector.selectOneByAddress(targetAddress);

            Assert.isNotNull(result, 'Expected a result for a known address');
            Assert.areEqual(targetAddress,result.Address,'Returned record address should match the queried address');
        } else {            
            OrgWideEmailAddress result = selector.selectOneByAddress('nonexistent@example.com');
            Assert.isNull(result, 'Should return null when no matching record exists');
        }
        Test.stopTest();
    }
    /**
     * @description Test selectOneByAddress returns null when no matching address exists
     */
    @isTest
    static void testSelectOneByAddressReturnsNullForNoMatch() {
        SEL_OrgWideEmailAddress selector = new SEL_OrgWideEmailAddress();

        Test.startTest();
        OrgWideEmailAddress result = selector.selectOneByAddress('definitelynotvalid_xyz@notreal.com');
        Test.stopTest();
        Assert.isNull(result, 'Should return null when no OrgWideEmailAddress matches the given address');
    }
    /**
     * @description Test selectOneByAddress handles null input gracefully
     */
    @isTest
    static void testSelectOneByAddressWithNullInput() {
        SEL_OrgWideEmailAddress selector = new SEL_OrgWideEmailAddress();

        Test.startTest();
        OrgWideEmailAddress result = selector.selectOneByAddress(null);
        Test.stopTest();

        Assert.isNull(result, 'Should return null when null is passed as the address');
    }
}