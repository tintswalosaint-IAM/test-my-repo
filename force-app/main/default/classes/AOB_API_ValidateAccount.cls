/**
 * @description Class used to Perform an API call to validate account Number
 * <p/>
 * <p>DBP-2053</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Jan 20th 2020
 */
public class AOB_API_ValidateAccount extends AOB_API_RestBaseOutboundPing
{
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	public static final String SERVICE_NAME = AOB_API_ValidateAccount.class
			.getName();

	public String branchCode;
	public String accountNumber;

	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *
	 * @param branchCode
	 * @param accountNumber
	 */
	public AOB_API_ValidateAccount(String branchCode, String accountNumber)
	{
		accessToken = AOB_Utils.getAccessToken();
		this.accountNumber = accountNumber;
		this.branchCode = branchCode;
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
	public override String getResponseBody()
	{
		String responseBody = super.getResponseBody();
		//We have to inject a JSON outer class because we are receiving an Array Response
		return responseBody;
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
		if(
				settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)
				)
		{
			String path = String.isNotBlank(settings.CMN_Path__c)
					? settings.CMN_Path__c
					: CMN_UTIL_String.EMPTY;
			path +=
					'?branchCode=' +
							this.branchCode +
							'&accountNumber=' +
							this.accountNumber;
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
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_ValidateAccountMock();
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

	/**
	 * @description method used to set API call Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
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
		@AuraEnabled
		public string accountType;
		@AuraEnabled
		public string ValidationStatus;
		@AuraEnabled
		public string ValidationText;
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

	public class AOB_API_ValidateAccountMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = '{"type":"NATIONAL IDENTITY DOCUMENT","number":"7602125236089","issuingCountry":"ZA","issuedDate":"","expirationDate":""}';

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