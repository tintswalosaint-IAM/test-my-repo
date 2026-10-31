/**
 * @description Test class for SVC_CTRL_TeamSearch and SVC_QueueTeamMappingSelector
 * @see SVC_CTRL_TeamSearch
 * @author Hlayisani Hlungwane
 *@created Date 25 August 2026
 * 25- 09 -10      Hlayisani Hlungwani      SFP-55563 Insurance: Manual case creation 
 *                                                     should reflect status of new
 * @date August 2026
 */

@isTest (seeAllData=false isParallel=true)
private class SVC_SEL_Team_TEST {

    private static final String COUNTRY_CODE_ZA = 'ZA';
    private static final String RESULTS_NOT_NULL = 'results should not be null';

    @TestSetup
    static void setupTestData() {
        List<CMN_Team__c> teams = new List<CMN_Team__c>();
        for (Integer i = 1; i <= 15; i++) {
            teams.add(new CMN_Team__c(
                Name = 'Insurance Team ' + i,
                CMN_Country__c = COUNTRY_CODE_ZA,
                CMN_Active__c = true
            ));
        }
        insert teams;
    }

    @IsTest
    static void testGetSObjectType() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(CMN_Team__c.SObjectType, sObjectType, 'Expected CMN_Team__c SObjectType');
    }

    @IsTest
    static void testGetSObjectFieldList() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isNotNull(fields, 'Field list must not be null');
        Assert.isTrue(fields.contains(CMN_Team__c.Name), 'Field list should contain Name');
    }

    @IsTest
    static void testSelectByCountryBlankSearch() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<CMN_Team__c> results = selector.selectByCountry(COUNTRY_CODE_ZA, '');
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.areEqual(10, results.size(), 'Should return capped 10 teams');
    }

    @IsTest
    static void testSelectByCountryWithSearchKeyword() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<CMN_Team__c> results = selector.selectByCountry(COUNTRY_CODE_ZA, 'Insurance Team 1');
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.isFalse(results.isEmpty(), 'At least one team should match');
        Assert.isTrue(results.size() < 10, 'Expected fewer than 10 records');
    }

    @IsTest
    static void testSelectByCountryBlankCountry() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<CMN_Team__c> results = selector.selectByCountry('', 'Insurance');
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.areEqual(0, results.size(), 'Blank country should return empty list');
    }

    @IsTest
    static void testSelectById() {
        CMN_Team__c testTeam = [SELECT Id FROM CMN_Team__c LIMIT 1];
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<CMN_Team__c> results = selector.selectById(new Set<Id>{ testTeam.Id });
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.areEqual(1, results.size(), 'Should return exactly 1 team');
    }

    @IsTest
    static void testSelectByIdEmptySet() {
        SVC_SEL_Team selector = SVC_SEL_Team.newInstance();

        Test.startTest();
        List<CMN_Team__c> results = selector.selectById(new Set<Id>());
        Test.stopTest();

        Assert.isNotNull(results, RESULTS_NOT_NULL);
        Assert.areEqual(0, results.size(), 'Empty set should return empty list');
    }
}