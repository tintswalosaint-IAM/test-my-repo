/**
 * @description Will test the inbound service class SVC_API_UpdatePrediction
 */
@IsTest(SeeAllData=false IsParallel=true)
private class SVC_API_UpdatePrediction_TEST
{
	private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;
	private static final Integer NUMBER_OF_SERVICE_TYPES_TO_GENERATE = 5;
	private static final Decimal SENTIMENT_SCORE = 0.5;

	private static SVC_API_UpdatePrediction.DTO_Request generateRequest()
	{
		List<Contact> contacts = SVC_DAL_DataFactory.generateContacts(NUMBER_OF_ITEMS_TO_GENERATE, NUMBER_OF_ITEMS_TO_GENERATE);
		Case newCase = SVC_DAL_DataFactory.generateCases(contacts[0].Id, NUMBER_OF_ITEMS_TO_GENERATE)[0];

		SVC_API_UpdatePrediction.DTO_Request dtoRequest = new SVC_API_UpdatePrediction.DTO_Request();
		dtoRequest.objectId = newCase.Id;

		return dtoRequest;
	}

	/**
	 * @description Will setup test scenario for a particular sentiment
	 *
	 * @param sentiment Sentiment enum for which to run a test
	 */
	private static void checkSentimentSetCorrectly(SVC_API_UpdatePrediction.Sentiment sentiment)
	{
		SVC_API_UpdatePrediction.DTO_Request dtoRequest = generateRequest();

		dtoRequest.sentimentAnalysis = new SVC_API_UpdatePrediction.DTO_SentimentAnalysis();
		dtoRequest.sentimentAnalysis.sentiment = sentiment.name();

		switch on sentiment
		{
			when POSITIVE
			{
				dtoRequest.sentimentAnalysis.sentimentScore.positive = SENTIMENT_SCORE;
			}
			when NEGATIVE
			{
				dtoRequest.sentimentAnalysis.sentimentScore.negative = SENTIMENT_SCORE;
			}
			when MIXED
			{
				dtoRequest.sentimentAnalysis.sentimentScore.mixed = SENTIMENT_SCORE;
			}
			when NEUTRAL
			{
				dtoRequest.sentimentAnalysis.sentimentScore.neutral = SENTIMENT_SCORE;
			}
		}

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_Prediction.processPredictions();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_UpdatePrediction.SERVICE_NAME);

		Case newCase = SVC_DAL_Case.findById(dtoRequest.objectId);

		System.assert(sentiment.name().equalsIgnoreCase(newCase.SVC_Sentiment__c), 'Sentiment not set correctly');
		System.assertEquals(SENTIMENT_SCORE * 100, newCase.SVC_SentimentScore__c, 'Sentiment Score not set correctly');
	}

	/**
	 * @description Will check that a case service type is updated correctly from a prediction
	 */
	@IsTest
	private static void updateCaseWithIntent()
	{
		SVC_API_UpdatePrediction.DTO_Request dtoRequest = generateRequest();
		dtoRequest.isSpam = true;

		dtoRequest.intentPrediction = new SVC_API_UpdatePrediction.DTO_IntentPrediction();
		SVC_API_UpdatePrediction.DTO_IntentPrediction dtoIntentPrediction = dtoRequest.intentPrediction;
		dtoIntentPrediction.labels = new List<SVC_API_UpdatePrediction.DTO_Label>();
		SVC_API_UpdatePrediction.DTO_Label dtoLabel = new SVC_API_UpdatePrediction.DTO_Label();

		SVC_ServiceType__c newServiceType = (SVC_ServiceType__c)CMN_UTIL_System.getRandomItem(SVC_DAL_DataFactory.generateServiceTypes(NUMBER_OF_SERVICE_TYPES_TO_GENERATE));

		dtoLabel.name = newServiceType.SVC_ExternalId__c;
		dtoLabel.score = CMN_DAL_SObjectDomain.generateRandomDecimal();

		dtoIntentPrediction.labels.add(dtoLabel);

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_Prediction.processPredictions();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_UpdatePrediction.SERVICE_NAME);

		Case newCase = SVC_DAL_Case.findById(dtoRequest.objectId);

		System.assertNotEquals(null, newCase.SVC_ServiceType__c, 'Service Type was not set');
		System.assertEquals(true, newCase.SVC_PotentialSpam__c, 'Potential Spam flag not set');
	}

	/**
	 * @description Will test that exception is thrown if an ObjectId not provided
	 */
	@IsTest
	private static void missingObjectId()
	{
		SVC_API_UpdatePrediction.DTO_Request dtoRequest = new SVC_API_UpdatePrediction.DTO_Request();

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_Prediction.processPredictions();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_UpdatePrediction.SERVICE_NAME, SVC_API_UpdatePrediction.ERROR_OBJECT_ID_MISSING);
	}

	/**
	 * @description Will test that exception is thrown if object cannot be found
	 */
	@IsTest
	private static void objectNotFound()
	{
		SVC_API_UpdatePrediction.DTO_Request dtoRequest = generateRequest();

		//Delete case so that it triggers the error where object is not found
		Case deleteCase = new Case(Id = dtoRequest.objectId);
		delete deleteCase;

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_Prediction.processPredictions();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(SVC_API_UpdatePrediction.SERVICE_NAME, SVC_API_UpdatePrediction.ERROR_OBJECT_NOT_FOUND);
	}

	/**
	 * @description Will test that exception is thrown if an ID for an invalid Object Type is provided
	 */
	@IsTest
	private static void invalidObjectType()
	{
		SVC_API_UpdatePrediction.DTO_Request dtoRequest = new SVC_API_UpdatePrediction.DTO_Request();
		dtoRequest.objectId = UserInfo.getUserId();

		CMN_API_InboundTestHelper.setupRestContext(dtoRequest);

		Test.startTest();

		SVC_URL_Prediction.processPredictions();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.findByServiceName(SVC_API_UpdatePrediction.SERVICE_NAME);

		Boolean statusCorrect = CMN_DAL_WebserviceCallQueue.STATUS_FAILED.equalsIgnoreCase(queueItems[0].CMN_Status__c);

		System.assertEquals(true, statusCorrect, 'Service does not have the correct status');
	}

	/**
	 * @description Will check that a case is updated correctly with negative sentiment
	 */
	@IsTest
	private static void negativeSentiment()
	{
		checkSentimentSetCorrectly(SVC_API_UpdatePrediction.Sentiment.NEGATIVE);
	}

	/**
	 * @description Will check that a case is updated correctly with positive sentiment
	 */
	@IsTest
	private static void positiveSentiment()
	{
		checkSentimentSetCorrectly(SVC_API_UpdatePrediction.Sentiment.POSITIVE);
	}

	/**
	 * @description Will check that a case is updated correctly with mixed sentiment
	 */
	@IsTest
	private static void mixedSentiment()
	{
		checkSentimentSetCorrectly(SVC_API_UpdatePrediction.Sentiment.MIXED);
	}

	/**
	 * @description Will check that a case is updated correctly with neutral sentiment
	 */
	@IsTest
	private static void neutralSentiment()
	{
		checkSentimentSetCorrectly(SVC_API_UpdatePrediction.Sentiment.NEUTRAL);
	}
}