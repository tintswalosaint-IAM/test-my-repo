/**
 * @description This class is used as an API class for the OTP API
 * <p/>
 * <p>DBP-1450</p>
 *
 * @author (aessbai@salesforce.com)
 *
 * @date Dec 21th 2020
 */
public virtual class AOB_API_OTP extends CMN_API_HttpBaseOutbound
{
	public string jsonBody;
	public string responseBody;
	public string accessToken;
	public static final String HTTP_HEADER_CHANNELID = 'x-channel-id';

	public static final String SERVICE_NAME = AOB_API_OTP.class.getName();

	/**
	 * @description constructor to make sure a token is passed before making the API call
	 */
	public AOB_API_OTP()
	{
		this.accessToken = AOB_Utils.getAccessToken();
	}
	/**
	 * @description Used to set the Http Request Headers
	 */
	protected virtual override void setHeaders()
	{
		super.setHeaders();
		request.setHeader(HTTP_CONTENT_TYPE, AOB_Constants.HTTP_ENCODING_XML);
		request.setHeader(HTTP_HEADER_ACCEPT, AOB_Constants.HTTP_ENCODING_XML);
		request.setHeader(
				HTTP_HEADER_CERTIFICATE,
				AOB_Constants.API_TESTCERTIFICATE
		);
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CLIENTID, settings.CMN_ClientID__c);
		request.setHeader(HTTP_HEADER_CLIENTSECRET, settings.CMN_Client_Secret__c);
		request.setHeader(HTTP_HEADER_CORRELATION, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CHANNELID, settings.AOB_DefaultChannel__c);
		String authString = this.accessToken;
		if(String.isNotEmpty(authString))
		{
			request.setHeader(HTTP_HEADER_AUTHORIZATION, authString);
		}
	}

	/**
	 * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
	 * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
	 * We are doing this to support unit tests
	 */
	protected override void populateRequestDTO()
	{
		if(!String.isBlank(jsonBody))
			request.setBody(jsonBody);
	}
	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		PageReference staticTemplate = new PageReference(
				'/resource/AOB_OTP_Request'
		);
		Blob content;
		if(Test.isRunningTest())
		{
			content = Blob.valueOf('MockContent');
		}
		else
		{
			content = staticTemplate.getContent();
		}
		jsonBody = content.toString();
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return
	 */
	@testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
	 */
	@testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
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
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();
		populateRequestDTO();
		return queueItem.CMN_Request__c != null
				? queueItem.CMN_Request__c
				: jsonBody;
	}

	/**
	 * @description Calls the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_OTPMock();
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		/* do Something here with the Response DTO */
		System.debug(
				LoggingLevel.DEBUG,
				'Response Received for ' +
						getServiceName() +
						':' +
						responseBody
		);
	}
	/**
	 * @description Used to get response Body
	 *
	 * @return
	 */
	protected override String getResponseBody()
	{
		return response.getBody();
	}

	/**
	 * @description Calls the parent objects method to customize the parse
	 */
	protected virtual override void parseResponse()
	{
		super.parseResponse();
		responseBody = getResponseBody();
	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public string response;
		public DTO_Response(string resp)
		{
			this.response = resp;
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
	 * @description HTTP Character encoding, override if you want to define custom content encoding for service
	 *
	 * @return result
	 */
	public virtual override String getEncoding()
	{
		return AOB_Constants.HTTP_ENCODING_XML;
	}

	public class AOB_API_OTPMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String VALID_RESPONSE = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://www.VERSIONR.VBOTPBRI.Request.com" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><VERSIONROperationResponse xmlns="http://www.VERSIONR.VBOTPBRI.Response.com"><vers_v_version_data><vers_v_trancode>VBOB</vers_v_trancode><vers_v_version>5</vers_v_version><vers_v_token></vers_v_token><vers_v_cardno>0</vers_v_cardno><vers_v_channel_id>MAPP</vers_v_channel_id><vers_v_user_id>0026</vers_v_user_id><vers_v_user_ibt>4586</vers_v_user_ibt><vers_v_response_code>2001</vers_v_response_code><vers_v_digital_uid> </vers_v_digital_uid></vers_v_version_data><otp_data><otp_function_id>VAL</otp_function_id><otp_otp>13182</otp_otp><otp_delivery_type>E</otp_delivery_type><otp_country_code>27     </otp_country_code><otp_cell_no></otp_cell_no><otp_email_address>test@standardbank.co.za </otp_email_address><otp_qname>MAPPOTP020010885</otp_qname><otp_msg_type>SIGNCD</otp_msg_type><otp_msg_content>Credit Card                                                                                                                                                                                                                                                                                                                   </otp_msg_content></otp_data></VERSIONROperationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
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