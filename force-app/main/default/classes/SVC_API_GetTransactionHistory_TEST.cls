/**
 * @description Test class for SVC_API_GetTransactionHistory
 *
 * @see SVC_API_GetTransactionHistory
 *
 * @author Accenture
 *
 * @date April 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
private class SVC_API_GetTransactionHistory_TEST
{
	public static final String SAMPLE_DAYS = '5';

	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetTransactionHistory.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCallWithCreditCardType()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				SVC_API_GetTransactionHistory.PARAMETER_ACCOUNT_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber(),
				SVC_API_GetTransactionHistory.PARAMETER_CARD_TYPE => SVC_API_GetTransactionHistory.CARD_TYPE_CREDIT,
				SVC_API_GetTransactionHistory.PARAMETER_CARD_DAYS => SAMPLE_DAYS
		};

		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer
				(
						SVC_API_GetTransactionHistory.SERVICE_NAME,
						null,
						parameterMap
				);
	}

	/**
	 * @description Test to validate the response when the account number is null
	 */
	@IsTest
	private static void testNullAccountNumber()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				SVC_API_GetTransactionHistory.PARAMETER_ACCOUNT_NUMBER => null,
				SVC_API_GetTransactionHistory.PARAMETER_CARD_TYPE => SVC_API_GetTransactionHistory.CARD_TYPE_CREDIT,
				SVC_API_GetTransactionHistory.PARAMETER_CARD_DAYS => SAMPLE_DAYS
		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(
				SVC_API_GetTransactionHistory.SERVICE_NAME,
				null,
				parameterMap);

	}

	/**
	 * @description Tests to validate the correct parameters are sent with the appropriate card type, when the
	 *              card type is CREDIT then the days parameters is required
	 */
	@IsTest
	private static void testCreditCardParameters()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				SVC_API_GetTransactionHistory.PARAMETER_ACCOUNT_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber(),
				SVC_API_GetTransactionHistory.PARAMETER_CARD_TYPE => SVC_API_GetTransactionHistory.CARD_TYPE_CREDIT
		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(
				SVC_API_GetTransactionHistory.SERVICE_NAME,
				null,
				parameterMap);
	}

	/**
	 * @description Tests to validate the correct parameters are sent with the appropriate card type, when the
	 *              card type is anything other than CREDIT then the startDate and endDate parameters are required
	 */
	@IsTest
	private static void testNonCreditCardParameters()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				SVC_API_GetTransactionHistory.PARAMETER_ACCOUNT_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber(),
				SVC_API_GetTransactionHistory.PARAMETER_CARD_TYPE => CMN_DAL_SObjectDomain.generateRandomName()
		};

		CMN_API_RestBaseOutboundTestHelper.abortedCall(
				SVC_API_GetTransactionHistory.SERVICE_NAME,
				null,
				parameterMap);
	}

	/**
	 * @description Emulates a successful call and checks that the code to transform to a table has been implemented
	 *
	 * @see SVC_API_GetTransactionHistory.DTO_Table.transform
	 */
	@IsTest
	private static void successfulCall()
	{
		Map<String, String> parameterMap = new Map<String, String>
		{
				SVC_API_GetTransactionHistory.PARAMETER_ACCOUNT_NUMBER => CMN_DAL_SObjectDomain.generateRandomNumber(),
				SVC_API_GetTransactionHistory.PARAMETER_CARD_TYPE => CMN_DAL_SObjectDomain.generateRandomName(),
				SVC_API_GetTransactionHistory.PARAMETER_START_DATE => CMN_UTIL_Date.dateToIso8601String(Date.today() - 10),
				SVC_API_GetTransactionHistory.PARAMETER_END_DATE => CMN_UTIL_Date.dateToIso8601String(Date.today() - 5)
		};

		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer
				(
						SVC_API_GetTransactionHistory.SERVICE_NAME,
						null,
						parameterMap
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
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetTransactionHistory.SERVICE_NAME, null);
	}

}