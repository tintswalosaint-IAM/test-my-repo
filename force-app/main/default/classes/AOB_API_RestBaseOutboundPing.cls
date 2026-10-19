/**
 * @description Class Used as a Template for All API calls Classes to Inherit from
 * <p/>
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 20th 2020
 */
public virtual class AOB_API_RestBaseOutboundPing extends CMN_API_RestBaseOutbound
{
	public static final String HTTP_HEADER_CLIENTID = 'x-ibm-client-id';
	public static final String HTTP_HEADER_CLIENTSECRET = 'x-ibm-client-secret';
	public static final String HTTP_HEADER_CHANNELID = 'x-channel-id';
    
    public static final String HTTP_HEADER_IBMClient = 'X-IBM-Client-Id';
    public static final String HTTP_HEADER_IBMSecret = 'X-IBM-Client-Secret';
    public static final String HTTP_HEADER_token = 'token';
     public static final String HTTP_HEADER_CERTIFICATE = 'x-client-certificate';


	public String jsonBody;
	public String accessToken;
	public String correlationId;
	public String identityNumber;
	public String applicationId; 
	
    /**
	 * @description Will return authorisation token 
	 *
	 * @return Authorisation token value
	 */
    @TestVisible
	protected override String getAuthorisationToken()
	{

		return String.isBlank(accessToken) ?
				CMN_UTIL_String.EMPTY :
				HTTP_HEADER_AUTH_BEARER + accessToken;
	}
	/**
	 * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
	 * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
	 * We are doing this to support unit tests
	 */
    @TestVisible
	protected virtual override void populateRequestDTO()
	{
		super.populateRequestDTO();
		if(!String.isBlank(jsonBody)){
			request.setBody(jsonBody);
		}
		//get current Application for this user
		List<AOB_Application__c> currentApp =
		[
				SELECT id
				FROM AOB_Application__c
				WHERE
						AOB_Customer__c IN
						(
								SELECT AccountId
								FROM User
								WHERE id = :UserInfo.getUserId()
						)order by CreatedDate desc Limit 1
		];
		if(!currentApp.isEmpty())
		{
			this.applicationId = currentApp[0].id;
		}
		if(String.isNotBlank(this.applicationId))
		{
			queueItem.CMN_TriggeringObjectId__c = this.applicationId;
		}
		baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
    @TestVisible
	protected virtual override void setHeaders()
	{
		setServiceSettings();
		if(
				String.isBlank(settings.CMN_ClientID__c) ||
						String.isBlank(settings.CMN_Client_Secret__c)
				)
            if(!Test.isRunningTest()){
			throw new AuraHandledException(Label.AOB_APIError);
            }
		super.setHeaders();
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(
				HTTP_HEADER_CERTIFICATE,
				AOB_Constants.API_TESTCERTIFICATE
		);
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
			request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
		}
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_utils.generateGUID());
		// request.setHeader(HTTP_HEADER_CLIENTID, settings.CMN_ClientID__c);
		request.setHeader(HTTP_HEADER_CLIENTID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
		request.setHeader(HTTP_HEADER_CLIENTSECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
		// request.setHeader(HTTP_HEADER_CLIENTSECRET, settings.CMN_Client_Secret__c);
		request.setHeader(HTTP_HEADER_CORRELATION, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CHANNELID, settings.AOB_DefaultChannel__c);
	}

	/**
	 * @description Used to get response Status Code
	 *
	 * @return Integer
	 */
    @TestVisible
	public virtual Integer getResponseStatusCode()
	{
		return response.getStatusCode();
	}

}