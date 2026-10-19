/**
 * @description Test class for SVC_API_GetTransactions
 *
 * @see SVC_API_GetTransactions
 *
 * @author Accenture
 *
 * @date January 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
private class SVC_API_GetTransactions_TEST
{
	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetTransactions.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer
				(
						SVC_API_GetTransactions.SERVICE_NAME,
						null,
						SVC_API_GetTransactions.PARAMETER_ACCOUNT_NUMBER
				);
	}

	/**
	 * @description Checks that a call is aborted correctly when no parameter is given containing card number
	 *
	 * @see SVC_API_GetTransactions.getRequiredParameters
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetTransactions.SERVICE_NAME, null);
	}
}