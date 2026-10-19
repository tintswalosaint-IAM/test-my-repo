/**
* @description      : Service class responsible for generating requests and handling responses for the Lead API Connex integration.
* @author           : Raja Arsalan
* @date             : June 2025
*/

public with sharing class INS_Leads_API extends AOB_API_RestBaseOutboundPing {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Leads_API');
    private static final Integer DEFAULT_TIMEOUT_MS = 120000;
    
    private static final String XID_IBM_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String XID_IBM_SECRET_ID = 'X-IBM-Client-Secret';
    private static final String CIF_COUNTRY = 'cifCountry';
    private static final String CIF_CHNAME = 'channelName';
    private static final String CIF_CHID = 'channelId';
    
    private String httpVerb = HTTP_VERB_POST; 
    private String leadReferenceNumber;
    
    // NEW: Flexible / Dynamic Variables (Defaults to Existing Setup)
    private String namedCredentialName = 'INS_Insurance_Leads'; 
    private String customChannelId = null; 
    private Map<String, String> customHeaders = new Map<String, String>();

    public static final String SERVICE_NAME = INS_Leads_API.class.getName();
    public static String mockScenario;
    public static String testLeadId;
    

    public INS_Leads_API(String jsonBody, String accessToken, String methodVerb, String leadReferenceNumber) {
        this.jsonBody = jsonBody;
        this.accessToken = accessToken;
        this.leadReferenceNumber = leadReferenceNumber;
        if (!String.isBlank(methodVerb)) {
            this.httpVerb = methodVerb;
        }
    }
    
    public INS_Leads_API(String jsonBody, String accessToken, String methodVerb) {
        this(jsonBody, accessToken, methodVerb, null);
    }

    /**
     * @description Allows future features to override Named Credential, Channel ID or extra headers dynamically
     */
    public INS_Leads_API setNamedCredential(String customNamedCredential) {
        if(String.isNotBlank(customNamedCredential)) {
            this.namedCredentialName = customNamedCredential;
        }
        return this;
    }

    public INS_Leads_API setChannelId(String channelId) {
        if(String.isNotBlank(channelId)) {
            this.customChannelId = channelId;
        }
        return this;
    }

    public INS_Leads_API addCustomHeader(String key, String value) {
        if(String.isNotBlank(key) && String.isNotBlank(value)) {
            this.customHeaders.put(key, value);
        }
        return this;
    }

    @TestVisible
    protected virtual override void setHeaders() {
        request.setMethod(getVerb());
        request.setTimeout(DEFAULT_TIMEOUT_MS);

        String authHeader = 'Bearer ' + this.accessToken;
        String interactionId = AOB_Utils.generateGUID();
        
        request.setHeader(HTTP_HEADER_INTERACTIONID, interactionId);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, authHeader);
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);

        request.setHeader('x-env-key', '{!$Credential.' + this.namedCredentialName + '.xenvkey}');
        request.setHeader(XID_IBM_CLIENT_ID, '{!$Credential.' + this.namedCredentialName + '.clientId}');
        request.setHeader(XID_IBM_SECRET_ID, '{!$Credential.' + this.namedCredentialName + '.clientSecret}');
        request.setHeader(CIF_COUNTRY, '{!$Credential.' + this.namedCredentialName + '.cifCountry}');
        request.setHeader(CIF_CHNAME, '{!$Credential.' + this.namedCredentialName + '.channelName}');
        
        if(String.isNotBlank(this.customChannelId)) {
            request.setHeader(CIF_CHID, this.customChannelId);
        } else {
            request.setHeader(CIF_CHID, '{!$Credential.' + this.namedCredentialName + '.channel_Id}');
        }
        
        String clientCertificate = '{!$Credential.' + this.namedCredentialName + '.XClientCertificate1}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate2}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate3}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate4}' +
                                   '{!$Credential.' + this.namedCredentialName + '.XClientCertificate5}';
        request.setHeader(HTTP_HEADER_CERTIFICATE, clientCertificate);

        for(String key : this.customHeaders.keySet()) {
            request.setHeader(key, this.customHeaders.get(key));
        }
    }
    
    protected override HttpRequest createRequest(String body) {
        setHeaders();
        
        if (String.isNotBlank(body) && !HTTP_VERB_GET.equalsIgnoreCase(request.getMethod())) {
            request.setBody(body);
        }
        
        String endpointPath;
        if (HTTP_VERB_PUT.equalsIgnoreCase(httpVerb) && String.isNotBlank(leadReferenceNumber)) {
            endpointPath = '/' + leadReferenceNumber + '/LeadEnhancement';
            request.setEndpoint('callout:' + this.namedCredentialName + endpointPath);
        } else {
            request.setEndpoint('callout:' + this.namedCredentialName);
        }
        return request;
    }
   
    
    /**
* @description Overriding parent class method to use the right API Method
* @return String
*/
    @TestVisible
    protected override virtual String getVerb() {
        return httpVerb;
    }
    
    
    
    
    /**
* @description Overriding parent class method to indicate that triggering object is not needed
* @return Boolean
*/
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired() {
        return false;
    }
    

    /**
* @description method to extract the body of the response
* @return String Serialized body of the response
**/
    public override String getResponseBody() {
        return response.getBody();
    }
    
@TestVisible
protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
    if (String.isNotBlank(INS_DotsureService.mockScenario)) {
        return new INS_DotsureAPI_Mock();
    }
    return new INS_LeadsAPI_Mock();
}

}