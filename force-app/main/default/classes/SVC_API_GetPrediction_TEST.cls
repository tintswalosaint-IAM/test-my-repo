/**
 * @description Test class for SVC_API_OutboundPerformNLP
 *
 * @see SVC_API_GetPrediction
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetPrediction_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;

	/**
	 * @description Will create the case required for the webservice handler
	 */
	@TestSetup
	private static void setupData()
	{
		List<Contact> contacts = SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE);
		SVC_DAL_DataFactory.generateCases(contacts[0].Id, NUMBER_OF_ITEMS_TO_GENERATE);
	}

	/**
	 * @description Will emulate a successful call for NLP processing
	 *
	 * @see SVC_API_GetPrediction.DTO_Request.populate
	 */
	@IsTest
	private static void successfulCall()
	{
		Case newCase = (Case)SVC_DAL_Case.getAll().iterator().next();
		CMN_API_RestBaseOutboundTestHelper.successfulCall(SVC_API_GetPrediction.SERVICE_NAME, newCase.Id);
	}

	/**
	 * @description Will test scenario where the id being provided is not for a case object
	 *
	 * @see SVC_API_GetPrediction.abortRequest
	 */
	@IsTest
	private static void abortedCall()
	{
		CMN_API_HttpBase response = CMN_API_RestBaseOutboundTestHelper.abortedCall(SVC_API_GetPrediction.SERVICE_NAME, null);
		System.assertEquals(true, response.callResult.aborted, 'Call was not aborted as expected, expected abort, received ' + response.callResult.aborted);
	}

	/**
	 * @description Will test scenario where the Id is a case Id but the case no longer exists
	 *
	 * @see SVC_API_GetPrediction.abortRequest
	 */
	@IsTest
	private static void itemNotFound()
	{
		Case newCase = (Case)SVC_DAL_Case.getAll().iterator().next();
		User adminUser = CMN_DAL_User.findRandomActiveByProfileName(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);

		//Making sure the delete runs in a different transaction; so we can make API call
		System.runAs(adminUser)
		{
			delete newCase;
		}

		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SVC_API_GetPrediction.SERVICE_NAME, newCase.Id);

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			//First test that all the calls have an error status
			System.assertEquals(true, response.callResult.failed, 'Call did not fail as expected');
		}
	}
}