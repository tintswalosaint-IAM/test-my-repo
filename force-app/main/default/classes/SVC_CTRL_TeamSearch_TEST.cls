/**
 * @description Tests the Team Search Controller class SVC_CTRL_TeamSearch, and the selectors it uses
 * @see SVC_CTRL_TeamSearch
 * @see SVC_SEL_Team
 * @see SVC_QueueTeamMappingSelector
 * @author Hlayisani Hlungwani
 * @date August 2026
 * @User Story SFP-55563 Insurance: Manual case creation should reflect status of new
 */
@IsTest(SeeAllData = false)
private class SVC_CTRL_TeamSearch_TEST
{
	// Test constants
	private static final String COUNTRY_CODE_ZA = 'ZA';
	private static final String UNUSED_COUNTRY_CODE = 'XX'; // Only passed as a plain string, never inserted
	private static final String TEAM_NAME_PREFIX = 'Insurance Team ';
	private static final String INACTIVE_TEAM_NAME = 'Dormant Claims Team';
	private static final String SEARCH_TEXT = 'Insurance';
	private static final String NON_EXISTENT_SEARCH_TEXT = 'DoesNotExistXYZ';
	private static final Integer BULK_TEAM_COUNT = 15;
	private static final Integer MAX_RESULTS = 10;

	// Test assertion messages
	private static final String RESULTS_NOT_NULL = 'Results should not be null';
	private static final String RESULTS_MAXIMUM = 'Search should return a maximum of 10 teams';
	private static final String RESULTS_EMPTY = 'Results should be empty';
	private static final String QUEUE_NAME_NULL = 'Queue name should be null when no mapping exists';
	private static final String QUEUE_NAME_MATCH = 'Queue name should match custom metadata mapping';
	private static final String AURA_EXCEPTION_NOT_CAUGHT = 'AuraHandledException was not caught';
	private static final String SHOULD_HAVE_EXCEPTION_MESSAGE = 'Should have exception message';

	private static Integer userCounter = 0;

	/**
	 * @description Creates active teams, an inactive team and a team matching a deployed queue mapping (if any)
	 */
	@TestSetup
	public static void setupScenario()
	{
		SVC_CTRL_TeamSearch.mockForceException = false;

		List<CMN_Team__c> teams = new List<CMN_Team__c>();
		Set<String> teamNames = new Set<String>();

		for(Integer index = 1; index <= BULK_TEAM_COUNT; index++)
		{
			String teamName = TEAM_NAME_PREFIX + index;

			teams.add(new CMN_Team__c(
				Name = teamName,
				CMN_Country__c = COUNTRY_CODE_ZA,
				CMN_Active__c = true
			));
			teamNames.add(teamName.toLowerCase());
		}

		teams.add(new CMN_Team__c(
			Name = INACTIVE_TEAM_NAME,
			CMN_Country__c = COUNTRY_CODE_ZA,
			CMN_Active__c = false
		));

		SVC_QueueTeamMapping__mdt mapping = getFirstMapping();

		if(mapping != null && String.isNotBlank(mapping.SVC_Team__c) && !teamNames.contains(mapping.SVC_Team__c.toLowerCase()))
		{
			teams.add(new CMN_Team__c(
				Name = mapping.SVC_Team__c,
				CMN_Country__c = COUNTRY_CODE_ZA,
				CMN_Active__c = true
			));
		}

		insert teams;
	}

	/**
	 * @description Creates and inserts a user with the given country. Called inside each test method (not in
	 *              @TestSetup) so the User insert never shares a transaction with the CMN_Team__c inserts
	 * @param country The value for User_Country__c, may be null
	 * @return User The inserted user
	 */
	private static User insertUser(String country)
	{
		userCounter++;
		String unique = String.valueOf(Math.abs(Crypto.getRandomInteger())) + userCounter;
		Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		User newUser = new User(
			ProfileId = adminProfile.Id,
			Username = 'teamsearch.' + unique + '@test.example.com',
			Email = 'teamsearch.' + unique + '@test.example.com',
			LastName = 'TeamSearch',
			Alias = 'ts' + String.valueOf(userCounter),
			TimeZoneSidKey = 'Africa/Johannesburg',
			LocaleSidKey = 'en_ZA',
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			User_Country__c = country
		);

		insert newUser;
		return newUser;
	}

