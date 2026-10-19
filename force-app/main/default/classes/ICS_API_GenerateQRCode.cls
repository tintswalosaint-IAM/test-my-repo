/**
 * @description SFP-32986 Class used to Generate QR code from GBG for client.
 *              This class extends ICS_API_RestBaseOutbound for handling outbound REST API calls.
 * @author Ikyatha Naidu,Swapnil Walse 
 * @date 12/01/2024
 *****************************************************
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to latest version
 */
public with sharing class ICS_API_GenerateQRCode extends ICS_API_RestBaseOutbound {

    // Private static constant for the named credential URL format
private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';



// Public static Boolean flag indicating if the test has failed (initially false)
public static Boolean isFailedTest = false;

// Public static String variable for storing journey definition ID (initially empty)
Public  String jounreyDefinitionID = '';

// Public static String variable for storing token information (initially empty)
Public  String tokenInfo = '';

// Public static String variable for storing account ID (initially empty)
Public  String accountId = '';

// Public static constant for the service name, fetched from ICS_API_GenerateQRCode class
public static final String SERVICE_NAME = ICS_API_GenerateQRCode.class.getName();


    

    /**
     * @description Override method to populate the request DTO with additional key data and replace placeholders
     */
    protected virtual override void populateRequestDTO() {
        super.populateRequestDTO();
        string bodyData = settings.CMN_AdditionalKey__c;
        if (bodyData.contains('{!accId}')) {
            bodyData = bodyData.replace('{!accId}', accountId);
        }
        String bodyInfo = bodyData;
        request.setBody(bodyInfo);
        baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
    }

    /**
     * @description Override method to return query parameters; not used in this implementation
     */
    protected virtual override String getQueryParameters() {
        return null;
    }

    /**
     * @description Override method to return the service name for custom settings lookup
     * @return SERVICE_NAME
     */
    @TestVisible
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }

    /**
     * @description Override method to initialize request and response DTOs
     */
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    /**
     * @description Inner class for request DTO, extending CMN_DTO_JsonBase
     */
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
         * @description Method to populate triggering object
         * @param triggeringObjectId Id of the triggering object
         */
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Override method to serialize request DTO after it has been populated
     * @return JSON representation of request body
     */
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }

    /**
     * @description Override method to return HTTP method verb for API call (POST)
     * @return HTTP_VERB_POST
     */
    @TestVisible
    protected override virtual String getVerb() {
        return HTTP_VERB_POST;
    }

    /**
     * @description Override method to set HTTP headers for API request
     */
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, ICS_Constants.BEARER + ' ' + this.accessToken);
        request.setTimeout(120000);
    }

    /**
     * @description Override method to return the endpoint URL for HTTP request using Named Credentials
     * @return Endpoint URL
     */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            
            String path = settings.CMN_Path__c;
            if (jounreyDefinitionID != null && (path.contains('{defId}') || path.contains('{token}'))) {
                path = path.replace('{defId}', jounreyDefinitionID);
                path = path.replace('{token}', tokenInfo);
            }
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                    String.isNotBlank(settings.CMN_Path__c) ? path : CMN_UTIL_String.EMPTY
                }
            );
        }
        return endPoint;
    }

    /**
     * @description Override method to provide a mock endpoint for unit testing
     * @return Mock object for HTTP endpoint
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {  
        super.getEndpointMock();
        integer statusCode=0;
        if(jounreyDefinitionID  == null || tokenInfo == null){
            statusCode = 500;
        }else{
            statusCode =200;
        }
        
        return new ICS_API_GenerateTokenGBG.ICS_API_GenerateTokenGBGMock(SERVICE_NAME,statusCode);
    }

    /**
     * @description Override method to indicate that triggering object is not required
     * @return Boolean indicating if triggering object is required (false in this case)
     */
    protected override virtual Boolean triggeringObjectRequired() {
        return false;
    }

    /**
     * @description Inner class for response DTO, extending CMN_DTO_JsonBase
     */
    public class DTO_Response extends CMN_DTO_JsonBase {
        /**
         * @description Response string received from API call
         */
        @AuraEnabled
        public String response { get; set; }

        /**
         * @description Override method to return the type of the DTO used for deserialization
         * @return Class of the DTO
         */
        @TestVisible
        public override Type getObjectType() {
            return DTO_Response.class;
        }
    }

    /**
     * @description Method to return the HTTP response body
     * @return Response body as String
     */
    public override String getResponseBody() {
        return response.getBody();
    }
}