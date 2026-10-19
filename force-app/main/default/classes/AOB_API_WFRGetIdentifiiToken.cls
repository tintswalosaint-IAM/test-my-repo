public with sharing class AOB_API_WFRGetIdentifiiToken extends AOB_API_RestBaseOutboundPing
{
	@TestVisible
	private static final String FMT_JSON_OUTER_ATTR_NAME = '"response":"';
	public static final String SERVICE_NAME = AOB_API_WFRGetIdentifiiToken.class
			.getName();
	public String idNumber;
	public String clientReference;
	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *
	 * @param idNum
	 * @param correlationId
	 */
	public AOB_API_WFRGetIdentifiiToken(String idNum, string correlationId)
	{
		accessToken = AOB_Utils.getAccessToken();
		this.idNumber = idNum;
		this.clientReference = correlationId;
	}

	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to inject JSON outer class in API response
	 *
	 * @return String Response body
	 */
	protected override String getResponseBody()
	{
		String responseBody = super.getResponseBody();

		//We have to inject a JSON outer class because we are receiving an Array Response
		return '{' + FMT_JSON_OUTER_ATTR_NAME + responseBody + '"}';
	}

	/**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_PersonalDetailsMock();
	}

	/**
	 * @description method used to initialise the api call
	 */
	protected override void initialise()
	{
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	private class DTO_Body
	{
		private String idNumber;
		private String clientReference;
		public DTO_Body(String idnum, String clientRef)
		{
			this.idNumber = idnum;
			this.clientReference = clientRef;
		}
	}
	/**
	 * @description method used to set API call Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description method used to indicate that there is no need for a triggering object
	 *
	 * @return
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}

	@TestVisible
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public string response;
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
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(new DTO_Body(this.idNumber, this.clientReference));
	}

	/**
	 * @description Helper Method is used for parsing
	 *
	 * @param p
	 *
	 * @return
	 */
	private static List<AOB_DTO_Identifications> arrayOfIdentifications(
			System.JSONParser p
	)
	{
		List<AOB_DTO_Identifications> res = new List<AOB_DTO_Identifications>();
		if(p.getCurrentToken() == null)
			p.nextToken();
		while(p.nextToken() != System.JSONToken.END_ARRAY)
		{
			res.add(new AOB_DTO_Identifications(p));
		}
		return res;
	}

	public class AOB_API_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = 'sampleResponse';

		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}