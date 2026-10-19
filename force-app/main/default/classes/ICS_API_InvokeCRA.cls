/**
 * @description SFP-32986 Class used to send Risk Assessment request to Rely comply.
 *              This class extends ICS_API_RestBaseOutbound for handling outbound REST API calls.
 * @author Ikyatha Naidu,Swapnil Walse
 * @date 22/04/2024
 ***************************************************** 
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to latest version 
 */
public with sharing class ICS_API_InvokeCRA extends ICS_API_RestBaseOutbound {

    // Define a format for named credential URL
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    // Instance variable to store party profile ID
    String partyProfileId;
    Public string reqBody;
    
    // Constant for service name, using class name
    public static final String SERVICE_NAME = ICS_API_InvokeCRA.class.getName();

    

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
        
        jsonBody = reqBody;
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
        request.setHeader(HTTP_CONTENT_TYPE, 'application/Json');
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
        }
        return endPoint;
    }

   

    /**
     * Call the parent objects' method to ensure code coverage for mock testing
     * @return CMN_API_HttpBaseOutboundMock instance
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new ICS_API_InvokeMock();
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
    public class ICS_API_InvokeMock extends CMN_API_HttpBaseOutboundMock {

        // Mock response status code
        String mockResponse = '';

        /**
         * Constructor to initialize mock response based on the service name
         * @param className Class name for service identification
         */
        public ICS_API_InvokeMock() {
            mockResponse = '{"CustomerId":"0013L00000gNV2GQAW","CraKeys":[{"value":"0063L00000A988LQAR","key":"opportunity"},{"value":"false","key":"is_pep"},{"value":"false","key":"has_adverse_media"},{"value":"false","key":"has_high_net_worth"},{"value":"false","key":"shell_bank"},{"value":"false","key":"bearer_shares"},{"value":"false","key":"government_contracts"},{"value":"platinum_optimum _account","key":"product"},{"value":"salaried_employee_bank","key":"occupation_category"},{"value":"chief_executive","key":"occupation_position"},{"value":"408","key":"business_activity"},{"value":"IN","key":"residence"},{"value":"IN","key":"country_of_birth"},{"value":"IN","key":"nationality"},{"value":"IN","key":"country_of_wealth"},{"value":"IN","key":"country_of_funds"},{"value":"direct_non_face_to_face","key":"distribution_channel"}]}';
                
            
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