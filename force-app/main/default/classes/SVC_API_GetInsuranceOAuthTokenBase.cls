/**
 * @description Outbound Service class to retrieve an OAuth Token; this is used by several services but
 * expected to be eventually deprecated with PING
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions') // Required in non standard format for external API
public virtual inherited sharing class SVC_API_GetInsuranceOAuthTokenBase extends CMN_API_RestBaseOutbound
{
	/**
	 * @description Set this true to generate an unauthorised HTTP whilst attempting to get an access token
	 */
	@TestVisible
	private static Boolean simulateGetAccessTokenFailed = false;

	/**
	 * @description Set this static variable so the class knows not to perform an commits as its being run embedded in another service class request
	 */
	public static Boolean runAsEmbedded = false;
	private static final String REQUEST_BODY = 'grant_type=client_credentials&scope=policy prod retail';

	/**
	 * @description Returns the accessToken retrieved
	 */
	public String accessToken
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).access_token;
		}
	}

	/**
	 * @description The number of seconds the token expires in
	 */
	public Integer expiresIn
	{
		get
		{
			return ((DTO_Response)baseResponseDTO).expires_in;
		}
	}

	/**
	 * @description The client Certificate to use
	 */
	public String clientCertificate
	{
		get
		{
			String clientCertificate = getAdditionalKey();
			CMN_UTIL_Logger.debug('Client Certificate: ' + clientCertificate, 'SVC_API_GetInsuranceOAuthTokenBase/clientCertificate');
			return clientCertificate;
		}
	}

	/**
	 * @description Retrieves current Service Client Id
	 *
	 * @return The client id
	 */
	public override String getClientId()
	{
		return super.getClientId();
	}

	/**
	 * @description Retrieves current Service Client Secret
	 *
	 * @return The client id
	 */
	public override String getClientSecret()
	{
		return super.getClientSecret();
	}

	/**
	 * @description Override of base commit method which will check to see if this service is running embedded in another service, if so it won't commit it's queue item
	 */
	public override void commitWork()
	{
		if(!runAsEmbedded)
		{
			super.commitWork();
		}
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

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
	 * @description Returns the mock endpoint for testing purposes
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new SVC_API_GetOAuthTokenMock();
	}

	/**
	 * @description HTTP Content encoding
	 *
	 * @return The relevant Encoding type
	 */
	public override String getEncoding()
	{
		return HTTP_ENCODING_FORM_URL_ENCODED;
	}

	/**
	 * @description Override the setting of the headers to include client certificate
	 */
	protected override void setHeaders()
	{
		super.setHeaders();
		request.setHeader(HTTP_HEADER_X_CLIENT_CERTIFICATE, clientCertificate);
	}

	/**
	 * @description Will populate the body of the request appropriately
	 *
	 * @return request body
	 */
	protected virtual override String getBody()
	{
		return REQUEST_BODY;
	}
	/**
	 * @description DTO_Response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public String token_type;
		public String access_token;
		public Integer expires_in;
		public Decimal consented_on;
		public String scope;

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
	@TestVisible
	private class SVC_API_GetOAuthTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"token_type":"Bearer","access_token":"AAIkMGM2OGNiYTUtZTFlMi00MzE3LWE2ZjctNDkwYzZhM2ViNjEwqZJz7M2W87mcNq41yr-ayWmWsimqRNfpm9cfnw6zW29L6jcnkMCEIPrBUOoD3QMfeolLMrhppPa25NzgnVpL6sCz0COdyboM5bbsbwVwhJFtkbowloIFUwyEspXoFpl6","expires_in":3600,"consented_on":1610027743,"scope":"policy"}';
		private final String unAuthorizedResponse = '{ "httpCode":"401", "httpMessage":"Unauthorized", "moreInformation":"This server could not verify that you are authorized to access the URL" }';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);

			if(simulateGetAccessTokenFailed)
			{
				response.setStatusCode(CMN_API_HttpBase.HTTP_UNAUTHORISED);
				response.setStatus(CMN_API_HttpBase.ERR_INTERNAL_UNAUTHORISED);
				response.setBody(unAuthorizedResponse);
			}
			else
			{
				response.setBody(validResponse);
			}
		}
	}
}