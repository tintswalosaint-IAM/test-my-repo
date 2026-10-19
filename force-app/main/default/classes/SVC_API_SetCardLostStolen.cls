/**
 * @description API and DTO to facilitate the callout of the ATM Card Lost or Stolen
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class SVC_API_SetCardLostStolen extends SVC_API_PingOutboundBase
{
	private static final String ORIGINATOR_CUSTOMER_FIRST = 'CFRST';
	private static final String PARAMETER_CARD_NUMBER = 'cardNumber';
	private static final String PARAMETER_DATE_STOLEN = 'cardDateStolen';
	private static final String PARAMETER_IS_BRANCH_DELIVERY = 'isBranchDelivery';
	private static final String PARAMETER_DELIVERY_CENTER = 'cardDeliveryCenter';
	private static final String PARAMETER_USER = 'userId';
	private static final String PARAMETER_ADDRESS_LINE1 = 'faceToFaceAddressLine1';
	private static final String PARAMETER_ADDRESS_LINE2 = 'faceToFaceAddressLine2';
	private static final String PARAMETER_ADDRESS_LINE3 = 'faceToFaceAddressLine3';
	private static final String PARAMETER_ADDRESS_LINE4 = 'faceToFaceAddressLine4';
	private static final String PARAMETER_POSTAL_CODE = 'faceToFaceAddressPostalCode';

	@TestVisible
	private static final Set<String> REQUIRED_PARAMETERS = new Set<String> {PARAMETER_CARD_NUMBER, PARAMETER_USER, PARAMETER_DATE_STOLEN, PARAMETER_DELIVERY_CENTER, PARAMETER_IS_BRANCH_DELIVERY};

	@TestVisible
	private static final String SERVICE_NAME = SVC_API_SetCardLostStolen.class.getName();

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
		return new SVC_API_SetCardLostStolenMock();
	}

	/**
	 * @description The Request DTO to be sent for retrieve Cards
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String cardNumber;
		//Appears to be hard code for this request...
		public String originator = ORIGINATOR_CUSTOMER_FIRST;
		public String userId;
		public String cardDateStolen;
		public String cardDeliveryCenter;
		public Boolean isBranchDelivery;
		public String faceToFaceAddressLine1;
		public String faceToFaceAddressLine2;
		public String faceToFaceAddressLine3;
		public String faceToFaceAddressLine4;
		public String faceToFaceAddressPostalCode;

		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			cardNumber = dtoRequestParameters.getFirst(PARAMETER_CARD_NUMBER);
			userId = dtoRequestParameters.getFirst(PARAMETER_USER);
			cardDateStolen = dtoRequestParameters.getFirst(PARAMETER_DATE_STOLEN);
			cardDeliveryCenter = dtoRequestParameters.getFirst(PARAMETER_DELIVERY_CENTER);
			isBranchDelivery = Boolean.valueOf(dtoRequestParameters.getFirst(PARAMETER_IS_BRANCH_DELIVERY));
			faceToFaceAddressLine1 = dtoRequestParameters.getFirst(PARAMETER_ADDRESS_LINE1);
			faceToFaceAddressLine2 = dtoRequestParameters.getFirst(PARAMETER_ADDRESS_LINE2);
			faceToFaceAddressLine3 = dtoRequestParameters.getFirst(PARAMETER_ADDRESS_LINE3);
			faceToFaceAddressLine4 = dtoRequestParameters.getFirst(PARAMETER_ADDRESS_LINE4);
			faceToFaceAddressPostalCode = dtoRequestParameters.getFirst(PARAMETER_POSTAL_CODE);
		}
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		Integer code;
		String message;

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
	private class SVC_API_SetCardLostStolenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"code":203,"message":"ACCOUNT ALREADY TRANSFERRED TO REPLACEMENT ACCOUNT"}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}