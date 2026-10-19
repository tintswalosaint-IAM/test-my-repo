/**
 * @description Tests the Inbound Service class SVC_API_UpsertContactChannelSurvey
 *
 * @author Accenture
 *
 * @date 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts') // The asserts are in helper classes
private class SVC_API_UpsertContactChannelSurvey_TEST
{
	private static final Integer MIN_SURVEY_RESPONSE = 1;
	private static final Integer MAX_SURVEY_RESPONSE = 10;

	/**
	 * @description Sets up the RestContext Objects
	 *
	 * @param dtoRequest The Survey Upsert Request DTO
	 *
	 * @see SVC_API_UpsertContactChannelSurvey.DTO_Request
	 */
	private static void setupRestContext(SVC_API_UpsertContactChannelSurvey.DTO_Request dtoRequest)
	{
		dtoRequest.answerOne = CMN_UTIL_Word.capitalizeFully(CMN_UTIL_Boolean.toStringYesNo(CMN_DAL_SObjectDomain.generateRandomBoolean()));
		dtoRequest.answerTwo = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(MIN_SURVEY_RESPONSE, MAX_SURVEY_RESPONSE));
		dtoRequest.answerThree = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(MIN_SURVEY_RESPONSE, MAX_SURVEY_RESPONSE));

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);
	}

	/**
	 * @description Will check that Contact Channel is found and then Survey created for the Channel
	 */
	@IsTest
	private static void insertNewForExistingContactChannel()
	{
		amazonconnect__AC_ContactChannels__c newContactChannel = SVC_DAL_DataFactory.insertContactChannel();
		SVC_API_UpsertContactChannelSurvey.DTO_Request dtoRequest = new SVC_API_UpsertContactChannelSurvey.DTO_Request();
		dtoRequest.contactId = newContactChannel.amazonconnect__ContactId__c;

		setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_ContactChannelSurvey.upsertSurvey();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_UpsertContactChannelSurvey.SERVICE_NAME);

		List<SVC_ContactChannelSurvey__c> newSurveys = SVC_DAL_ContactChannelSurvey.getAll();
		System.assertNotEquals(true, newSurveys.isEmpty(), 'No Surveys created.');

		System.assertEquals(newContactChannel.Id, newSurveys.iterator().next().SVC_ACContactChannel__c, 'Contact Channel not set correctly.');
	}

	/**
	 * @description Will Check to see that existing survey for a case is updated correctly
	 */
	@IsTest
	private static void updateExisting()
	{
		amazonconnect__AC_ContactChannels__c newContactChannel = SVC_DAL_DataFactory.insertContactChannel();
		SVC_API_UpsertContactChannelSurvey.DTO_Request dtoRequest = new SVC_API_UpsertContactChannelSurvey.DTO_Request();
		dtoRequest.contactId = newContactChannel.amazonconnect__ContactId__c;

		setupRestContext(dtoRequest);

		//This will create initial survey row
		SVC_URL_ContactChannelSurvey.upsertSurvey();

		//Only 1 record should exist
		List<SVC_ContactChannelSurvey__c> newSurveys = SVC_DAL_ContactChannelSurvey.getAll();
		System.assertEquals(1, newSurveys.size(), 'Invalid number of Surveys');

		Test.startTest();

		//By calling this service type twice we expect existing survey to have been updated
		SVC_URL_ContactChannelSurvey.upsertSurvey();

		Test.stopTest();

		//Only 1 record should still exist
		newSurveys = SVC_DAL_ContactChannelSurvey.getAll();
		System.assertEquals(1, newSurveys.size(), 'Invalid number of Surveys');

		SVC_ContactChannelSurvey__c newSurvey = newSurveys.iterator().next();

		// check if field/s are updated correctly
		System.assertEquals(dtoRequest.answerOne, newSurvey.SVC_AchievedPurpose__c, 'Achieved Purpose not updated');
		System.assertEquals(dtoRequest.answerTwo, newSurvey.SVC_NetPromoterScoreRating__c, 'Net Promoter Score Rating not updated');
		System.assertEquals(dtoRequest.answerThree, newSurvey.SVC_AgentRating__c, 'Agent Rating not updated');
		System.assertEquals(true, newSurvey.SVC_SurveyComplete__c, 'Survey complete not updated');
	}

	/**
	 * @description Request is invalid as it doesn't match an existing Channel Contact
	 */
	@IsTest
	private static void noExistingContactId()
	{
		SVC_API_UpsertContactChannelSurvey.DTO_Request dtoRequest = new SVC_API_UpsertContactChannelSurvey.DTO_Request();
		dtoRequest.contactId = CMN_DAL_SObjectDomain.generateRandomNumber();

		setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_ContactChannelSurvey.upsertSurvey();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_UpsertContactChannelSurvey.SERVICE_NAME, SVC_API_UpsertContactChannelSurvey.ERROR_NO_RECORD_FOUND);
	}

	/**
	 * @description Request Invalid as it doesn't have a Contact Id
	 */
	@IsTest
	private static void missingContactId()
	{
		SVC_API_UpsertContactChannelSurvey.DTO_Request dtoRequest = new SVC_API_UpsertContactChannelSurvey.DTO_Request();

		setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_ContactChannelSurvey.upsertSurvey();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_UpsertContactChannelSurvey.SERVICE_NAME, SVC_API_UpsertContactChannelSurvey.ERROR_CONTACT_ID_WAS_NOT_PROVIDED);
	}
}