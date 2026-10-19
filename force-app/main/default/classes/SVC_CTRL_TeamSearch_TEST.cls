/**
 * @description Test class for SVC_CTRL_TeamSearch and SVC_QueueTeamMappingSelector
 * @see SVC_CTRL_TeamSearch
 * @author Hlayisani Hlungwane
 * @date August 2026
 */
@IsTest(SeeAllData = false)
private class SVC_CTRL_TeamSearch_TEST {

    private static final String COUNTRY_CODE_ZA = 'ZA';
    private static final String TEAM_NAME_PREFIX = 'Insurance Team ';
    private static final Integer BULK_TEAM_COUNT = 15;

    @TestSetup
    static void setupTestData() {
        List<CMN_Team__c> teams = new List<CMN_Team__c>();

        // Create 15 teams to test pagination / MAX_RESULTS = 10 limit
        for (Integer i = 1; i <= BULK_TEAM_COUNT; i++) {
            teams.add(new CMN_Team__c(
                Name = TEAM_NAME_PREFIX + String.valueOf(i),
                CMN_Country__c = COUNTRY_CODE_ZA,
                CMN_Active__c = true
            ));
        }

        // Match existing Custom Metadata record if present in the org
        List<SVC_QueueTeamMapping__mdt> existingMetadata = [
            SELECT SVC_Team__c 
            FROM SVC_QueueTeamMapping__mdt 
            WHERE SVC_Team__c != null 
            LIMIT 1
        ];

        if (!existingMetadata.isEmpty()) {
            teams.add(new CMN_Team__c(
                Name = existingMetadata[0].SVC_Team__c,
                CMN_Country__c = COUNTRY_CODE_ZA,
                CMN_Active__c = true
            ));
        }

        insert teams;
    }

    /**
     * @description Tests blank search text returns initial maximum of 10 teams.
     */
    @IsTest
    static void testSearchTeamsBlankSearch() {
        Test.startTest();
        List<CMN_Team__c> results = SVC_CTRL_TeamSearch.searchTeams('', COUNTRY_CODE_ZA);
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(10, results.size(), 'Blank search should return maximum 10 teams.');
    }

    /**
     * @description Tests search functionality with search text.
     */
    @IsTest
    static void testSearchTeamsWithSearchText() {
        Test.startTest();
        List<CMN_Team__c> results = SVC_CTRL_TeamSearch.searchTeams('Insurance', COUNTRY_CODE_ZA);
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(10, results.size(), 'Search should return maximum 10 matching teams.');
    }

    /**
     * @description Tests search returning fewer than 10 results.
     */
    @IsTest
    static void testSearchTeamsLessThanMaximum() {
        Test.startTest();
        List<CMN_Team__c> results = SVC_CTRL_TeamSearch.searchTeams('Insurance Team 1', COUNTRY_CODE_ZA);
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.isTrue(results.size() > 0, 'At least one team should match.');
        Assert.isTrue(results.size() < 10, 'Result should contain fewer than 10 teams.');
    }

    /**
     * @description Tests search returning no results when search text does not match.
     */
    @IsTest
    static void testSearchTeamsNoMatch() {
        Test.startTest();
        List<CMN_Team__c> results = SVC_CTRL_TeamSearch.searchTeams('DoesNotExistXYZ', COUNTRY_CODE_ZA);
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(0, results.size(), 'No matching teams should return an empty list.');
    }

    /**
     * @description Tests null search text behaves as blank search.
     */
    @IsTest
    static void testSearchTeamsNullSearchText() {
        Test.startTest();
        List<CMN_Team__c> results = SVC_CTRL_TeamSearch.searchTeams(null, COUNTRY_CODE_ZA);
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(10, results.size(), 'Null search should return maximum 10 teams.');
    }

    /**
     * @description Tests null team Id returns null.
     */
    @IsTest
    static void testGetQueueNameNullTeamId() {
        Test.startTest();
        String queueName = SVC_CTRL_TeamSearch.getQueueName(null);
        Test.stopTest();

        Assert.isNull(queueName, 'Queue name should be null when Team Id is null.');
    }

