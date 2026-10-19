/**
 * @description Provides an inbound API to receive the results of a Natural Language Processing prediction request
 *
 * @author Accenture
 *
 * @date December 2020
 */
public inherited sharing class SVC_API_UpdatePrediction extends CMN_API_RestBaseInbound
{
	public static final String SERVICE_NAME = SVC_API_UpdatePrediction.class.getName();

	private static final String ERROR_INVALID_OBJECT_TYPE = 'Object type "{0}" not supported';
	@TestVisible
	private static final String ERROR_OBJECT_ID_MISSING = '"objectId" is a required field when processing a prediction result';
	@TestVisible
	private static final String ERROR_OBJECT_NOT_FOUND = 'Object could not be found for the objectId provided';
	private static final String DEBUG_SERVICE_TYPE_NOT_FOUND = 'Service Type: "{0}" not found for Case Id: "{1}"';
	private static final String DEBUG_SERVICE_TYPE_FOUND = 'Service Type: "{0}" found for Case Id: "{1}"';

	public enum Sentiment
	{
		POSITIVE, NEGATIVE, MIXED, NEUTRAL
	}

	private static final Map<String, Sentiment> SENTIMENT_MAP = new Map<String, Sentiment>
	{
			Sentiment.POSITIVE.name() => Sentiment.POSITIVE,
			Sentiment.NEGATIVE.name() => Sentiment.NEGATIVE,
			Sentiment.MIXED.name() => Sentiment.MIXED,
			Sentiment.NEUTRAL.name() => Sentiment.NEUTRAL
	};

	/**
	 * @description Initialise variable Object variables
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description register all the object types we want to update
	 */
	protected override void setUnitOfWorksObjectTypes()
	{
		super.setUnitOfWorksObjectTypes();
		addSObjectTypes(new List<Schema.SObjectType> {SVC_ServiceType__c.SObjectType, Case.SObjectType});
	}

	/**
	 * @description Will check that the information received is valid and query any related data
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		//Check we are given an ID
		if(dtoRequest.objectId == null)
		{
			throw new SObjectException(ERROR_OBJECT_ID_MISSING);
		}

		SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(dtoRequest.objectId);

		//Current we can only handle prediction results for the case object
		if(objectType != Case.SObjectType)
		{
			String objectName = objectType?.getDescribe().getLocalName();
			String error = String.format(ERROR_INVALID_OBJECT_TYPE, new List<String> {objectName});
			throw new SObjectException(error);
		}

		//Make sure the ID we are given is for an existing Case
		if(SVC_DAL_Case.findById(dtoRequest.objectId) == null)
		{
			throw new SearchException(ERROR_OBJECT_NOT_FOUND);
		}
	}

	/**
	 * @description Will take information provided and either update or insert cases provided,
	 * if provided transcript will be stored against related activity
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		Case updateCase = new Case(Id = dtoRequest.objectId);

		if(dtoRequest.intentPrediction?.labels != null && !dtoRequest.intentPrediction.labels.isEmpty())
		{
			String externalId = dtoRequest.intentPrediction.labels[0].name;

			SVC_ServiceType__c foundServiceType = SVC_DAL_ServiceType.findByExternalId(externalId);

			if(foundServiceType != null)
			{
				updateCase.SVC_ServiceType__c = foundServiceType.Id;
			}

			//Ensure that we indicate if we were able to match and set the service type
			String warningMessage = String.isBlank(updateCase.SVC_ServiceType__c) ? DEBUG_SERVICE_TYPE_NOT_FOUND : DEBUG_SERVICE_TYPE_FOUND;
			String.format(warningMessage, new List<String> {externalId, dtoRequest.objectId});

			CMN_UTIL_Logger.debug(warningMessage, 'SVC_API_UpdatePrediction/registerDatabaseChanges');
		}

		updateCase.SVC_Sentiment__c = dtoRequest.sentimentAnalysis?.sentiment;

		Decimal sentimentScore;

		switch on SENTIMENT_MAP.get(updateCase.SVC_Sentiment__c)
		{
			when POSITIVE
			{
				sentimentScore = dtoRequest.sentimentAnalysis.sentimentScore.positive;
			}
			when NEGATIVE
			{
				sentimentScore = dtoRequest.sentimentAnalysis.sentimentScore.negative;
			}
			when MIXED
			{
				sentimentScore = dtoRequest.sentimentAnalysis.sentimentScore.mixed;
			}
			when NEUTRAL
			{
				sentimentScore = dtoRequest.sentimentAnalysis.sentimentScore.neutral;
			}
		}

		updateCase.SVC_SentimentScore__c = sentimentScore == null ? sentimentScore : sentimentScore * 100;
		updateCase.SVC_PotentialSpam__c = dtoRequest.isSpam == null ? updateCase.SVC_PotentialSpam__c : dtoRequest.isSpam;

		registerDirty(updateCase);

		//Also set the queueItem triggering object Id for easy navigation to the case if debugging
		queueItem.CMN_TriggeringObjectId__c = updateCase.Id;
	}

	/**
	 * @description Response DTO which will indicate if the prediction results were processed successfully
	 */
	@TestVisible
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String message = 'Prediction processed successfully';
	}

	/**
	 * @description Request DTO which contains a the result of a prediction for an object
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public Id objectId; //The object for which the prediction was made
		public Boolean isSpam; //Indicates if the prediction is classifying the information provided as potential spam
		public DTO_IntentPrediction intentPrediction;
		public DTO_SentimentAnalysis sentimentAnalysis;
		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Request.class;
		}
	}

	/**
	 * @description Has the list of intents predicted with relative probabilities for each prediction
	 */
	@TestVisible
	private class DTO_IntentPrediction
	{
		public List<DTO_Label> labels;
	}

	/**
	 * @description Label for the prediction
	 */
	@TestVisible
	private class DTO_Label
	{
		public String name;
		public Decimal score;
	}

	/**
	 * @description Contains sentiment analysis for the prediction
	 */
	@TestVisible
	private class DTO_SentimentAnalysis
	{
		public String sentiment;
		public DTO_SentimentScore sentimentScore = new DTO_SentimentScore();
	}

	/**
	 * @description The relative probabilities for each sentiment
	 */
	@TestVisible
	private class DTO_SentimentScore
	{
		public Decimal mixed;
		public Decimal negative;
		public Decimal neutral;
		public Decimal positive;
	}

}