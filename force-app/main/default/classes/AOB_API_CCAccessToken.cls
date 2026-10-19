/**
 * @description This class is used as an API class for OCAPI Connector
 * <p/>
 * <p>DBP-2071-2073-2074-2076</p>
 *
 * @author (aessbai@salesforce.com)
 *
 * @date Feb 05th 2021
 */
public virtual class AOB_API_CCAccessToken extends CMN_API_RestBaseOutbound
{
	public static final String SERVICE_NAME = AOB_API_CCAccessToken.class.getName();
	public static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	public static final String GRANT_TYPE = 'grant_type=urn:demandware:params:oauth:grant-type:client-id:dwsid:dwsecuretoken';

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();
		return GRANT_TYPE;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected override String getWebServiceEndPoint()
	{
		String endPoint;
		string path = String.isNotBlank(settings.CMN_Path__c)
				? settings.CMN_Path__c
				: CMN_UTIL_String.EMPTY;
		path += String.isNotBlank(settings.CMN_ClientID__c)
				? settings.CMN_ClientID__c
				: CMN_UTIL_String.EMPTY;
		endPoint = String.format(
				NAMED_CREDENTIAL_URL_FORMAT,
				new List<String>
				{
						settings.CMN_NamedCredential__c,
						String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
				}
		);
		return endPoint;
	}

	/**
	 * @description Return the string concatenation of the basic authentication type
	 *
	 * @return result
	 */
	protected override String getAuthorisationToken()
	{
		String authorization = EncodingUtil.base64Encode(
				Blob.valueOf(
						settings.CMN_Username__c +
								':' +
								settings.CMN_Password__c +
								':' +
								settings.CMN_Client_Secret__c
				)
		);
		return HTTP_HEADER_AUTH_BASIC + authorization;
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
	}

	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public string access_token;
		public string expires_in;
		public string token_type;

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
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return result
	 */
	public override virtual String getEncoding()
	{
		return HTTP_ENCODING_URL;
	}
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}
	/**
	 * @description Mock
	 */
	private class AOB_API_CCAccessTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"access_token":"9ee85811-033a-40ba-808a-1cdac0e5a128","expires_in":898,"token_type":"Bearer"}';
		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
	/**
	 * @description Set Mock
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		/* Call the parent objects' method to ensure we get code coverage */
		super.getEndpointMock();
		return new AOB_API_CCAccessTokenMock();
	}
}