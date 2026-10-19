/**
 * @description Tests the Authentication Combination Controller class SVC_CTRL_AuthenticationCombination
 *
 * @see SVC_CTRL_AuthenticationCombination
 *
 * @author Accenture
 *
 * @date May 2021
 */
@IsTest(SeeAllData = false IsParallel = true)
private class SVC_CTRL_AuthenticationCombination_TEST
{
	private static final Integer AUTHENTICATION_LEVEL4 = 4;
	private static final Integer MAX_AUTHENTICATION_LEVEL = 3;
	private static final Integer MIN_AUTHENTICATION_LEVEL = 1;
	private static final String AUTHENTICATION_METHOD = 'NIUSSD';

	/**
	 * @description Common method to setup authentication combinations
	 *
	 * @return
	 */
	private static String setAuthenticationCombinations()
	{
		String authenticationLevel = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(MIN_AUTHENTICATION_LEVEL, MAX_AUTHENTICATION_LEVEL));

		// Generate service type
		SVC_ServiceType__c serviceType = SVC_DAL_DataFactory.generateServiceType(authenticationLevel);
		insert serviceType;

		return authenticationLevel;
	}

	/**
	 * @description Will check if list of authentication method/s is/are found given a authentication level
	 */
	@IsTest
	private static void getAuthenticationMethodsTest()
	{
		String authenticationLevel = setAuthenticationCombinations();

		Test.startTest();

		SVC_DAL_DataFactory.generateAuthenticationCombinations();

		Test.stopTest();

		List<SVC_AuthenticationCombination__c> authMethods = SVC_CTRL_AuthenticationCombination.getAuthenticationMethods(authenticationLevel);

		System.assertNotEquals(true, authMethods.isEmpty(), 'No available methods for Auth Level ' + authenticationLevel);
	}

	/**
	 * @description Will check if no authentication method beyond the available authentication level
	 */
	@IsTest
	private static void noMethodsTest()
	{
		setAuthenticationCombinations();

		Test.startTest();

		SVC_DAL_DataFactory.generateAuthenticationCombinations();

		Test.stopTest();

		List<SVC_AuthenticationCombination__c> authMethods = SVC_CTRL_AuthenticationCombination.getAuthenticationMethods(String.valueOf(AUTHENTICATION_LEVEL4));

		System.assertEquals(true, authMethods.isEmpty(), 'Authentication level exceeds beyond the available one');
	}

	/**
	 * @description To check if has authentication level given the authentication method
	 */
	@IsTest
	private static void hasAuthenticationLevelTest()
	{
		setAuthenticationCombinations();

		Test.startTest();

		SVC_DAL_DataFactory.generateAuthenticationCombinations();

		Test.stopTest();

		SVC_AuthenticationCombination__c authLevel = SVC_CTRL_AuthenticationCombination.getAuthenticationLevel(AUTHENTICATION_METHOD);

		System.assertNotEquals(null, authLevel, 'No available level for Auth Method ' + AUTHENTICATION_METHOD);
	}
}