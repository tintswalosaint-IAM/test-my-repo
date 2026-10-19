/**
 * This class is used as an API class for the FindOpenApplications API
 *
 * <p>DBP-1819</p>
 *
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 * DOC_API_FilenetSendNotification
 * @date Feb 15th 2021
 */

public with sharing class DOC_API_FilenetNotification extends AOB_API_RestBaseOutboundPing
{
	public static final String SERVICE_NAME = DOC_API_FilenetNotification.class
			.getName();
	@TestVisible
	private static final String FMT_JSON_OUTER_ATTR_NAME = '"acks":';
	public DOC_Document__c document;

	/**
	 * @description constructor to make sure a token is passed before making the API call
	 *
	 * @param docId
	 */
	public DOC_API_FilenetNotification(Id docId)
	{
		List<DOC_Document__c> docs =
		[
				SELECT
						id,
						AOB_Application__c,
						DOC_FileExtension__c,
						DOC_ConditionCode__c,
						DOC_ConditionDescription__c,
						DOC_Country__c,
						DOC_MasterContentId__c,
						DOC_Origin__c,
						DOC_DocumentGUID__c,
						DOC_Customer_BPGUID__c,
						DOC_Customer_BPID__c
				FROM DOC_Document__c
				WHERE id = :docId
		];
		this.accessToken = AOB_Utils.getAccessToken();
		if(!docs.isEmpty())
		{
			this.document = docs[0];
		}
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Used to parse response
	 */
	protected virtual override void parseResponse()
	{
		super.parseResponse();
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return POST
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return boolean
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected override String getServiceName()
	{
		super.getServiceName(); /* NB: Running this to cover base code method. */
		return SERVICE_NAME;
	}

	/**
	 * @description Calls the parent objects' method to ensure we get code coverage
	 *
	 * @return mock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new DOC_API_FilenetNotifMock();
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		/* do Something here with the Response DTO */
		System.debug(
				LoggingLevel.DEBUG,
				'Response Received for ' +
						getServiceName() +
						':' +
						baseResponseDTO.serialize()
		);
	}
	/**
	 * @description DTO request class
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(this.document);
	}
	/**
	 * @description populate Request DTO
	 */
	public override void populateRequestDTO()
	{
		super.populateRequestDTO();
	}
	/**
	 * @description Response DTO
	 */
	@TestVisible
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<Acks> acks = new List<Acks>();
		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}
	/**
	 * @description AcKs class
	 */
	public class Acks
	{
		public NotificationsResponse notificationsResponse;
	}
	/**
	 * @description NotificationsResponse class
	 */
	public class NotificationsResponse
	{
		public String Ack;
	}
	/**
	 * @description Override to inject JSON outer class in API response
	 *
	 * @return String Response body
	 */
	protected override String getResponseBody()
	{
		String responseBody = super.getResponseBody();
		return '{' + FMT_JSON_OUTER_ATTR_NAME + responseBody + '}';
	}
	/**
	 * @description Filenet Notification Mock
	 */
	public class DOC_API_FilenetNotifMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String valideResponse = '[{"notificationsResponse":{"Ack":"Request recieved"}}]';

		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(valideResponse);
		}
	}
}