/**
 * @description Tests the SVC_CTRL_UnresolvedReason class
 *
 * @see SVC_CTRL_UnresolvedReason
 *
 * @author Raymond Magezi
 *
 * @date 15 June 2026
 */
@IsTest(SeeAllData = false)
private class SVC_CTRL_UnresolvedReason_TEST
{
	/**
	 * @description Verifies getReasonsByCountry returns values for UG
	 */
	@IsTest
	private static void testGetReasonsByCountryForUG()
	{
		Test.startTest();
		List<SVC_CTRL_UnresolvedReason.PicklistOption> options = SVC_CTRL_UnresolvedReason.getReasonsByCountry('UG');
		Test.stopTest();

		Assert.isNotNull(options, 'Should return a list for UG');
		Assert.isFalse(options.isEmpty(), 'UG should have at least 1 valid reason');
	}

	/**
	 * @description Verifies getReasonsByCountry returns values for ZA
	 */
	@IsTest
	private static void testGetReasonsByCountryForZA()
	{
		Test.startTest();
		List<SVC_CTRL_UnresolvedReason.PicklistOption> options = SVC_CTRL_UnresolvedReason.getReasonsByCountry('ZA');
		Test.stopTest();

		Assert.isNotNull(options, 'Should return a list for ZA');
		Assert.isFalse(options.isEmpty(), 'ZA should have valid reasons');
	}

	/**
	 * @description Verifies getReasonsByCountry returns empty for invalid country
	 */
	@IsTest
	private static void testGetReasonsByCountryInvalidCountry()
	{
		Test.startTest();
		List<SVC_CTRL_UnresolvedReason.PicklistOption> options = SVC_CTRL_UnresolvedReason.getReasonsByCountry('XX');
		Test.stopTest();

		Assert.isNotNull(options, 'Should return a list');
		Assert.isTrue(options.isEmpty(), 'Invalid country should return empty list');
	}

	/**
	 * @description Verifies getFilteredReasons returns a list for a valid case
	 */
	@IsTest
	private static void testGetFilteredReasonsValidCase()
	{
		User testUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		System.runAs(testUser)
		{
			Case testCase = new Case(Subject = 'Test Unresolved', Status = 'New');
			insert testCase;

			Test.startTest();
			List<SVC_CTRL_UnresolvedReason.PicklistOption> options = SVC_CTRL_UnresolvedReason.getFilteredReasons(testCase.Id);
			Test.stopTest();

			Assert.isNotNull(options, 'Should return a list for valid case');
		}
	}

	/**
	 * @description Verifies getFilteredReasons returns empty list for null Id
	 */
	@IsTest
	private static void testGetFilteredReasonsNullId()
	{
		Test.startTest();
		List<SVC_CTRL_UnresolvedReason.PicklistOption> options = SVC_CTRL_UnresolvedReason.getFilteredReasons(null);
		Test.stopTest();

		Assert.isNotNull(options, 'Should return a list');
		Assert.isTrue(options.isEmpty(), 'Null Id should return empty list');
	}

	/**
	 * @description Verifies selectCountryById returns case with country field
	 */
	@IsTest
	private static void testSelectCountryById()
	{
		Case testCase = new Case(Subject = 'Test Country', Status = 'New');
		insert testCase;

		Test.startTest();
		List<Case> results = SEL_Case.newInstance().selectCountryById(testCase.Id);
		Test.stopTest();

		Assert.isFalse(results.isEmpty(), 'Should return the case');
		Assert.areEqual(testCase.Id, results[0].Id, 'Should return correct case');
	}

	/**
	 * @description Verifies selectWithTeamNotificationFieldsByIds returns cases
	 */
	@IsTest
	private static void testSelectWithTeamNotificationFieldsByIds()
	{
		Case testCase = new Case(Subject = 'Test Notification', Status = 'New');
		insert testCase;

		Test.startTest();
		List<Case> results = SEL_Case.newInstance().selectWithTeamNotificationFieldsByIds(new Set<Id>{ testCase.Id });
		Test.stopTest();

		Assert.isFalse(results.isEmpty(), 'Should return the case');
	}
}