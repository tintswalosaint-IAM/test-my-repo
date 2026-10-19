/**
 * @description Tests the Inbound Service class SVC_API_UpsertLiveChatTranscript
 *
 * @author Accenture
 *
 * @date March 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_UpsertLiveChatTranscript_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;

	/**
	 * @description Sets up the RestContext Objects
	 *
	 * @param dtoRequest The Transcript Upsert Request DTO
	 *
	 * @see SVC_API_UpsertLiveChatTranscript.DTO_Request
	 */
	private static void setupRestContext(SVC_API_UpsertLiveChatTranscript.DTO_Request dtoRequest)
	{
		dtoRequest.chatTranscript = CMN_DAL_SObjectDomain.generateRandomDescription();
		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);
	}

	/**
	 * @description Will check that Case is found, and then chat transcript created for the case
	 */
	@IsTest
	private static void insertNewForExistingCase()
	{
		amazonconnect__AC_ContactChannels__c newContactChannel = SVC_DAL_DataFactory.insertContactChannel();

		Case newCase = SVC_DAL_DataFactory.newCase(null);
		newCase.amazonconnect__AC_Contact_Id__c = newContactChannel.amazonconnect__ContactId__c;
		insert newCase;
		newContactChannel.amazonconnect__Case__c = newCase.id;
		update newContactChannel;

		SVC_API_UpsertLiveChatTranscript.DTO_Request dtoRequest = new SVC_API_UpsertLiveChatTranscript.DTO_Request();
		dtoRequest.contactId = newContactChannel.amazonconnect__ContactId__c;

		setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_LiveChatTranscript.upsertLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_UpsertLiveChatTranscript.SERVICE_NAME);

		List<LiveChatTranscript> newTranscripts = SVC_DAL_LiveChatTranscript.getAll();

		System.assertNotEquals(true, newTranscripts.isEmpty(), 'No Transcripts created.');
		System.assertEquals(newCase.Id, newTranscripts[0].CaseId, 'Transcript has invalid Case Id');

		List<amazonconnect__AC_ContactChannels__c> foundChannels = SVC_DAL_AcContactChannel.getAll();
		System.assertEquals(newCase.Id, foundChannels.iterator().next().amazonconnect__Case__c, 'Channel was not linked to case.');
	}

	/**
	 * @description Will Check to see that existing transcript for a case is updated correctly
	 */
	@IsTest
	private static void updateExisting()
	{
		amazonconnect__AC_ContactChannels__c newContactChannel = SVC_DAL_DataFactory.insertContactChannel();

		Case newCase = SVC_DAL_DataFactory.newCase(null);
		newCase.amazonconnect__AC_Contact_Id__c = newContactChannel.amazonconnect__ContactId__c;
		insert newCase;

		SVC_API_UpsertLiveChatTranscript.DTO_Request dtoRequest = new SVC_API_UpsertLiveChatTranscript.DTO_Request();
		dtoRequest.contactId = newContactChannel.amazonconnect__ContactId__c;

		setupRestContext(dtoRequest);
		SVC_URL_LiveChatTranscript.upsertLiveChat();

		//Only 1 should exist
		List<LiveChatTranscript> newTranscripts = SVC_DAL_LiveChatTranscript.getAll();
		System.assertEquals(1, newTranscripts.size(), 'Invalid number of Transcripts');

		Test.startTest();

		//By calling this service type twice we expect existing transcript to have been updated
		SVC_URL_LiveChatTranscript.upsertLiveChat();

		Test.stopTest();

		//Only 1 should still exist
		newTranscripts = SVC_DAL_LiveChatTranscript.getAll();
		System.assertEquals(1, newTranscripts.size(), 'Invalid number of Transcripts');

		System.assertEquals(dtoRequest.chatTranscript + CMN_UTIL_String.LF + dtoRequest.chatTranscript, newTranscripts[0].Body, 'Transcript not updated correctly');
	}

	/**
	 * @description Will Check to see that a new transcript is created if both case and transcript don't exist and is linked correctly to customer
	 */
	@IsTest
	private static void createNewWithExistingContact()
	{
		amazonconnect__AC_ContactChannels__c newContactChannel = SVC_DAL_DataFactory.insertContactChannel();

		Contact newContact = SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE)[0];
		Account newAccount = SVC_DAL_Account.findById(newContact.AccountId);

		SVC_API_UpsertLiveChatTranscript.DTO_Request dtoRequest = new SVC_API_UpsertLiveChatTranscript.DTO_Request();
		dtoRequest.contactId = newContactChannel.amazonconnect__ContactId__c;
		dtoRequest.customerPBID = newAccount.ExternalCIFId__c;

		setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_LiveChatTranscript.upsertLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_UpsertLiveChatTranscript.SERVICE_NAME);

		List<LiveChatTranscript> newTranscripts = SVC_DAL_LiveChatTranscript.getAll();
		System.assertNotEquals(true, newTranscripts.isEmpty(), 'No Transcripts created.');

		System.assertEquals(newContact.Id, newTranscripts.iterator().next().ContactId, 'Contact was not associated to Transcript');
		List<Case> newCases = SVC_DAL_Case.getAll();
		System.assertEquals(newContact.Id, newCases.iterator().next().ContactId, 'Contact not associated with case');

		newContactChannel.amazonconnect__Case__c = newCases[0].id;
		update newContactChannel;

		List<amazonconnect__AC_ContactChannels__c> contactChannels = SVC_DAL_AcContactChannel.getAll();
		System.assertEquals(newCases.iterator().next().Id, contactChannels.iterator().next().amazonconnect__Case__c, 'Case was not set on Contact Channel');
	}
}