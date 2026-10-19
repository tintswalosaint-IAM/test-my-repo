/**
 * @description Class has base methods that can be used to test and DAL class of Base Object
 *
 * @author Accenture
 *
 * @date May 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_TeamMember_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;
	private static final Boolean ACTIVE = true;

	/**
	 * @description Common method to generate random Team Member type
	 *
	 * @return
	 */
	private static String generateRandomType()
	{
		List<String> pickvals = CMN_UTIL_System.getPicklistValues(CMN_DAL_TeamMember.OBJECT_NAME, CMN_DAL_TeamMember.FIELD_TYPE);
		Integer maxNum = CMN_DAL_SObjectDomain.generateRandomInteger(0, (pickvals.size() - 1));
		return pickvals[maxNum];
	}

	/**
	 * @description To test if team members are available
	 */
	@IsTest
	private static void hasTeamMembers()
	{
		Test.startTest();

		String type = generateRandomType();

		CMN_Team__c team = SVC_DAL_DataFactory.createNewTeam(ACTIVE);
		insert team;

		List<CMN_TeamMember__c> teamMembers = SVC_DAL_DataFactory.generateTeamMembers(type, team.Id, NUMBER_OF_ITEMS_TO_GENERATE);

		List<CMN_TeamMember__c> foundTeamMembers = CMN_DAL_TeamMember.getAll();

		Test.stopTest();

		// Total team members should match
		System.assertEquals(NUMBER_OF_ITEMS_TO_GENERATE, foundTeamMembers.size(), 'Total team members did not match');

		// Members should have the same Team
		System.assertEquals(teamMembers.iterator().next()?.CMN_Team__c, foundTeamMembers.iterator().next()?.CMN_Team__c, 'Members have different Team');

		// Member should have the exact Type
		System.assertEquals(type, foundTeamMembers.iterator().next()?.CMN_Type__c, 'Team member\'s type did not match');
	}

	/**
	 * @description To test if team members are available according to Type
	 */
	@IsTest
	private static void hasTeamMembersByType() 
	{
		Test.startTest();

		String type = generateRandomType();

		CMN_Team__c team = SVC_DAL_DataFactory.createNewTeam(ACTIVE);
		insert team;

		SVC_DAL_DataFactory.generateTeamMembers(type, team.Id, NUMBER_OF_ITEMS_TO_GENERATE);

		List<CMN_TeamMember__c> foundTeamMembers = CMN_DAL_TeamMember.findByType(type);

		Test.stopTest();

		// Total team members should match
		System.assertEquals(NUMBER_OF_ITEMS_TO_GENERATE, foundTeamMembers.size(), 'Total team members did not match');
	}
	
}