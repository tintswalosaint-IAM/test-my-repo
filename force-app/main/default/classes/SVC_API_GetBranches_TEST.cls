/**
 * @description Test class for SVC_API_GetBranches
 *
 * @see SVC_API_GetBranches
 *
 * @author Accenture
 *
 * @date January 201§
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetBranches_TEST
{
	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetBranches.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCall()
	{
		SVC_API_GetBranches handler = (SVC_API_GetBranches)CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SVC_API_GetBranches.SERVICE_NAME, null);
	}

	/**
	 * @description Checks that a call is aborted correctly when no parameter is given containing table name
	 *
	 * @see SVC_API_ReferenceDataBase.getRequiredParameters
	 */
	@IsTest
	private static void abortedCall()
	{
		//This will ensure that the required tableName parameter is not automatically set and therefore result in call being aborted
		SVC_API_ReferenceDataBase.induceAbort = true;
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetBranches.SERVICE_NAME, null);
	}

	/**
	 * @description Emulates a call where an unauthorised exception is received and as a result another call is made to refresh the access token
	 *
	 * @see SVC_API_OAuthOutboundBase.sendRequest
	 * @see SVC_API_GetInsuranceOAuthTokenBase.SVC_API_GetOAuthTokenMock.setResponse
	 */
	@IsTest
	private static void unAuthorisedCall()
	{
		SVC_API_OAuthOutboundBase.simulateInvalidAuthorisationToken = true;

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SVC_API_GetBranches.SERVICE_NAME);

		Test.startTest();

		SVC_API_GetBranches handler = (SVC_API_GetBranches)CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(SVC_API_GetInsuranceDirectOAuth.SERVICE_NAME);
		System.assertEquals(2, queueItems.size(), 'Auth Service Not called twice as expected');
	}

	/**
	 * @description Emulates a call where an unauthorised exception is received and as a result another call is made to refresh the access token
	 *
	 * @see SVC_API_OAuthOutboundBase.sendRequest
	 * @see SVC_API_GetInsuranceOAuthTokenBase.SVC_API_GetOAuthTokenMock.setResponse
	 */
	@IsTest
	private static void tokenRequestFailed()
	{
		SVC_API_GetInsuranceOAuthTokenBase.simulateGetAccessTokenFailed = true;

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SVC_API_GetBranches.SERVICE_NAME);

		Test.startTest();

		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem}).iterator().next();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(SVC_API_GetBranches.SERVICE_NAME);
		System.assertEquals(1, queueItems.size(), 'Expected only a single entry');

		queueItem = queueItems.iterator().next();

		System.assertEquals(true, CMN_UTIL_String.contains(queueItem.CMN_Errors__c, SVC_API_OAuthOutboundBase.ERROR_TOKEN_REQUEST_FAILED));
	}
}