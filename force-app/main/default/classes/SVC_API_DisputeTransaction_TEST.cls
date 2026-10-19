/**
 * @description Test class for SVC_API_DisputeTransaction
 *
 * @see SVC_API_DisputeTransaction
 *
 * @author Accenture
 *
 * @date January 2021
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_DisputeTransaction_TEST
{
	/**
	 * @description Emulates a successful call
	 *
	 * @see SVC_API_DisputeTransaction.DTO_Request.populate
	 */
	@IsTest
	private static void successfulCall()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				SVC_API_DisputeTransaction.PARAMETER_ACCOUNT_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber(),
				SVC_API_DisputeTransaction.PARAMETER_TRANSACTION_ID => CMN_UTIL_Random.randomUUID(),
				SVC_API_DisputeTransaction.PARAMETER_REASON => SVC_API_DisputeTransaction.REASON_AUTHORITY

		};

		CMN_API_RestBaseOutboundTestHelper.successfulCall
				(
						SVC_API_DisputeTransaction.SERVICE_NAME,
						null,
						parameters
				);
	}

	/**
	 * @description Checks that the call is aborted because required parameters were not provided
	 *
	 * @see SVC_API_DisputeTransaction.abortRequest
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_DisputeTransaction.SERVICE_NAME, null);
	}
}