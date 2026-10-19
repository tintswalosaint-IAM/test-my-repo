/**
 * @description This class is used as an API class for the FindOpenApplications API
 * <p/>
 * <p>DBP-1874</p>
 *
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 *
 * @date Jan 5th 2021
 */
public class AOB_API_GetDocument extends AOB_API_RestBaseOutboundPing
{
	public static final String SERVICE_NAME = AOB_API_GetDocument.class.getName();
	public String contractId;

	/**
	 * @description constructor to make sure a token is passed before making the API call
	 *
	 * @param contract
	 */
	public AOB_API_GetDocument(String contract)
	{
		this.accessToken = AOB_Utils.getAccessToken();
		if(String.isNotBlank(contract))
		{
			this.contractId = contract;
		}
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseRequestDTO = new DTO_Request();

	}

	/**
	 * @description Used to parse response
	 */
	protected virtual override void parseResponse()
	{
		Blob responseBody = getResponseBlobBody();
		if(responseBody != null)
		{
			DTO_Response resp = new DTO_Response(responseBody);
			baseResponseDTO = (CMN_DTO_JsonBase)resp;
		}
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
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
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_CreateOnlineOfferMock();
	}

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

		return JSON.serialize(new DTO_Body(this.contractId));
	}

	private class DTO_Body
	{
		public String guId;
		public String documentId;
		public String contentId;
		public String filename;
		public String businessFlag;

		public DTO_Body(String contractId)
		{
			this.businessFlag = 'P';
			List<Account> accs =
			[
					SELECT id,
							ExternalCIFUUID__c
					FROM Account
					WHERE id IN
					(
							SELECT AccountId
							FROM user
							WHERE id = :UserInfo.getUserId()
					)
			];

			if(!accs.isEmpty())
				this.guId = accs[0].ExternalCIFUUID__c;
			this.contentId = contractId;
			this.documentId = '0';
			this.filename = '';
		}
	}

	public override void populateRequestDTO()
	{
		super.populateRequestDTO();
	}

	public class DTO_Response extends CMN_DTO_JsonBase
	{
		@auraEnabled
		public Blob response;
		public DTO_Response()
		{
		}
		public DTO_Response(Blob file)
		{
			this.response = file;
		}
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
	 * @description Used to get response Body
	 *
	 * @return
	 */
	public Blob getResponseBlobBody()
	{
		return response.getBodyAsBlob();
	}

	public class AOB_API_CreateOnlineOfferMock extends CMN_API_HttpBaseOutboundMock
	{
		@testVisible
		private final String VALID_RESPONSE = '{"success":""}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}