	/**
	 * @description Returns the first Queue Team Mapping that has a team, or null if none is deployed
	 * @return SVC_QueueTeamMapping__mdt The mapping, or null
	 */
	private static SVC_QueueTeamMapping__mdt getFirstMapping()
	{
		List<SVC_QueueTeamMapping__mdt> mappings = [
			SELECT SVC_Team__c, SVC_Queue__c
			FROM SVC_QueueTeamMapping__mdt
			WHERE SVC_Team__c != NULL
			LIMIT 1
		];

		return mappings.isEmpty() ? null : mappings.iterator().next();
	}

	/**
	 * @description Runs searchTeams as a user with the given country
	 * @param country The user's country
	 * @param searchText The search text passed to the controller
	 * @return List<CMN_Team__c> The controller result
	 */
	private static List<CMN_Team__c> searchAsUser(String country, String searchText)
	{
		User countryUser = insertUser(country);
		List<CMN_Team__c> results;

		System.runAs(countryUser)
		{
			Test.startTest();
			results = SVC_CTRL_TeamSearch.searchTeams(searchText);
			Test.stopTest();
		}

		return results;
	}

	/**
	 * @description Tests that a blank search returns the maximum number of active teams for the user's country
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsBlankSearch()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, '');

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.areEqual(MAX_RESULTS, results.size(), RESULTS_MAXIMUM);
	}

	/**
	 * @description Tests that a null search returns the maximum number of active teams for the user's country
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsNullSearchText()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, null);

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.areEqual(MAX_RESULTS, results.size(), RESULTS_MAXIMUM);
	}

	/**
	 * @description Tests searching by partial team name
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsWithSearchText()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, SEARCH_TEXT);

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.areEqual(MAX_RESULTS, results.size(), RESULTS_MAXIMUM);
	}

	/**
	 * @description Tests a search that matches fewer teams than the maximum
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsLessThanMaximum()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, TEAM_NAME_PREFIX + '1');

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isFalse(results.isEmpty(), 'At least one team should match');
		Assert.isTrue(results.size() < MAX_RESULTS, 'Result should contain fewer than 10 teams');
	}

	/**
	 * @description Tests a search using the full name of one team
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsExactName()
	{
		String expectedName = TEAM_NAME_PREFIX + BULK_TEAM_COUNT;

		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, expectedName);

		Assert.areEqual(1, results.size(), 'Exactly one team should match the full name');
		Assert.areEqual(expectedName, results.iterator().next().Name, 'Returned team should be the one searched for');
	}

	/**
	 * @description Tests a search that matches no teams
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsNoMatch()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, NON_EXISTENT_SEARCH_TEXT);

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isTrue(results.isEmpty(), RESULTS_EMPTY);
	}

	/**
	 * @description Tests that a user whose country has no active teams gets no results
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsNoActiveTeamsForCountry()
	{
		User countryUser = insertUser(COUNTRY_CODE_ZA);
		List<CMN_Team__c> results;

		// DML on the teams happens inside runAs so it does not share a context with the User insert
		System.runAs(countryUser)
		{
			List<CMN_Team__c> teams = [SELECT Id, CMN_Active__c FROM CMN_Team__c];
			for(CMN_Team__c team : teams)
			{
				team.CMN_Active__c = false;
			}
			update teams;

			Test.startTest();
			results = SVC_CTRL_TeamSearch.searchTeams(SEARCH_TEXT);
			Test.stopTest();
		}

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isTrue(results.isEmpty(), 'No teams should be returned when none are active for the country');
	}

	/**
	 * @description Tests that a user without a country gets no teams
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsBlankUserCountry()
	{
		List<CMN_Team__c> results = searchAsUser(null, SEARCH_TEXT);

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isTrue(results.isEmpty(), 'User without a country should get no teams');
	}

	/**
	 * @description Tests that inactive teams are excluded
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 */
	@IsTest
	private static void testSearchTeamsExcludesInactive()
	{
		List<CMN_Team__c> results = searchAsUser(COUNTRY_CODE_ZA, INACTIVE_TEAM_NAME);

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isTrue(results.isEmpty(), 'Inactive teams should not be returned');
	}

