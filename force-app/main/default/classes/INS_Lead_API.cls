/**
* @description : Pure Outbound HTTP Transport Engine for Lead Integrations.
* @author      : Raja Arsalan
* @date        : August 2026
*/
public with sharing class INS_Lead_API extends AOB_API_RestBaseOutboundPing {
    
    private static final Integer DEFAULT_TIMEOUT_MS = 120000;
    public static final String SERVICE_NAME = INS_Lead_API.class.getName();
    
    private String namedCredentialName;
    private String endpointPath;
    private String httpVerb;
    private Map<String, String> customHeaders;
    
    /**
* @description Generic Primary Constructor
*/
    public INS_Lead_API(String jsonBody, String accessToken, String methodVerb, String namedCredential, String endpointPath, Map<String, String> customHeaders) {
        this.jsonBody = jsonBody;
        this.accessToken = accessToken;
        this.httpVerb = String.isNotBlank(methodVerb) ? methodVerb : HTTP_VERB_POST;
        this.namedCredentialName = String.isNotBlank(namedCredential) ? namedCredential : 'INS_Insurance_Leads';
        this.endpointPath = String.isNotBlank(endpointPath) ? endpointPath : '';
        this.customHeaders = (customHeaders != null) ? customHeaders : new Map<String, String>();
    }
    
    // Overloaded Constructor for Connex Backward Compatibility
    public INS_Lead_API(String jsonBody, String accessToken, String methodVerb, String leadReferenceNumber) {
        this(
            jsonBody, 
            accessToken, 
            methodVerb, 
            'INS_Insurance_Leads', 
            (HTTP_VERB_PUT.equalsIgnoreCase(methodVerb) && String.isNotBlank(leadReferenceNumber)) ? '/' + leadReferenceNumber + '/LeadEnhancement' : '', 
            null
        );
    }
    
    public INS_Lead_API(String jsonBody, String accessToken, String methodVerb) {
        this(jsonBody, accessToken, methodVerb, null);
    }
    
    @TestVisible
    protected override String getServiceName() {
        return SERVICE_NAME;
    }
    
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase {
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }
    
    @TestVisible
    protected override String getBody() {
        return jsonBody;
    }
    
    @TestVisible
    protected override void setHeaders() {
        request.setMethod(getVerb());
        request.setTimeout(DEFAULT_TIMEOUT_MS);
        
        if (String.isNotBlank(this.accessToken)) {
            request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer ' + this.accessToken);
        }
        
        request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_Utils.generateGUID());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        
        // Connex Default Headers Fallback
        if (customHeaders.isEmpty() && 'INS_Insurance_Leads'.equalsIgnoreCase(namedCredentialName)) {
            populateDefaultConnexHeaders();
        } else {
            // Custom Headers for Dotsure / AWS / Custom Integration
            for (String key : customHeaders.keySet()) {
                request.setHeader(key, customHeaders.get(key));
            }
        }
    }
    
    /**
* @description Executes direct synchronous HTTP callout without requiring CMN_WebserviceCallQueue__c
*/
    public virtual void execute() {
        this.initialise();
        HttpRequest req = this.createRequest(this.getBody());
        this.sendRequest(req);
    }
    
    private void populateDefaultConnexHeaders() {
        String clientCertificates = '{!$Credential.INS_Insurance_Leads.XClientCertificate1}' +
            '{!$Credential.INS_Insurance_Leads.XClientCertificate2}' +
            '{!$Credential.INS_Insurance_Leads.XClientCertificate3}' +
            '{!$Credential.INS_Insurance_Leads.XClientCertificate4}' +
            '{!$Credential.INS_Insurance_Leads.XClientCertificate5}';
        
        request.setHeader('x-env-key', '{!$Credential.INS_Insurance_Leads.xenvkey}');
        request.setHeader('X-IBM-Client-Id', '{!$Credential.INS_Insurance_Leads.clientId}');
        request.setHeader('X-IBM-Client-Secret', '{!$Credential.INS_Insurance_Leads.clientSecret}');
        request.setHeader('cifCountry', '{!$Credential.INS_Insurance_Leads.cifCountry}');
        request.setHeader('channelName', '{!$Credential.INS_Insurance_Leads.channelName}');
        request.setHeader('channelId', '{!$Credential.INS_Insurance_Leads.channel_Id}');
        request.setHeader(HTTP_HEADER_CERTIFICATE, clientCertificates);
    }
    
    protected override HttpRequest createRequest(String body) {
        setHeaders();
        
        if (String.isNotBlank(body) && !HTTP_VERB_GET.equalsIgnoreCase(request.getMethod())) {
            request.setBody(body);
        }
        
        String fullEndpoint = 'callout:' + namedCredentialName + (String.isNotBlank(endpointPath) ? endpointPath : '');
        request.setEndpoint(fullEndpoint);
        
        return request;
    }
    
    @TestVisible
    protected override String getVerb() {
        return httpVerb;
    }
    
    @TestVisible
    protected override Boolean triggeringObjectRequired() {
        return false;
    }
    
    @TestVisible
    public override String getResponseBody() {
        return (response != null) ? response.getBody() : null;
    }
    
    @TestVisible
    public override Integer getResponseStatusCode() {
        return (response != null) ? response.getStatusCode() : null;
    }
}