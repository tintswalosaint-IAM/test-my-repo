/**
 * @description Class used as controller to make a callout for updating the contactId in Ping SBO-UK PING Feature
 *
 * Story: SFP-31800
 *
 * @author Ikyatha Naidu
 * @date 10/01/2024
 * *************************************
 * @last modified on  : 13-03-2024
 * @last modified by  : Ikyatha Naidu 
 * @Modification Description :updated to latest version
 */
public with sharing class ICS_API_UpdatePINGContactDetails extends ICS_API_RestBaseOutbound {
    /**
    * @description Represents the format string for named credential URL.
    */
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
 /** 
 * This line defines a private static final logger instance named LOGGER using the sbgplatform.rflib_Logger class.
 * It is created by invoking the createLogger method of sbgplatform.rflib_LoggerUtil.getFactory()
 *  with the identifier 'ICS_API_UpdatePINGContactDetails'.
 * The LOGGER instance is utilized throughout the codebase to capture and manage log messages specific
 *  to the 'ICS_API_UpdatePINGContactDetails' component or functionality.
 */
       Private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_UpdatePINGContactDetails');
    /**
    * @description Stores the PING ID associated with the contact.
    */
       Public  string conPingId='';
    /**
    * @description Stores the JSON body .
    */
     Public  string jsonData='';

    /**
    * @description Represents the name of the service class.
    */
    public static final String SERVICE_NAME = ICS_API_UpdatePINGContactDetails.class.getName();
	
	
    

    /**
     * @description Override to populate the request DTO with specific data
     */
    protected virtual override void populateRequestDTO() {
        super.populateRequestDTO();
        if(this.jsonData == null){
            LOGGER.error('jsonbody is empty');
        }else{
            request.setBody(this.jsonData);
        }
        
        if(queueItem.CMN_TriggeringObjectId__c != null) {
         baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
        }
    }

    /**
     * @description Returns the name of the service for custom settings lookup
     * @return SERVICE_NAME
     */
    @TestVisible
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }

    /**
     * @description Override to initialize request and response DTO types and other globals
     */
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    /**
     * @description Inner DTO class for the request
     */
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
         * @description Populates the triggering object ID
         * @param triggeringObjectId ID of the triggering object
         */
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Serializes request DTO after it's been populated
     * @return JSON string of request body
     */
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }

    /**
     * @description Override parent class method to specify HTTP verb (PUT in this case)
     * @return HTTP method type
     */
    @TestVisible
    protected override virtual String getVerb() {
        return HTTP_VERB_PUT;
    }

    /**
     * @description Sets HTTP headers including content type and timeout
     */
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setTimeout(120000);
    }

    /**
     * @description Returns the endpoint URL to use in the HTTP request
     * @return Endpoint URL
     */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        String servicePath = '';
        try{
            if(settings.CMN_Path__c != null){
                servicePath = settings.CMN_Path__c;
                if (servicePath.contains('{!pingId}')) {
                    servicePath = servicePath.replace('{!pingId}', conPingId);
                }
            }
            if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
                endPoint = String.format(
                    NAMED_CREDENTIAL_URL_FORMAT,
                    new List<String>{
                        settings.CMN_NamedCredential__c,
                        String.isNotBlank(conPingId) ? servicePath : CMN_UTIL_String.EMPTY
                    }
                );
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getmessage());
        }
        return endPoint;
    }

    /**
     * @description Calls parent object's method to ensure code coverage
     * @return CMN_API_HttpBaseOutboundMock instance
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new UpdateRPMock();
    }

    /**
     * @description Override parent class method to indicate that triggering object is not needed
     * @return Boolean value indicating if triggering object is required
     */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired() {
        return false;
    }

    /**
     * @description Wrapper class for HTTP response DTO
     */
    public class DTO_Response extends CMN_DTO_JsonBase {
        /**
         * @description Response string received from HTTP callout
         */
        @AuraEnabled
        public string response { get; set; }

        /**
         * @description Returns the type of DTO used for deserialization
         * @return Class type of DTO_Response
         */
        @TestVisible
        public override Type getObjectType() {
            return DTO_Response.class;
        }
    }

    /**
     * @description Mock class for test classes to simulate HTTP callout responses
     */
    public class UpdateRPMock extends CMN_API_HttpBaseOutboundMock {
        public final String validResponse = '{"_links":{"schemas":[{"href":"https://enterprisedirectorysit.standardbank.co.za/directory/v1/schemas/StandardbankPerson"},{"href":"https://enterprisedirectorysit.standardbank.co.za/directory/v1/schemas/pf-connected-identities"}],"self":{"href":"https://enterprisedirectorysit.standardbank.co.za/directory/v1/entryUUID=aa7a36cf-a8a1-41f5-8710-5e424fd552d8,ou=People,dc=sbsa,dc=com"}},"objectClass":["top","StandardbankPerson","pf-connected-identities"],"SB-mail":"ikyatha829@gmail.com","uid":["iky"],"SBO-SalesforceID":"123456789","_dn":"entryUUID=aa7a36cf-a8a1-41f5-8710-5e424fd552d8,ou=People,dc=sbsa,dc=com"}';

        /**
         * @description Sets the mock response for HTTP calls
         * @param request HTTP request object
         * @param response HTTP response object
         */
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }

    /**
     * @description Retrieves the response body from DTO_Response
     * @return Response body string
     */
    public override String getResponseBody() {
        return response.getBody();
    }
}