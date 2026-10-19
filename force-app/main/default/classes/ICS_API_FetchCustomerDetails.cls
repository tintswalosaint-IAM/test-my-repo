/**
* @description SFP-32986 Class used to send TIN data .
* This class extends ICS_API_RestBaseOutbound for handling outbound REST API calls.
* @author Ramya Gurram
* @date 13/10/2024
*****************************************************
* @last modified on  : 13/10/2024
* @last modified by  : Ramya Gurram
* @last modified description: updated to latest version
*/
public without sharing class ICS_API_FetchCustomerDetails  extends ICS_API_RestBaseOutbound {
    /**
     * @description final logger instance used for logging messages in the ICS_API_FetchCustomerDetails class.
     * created using the sbgplatform.rflib_LoggerUtil factory method.
	*/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_FetchCustomerDetails');
    // Define a format for named credential URL
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    // Instance variable to store party profile ID
    public String accountId;
    
    // Constant for service name, using class name
    public static final String SERVICE_NAME = ICS_API_FetchCustomerDetails.class.getName();
    
    /**
* Override to populate the request DTO with triggering object data
*/
    protected virtual override void populateRequestDTO() {
        super.populateRequestDTO();
        if(queueItem.CMN_TriggeringObjectId__c != null){
            baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
        }
    }
    
    /**
* Override to provide query parameters (currently not used)
* @return null as no query parameters are used
*/
    protected virtual override String getQueryParameters() {
        return null;
    }
    
    /**
* Retrieve the service name used for looking up custom settings
* @return SERVICE_NAME
*/
    @TestVisible
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }
    
    /**
* Override to initialize request and response DTO types
*/
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
    /**
* Inner class extending CMN_DTO_JsonBase for request DTO
*/
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        
        /**
* Populate triggering object data into the request DTO
* @param triggeringObjectId The ID of the triggering object
*/
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }
    
    /**
* Override to serialize requestDTO after it's been populated
* @return JSON body for the API request
*/
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        // ICS_API_UpdateTINRequestData reqData = new ICS_API_UpdateTINRequestData();
        // jsonBody = reqData.prepareTINJson(this.accountId);
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('customerId', this.accountId);
        jsonBody = JSON.serialize(requestMap);
        populateRequestDTO();
        return jsonBody;
    }
    
    /**
* Override to specify the HTTP verb for the API call
* @return HTTP_VERB_POST
*/
    @TestVisible
    protected override virtual String getVerb() {
        return HTTP_VERB_POST;
    }
    
    /**
* Override to set HTTP headers for the request
*/
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setTimeout(ICS_Constants.timeoutVal);
    }
    
    /**
* Override to construct and return the endpoint URL using named credentials and path settings
* @return Endpoint URL for the HTTP request
*/
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c: CMN_UTIL_String.EMPTY
                            }
            );
        }else{
            LOGGER.error('Not able to fetch Named Credential ');
        }
        return endPoint;
    }
    
    
    
    /**
* Call the parent objects' method to ensure code coverage for mock testing
* @return CMN_API_HttpBaseOutboundMock instance
*/
    
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new ICS_API_FetchCustomerDetailsMock(SERVICE_NAME,'FAILURE');
    }
    
    /**
* Inner class extending CMN_DTO_JsonBase for response DTO
*/
    public class DTO_Response extends CMN_DTO_JsonBase {
        
        /**
* Response string
*/
        @AuraEnabled
        public String response { get; set; }
        
        /**
* Return the class type when deserializing the response DTO
* @return Class type of the response DTO
*/
        @TestVisible
        public override Type getObjectType() {
            return DTO_Response.class;
        }
    }
    /**
* Inner mock class for HTTP mock responses during testing
*/
    public class ICS_API_FetchCustomerDetailsMock extends CMN_API_HttpBaseOutboundMock {
        
        // Mock response status code
        String mockResponse = '';
        
        /**
* Constructor to initialize mock response based on the service name
* @param className Class name for service identification
*/
        public ICS_API_FetchCustomerDetailsMock(String className,String scenario) {
            if(className == SERVICE_NAME) {
                if (scenario == 'SUCCESS') {
                    mockResponse = '{"statusCode":200,"statusMessage":"OK","data":"Your response data here"}';
                } else if (scenario == 'FAILURE') {
                    mockResponse = '{"statusCode":400,"statusMessage":"Bad Request","data":"Error message here"}';
                }
            }
        }
        
        /**
* Override to set mock response body for HTTP calls
* @param request HttpRequest instance
* @param response HttpResponse instance
*/
        @TestVisible
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(mockResponse);
        }
    }
    
}