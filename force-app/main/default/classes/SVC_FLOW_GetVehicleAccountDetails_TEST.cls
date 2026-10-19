/**
 * @description Test class for SVC_FLOW_GetVehicleAccountDetails
 *
 * @see SVC_FLOW_GetVehicleAccountDetails
 *
 * @author Accenture
 *
 * @date 2021 April
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_FLOW_GetVehicleAccountDetails_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;

	/**
	 * @description Creates required test data
	 */
	@TestSetup
	private static void setup()
	{
		SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE);
	}

	/**
	 * @description Will run test with relevant parameter provided, done to support DRY principals
	 *
	 * @param useValidContactId If false, the method will be run with an invalid Contact Id
	 *
	 * @return A response from the method call
	 */
	private static SVC_FLOW_GetVehicleAccountDetails.DTO_Response runTest(Boolean useValidContactId)
	{
		Contact newContact = (Contact)SVC_DAL_Contact.getAll().iterator().next();

		List<SVC_FLOW_GetVehicleAccountDetails.DTO_Request> dtoRequests = new List<SVC_FLOW_GetVehicleAccountDetails.DTO_Request>();
		SVC_FLOW_GetVehicleAccountDetails.DTO_Request dtoRequest = new SVC_FLOW_GetVehicleAccountDetails.DTO_Request();

		dtoRequest.contactId = useValidContactId ? newContact.Id : newContact.Account.Id;
		dtoRequest.sourceSystemId = SVC_API_GetAccounts.CREDIT_AND_DEBIT_CARDS_FILTER;
		dtoRequests.add(dtoRequest);

		Test.startTest();

		List<SVC_FLOW_GetVehicleAccountDetails.DTO_Response> dtoResponses = SVC_FLOW_GetVehicleAccountDetails.getFilteredVehicleDetails(dtoRequests);

		Test.stopTest();

		return dtoResponses.iterator().next();
	}

	/**
	 * @description Emulates a successful call where two API's called and the results merged
	 *
	 * @see SVC_API_GetAccounts
	 * @see SVC_API_GetVehicleDocumentation
	 */
	@IsTest
	private static void successfulCall()
	{
		SVC_FLOW_GetVehicleAccountDetails.DTO_Response dtoResponse = runTest(true);
		System.assertEquals(true, dtoResponse.success, 'Method failed with following error: ' + dtoResponse.payload);
		System.assertEquals(SVC_API_GetAccounts.NUMBER_OF_CREDIT_AND_DEBIT_CARDS, dtoResponse.tableRowCount, 'Invalid number of accounts returned');
	}

}