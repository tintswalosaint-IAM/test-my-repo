/**
 * @description Class used to Perform an API call to get Access token
 * <p/>
 * <p>DBP-1279</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 */
public with sharing class AOB_API_AccessToken extends AOB_API_AccessTokenBase
{
	public static final String SERVICE_NAME = AOB_API_AccessToken.class.getName();
	public string scope;
	public AOB_API_AccessToken(string scope)
	{
		this.scope = scope;
	}
    public AOB_API_AccessToken()
	{
		this.scope = 'retail customer prod';
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		System.debug('REMOVE THIS COMMENT');
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();

	}

	/**
	 * @description method used to set API call Method
	 *
	 * @return
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description method used to indicate that triggering object is not needed
	 *
	 * @return
	 */
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
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

		return 'grant_type=' +
				EncodingUtil.urlEncode(HTTP_BODY_GRATTYPE, UTF8_ENCODING_SCHEME) +
				'&' +
				HTTP_BODY_SCOPE +
				'=' +
				EncodingUtil.urlEncode(scope, UTF8_ENCODING_SCHEME);
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

	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		/* Call the parent objects' method to ensure we get code coverage */
		super.getEndpointMock();
		return new AOB_API_AccessTokenMock();
	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public string grant_type;
		public string scope;

	}

	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public string token_type;
		public String access_token;
		public string metadata;
		public integer expires_in;
		public integer consented_on;
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

	@testVisible
	private class AOB_API_AccessTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"token_type": "Bearer","access_token": "AAIkYzc0NmM","metadata": "m:","expires_in": 7200,"consented_on": 1606135456,"scope": "business write prod"}';
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