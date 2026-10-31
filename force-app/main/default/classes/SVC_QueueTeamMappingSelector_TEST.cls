/**
 * @description Test class for SVC_QueueTeam Mapping Selector
 * * @author Hlayisani Hlungwani
 * @date August 2026
 * @description       : Test methods for custom metadata selector SVC_QueueTeamMappingSelector
 * * 25- 09 -10      Hlayisani Hlungwani      SFP-55563 Insurance: Manual case creation 
 *                                                     should reflect status of new
 */
@IsTest(SeeAllData = false)
private class SVC_QueueTeamMappingSelector_TEST
{
    // Test constants
    private static final String RESULTS_NOT_NULL = 'Results should not be null.';
    private static final String EXPECTED_EMPTY = 'Result list should be empty.';
    private static final String NON_EXISTENT_TEAM = 'NonExistentTeamName_XYZ_123';
    private static final Integer EXPECTED_FIELD_COUNT = 3;

    @IsTest
    private static void testGetSObjectType()
    {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(
            SVC_QueueTeamMapping__mdt.SObjectType,
            sObjectType,
            'Selector should return SVC_QueueTeamMapping__mdt SObjectType.'
        );
    }

    @IsTest
    private static void testGetSObjectFieldList()
    {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isNotNull(fields, RESULTS_NOT_NULL);
        Assert.areEqual(EXPECTED_FIELD_COUNT, fields.size(), 'Selector should return exactly three fields.');
        Assert.isTrue(fields.contains(SVC_QueueTeamMapping__mdt.Label), 'Field list should include Label.');
        Assert.isTrue(fields.contains(SVC_QueueTeamMapping__mdt.SVC_Team__c), 'Field list should include SVC_Team__c.');
        Assert.isTrue(fields.contains(SVC_QueueTeamMapping__mdt.SVC_Queue__c), 'Field list should include SVC_Queue__c.');
    }

    @IsTest
    private static void testGetQueuesWithBlankTeamName()
    {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<SVC_QueueTeamMapping__mdt> nullResults = selector.getQueues(null);
        List<SVC_QueueTeamMapping__mdt> emptyResults = selector.getQueues('');
        List<SVC_QueueTeamMapping__mdt> whitespaceResults = selector.getQueues('   ');
        Test.stopTest();

        Assert.isNotNull(nullResults, RESULTS_NOT_NULL);
        Assert.areEqual(0, nullResults.size(), EXPECTED_EMPTY);

        Assert.isNotNull(emptyResults, RESULTS_NOT_NULL);
        Assert.areEqual(0, emptyResults.size(), EXPECTED_EMPTY);

        Assert.isNotNull(whitespaceResults, RESULTS_NOT_NULL);
        Assert.areEqual(0, whitespaceResults.size(), EXPECTED_EMPTY);
    }

    @IsTest
    private static void testGetQueuesWithNoMatchingTeam()
    {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<SVC_QueueTeamMapping__mdt> results = selector.getQueues(NON_EXISTENT_TEAM);
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.areEqual(0, results.size(), EXPECTED_EMPTY);
    }

    @IsTest
    private static void testGetQueuesWithExistingMetadata()
    {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        // SOQL loop handles orgs with metadata deterministically without IF/ELSE branching
        for (SVC_QueueTeamMapping__mdt existingMapping : [
            SELECT SVC_Team__c, SVC_Queue__c
            FROM SVC_QueueTeamMapping__mdt
            WHERE SVC_Team__c != null
            LIMIT 1
        ])
        {
            List<SVC_QueueTeamMapping__mdt> results = selector.getQueues(existingMapping.SVC_Team__c);

            Assert.isNotNull(results, RESULTS_NOT_NULL);
            Assert.isFalse(results.isEmpty(), 'Expected at least one mapping for existing team.');
            Assert.areEqual(existingMapping.SVC_Team__c, results[0].SVC_Team__c, 'Team name should match metadata record.');
        }
        Test.stopTest();
    }
}