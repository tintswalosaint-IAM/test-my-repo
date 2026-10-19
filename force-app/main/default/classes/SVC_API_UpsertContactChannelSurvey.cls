/**
 * @description Inbound REST API handler for updating the survey results
 * VCCC-2011
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class SVC_API_UpsertContactChannelSurvey extends CMN_API_RestBaseInbound
{
	private SVC_ContactChannelSurvey__c upsertSurveyResponse;

	@TestVisible
	private static final String ERROR_CONTACT_ID_WAS_NOT_PROVIDED = 'The required contact channel external Id was not provided.';
	private static final String SUCCESS_MESSAGE = 'Contact Channel Survey Updated';
	@TestVisible
	private static final String ERROR_NO_RECORD_FOUND = 'Unable to retrieve Contact Channel for the contact Id provided';

	public static final String SERVICE_NAME = SVC_API_UpsertContactChannelSurvey.class.getName();

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
		addSObjectTypes(new List<Schema.SObjectType> {SVC_ContactChannelSurvey__c.SObjectType});
	}

	/**
	 * @description Process the request by checking the request is valid and then finding item to upsert
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		if(String.isBlank(dtoRequest.contactId))
		{
			throw new SearchException(ERROR_CONTACT_ID_WAS_NOT_PROVIDED);
		}

		amazonconnect__AC_ContactChannels__c contactChannel = SVC_DAL_AcContactChannel.findByContactId(dtoRequest.contactId);

		// If Channel not found. throw error
		if(contactChannel == null)
		{
			throw new SearchException(ERROR_NO_RECORD_FOUND);
		}

		upsertSurveyResponse = SVC_DAL_ContactChannelSurvey.findSurveyResponseByContactChannelId(contactChannel.Id);

		upsertSurveyResponse = upsertSurveyResponse == null ? new SVC_ContactChannelSurvey__c() : upsertSurveyResponse;

		upsertSurveyResponse.SVC_ACContactChannel__c = contactChannel.Id;
		upsertSurveyResponse.SVC_AchievedPurpose__c = dtoRequest.answerOne;
		upsertSurveyResponse.SVC_NetPromoterScoreRating__c = dtoRequest.answerTwo;
		upsertSurveyResponse.SVC_AgentRating__c = dtoRequest.answerThree;
		upsertSurveyResponse.OwnerId = contactChannel.OwnerId;
	}

	/**
	 * @description Will take information provided and perform relevant database changes
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		registerChange(upsertSurveyResponse);
	}

	/**
	 * @description Will update Response DTO with the newly Live chat details
	 */
	protected override void updateResponseDTO()
	{
		super.updateResponseDTO();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
		dtoResponse.id = upsertSurveyResponse.Id;
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String contactId;
		public String answerOne;
		public String answerTwo;
		public String answerThree;

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
	 * @description DTO representing a successful response
	 */
	@SuppressWarnings('PMD.VariableNamingConventions') // Required in non standard format for external API
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String id;
		public Integer code = CMN_API_HttpBase.HTTP_OK;
		public String success = SUCCESS_MESSAGE;
	}
}