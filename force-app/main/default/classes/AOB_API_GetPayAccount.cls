/**
 * @description Class used to Perform an API call to get customer's personal details
 * <p/>
 * <p>DBP-1159</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 13th 2020
 */
public with sharing class AOB_API_GetPayAccount extends AOB_API_RestBaseOutboundPing
{
	public static final String SERVICE_NAME = AOB_API_GetPayAccount.class
			.getName();
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';

	/**
	 * @description constructor to make sure a token is passed before making the API call
	 */
	public AOB_API_GetPayAccount()
	{
		accessToken = AOB_Utils.getAccessToken();
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
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
	 * @description Override to set your request and response DTO types and any other globals you may have
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
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
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
		string fedId;
		List<Account> accounts =
		[
				SELECT id,
						ExternalCIFUUID__c
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
			if(!String.isBlank(accounts[0].ExternalCIFUUID__c))
			{
				fedId = accounts[0].ExternalCIFUUID__c + settings.AOB_AddPath__c;
			}
			string path = String.isNotBlank(settings.CMN_Path__c)
					? settings.CMN_Path__c
					: CMN_UTIL_String.EMPTY;
			path += String.isNotBlank(fedId) ? fedId : CMN_UTIL_String.EMPTY;
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
	 * @description Used to set the Http Request Headers
	 */
	protected virtual override void setHeaders()
	{
		super.setHeaders();
		request.setHeader('s-location', 'SBG_SF');
		request.setHeader('s-version', '0001');
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
	 */
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}

	public class DTO_Response extends CMN_DTO_JsonBase
	{
		@AuraEnabled
		public List<DTO_PayAccount> accounts;

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

	public class DTO_PayAccount
	{
		@AuraEnabled
		public String bankCtry;
		public String bankCtryiso;
		public String bankKey;
		@AuraEnabled
		public String bankAcct;
		public String ctrlKey;
		public String systemId;
		public String productId;
		public String credDebt;
	}

	public class AOB_API_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = '{"accounts":[{"bankCtry":"ZA","bankCtryiso":"ZA","bankKey":"010145","bankAcct":"0000000011890525","ctrlKey":"00","systemId":"110","productId":"9261","credDebt":"D"}]}';

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