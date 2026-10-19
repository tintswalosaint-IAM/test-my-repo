/***************************************************************************************
 * @description             : API class for Quick Quote Benefits
 * @story                   : SFP-51843
 * @author                  : Irshad
 * @created date            : 2026-02-12
 * @last modified date      :
 * @last modified by        :
 * @modification details    :
 ***************************************************************************************/
public inherited sharing class INS_SRV_QuickQuoteBenefits extends AOB_API_RestBaseOutboundPing {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_SRV_QuickQuoteBenefits');

    private static final String EC_NAME = 'KYC_MulesoftConnect_ENC';

    public static final String SERVICE_NAME = INS_SRV_QuickQuoteBenefits.class.getName();

    @TestVisible
    private String quoteId;

    @TestVisible
    static CMN_API_HttpBaseOutboundMock injectedMock;

    /**
     * @description Constructor
     * @param jsonBody      Request payload
     * @param quoteId       Quote record Id
     */
    public INS_SRV_QuickQuoteBenefits(String jsonBody, String quoteId) {
        this.jsonBody = jsonBody;
        this.accessToken = KYC_SRV_GenerateAccessToken.getAccessToken();
        this.quoteId = quoteId;
    }

    /**
     * @description The name of your service to be used when looking up custom settings for your service
     * @return SERVICE_NAME
     */
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }

    /**
     * @description Override to set your request and response DTO types and any other globals you may have
     */
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
         * @description Populates triggering object
         * @param triggeringObjectId Triggering object Id
         */
        @TestVisible
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Will serialize requestDTO after it has been populated
     * @return jsonBody
     */
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }

    /**
     * @description Overriding parent class method to use the right HTTP verb
     * @return HTTP_VERB_PUT
     */
    @TestVisible
    protected override virtual String getVerb() {
        return HTTP_VERB_PUT;
    }

    /**
     * @description Overriding parent class method to set request headers
     */
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, 'Bearer ' + accessToken);
        request.setHeader('country_code', INS_Quote_Helper.CLIENT_COUNTRY_KE);
        request.setHeader('transaction_id', generateTransactionId());
        request.setHeader('client_id', '{!$Credential.' + EC_NAME + '.Kyc_client_id}');
        request.setHeader('org_client_id', 'Dev_Testing');
        request.setHeader('channel', 'salesforce');
        request.setTimeout(120000);
    }

    /**
     * @description Generates a UUID-formatted transaction Id using Crypto
     * @return String UUID
     */
    private static String generateTransactionId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertToHex(b);
        return h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16)
            + '-' + h.substring(16, 20) + '-' + h.substring(20);
    }

    /**
     * @description Returns the endpoint URL used in the HTTP request
     * @return endpoint
     */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endpoint;
        if (settings != null && String.isNotBlank(settings.CMN_Path__c)) {
            String subUrl = '/' + settings.AOB_Channel__c + settings.CMN_Path__c.replace('{quoteId}', quoteId);
            endpoint = settings.CMN_NamedCredential__c + subUrl;
        }
        return endpoint;
    }

    /**
     * @description Returns the mock callout to use during test execution
     * @return CMN_API_HttpBaseOutboundMock instance
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        if (Test.isRunningTest() && injectedMock != null) {
            return injectedMock;
        }
        return new QuickQuoteBenefitsMock();
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
     * @description Wrapper class for HTTP response
     */
    public class DTO_Response extends CMN_DTO_JsonBase {
        /**
         * @description Response body
         * @return String
         */
        @AuraEnabled
        public String response { get; set; }

        /**
         * @description The Type of the DTO used when deserializing the class
         * @return Class of the DTO
         */
        @TestVisible
        public override Type getObjectType() {
            return DTO_Response.class;
        }
    }

    /**
     * @description Overriding parent class method to return response body
     * @return String response body
     */
    public override String getResponseBody() {
        return response.getBody();
    }

    /**
     * @description Mock class for test classes
     */
    public class QuickQuoteBenefitsMock extends CMN_API_HttpBaseOutboundMock {

        public final String validResponse = '{"documentStatus":"Success","documentStatusMessage":"Uploaded OK"}';

        /**
         * @description Creates a mock HTTP response
         * @param request  HttpRequest
         * @param response HttpResponse
         */
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
}