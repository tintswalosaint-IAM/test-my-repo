/**
 * @description       : Test class for SEL_PartyProfileRisk
 * @author            : Tushar Walse
 * @last modified on  : 19-10-2024
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_PartyProfileRisk_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile partyProfile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        ICS_DAL_TestFactory.createPartyProfileRisk(partyProfile.Id);
    }

    /**
     * @description Test the getSObjectType method of SEL_PartyProfileRisk class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_PartyProfileRisk testPartyProfileRisk = new SEL_PartyProfileRisk();
        Test.startTest();
        Schema.SObjectType sObjectType = testPartyProfileRisk.getSObjectType();
        Test.stopTest();
        Assert.areEqual(PartyProfileRisk.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_PartyProfileRisk class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_PartyProfileRisk testPartyProfileRisk = new SEL_PartyProfileRisk();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = testPartyProfileRisk.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the selectById method of SEL_PartyProfileRisk class
     */
    @isTest
    static void testSelectById() {
        Id partyProfileRiskId = [select Id from PartyProfileRisk Limit 1].Id;

        SEL_PartyProfileRisk partyProfileRiskSelector = new SEL_PartyProfileRisk();
        Test.startTest();
        List<PartyProfileRisk> partyProfileRisk = partyProfileRiskSelector.selectById(partyProfileRiskId);
        Test.stopTest();
        Assert.areEqual(true, partyProfileRisk.size()>0, 'Expected 1 PartyProfileRisk record to be returned.');
    }

    /**
     * @description Test the selectByPartyProfileIds method of SEL_PartyProfileRisk class
     */
    @isTest
    static void testSelectByPartyProfileIds() {
        Set<Id> partyProfileIds = new Map<Id, PartyProfile>([select Id from PartyProfile Limit 1]).keySet();

        SEL_PartyProfileRisk partyProfileRiskSelector = new SEL_PartyProfileRisk();
        Test.startTest();
        List<PartyProfileRisk> partyProfileRisk = partyProfileRiskSelector.selectByPartyProfileIds(partyProfileIds);
        Test.stopTest();
        Assert.areEqual(true, partyProfileRisk.size()>0, 'Expected at least 1 PartyProfileRisk record to be returned.');
    }

}