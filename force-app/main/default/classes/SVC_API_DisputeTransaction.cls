/**
 * @description API and DTO to facilitate the callout of the Debit Order Dispute Get
 *
 * @author Accenture
 *
 * @date January 2021
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions') // Required in non standard format for external API
public inherited sharing class SVC_API_DisputeTransaction extends SVC_API_PingOutboundBase
{
	@TestVisible
	private static final String PARAMETER_ACCOUNT_NUMBER = 'account_number';
	@TestVisible
	private static final String PARAMETER_REASON = 'reason';
	@TestVisible
	private static final String PARAMETER_TRANSACTION_ID = 'transaction_id';
	private static final String PARAMETER_CARD_NUMBER = 'card_number';

	@TestVisible
	private static final String REASON_AUTHORITY = 'AUTHORITY';

	private static final Set<String> VALID_REASONS = new Set<String> {REASON_AUTHORITY, 'AMOUNT', 'CANCELLED', 'STOPPED'};
	private static final String ERROR_INVALID_REASON = 'Reason is not in the following list ' + JSON.serialize(VALID_REASONS);

	@TestVisible
	private static final String SERVICE_NAME = SVC_API_DisputeTransaction.class.getName();

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
	 * @description If there are reserved words in a particular service handler response, indicate what it should be replace with prior to de-serialisation
	 *
	 * @param searchTokens The search tokens to be found
	 * @param replaceTokens The token to replace with if matching search token is found
	 */
	protected override void getResponseReplacementTokens(List<String> searchTokens, List<String> replaceTokens)
	{
		super.getResponseReplacementTokens(searchTokens, replaceTokens);

		searchTokens.add('"exception"');
		replaceTokens.add('"exceptionMessage"');
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
	 * @description Does this API call require a triggering object id
	 *
	 * @return False, no triggering object required.
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
						new Set<String>
						{
								PARAMETER_TRANSACTION_ID, PARAMETER_ACCOUNT_NUMBER, PARAMETER_REASON
						}
				);

		return parameters;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run, requires relevant parameters to be set
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	protected override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();

		if(abort && !VALID_REASONS.contains(requestParameters.getFirst(PARAMETER_REASON)))
		{
			callResult.errors.add(ERROR_INVALID_REASON);
			abort = true;
		}

		return abort;
	}

	/**
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_DisputeMock();
	}

	/**
	 * @description The Request DTO to be sent for retrieve Cards
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public String account_number;
		public String card_number;
		public String correlation_id;
		public String reason;
		public String transaction_id;

		/**
		 * @description Will populate the DTO using combination of triggeringObjectId (if necessary) as well as request parameters
		 *
		 * @param triggeringObjectId The object that triggered outbound call (could be null)
		 * @param dtoRequestParameters A list of parameters provided
		 */
		public override void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
		{
			super.populate(triggeringObjectId, dtoRequestParameters);

			account_number = dtoRequestParameters.getFirst(PARAMETER_ACCOUNT_NUMBER);
			card_number = dtoRequestParameters.getFirst(PARAMETER_CARD_NUMBER);
			reason = dtoRequestParameters.getFirst(PARAMETER_REASON);
			transaction_id = dtoRequestParameters.getFirst(PARAMETER_TRANSACTION_ID);
			correlation_id = CMN_UTIL_Random.randomUUID();
		}
	}

	/**
	 * @description DTO Structure to format the callout response
	 */
	private class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<DTO_Error> errors;
		public List<String> messages;
		public Boolean success;

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
	 * @description Sub class of DTO_Request containing the Error information
	 */
	public class DTO_Error
	{
		public String code;
		public String exceptionMessage;
		public String message;
	}

	/**
	 * @description Mock class for returning test data
	 */
	private class SVC_API_DisputeMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"success":true,"errors":[],"messages":[]}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

}