	/**
	 * @description Tests exception handling in searchTeams when mockForceException is set
	 * @see SVC_CTRL_TeamSearch.searchTeams
	 * @see SVC_CTRL_TeamSearch.mockForceException
	 */
	@IsTest
	private static void testSearchTeamsException()
	{
		SVC_CTRL_TeamSearch.mockForceException = true;
		Integer caughtException = 0;
		String exceptionMessage;

		Test.startTest();
		try{
			SVC_CTRL_TeamSearch.searchTeams(SEARCH_TEXT);
		} catch(AuraHandledException e){
			caughtException++;
			exceptionMessage = e.getMessage();
		}
		Test.stopTest();
		SVC_CTRL_TeamSearch.mockForceException = false; // Reset after test

		Assert.isTrue(caughtException > 0, AURA_EXCEPTION_NOT_CAUGHT);
		Assert.isNotNull(exceptionMessage, SHOULD_HAVE_EXCEPTION_MESSAGE);
	}

	/**
	 * @description Tests that a null team ID returns null
	 * @see SVC_CTRL_TeamSearch.getQueueName
	 */
	@IsTest
	private static void testGetQueueNameNullTeamId()
	{
		Test.startTest();
		String queueName = SVC_CTRL_TeamSearch.getQueueName(null);
		Test.stopTest();

		Assert.isNull(queueName, 'Queue name should be null when Team ID is null');
	}

	/**
	 * @description Tests that a team with no queue mapping returns null
	 * @see SVC_CTRL_TeamSearch.getQueueName
	 */
	@IsTest
	private static void testGetQueueNameWithoutMapping()
	{
		String teamName = TEAM_NAME_PREFIX + '1';
		CMN_Team__c team = [SELECT Id FROM CMN_Team__c WHERE Name = :teamName LIMIT 1];

		Test.startTest();
		String queueName = SVC_CTRL_TeamSearch.getQueueName(team.Id);
		Test.stopTest();

		Assert.isNull(queueName, QUEUE_NAME_NULL);
	}

	/**
	 * @description Tests that a deleted team returns null
	 * @see SVC_CTRL_TeamSearch.getQueueName
	 */
	@IsTest
	private static void testGetQueueNameTeamNotFound()
	{
		CMN_Team__c team = new CMN_Team__c(
			Name = 'Team To Delete',
			CMN_Country__c = COUNTRY_CODE_ZA,
			CMN_Active__c = true
		);
		insert team;
		Id deletedTeamId = team.Id;
		delete team;

		Test.startTest();
		String queueName = SVC_CTRL_TeamSearch.getQueueName(deletedTeamId);
		Test.stopTest();

		Assert.isNull(queueName, 'Queue name should be null when the team no longer exists');
	}

	/**
	 * @description Tests that a team with a deployed queue mapping returns the mapped queue
	 * @see SVC_CTRL_TeamSearch.getQueueName
	 */
	@IsTest
	private static void testGetQueueNameWithMapping()
	{
		SVC_QueueTeamMapping__mdt mapping = getFirstMapping();

		if(mapping == null)
		{
			// Custom metadata cannot be inserted in tests, so nothing to assert when none is deployed
			return;
		}

		String mappedTeamName = mapping.SVC_Team__c;
		List<CMN_Team__c> teams = [SELECT Id FROM CMN_Team__c WHERE Name = :mappedTeamName LIMIT 1];
		Assert.isFalse(teams.isEmpty(), 'A team matching the metadata mapping must exist');

		Test.startTest();
		String queueName = SVC_CTRL_TeamSearch.getQueueName(teams.iterator().next().Id);
		Test.stopTest();

		Assert.areEqual(mapping.SVC_Queue__c, queueName, QUEUE_NAME_MATCH);
	}

