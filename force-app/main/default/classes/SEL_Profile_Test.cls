/**
 * @description       : Test class for SEL_Profile selector class
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * created date       : 17/09/2025
 * @group             : Cloudsmiths
**/
@isTest
private class SEL_Profile_Test {

    @isTest
    static void testGetSObjectTypeAndFields() {
        SEL_Profile sel = new SEL_Profile();
        // Verify SObjectType
        assert.areEqual(Profile.SObjectType, sel.getSObjectType());
        // Verify fields list contains Id and Name
        List<Schema.SObjectField> fieldList = sel.getSObjectFieldList();
        Assert.areEqual(2, fieldList.size(), 'Field list should contain 2 fields');
        Assert.areNotEqual(null, fieldList, 'Field list should not be null');
    }
    @isTest
    static void testSelectByName() {
        Profile p = [SELECT Id, Name FROM Profile where Name = 'Partner Community User' LIMIT 1];
        //call selector
        SEL_Profile sel = new SEL_Profile();
        List<Profile> result = sel.selectByName(p.Name);

        // Assert: we should get at least one record back
        Assert.areNotEqual(0, result.size(), 'Should return at least one profile');
        Assert.areEqual(p.Name, result[0].Name, 'Returned profile name should match');
    } 
}