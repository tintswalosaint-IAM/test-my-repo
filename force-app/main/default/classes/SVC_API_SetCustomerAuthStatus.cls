/**
 * @description API and DTO to facilitate the callout of the Customer Authentication Status
 *
 * @author Accenture
 *
 * @date April 2021
 */
public inherited sharing class SVC_API_SetCustomerAuthStatus extends CMN_API_RestBaseOutbound
{
	private static final String PARAMETER_INITIAL_CONTACT_ID = 'initialContactID';
	private static final String PARAMETER_SALESFORCE_ORG_ID = 'salesforceOrgID';
	private static final String PARAMETER_IS_AUTHENTICATED = 'isAuthenticated';

	@TestVisible
	private static final Set<String> REQUIRED_PARAMETERS = new Set<String> {PARAMETER_INITIAL_CONTACT_ID, PARAMETER_SALESFORCE_ORG_ID, PARAMETER_IS_AUTHENTICATED};

	@TestVisible
	private static final String SERVICE_NAME = SVC_API_SetCustomerAuthStatus.class.getName();

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
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_SetCustomerAuthStatusMock();
	}

	/**
	 * @description Override the HTTP verb to use
	 *
	 * @return HTTP Verb
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_PUT;
	}

	/**
	 * @description Indicates whether a triggering object Id is required for the API
	 *
	 * @return A boolean indicating whether trigger object is required or not
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}

	/**
	 * @description Returns the list of required parameters need to execute the request
	 *
	 * @return A list of required service parameters
	 *
	 * @see CMN_API_HttpBaseOutbound.abortRequest
	 */
	protected override Set<String> getRequiredParameters()
	{
		Set<String> parameters = super.getRequiredParameters();

		parameters.addAll
				(
						REQUIRED_PARAMETERS
				);

		return parameters;
	}

	/**
	 * @description The Request DTO to be sent for retrieve Cards
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String initialContactID;
		public String salesforceOrgID;
		public DTO_Attributes attributes;

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			initialContactID = dtoRequestParameters.getFirst(PARAMETER_INITIAL_CONTACT_ID);
			salesforceOrgID = dtoRequestParameters.getFirst(PARAMETER_SALESFORCE_ORG_ID);

			DTO_Attributes requestAttribute = new DTO_Attributes();
			requestAttribute.isAuthenticated = Boolean.valueOf(dtoRequestParameters.getFirst(PARAMETER_IS_AUTHENTICATED));

			attributes = requestAttribute;
		}
	}

	private class DTO_Attributes
	{
		public Boolean isAuthenticated;
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String status;
		public String message;

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
	 * @description Mock class for returning test data
	 */
	private class SVC_API_SetCustomerAuthStatusMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"status": "success", "message": "Success"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}