	/**
	 * @description Tests exception handling in getQueueName when mockForceException is set
	 * @see SVC_CTRL_TeamSearch.getQueueName
	 * @see SVC_CTRL_TeamSearch.mockForceException
	 */
	@IsTest
	private static void testGetQueueNameException()
	{
		CMN_Team__c team = [SELECT Id FROM CMN_Team__c LIMIT 1];
		SVC_CTRL_TeamSearch.mockForceException = true;
		Integer caughtException = 0;
		String exceptionMessage;

		Test.startTest();
		try{
			SVC_CTRL_TeamSearch.getQueueName(team.Id);
		} catch(AuraHandledException e){
			caughtException++;
			exceptionMessage = e.getMessage();
		}
		Test.stopTest();
		SVC_CTRL_TeamSearch.mockForceException = false; // Reset after test

		Assert.isTrue(caughtException > 0, AURA_EXCEPTION_NOT_CAUGHT);
		Assert.isNotNull(exceptionMessage, SHOULD_HAVE_EXCEPTION_MESSAGE);
	}

	/**
	 * @description Tests SVC_SEL_Team.selectById returns the requested teams
	 * @see SVC_SEL_Team.selectById
	 */
	@IsTest
	private static void testSelectorSelectById()
	{
		String namePattern = TEAM_NAME_PREFIX + '%';
		Map<Id, CMN_Team__c> teamsById = new Map<Id, CMN_Team__c>([
			SELECT Id, Name
			FROM CMN_Team__c
			WHERE Name LIKE :namePattern
			LIMIT 3
		]);

		Test.startTest();
		List<CMN_Team__c> results = SVC_SEL_Team.newInstance().selectById(teamsById.keySet());
		Test.stopTest();

		Assert.areEqual(teamsById.size(), results.size(), 'All requested teams should be returned');

		for(CMN_Team__c team : results)
		{
			Assert.isTrue(teamsById.containsKey(team.Id), 'Only requested teams should be returned');
			Assert.areEqual(teamsById.get(team.Id).Name, team.Name, 'Team Name should be selected');
		}
	}

	/**
	 * @description Tests SVC_SEL_Team.selectById with empty and null sets
	 * @see SVC_SEL_Team.selectById
	 */
	@IsTest
	private static void testSelectorSelectByIdEmptyAndNull()
	{
		Test.startTest();
		List<CMN_Team__c> emptyResults = SVC_SEL_Team.newInstance().selectById(new Set<Id>());
		List<CMN_Team__c> nullResults = SVC_SEL_Team.newInstance().selectById(null);
		Test.stopTest();

		Assert.isNotNull(emptyResults, RESULTS_NOT_NULL);
		Assert.isTrue(emptyResults.isEmpty(), RESULTS_EMPTY);
		Assert.isNotNull(nullResults, RESULTS_NOT_NULL);
		Assert.isTrue(nullResults.isEmpty(), RESULTS_EMPTY);
	}

	/**
	 * @description Tests SVC_SEL_Team.selectByCountry with a blank or null country
	 * @see SVC_SEL_Team.selectByCountry
	 */
	@IsTest
	private static void testSelectorSelectByCountryBlankCountry()
	{
		Test.startTest();
		List<CMN_Team__c> blankResults = SVC_SEL_Team.newInstance().selectByCountry('', SEARCH_TEXT);
		List<CMN_Team__c> nullResults = SVC_SEL_Team.newInstance().selectByCountry(null, SEARCH_TEXT);
		Test.stopTest();

		Assert.isTrue(blankResults.isEmpty(), 'Blank country should return no teams');
		Assert.isTrue(nullResults.isEmpty(), 'Null country should return no teams');
	}

