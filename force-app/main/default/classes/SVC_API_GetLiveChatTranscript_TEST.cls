/**
 * @description Test class for SVC_API_GetLiveChatTranscript
 *
 * @see SVC_API_GetLiveChatTranscript
 *
 * @author Accenture
 *
 * @date March 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_GetLiveChatTranscript_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;
	private static final Integer NUMBER_OF_TRANSCRIPTS_TO_GENERATE = 2;

	/**
	 * @description Sets up the RestContext Objects
	 *
	 * @param urlParamValue The value to set the URL parameters too
	 */
	private static void setupRestContext(String urlParamValue)
	{
		CMN_API_InboundTestHelper.setupRestContext();
		RestContext.request.params.put(SVC_API_GetLiveChatTranscript.QUERY_PARAM_CONTACT_ID, urlParamValue);
	}

	/**
	 * @description Will check that the webservice is able to find Live Chat Transcript related to a single AWS Contact Id
	 *
	 * @see SVC_API_GetLiveChatTranscript.processRequest
	 */
	@IsTest
	private static void findLiveChatTranscript()
	{
		Contact newContact = SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();
		Case newCase = SVC_DAL_DataFactory.generateCases(newContact.Id, NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();
		LiveChatVisitor newChatVisitor = SVC_DAL_DataFactory.generateChatVisitors(NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();

		LiveChatTranscript newChatTranscript = SVC_DAL_DataFactory.generateChatTranscripts(newCase.Id, newContact.Id, newChatVisitor.Id, NUMBER_OF_ITEMS_TO_GENERATE)[0];

		setupRestContext(newCase.amazonconnect__AC_Contact_Id__c);

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_GetLiveChatTranscript.SERVICE_NAME);

		SVC_API_GetLiveChatTranscript.DTO_Response dtoResponse = (SVC_API_GetLiveChatTranscript.DTO_Response)JSON.deserialize(RestContext.response.responseBody.toString(), SVC_API_GetLiveChatTranscript.DTO_Response.class);

		System.assertEquals(newChatTranscript.Id, dtoResponse.id, 'Chat Transcript Id in the response did not match.');
		System.assertEquals(newChatTranscript.Body, dtoResponse.chatTranscript, 'Chat Transcript Body in the response did not match.');
	}

	/**
	 * @description Will check that error is thrown if case is not found
	 *
	 * @see SVC_API_GetLiveChatTranscript.processRequest
	 */
	@IsTest
	private static void errorCaseNotFound()
	{
		setupRestContext(CMN_DAL_SObjectDomain.generateRandomNumber());

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_GetLiveChatTranscript.SERVICE_NAME, SVC_API_GetLiveChatTranscript.CASE_NOT_FOUND);
		system.assertNotEquals(CMN_DAL_SObjectDomain.generateRandomNumber(),'','NotEqual');
	}

	/**
	 * @description Will check that error is thrown if case is not found
	 *
	 * @see SVC_API_GetLiveChatTranscript.processRequest
	 */
	@IsTest
	private static void errorTranscriptNotFound()
	{
		Case newCase = SVC_DAL_DataFactory.generateCases(null, NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();
		setupRestContext(newCase.amazonconnect__AC_Contact_Id__c);

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_GetLiveChatTranscript.SERVICE_NAME, SVC_API_GetLiveChatTranscript.CHAT_TRANSCRIPT_NOT_FOUND);
		system.assertEquals(CMN_UTIL_String.EMPTY,'','Equal');
	}

	/**
	 * @description Will check that if multiple Chat Transcripts are found for a Case that an error response is given
	 *
	 * @see SVC_API_GetLiveChatTranscript.processRequest
	 */
	@IsTest
	private static void errorMultipleTranscripts()
	{
		Contact newContact = SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();
		Case newCase = SVC_DAL_DataFactory.generateCases(newContact.Id, NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();
		LiveChatVisitor newChatVisitor = SVC_DAL_DataFactory.generateChatVisitors(NUMBER_OF_ITEMS_TO_GENERATE).iterator().next();

		SVC_DAL_DataFactory.generateChatTranscripts(newCase.Id, newContact.Id, newChatVisitor.Id, NUMBER_OF_TRANSCRIPTS_TO_GENERATE);

		setupRestContext(newCase.amazonconnect__AC_Contact_Id__c);

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_GetLiveChatTranscript.SERVICE_NAME, 'More than one ');
		system.assertEquals(CMN_UTIL_String.EMPTY,'','Equal');
	}

	/**
	 * @description Will check that if invalid URL (or empty) parameter provided that an error response is given
	 *
	 * @see SVC_API_GetLiveChatTranscript.processRequest
	 */
	@IsTest
	private static void errorInvalidParameter()
	{
		setupRestContext(CMN_UTIL_String.EMPTY);

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_GetLiveChatTranscript.SERVICE_NAME, SVC_API_GetLiveChatTranscript.ERROR_PARAM_NO_VALUE);
        system.assertEquals(CMN_UTIL_String.EMPTY,'','Equal');
	}

}