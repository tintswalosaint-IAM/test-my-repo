/**
 * @description Test class for SVC_API_GetAccounts
 *
 * @see SVC_API_GetAccounts
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetAccounts_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;

	/**
	 * @description Create the data required for the unit test, needs to be done in a separate thread
	 */
	@TestSetup
	private static void setup()
	{
		SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE);
	}

	/**
	 * @description Emulates a successful call where all accounts are filtered out
	 *
	 * @see SVC_API_GetAccounts.parseResponse
	 */
	@IsTest
	private static void successfulCallFilterOnNoAccountFound()
	{
		Contact newContact = SVC_DAL_Contact.getAll().iterator().next();
		SVC_API_GetAccounts handler = (SVC_API_GetAccounts)CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_GetAccounts.SERVICE_NAME, newContact.Id, SVC_API_GetAccounts.PARAMETER_FILTER);
		SVC_API_GetAccounts.DTO_Response dtoResponse = (SVC_API_GetAccounts.DTO_Response)handler.baseResponseDTO;
		System.assertEquals(true, dtoResponse.customerAccountListDetails.isEmpty(), 'All product details should have been filtered out');
	}

	/**
	 * @description Emulates a successful call where some accounts¬ are filtered out
	 *
	 * @see SVC_API_GetAccounts.parseResponse
	 */
	@IsTest
	private static void successfulCallFilterAccounts()
	{
		Map<String, String> parameters = new Map<String, String>
		{
				SVC_API_GetAccounts.PARAMETER_FILTER => SVC_API_GetAccounts.CREDIT_AND_DEBIT_CARDS_FILTER

		};

		Contact newContact = SVC_DAL_Contact.getAll().iterator().next();
		SVC_API_GetAccounts handler = (SVC_API_GetAccounts)CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_GetAccounts.SERVICE_NAME, newContact.Id, parameters);
		SVC_API_GetAccounts.DTO_Response dtoResponse = (SVC_API_GetAccounts.DTO_Response)handler.baseResponseDTO;
		System.assertEquals(SVC_API_GetAccounts.NUMBER_OF_CREDIT_AND_DEBIT_CARDS, dtoResponse.customerAccountListDetails.size(), 'Accounts not filtered correctly');
	}

	/**
	 * @description Emulates a successful call with no parameters passed, i.e. we'll retrieve all accounts
	 *
	 * @see SVC_API_GetAccounts.DTO_Table.transform
	 * @see SVC_API_GetAccounts.getWebServiceEndPoint
	 */
	@IsTest
	private static void successfulCallNoParameters()
	{
		Contact newContact = SVC_DAL_Contact.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCallHasTableTransformer(SVC_API_GetAccounts.SERVICE_NAME, newContact.Id);
	}

	/**
	 * @description Checks that a call is aborted correctly when no BPID is available for the ID given
	 *
	 * @see SVC_API_GetAccounts.abortRequest
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetAccounts.SERVICE_NAME, UserInfo.getUserId());
	}
}