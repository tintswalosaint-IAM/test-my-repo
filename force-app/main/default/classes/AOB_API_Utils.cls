/**
 * @description       : Utility class for AOB Integration to get Access Token for UG PPB
 * @author            : Jagadish Thummala.
 * @group             : Utility 
 * @testClass         : 
 * @date modified on  : 18-03-2024
**/
public with sharing class AOB_API_Utils {
    //HTTP Constants
    private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final Integer HTTP_OK = 200;
    private static final Integer HTTP_CREATED = 201;
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String CLIENT_CERTIFICATE_1 = '{!$Credential.UG_BCB_PBB_ESB_INTEGRATION_CREDENTIALS_EC.client_certificate1}';
    private static final String CLIENT_CERTIFICATE_2 = '{!$Credential.UG_BCB_PBB_ESB_INTEGRATION_CREDENTIALS_EC.client_certificate2}';
    private static final String CLIENT_CERTIFICATE_3 = '{!$Credential.UG_BCB_PBB_ESB_INTEGRATION_CREDENTIALS_EC.client_certificate3}';
    private static String accessToken = null;
    private static DateTime tokenExpiryDateTime = System.now();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_API_Utils');
    private static final String PATH_CALLOUT = '/sysauth/oauth2/token';
      // Using for test classes
      @testVisible private static Integer mockHttpStatusCode;
      @testVisible private static String mockHttpStatus;
      @testVisible private static String mockHttpbody = '';
    /**
     * @description private Static method to Retrieve Access Token
     * @return AccessToken
     **/
    private static String getAccessToken() {
        String scope = 'customer prod';
        // Create the request body
        String requestBody = String.format('grant_type=client_credentials&scope={0}', new List<String>{scope});
        // Set the callout endpoint
        String CALLOUT_END_POINT = 'callout:UG_BCB_PBB_ESB_TOKEN_INTEGRATION_CREDENTIALS';
        // Create an HttpRequest object
        HttpRequest request = new HttpRequest();
        request.setEndpoint(CALLOUT_END_POINT + PATH_CALLOUT);
        request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
        request.setBody(requestBody);
        request.setMethod(HTTP_METHOD_POST);
        request.setTimeout(120000);
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                } else {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponse());
                }
            }
            // process the return status of the API call
            if (response.getStatusCode() == HTTP_OK) {
                JWKSResult resultToken = (JWKSResult) JSON.deserialize(response.getBody(), JWKSResult.class);
                accessToken = resultToken.access_Token;
                tokenExpiryDateTime = System.now().addSeconds(Integer.valueOf(resultToken.expires_in));
            } else {
                LOGGER.error('Error in calling AOB_API_Utils.getAccessToken' + '\n' + 'Response status: ' + response.getStatusCode());
            }
        } catch (Exception ex) {
            LOGGER.error('Error in calling AOB_API_Utils.getAccessToken', ex);
        }
        return accessToken;
    }

    /**
     * @description Method to Retrieve Access Token
     * @return AccessToken
     **/
    public static String refreshToken() {
        // Get a new token if no token available or the token is already expired.
        if (accessToken == null || System.now() >= tokenExpiryDateTime) {
            return getAccessToken();
        }
        return accessToken;
    }
     /**
      * @description Method to generate GUID used for callouts invoked from all callout classes
      * @return created unique id used for callouts
      */
      public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
    /**
      * @description Method to generate headers for callout
      * @param PATH_CALLOUT
      * @param HTTP_METHOD
      * @return httpRequest
      */
    public static HttpRequest getHeaders(String PATH_CALLOUT, String HTTP_METHOD) {
        HttpRequest httpRequest = new HttpRequest();
        String fApiInteractionId = AOB_API_Utils.createGUID();
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader('Authorization', AUTHORIZATION_TYPE_BEARER + AOB_API_Utils.refreshToken());
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setHeader('x-client-certificate', CLIENT_CERTIFICATE_1 + CLIENT_CERTIFICATE_2 + CLIENT_CERTIFICATE_3);
        httpRequest.setEndpoint('callout:UG_BCB_PBB_ESB_INTEGRATION_CREDENTIALS' + PATH_CALLOUT);
        httpRequest.setMethod(HTTP_METHOD);
        httpRequest.setTimeout(120000);
        return httpRequest;
    }
    @TestVisible
    private class AccessTokenMockResponse implements HttpCalloutMock {        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"token_type": "bearer","access_token": "201423083430380","expires_in": 33414050,"scope": "customer prod"}');
            return response;
        }        
    }
    /**
     * @description Class to return the required attribute for JWKToken
     */
    public class JWKSResult {
        /**
         * @description Property to get an accessToken
         **/
        public String access_Token { get; set; }
        /**
         * @description Property to get the error_description
         **/
        public String error_description { get; set; }
        /**
         * @description Property to get the error occurred
         **/
        public String error { get; set; }
        /**
         * @description Property to get the expiry duration (in seconds)
         **/
        public String expires_in { get; set; }
        /**
         * @description Property to get token_type
         **/
        public String token_type { get; set; }
        /**
         * @description Property to get token_type
         **/
        public String scope;
        /**
         * @description Property to get token_type
         **/
        public Integer consented_on;
        /**
         * @description Property to get token_type
         **/
        public String metadata;
    }
}