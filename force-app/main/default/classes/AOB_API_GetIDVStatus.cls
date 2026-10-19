/**
 * @description Class used to Perform an API call to get IDV Status
 * <p/>
 * <p>DBP-1459</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Dec 23th 2020
 */
public with sharing class AOB_API_GetIDVStatus extends AOB_API_RestBaseOutboundPing
{
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	public static final String SERVICE_NAME = AOB_API_GetIDVStatus.class
			.getName();
	public String idNumber;
	/**
	 * @description constructor used to make sure a token will be provided to authenticate to the API call
	 *
	 * @param idNum
	 */
	public AOB_API_GetIDVStatus(String idNum)
	{
		accessToken = AOB_Utils.getAccessToken();
		correlationId = AOB_Utils.generateGUID();
		this.idNumber = idNum;
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

	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
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
		string identificationReasonCode = AOB_Constants.WFR_DEFAULT_CODE;
		string deviceId = '';

		if(
				settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)
				)
		{
			string path = String.isNotBlank(settings.CMN_Path__c)
					? settings.CMN_Path__c
					: CMN_UTIL_String.EMPTY;
			path +=
					'?identityNumber=' +
							this.idNumber +
							'&correlationId=' +
							this.correlationId +
							'&identificationReasonCode=' +
							identificationReasonCode +
							'&deviceId=' +
							deviceId;
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
		public onlineIdVerificationGetStatusRs onlineIdVerificationGetStatusRs;
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

	public class onlineIdVerificationGetStatusRs
	{
		string identityNumber;
		string digitalId;
		@AuraEnabled
		public string correlationId;
		string statusCode;
		@AuraEnabled
		public string statusReason;
		string deviceId;
		string state;
	}

	public class AOB_API_StartIDVMock extends CMN_API_HttpBaseOutboundMock
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