	/**
	 * @description Tests SVC_SEL_Team.selectByCountry for a country with teams and one without
	 * @see SVC_SEL_Team.selectByCountry
	 */
	@IsTest
	private static void testSelectorSelectByCountry()
	{
		Test.startTest();
		List<CMN_Team__c> zaResults = SVC_SEL_Team.newInstance().selectByCountry(COUNTRY_CODE_ZA, SEARCH_TEXT);
		List<CMN_Team__c> otherResults = SVC_SEL_Team.newInstance().selectByCountry(UNUSED_COUNTRY_CODE, SEARCH_TEXT);
		Test.stopTest();

		Assert.areEqual(MAX_RESULTS, zaResults.size(), RESULTS_MAXIMUM);
		Assert.isTrue(otherResults.isEmpty(), 'Teams from another country should not be returned');
	}

	/**
	 * @description Tests the selector metadata methods
	 * @see SVC_SEL_Team.getSObjectType
	 * @see SVC_SEL_Team.getSObjectFieldList
	 */
	@IsTest
	private static void testSelectorMetadata()
	{
		Test.startTest();
		SVC_SEL_Team selector = SVC_SEL_Team.newInstance();
		Test.stopTest();

		Assert.areEqual(CMN_Team__c.SObjectType, selector.getSObjectType(), 'Selector should be for CMN_Team__c');
		Assert.isFalse(selector.getSObjectFieldList().isEmpty(), 'Selector should define fields');
	}

	/**
	 * @description Tests SVC_QueueTeamMappingSelector.getQueues with a team that has no mapping
	 * @see SVC_QueueTeamMappingSelector.getQueues
	 */
	@IsTest
	private static void testQueueMappingSelectorNoMatch()
	{
		Test.startTest();
		List<SVC_QueueTeamMapping__mdt> results = SVC_QueueTeamMappingSelector.newInstance().getQueues(NON_EXISTENT_SEARCH_TEXT);
		Test.stopTest();

		Assert.isNotNull(results, RESULTS_NOT_NULL);
		Assert.isTrue(results.isEmpty(), RESULTS_EMPTY);
	}

	/**
	 * @description Tests SVC_QueueTeamMappingSelector.getQueues with a blank or null team name
	 * @see SVC_QueueTeamMappingSelector.getQueues
	 */
	@IsTest
	private static void testQueueMappingSelectorBlankTeamName()
	{
		Test.startTest();
		List<SVC_QueueTeamMapping__mdt> blankResults = SVC_QueueTeamMappingSelector.newInstance().getQueues('');
		List<SVC_QueueTeamMapping__mdt> nullResults = SVC_QueueTeamMappingSelector.newInstance().getQueues(null);
		Test.stopTest();

		Assert.isTrue(blankResults.isEmpty(), 'Blank team name should return no mappings');
		Assert.isTrue(nullResults.isEmpty(), 'Null team name should return no mappings');
	}

	/**
	 * @description Tests SVC_QueueTeamMappingSelector.getQueues with a deployed mapping
	 * @see SVC_QueueTeamMappingSelector.getQueues
	 */
	@IsTest
	private static void testQueueMappingSelectorWithMatch()
	{
		SVC_QueueTeamMapping__mdt mapping = getFirstMapping();

		if(mapping == null)
		{
			return;
		}

		Test.startTest();
		List<SVC_QueueTeamMapping__mdt> results = SVC_QueueTeamMappingSelector.newInstance().getQueues(mapping.SVC_Team__c);
		Test.stopTest();

		Assert.isFalse(results.isEmpty(), 'Mapping should be returned for a configured team');
		Assert.areEqual(mapping.SVC_Queue__c, results.iterator().next().SVC_Queue__c, QUEUE_NAME_MATCH);
	}

	/**
	 * @description Tests the selector metadata methods of SVC_QueueTeamMappingSelector
	 * @see SVC_QueueTeamMappingSelector.getSObjectType
	 */
	@IsTest
	private static void testQueueMappingSelectorMetadata()
	{
		Test.startTest();
		SVC_QueueTeamMappingSelector selector = SVC_QueueTeamMappingSelector.newInstance();
		Test.stopTest();

		Assert.areEqual(SVC_QueueTeamMapping__mdt.SObjectType, selector.getSObjectType(), 'Selector should be for the mapping metadata');
		Assert.isFalse(selector.getSObjectFieldList().isEmpty(), 'Selector should define fields');
	}
}