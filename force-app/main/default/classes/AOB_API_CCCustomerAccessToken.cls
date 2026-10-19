/**
 * @description This class is used as an API class for OCAPI Connector
 * <p/>
 * <p>DBP-2071-2073-2074-2076</p>
 *
 * @author (aessbai@salesforce.com)
 *
 * @date Feb 05th 2021
 */
public virtual class AOB_API_CCCustomerAccessToken extends CMN_API_RestBaseOutbound
{
	public static final String SERVICE_NAME = AOB_API_CCCustomerAccessToken.class
			.getName();
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';

	public string accessToken;

  /**
	 * @description constructor to make sure a token is passed before making the API call
	 *
	 * @param token
	 */
	public AOB_API_CCCustomerAccessToken(String token)
	{
		this.accessToken = token;
	}
  /**
	 * @description Return the string concatenation of the basic authentication type
	 *
	 * @return result
	 */
	protected override String getAuthorisationToken()
	{
		return String.isBlank(accessToken)
				? CMN_UTIL_String.EMPTY
				: HTTP_HEADER_AUTH_BEARER + accessToken;
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
		string ccCustomerId;
		List<Account> accounts =
		[
				SELECT id,
						AOB_TECH_CCCustomerId__c
				FROM Account
				WHERE id IN
				(
						SELECT AccountId
						FROM user
						WHERE id = :UserInfo.getUserId()
				)
		];

		if(
				settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)
				)
		{
			if(!String.isBlank(accounts[0].AOB_TECH_CCCustomerId__c))
			{
				ccCustomerId =
						accounts[0].AOB_TECH_CCCustomerId__c + settings.AOB_AddPath__c;
			}
			string path = String.isNotBlank(settings.CMN_Path__c)
					? settings.CMN_Path__c
					: CMN_UTIL_String.EMPTY;
			path += String.isNotBlank(ccCustomerId)
					? ccCustomerId
					: CMN_UTIL_String.EMPTY;
			endPoint = String.format(
					NAMED_CREDENTIAL_URL_FORMAT,
					new List<String>
					{
							settings.CMN_NamedCredential__c,
							String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
					}
			);
		}
		return endPoint;
	}

  /**
	 * @description Method will get response header
	 *
	 * @return Authorisation
	 */
	public String getHeaderAuth()
	{
		//get the list of header names (keys)
		string[] headerkeys = response.getHeaderKeys();

		//create an object to store your header key-value pairs
		Map<string, string> headers = new Map<string, string>();

		//iterate through they keys, and populate your map
		for(string s : headerkeys)
		{
			headers.put(s, response.getHeader(s));
		}
		String header = headers.get('Authorization');
		if(header == null)
		{
			header = headers.get('authorization');
		}
		CMN_UTIL_Logger.debug(header, SERVICE_NAME);
		return header;
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
		return HTTP_ENCODING_JSON;
	}
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}
  /**
	 * @description Overriding parent class method to use the right API Method°
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}
  /**
	 * @description Mock
	 */
	private class AOB_API_CCCustomerAccessTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"_v":"20.8","_type":"customer","auth_type":"registered","creation_date":"2021-02-15T05:24:20.948Z","customer_id":"abH5Do5rfNuEWTAAa9WZGdiiES","customer_no":"00003501","email":"aminesomakd@gmail.com","enabled":true,"first_name":"Amine","last_login_time":"2021-02-15T05:24:20.983Z","last_modified":"2021-02-15T05:24:20.987Z","last_name":"KOUDRI","last_visit_time":"2021-02-15T05:24:20.983Z","login":"aminesomakd@gmail.com","phone_home":"9234567890","previous_login_time":"2021-02-15T05:24:20.983Z","previous_visit_time":"2021-02-15T05:24:20.983Z"}';
		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setHeader('Authorization', 'test');
			response.setHeader('authorization', 'test');
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
		return new AOB_API_CCCustomerAccessTokenMock();
	}
}