/**
 * @description SFP-32986 Class used to generate token for GBG and call other services
 *              This class extends ICS_API_RestBaseOutbound for handling outbound REST API calls.
 * @author Ikyatha Naidu,Swapnil Walse
 * @date 11/01/2024 
 *****************************************************
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to latest version
 */
public with sharing class ICS_API_GenerateTokenGBG extends ICS_API_RestBaseOutbound {

    // Constants
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}'; //Named CredentialFormat
    private static final String REQUEST_BODY = 'grant_type={0}&username={1}&password={2}&area={3}'; //Request Body

    // Properties
    // Variable to store service response
    Public string serviceResponse='';
   
    // Variable to store account ID
    Public string accountId;
    // Static flag indicating if the test has failed
    public static Boolean isFailedTest = false;
    // Counter variable initialized to 0
    Public integer counter=0;
    // Boolean flag to get QR info
    Public boolean getQRInfo;

    // Service name constant fetched from ICS_API_GenerateTokenGBG class
    public static final String SERVICE_NAME = ICS_API_GenerateTokenGBG.class.getName();


   
    /**
     * @description Override method to return the service name
     * @return SERVICE_NAME
     */
    @TestVisible
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }

    /**
     * @description Override method to initialize request DTO
     */
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
    }

    /**
     * @description Inner class to represent request DTO, extends CMN_DTO_JsonBase
     */
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
         * @description Method to populate triggering object
         * @param triggeringObjectId Triggering Object Id
         */
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Override method to get the request body for the API call
     * @return Request body as a string
     */
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        populateRequestDTO();
        request.setBody(String.format(REQUEST_BODY, new string[]{
            '{!$Credential.CHNW_SBO_UK_GBGE.granttype}',
            '{!$Credential.CHNW_SBO_UK_GBGE.username}',
            '{!$Credential.CHNW_SBO_UK_GBGE.password}',
            '{!$Credential.CHNW_SBO_UK_GBGE.area}'
        }));
        return jsonBody;
    }

    /**
     * @description Override method to specify HTTP verb for the API call
     * @return HTTP_VERB_POST
     */
    @TestVisible
    protected override virtual String getVerb() {
        return HTTP_VERB_POST;
    }

    /**
     * @description Override method to set HTTP headers for the API call
     */
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_URL);
        request.setTimeout(ICS_Constants.timeoutVal);
    }

    /**
     * @description Override method to get the endpoint URL for the API call
     * @return Endpoint URL
     */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                    String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY
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
        return new ICS_API_GenerateTokenGBGMock(SERVICE_NAME,200);
    }

    /**
     * @description Override method to get the response body from the API call 
     * @return Response body as a string 
     */
    @TestVisible
    Public override String getResponseBody() {
        string tokenData = '';
        String responsebody='';
        if (response.getBody() != '' && counter == 0) {
            String responseGBGBody = response.getBody();
            Map<String, Object> responseGBGMap = (Map<String, Object>) JSON.deserializeUntyped(responseGBGBody);
            tokenData = (String) responseGBGMap.get('access_token');
            
            // Fetch Journey Definition Id from GBG
            ICS_API_fetchJourneyDefinitionId customerServiceCall = new ICS_API_fetchJourneyDefinitionId();
            customerServiceCall.tokenInfo = tokenData;
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_fetchJourneyDefinitionId.SERVICE_NAME);
            customerServiceCall.process(obj);
            counter = counter + 1;
            string journeyDefinitionId = '';
            responsebody = customerServiceCall.getResponseBody();
            
            // Parsing JSON Response for Fetch API
            Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(responsebody);
            if (parsedData.containsKey('defId')) {
                journeyDefinitionId = (String) parsedData.get('defId');
            }
            
            // Generate QR Code API
            if (getQRInfo == true && Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable() ) {
                ICS_API_GenerateQRCode qrCodegenerate = new ICS_API_GenerateQRCode();
                qrCodegenerate.jounreyDefinitionID = journeyDefinitionId;
                qrCodegenerate.tokenInfo= tokenData;
                qrCodegenerate.accountId = accountId;
                CMN_WebserviceCallQueue__c qrObj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateQRCode.SERVICE_NAME);
                qrCodegenerate.process(qrObj);
                
                	insert obj;
                 
                serviceResponse = qrCodegenerate.getResponseBody();
            }
            if (getQRInfo == false) {
                map<string, string> responseMap = new Map<string, string>();
                responseMap.put('token', tokenData);
                responseMap.put('defId', journeyDefinitionId);
                responseMap.put('accountId', accountId);
                responseMap.put('domain', settings.CMN_AdditionalKey__c);
                serviceResponse = JSON.serialize(responseMap);
            }
        }
        return responsebody;
     }

    /**
     * @description Method to return the service response
     * @return Service response as a string
     */
    Public string serviceResponseInfo() {
        return serviceResponse;
    }

    /**
     * @description Inner class for mocking HTTP calls in unit tests
     */
    public class ICS_API_GenerateTokenGBGMock extends CMN_API_HttpBaseOutboundMock {
        String mockResponse = '';

        /**
         * @description Constructor for mock class to provide mock responses
         * @param className Class name for determining mock response
         */
        Public ICS_API_GenerateTokenGBGMock(string serviceAttribute,integer status) {
            if (serviceAttribute == SERVICE_NAME) {
                mockResponse = '{"access_token":"mock_access_token","token_type":"Bearer","expires_in":3600}';
            }
            if (serviceAttribute == 'ICS_API_fetchJourneyDefinitionId') {
                mockResponse = '[{"JourneyDefinitionId":"9accf621-47bb-4a81-ab87-d24d0faa9d10","Name":"SF Test","ChannelType":2,"CapturingMedia":3,"LastUpdatedDateTime":"2023-11-07T10:17:25.9312645","IsActive":true,"IsOCROnly":false,"IsPredefinedJourney":false}][{"JourneyDefinitionId":"9accf621-47bb-4a81-ab87-d24d0faa9d10","Name":"SF Test","ChannelType":2,"CapturingMedia":3,"LastUpdatedDateTime":"2023-11-07T10:17:25.9312645","IsActive":true,"IsOCROnly":false,"IsPredefinedJourney":false}]';
            }
            if(serviceAttribute == 'invalidAccessToken' || status == 500 ){
                mockResponse = '{"defId":"","data":{"QR_Code":""}}';
            }
            
            if (serviceAttribute == 'ICS_API_GenerateQRCode' && status==200) {
                mockResponse = '{"success":true,"message":"Success","data":{"QR_Code":"iVBORw0KGgoA","URL":"https://identify.idscan.cloud/APIHandler/idshostSession/?sessionID=55801646-3def-49bf-af2a-e97c6164d48f&lang=en&method=webview","Created_Time":"2024-03-26T09:35:43.217","SessionID":"55801646-3def-49bf-af2a-e97c6164d48f"}}';
            }
        }

        /**
         * @description Method to set mock response for HTTP calls
         * @param request HTTP request object
         * @param response HTTP response object
         */
        @TestVisible
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(mockResponse);
        }
    }
}