    /**
     * @description Tests a team that exists but has no queue mapping.
     */
    @IsTest
    static void testGetQueueNameWithoutMapping() {
        CMN_Team__c team = [
            SELECT Id, Name 
            FROM CMN_Team__c 
            WHERE Name = 'Insurance Team 1' 
            LIMIT 1
        ];

        Test.startTest();
        String queueName = SVC_CTRL_TeamSearch.getQueueName(team.Id);
        Test.stopTest();

        Assert.isNull(queueName, 'Queue should be null when no mapping exists.');
    }

    /**
     * @description Tests queue mapping when Custom Metadata mapping exists.
     */
    @IsTest
    static void testGetQueueNameWithMapping() {
        List<SVC_QueueTeamMapping__mdt> mappings = [
            SELECT SVC_Team__c, SVC_Queue__c 
            FROM SVC_QueueTeamMapping__mdt 
            WHERE SVC_Team__c != null 
            LIMIT 1
        ];

        if (!mappings.isEmpty()) {
            CMN_Team__c team = [
                SELECT Id, Name 
                FROM CMN_Team__c 
                WHERE Name = :mappings[0].SVC_Team__c 
                LIMIT 1
            ];

            Test.startTest();
            String queueName = SVC_CTRL_TeamSearch.getQueueName(team.Id);
            Test.stopTest();

            Assert.areEqual(mappings[0].SVC_Queue__c, queueName, 'Queue name should match the Custom Metadata mapping.');
        } else {
            CMN_Team__c team = [SELECT Id FROM CMN_Team__c LIMIT 1];

            Test.startTest();
            String queueName = SVC_CTRL_TeamSearch.getQueueName(team.Id);
            Test.stopTest();

            Assert.isNull(queueName, 'Queue should be null when no metadata mapping exists.');
        }
    }

    /**
     * @description Tests selector SObject type.
     */
    @IsTest
    static void testSelectorGetSObjectType() {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(SVC_QueueTeamMapping__mdt.SObjectType, result, 'Selector should return the correct SObject type.');
    }

    /**
     * @description Tests selector field list.
     */
    @IsTest
    static void testSelectorGetSObjectFieldList() {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isNotNull(fields, 'Field list should not be null.');
        Assert.areEqual(3, fields.size(), 'Selector should return three fields.');
    }

    /**
     * @description Tests selector with blank team name.
     */
    @IsTest
    static void testSelectorBlankTeamName() {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<SVC_QueueTeamMapping__mdt> results = selector.getQueues('');
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(0, results.size(), 'Blank team name should return an empty list.');
    }

    /**
     * @description Tests selector with a non-existing team.
     */
    @IsTest
    static void testSelectorNoMapping() {
        SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();

        Test.startTest();
        List<SVC_QueueTeamMapping__mdt> results = selector.getQueues('TeamThatDoesNotExistXYZ');
        Test.stopTest();

        Assert.isNotNull(results, 'Results should not be null.');
        Assert.areEqual(0, results.size(), 'No mapping should return an empty list.');
    }

    /**
     * @description Tests searchTeams exception handling.
     */
    @IsTest
    static void testSearchTeamsException() {
        SVC_CTRL_TeamSearch.forceException = true;
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            SVC_CTRL_TeamSearch.searchTeams('Insurance', COUNTRY_CODE_ZA);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        SVC_CTRL_TeamSearch.forceException = false;
        Assert.isTrue(exceptionThrown, 'AuraHandledException should be thrown.');
    }

    /**
     * @description Tests getQueueName exception handling.
     */
    @IsTest
    static void testGetQueueNameException() {
        CMN_Team__c team = [SELECT Id FROM CMN_Team__c LIMIT 1];
        SVC_CTRL_TeamSearch.forceException = true;
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            SVC_CTRL_TeamSearch.getQueueName(team.Id);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        SVC_CTRL_TeamSearch.forceException = false;
        Assert.isTrue(exceptionThrown, 'AuraHandledException should be thrown.');
    }
}