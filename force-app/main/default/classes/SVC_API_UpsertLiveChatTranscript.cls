/**
 * @description Inbound REST API handler for updating the live chat transcript and live chat visitor
 * <p/>
 *  VCCC -306, VCCC-440
 *
 * @author Accenture
 *
 * @date March 2021
 */
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public inherited sharing class SVC_API_UpsertLiveChatTranscript extends CMN_API_RestBaseInbound
{
	private LiveChatTranscript upsertLiveChatTranscript;
	private Case upsertCase;
	private amazonconnect__AC_ContactChannels__c updateContactChannel;

	private static final String SUCCESS_MESSAGE = 'Chat Transcript upserted successfully.';
	@TestVisible
	private static final String SUBJECT_INCOMPLETE = 'Incomplete Web Chat';

	private static final String VIRTUAL_AGENT_USERNAME = 'chatvirtualagent@standardbank.co.za';

	public static final String SERVICE_NAME = SVC_API_UpsertLiveChatTranscript.class.getName();

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
		addSObjectTypes(new List<Schema.SObjectType> {Case.SObjectType, LiveChatVisitor.SObjectType, LiveChatTranscript.SObjectType, amazonconnect__AC_ContactChannels__c.SObjectType});
	}

	/**
	 * @description Process the request by checking the request is valid and then finding item to upsert
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;

		if(dtoRequest.contactId != null)
		{
			//Check to see the contactId is valid
			updateContactChannel = SVC_DAL_AcContactChannel.findByContactId(dtoRequest.contactId);
			upsertCase = SVC_DAL_Case.findByAmazonConnectContactId(dtoRequest.contactId);
		}

		if(upsertCase == null)
		{
			upsertCase = new Case();

			if(dtoRequest.contactId != null)
			{
				upsertCase.amazonconnect__AC_Contact_Id__c = dtoRequest.contactId;

			}
			upsertCase.Origin = SVC_DAL_Case.ORIGIN_WEB_CHAT;
			upsertCase.Subject = SUBJECT_INCOMPLETE;
			upsertCase.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SVC_DAL_Case.RT_SERVICE_REQUEST);
			if(updateContactChannel != null)
			{
				upsertCase.OwnerId = updateContactChannel.OwnerId;
			}
			if(updateContactChannel == null)
			{
				List<User> bankerUsers = CMN_DAL_User.getAllBankerUsers();
				if(!bankerUsers.isEmpty())
				{
					for(User currentBankUser : bankerUsers)
					{
						if(currentBankUser.Username.contains(VIRTUAL_AGENT_USERNAME))
						{
							upsertCase.OwnerId = currentBankUser.Id;
						}
					}
				}
			}

			//Associate Case to a customer (if one is found)
			if(String.isNotBlank(dtoRequest.customerPBID))
			{
				//See if we can find the Related Contact based on BP ID
				Contact foundContact = SVC_DAL_Contact.findByExternalCfId(dtoRequest.customerPBID);

				upsertCase.ContactId = foundContact?.Id;
				upsertCase.AccountId = foundContact?.AccountId;
			}
		}
		else
		{
			upsertLiveChatTranscript = SVC_DAL_LiveChatTranscript.findLiveChatTranscriptByCaseId(upsertCase.Id);
		}

		if(upsertLiveChatTranscript == null)
		{
			upsertLiveChatTranscript = new LiveChatTranscript();
		}

		String encodedString = dtoRequest.chatTranscript;

		upsertLiveChatTranscript.Body = upsertLiveChatTranscript.Body == null ? encodedString : upsertLiveChatTranscript.Body + CMN_UTIL_String.LF + encodedString;
		upsertLiveChatTranscript.AccountId = upsertCase.AccountId;
		upsertLiveChatTranscript.ContactId = upsertCase.ContactId;
		upsertLiveChatTranscript.OwnerId = upsertCase.OwnerId;
	}

	/**
	 * @description Will take information provided and perform relevant database changes
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		registerChange(upsertLiveChatTranscript);

		if(upsertCase.Id == null)
		{
			registerNew(upsertCase);
			registerRelationship(upsertLiveChatTranscript, LiveChatTranscript.CaseId, upsertCase);
			//Make sure channel is linked to newly created case
			if(updateContactChannel != null)
			{
				registerRelationship(updateContactChannel, amazonconnect__AC_ContactChannels__c.amazonconnect__Case__c, upsertCase);
			}
		}
		else
		{
			upsertLiveChatTranscript.CaseId = upsertCase.Id;
		}

		if(upsertLiveChatTranscript.Id == null)
		{
			LiveChatVisitor newChatVisitor = new LiveChatVisitor();
			registerNew(newChatVisitor);
			registerRelationship(upsertLiveChatTranscript, LiveChatTranscript.LiveChatVisitorId, newChatVisitor);
		}
	}

	/**
	 * @description Will update Response DTO with the newly Live chat details
	 */
	protected override void updateResponseDTO()
	{
		super.updateResponseDTO();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		dtoResponse.chatTranscriptId = upsertLiveChatTranscript.Id;
		dtoResponse.caseId = upsertCase.Id;
	}

	/**
	 * @description The DTO representing the request being sent
	 */
	@TestVisible
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		/**
		 * @description Amazon Connect Contact ID used to identify the existing case so that transcript can be created or updated
		 */
		public String contactId;
		/**
		 * @description Chat transcript, could for an existing interaction or new one
		 */
		public String chatTranscript;
		/**
		 * @description Business Partner Id; unique Internal ID for a Customer
		 */
		public String customerPBID;

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
		/**
		 * @description Chat transcript Id, could for an existing interaction or new one
		 */
		public String chatTranscriptId;
		/**
		 * @description Case Id could for an existing case or new one
		 */
		public String caseId;
		public Integer code = CMN_API_HttpBase.HTTP_OK;
		public String Success = SUCCESS_MESSAGE;
	}
}