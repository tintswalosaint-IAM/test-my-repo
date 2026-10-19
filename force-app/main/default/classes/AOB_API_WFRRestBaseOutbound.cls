/**
 * @description Class Used as a Template for All API calls Classes to Inherit from
 * <p/>
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 20th 2020
 */
public virtual class AOB_API_WFRRestBaseOutbound extends CMN_API_HttpBaseOutbound
{
	public static final String HTTP_HEADER_CLIENTID = 'x-ibm-client-id';
	public static final String HTTP_HEADER_CLIENTSECRET = 'x-ibm-client-secret';
	public static final String HTTP_HEADER_CHANNELID = 'x-channel-id';
	public static final String HTTP_HEADER_DEFAULTCHANNEL = 'SBG_SF';

	public string jsonBody;
	public string accessToken;
	public string correlationId;
	public string identityNumber;

	/**
	 * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
	 * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
	 * We are doing this to support unit tests
	 */
	@TestVisible
	protected override void populateRequestDTO()
	{
		if(!String.isBlank(jsonBody))
			request.setBody(jsonBody);
		baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
    @TestVisible
	protected virtual override void setHeaders()
	{
		setServiceSettings();
		super.setHeaders();
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(
				HTTP_HEADER_CERTIFICATE,
				AOB_Constants.API_TESTCERTIFICATE
		);
       // request.setClientCertificateName('SF_Account_Onboarding_and_Commerce');//SFP-12843
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_utils.generateGUID());
		//request.setHeader(HTTP_HEADER_CLIENTID, settings.CMN_ClientID__c);
        request.setHeader(HTTP_HEADER_CLIENTID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
		//request.setHeader(HTTP_HEADER_CLIENTSECRET, settings.CMN_Client_Secret__c);
        request.setHeader(HTTP_HEADER_CLIENTSECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
		request.setHeader(HTTP_HEADER_CORRELATION, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CHANNELID, HTTP_HEADER_DEFAULTCHANNEL);
	}

}