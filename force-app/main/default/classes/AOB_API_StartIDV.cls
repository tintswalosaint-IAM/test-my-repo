/**
 * @description Class used to Perform an API call to start IDV
 * <p/>
 * <p>DBP-1459</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Dec 23th 2020
 * 
 * <p>SFP-11823</p> 
 * @author Mark Bailey 
 * @date 09 May 2022 
 * @description Use a different callback API (respondToAddress URL)
 */
public with sharing class AOB_API_StartIDV extends AOB_API_RestBaseOutboundPing
{
	public static final String SERVICE_NAME = AOB_API_StartIDV.class.getName();
	public String idNumber;
	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *
	 * @param idNum
	 * @param applicationId
	 */
	public AOB_API_StartIDV(String idNum, String applicationId)
	{
		accessToken = AOB_Utils.getAccessToken();
		this.idNumber = idNum;
		this.applicationId = applicationId;
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
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_StartIDVMock();
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

	private with sharing class DTO_Body
	{
		public String identificationReasonCode;
		public List<CustomerIdentity> customerIdentity;
		public String fullName;
		public String surname;
		public String channel;
		public String deviceId;
		public String respondToAddress;

		/**
	     * @description method used to format the body of the request
		 * @param idNumber customers ID Number
		 * @param applicationId applicationId to update
		 * @param channel consuming channel - SBG
	     */
		public DTO_Body(String idNumber, String applicationId, string channel)
		{
			List<Account> accs =
			[
					SELECT id,
							firstname,
							lastname
					FROM Account
					WHERE
							id IN
							(
									SELECT AccountId
									FROM user
									WHERE id = :UserInfo.getUserId()
							)
			];
			List<AOB_Application__c> app =
			[
					SELECT id
					FROM AOB_Application__c
					WHERE id = :applicationId
			];
			if(!accs.isEmpty())
			{
				fullName = accs[0].firstName;
				surname = accs[0].lastname;
			}
			customerIdentity = new List<customerIdentity>
			{
					new customerIdentity(idNumber)
			};

			String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
			if(!app.isEmpty())
			{
				this.respondToAddress = baseUrl + '/services/apexrest/v1/wfrNotify/' + applicationId;
			}
			this.channel = 'SBG_SF';
			deviceId = '';
			identificationReasonCode = AOB_Constants.WFR_DEFAULT_CODE;
		}
	}

	/**
	 * @description method used to format ID Number details in Request Body
	 */
	public class CustomerIdentity
	{
		public String idType;
		public String idNumber;
		/**
	     * @description method for ID Number
		 * @param idNumber the customers ID Number
	     */
		public CustomerIdentity(string idNumber)
		{
			this.idType = '01';
			this.idNumber = idNumber; //Id number of the customer
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
		return HTTP_VERB_POST;
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

	/**
	 * @description class for formatting of response
	 *
	 * @return
	 */
	@TestVisible
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		@AuraEnabled
		public string correlationId;
		@AuraEnabled
		public string statusReason;
		@AuraEnabled
		public string statusCode;
		@AuraEnabled
		public string processRefId;
		@AuraEnabled
		public string nonSuccessResponse;
		/**
	     * @description class for formatting of response
	     */
		public DTO_Response()
		{
		}
		/**
	     * @description class for formatting of response
		 * @param msg message
	     */
		public DTO_Response(string msg)
		{
			this.nonSuccessResponse = msg;
		}

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
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(
				new DTO_Body(
						this.idNumber,
						this.applicationId,
						settings.AOB_DefaultChannel__c
				)
		);
	}

	/**
	 * @description class to test mock response
	 *
	 * @return
	 */
	public class AOB_API_StartIDVMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String validResponse = '{"type":"NATIONAL IDENTITY DOCUMENT","number":"7602125236089","issuingCountry":"ZA","issuedDate":"","expirationDate":""}';

		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}