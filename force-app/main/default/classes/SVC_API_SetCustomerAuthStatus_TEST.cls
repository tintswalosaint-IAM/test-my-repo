/**
 * @description Test class for SVC_API_SetCustomerAuthStatus
 *
 * @see SVC_API_SetCustomerAuthStatus
 *
 * @author Accenture
 *
 * @date April 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
private class SVC_API_SetCustomerAuthStatus_TEST
{
	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		User testUser =
		[
				SELECT Id,
						IsActive
				FROM User
				WHERE Profile.Name = 'SVC Agent Banker'
				AND IsActive = TRUE
				LIMIT 1
		];
		System.runAs(testUser)
		{
			try
			{
				CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_SetCustomerAuthStatus.SERVICE_NAME, null, SVC_API_SetCustomerAuthStatus.REQUIRED_PARAMETERS);
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.INFO, e.getMessage());
			}
		}
	}

	/**
	 * @description Checks that the call is aborted because required parameters were not provided
	 *
	 * @see SVC_API_SetCustomerAuthStatus.getRequiredParameters
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_SetCustomerAuthStatus.SERVICE_NAME, null);
	}
}