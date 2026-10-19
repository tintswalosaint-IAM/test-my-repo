/**
 * @description Base web service handler for soft block API's which only differ with HTTP verb
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing virtual class SVC_API_SoftBlockBase extends SVC_API_PingOutboundBase
{
	private static final String ORIGINATOR_CUSTOMER_FIRST = 'CFRST';
	private static final String PARAMETER_CARD_NUMBER = 'cardNumber';
	private static final String PARAMETER_USER = 'userId';

	@TestVisible
	private static final Set<String> REQUIRED_PARAMETERS = new Set<String> {PARAMETER_CARD_NUMBER, PARAMETER_USER};

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
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_SoftBlockBaseMock();
	}

	/**
	 * @description The Request DTO to be sent for retrieve Cards
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String cardNumber;
		//Appears to be hardcode
		public String originator = ORIGINATOR_CUSTOMER_FIRST;
		public String userId;

		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			cardNumber = dtoRequestParameters.getFirst(PARAMETER_CARD_NUMBER);
			userId = dtoRequestParameters.getFirst(PARAMETER_USER);
		}
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public String status;
		public String statusCode;

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
	private class SVC_API_SoftBlockBaseMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"status": "SUCCESS", "statusCode": 200}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}