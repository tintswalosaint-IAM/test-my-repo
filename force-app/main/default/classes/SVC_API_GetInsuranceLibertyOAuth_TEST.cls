/**
 * @description Test class for SVC_API_GetInsuranceFlexiOAuth
 *
 * @see SVC_API_GetInsuranceLibertyOAuth
 *
 * @author Accenture
 *
 * @date January 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetInsuranceLibertyOAuth_TEST
{
	/**
	 * @description Emulates a successful API call
	 */
	@IsTest
	private static void successfulCall()
	{
		SVC_API_GetInsuranceLibertyOAuth handler = (SVC_API_GetInsuranceLibertyOAuth)CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_GetInsuranceLibertyOAuth.SERVICE_NAME, null);
		System.assertEquals(true, String.isNotBlank(handler.accessToken), 'No Access Token Returned');
	}
}