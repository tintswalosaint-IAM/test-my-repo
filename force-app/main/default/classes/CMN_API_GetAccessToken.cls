/**
 * @description Class used to Perform an API call to get Access Token from ESB Endpoint
 * @author Eduardo Salia
 * @date July 2021
 * 
 * 2023-07-04   Derek Hughes    Where fatal errors occur (such as missing named credentials or call out errors) an exception is now thrown rather than just returning null.
 *                              Returning null had the effect of suppressing system errors and made troubleshooting difficult. 
 * 2023-11-06   Derek Hughes    Switch to using LOGGER
 */
public with sharing class CMN_API_GetAccessToken {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_GetAccessToken');

    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_CERTIFICATE = 'x-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_XSRF = 'x-xsrf-header';
    private static final String AUTHORIZATION_TYPE_BASIC = 'Basic ';
    private static final String HTTP_METHOD_POST = 'POST';
    //Generic Constants
    private static final String PARAM_COLON = ':';
    private static final String XSRF_PING = 'PingFederate';
    //API specific
    private static final String CMN_API_EXTERNAL_GATEWAY_DEV = 'CMN_API_EXTERNAL_GATEWAY_DEV';
    private static final String CMN_API_EXTERNAL_GATEWAY_PROD = 'CMN_API_EXTERNAL_GATEWAY_PROD';
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PING_TOKEN = '/as/token.oauth2';

    //Used to simulate an error during testing
    public static Boolean simulateError = false;

    // is current instance a Sandbox, query once per transaction
    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }
    // web service setting, query once per transaction
    public static CMN_WebserviceSetting__mdt webServiceSetting {
        get {
            if (webServiceSetting == null) {
                if (isSandbox) {
                    webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(CMN_API_EXTERNAL_GATEWAY_DEV);
                }
                else {
                    webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(CMN_API_EXTERNAL_GATEWAY_PROD);
                }
            }
            return webServiceSetting;
        }
        private set;
    }
    
    /**
     * @description This method performs an API request to ESB
     * @param scope HTTP Request Scope
     * @return CMN_DTO_AuthenticationResponse responseObject
     */
    public static CMN_DTO_AuthenticationResponse getAccessToken(String scope) {

        LOGGER.info('getAccessToken: START: scope: '+scope);

        NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);

        if (namedCredential == null) {
            String message = 'Named credential "' + webServiceSetting.CMN_NamedCredential__c + '" is not available';
            throw new TokenException(message);
        }

        //Prepare Request
        Blob clientToken = Blob.valueOf(webServiceSetting.CMN_ClientID__c + PARAM_COLON + webServiceSetting.CMN_Client_Secret__c);
        String endpoint = namedCredential.Endpoint + PATH_TOKEN;
        String requestBody = String.format(webServiceSetting.CMN_Path__c, new List<String> {scope});

        HttpRequest httpRequest = new HttpRequest();

        //Set Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BASIC + EncodingUtil.base64Encode(clientToken));

        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);

        String responseBody;
        //Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();

            if (System.Test.isRunningTest()) {
                if (simulateError) {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponseError());
                }
                else {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponse());
                }
            }

            httpResponse = http.Send(httpRequest);
            
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                responseBody = httpResponse.getBody();
                CMN_DTO_AuthenticationResponse responseObject =
                    (CMN_DTO_AuthenticationResponse) JSON.deserialize(responseBody, CMN_DTO_AuthenticationResponse.class);

                LOGGER.info('getAccessToken: SUCCESS');
                
                return responseObject;
            }
            else {
                String message = 'Response status: ' + httpResponse.getStatusCode()+' '+httpResponse.getStatus()+(String.IsNotBlank(responseBody) ? '\nAPI response body:\n'+responseBody : '');
                throw new TokenException(message);
            }
        } 
        catch (Exception ex) {
            LOGGER.error('getAccessToken: Unhandled Exception', ex);
            throw new TokenException(ex.getMessage());
        }
    }
    
    /**
     * @description This method performs an API request to ESB
     * @return CMN_DTO_AuthenticationResponse responseObject
     */
    public static CMN_DTO_AuthenticationResponse getPingToken() {

        NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_Ping_NamedCredential__c);

        if (namedCredential == null) {
            String message = 'Named credential "' + webServiceSetting.CMN_NamedCredential__c + '" is not available';
            CMN_UTIL_Logger.error(message, 'CMN_API_GetAccessToken.getPingToken');
            throw new TokenException(message);
        }

        //Prepare Request
        String endpoint = namedCredential.Endpoint + PING_TOKEN;
        String requestBody = String.format(
            webServiceSetting.CMN_Ping_Template__c, new List<String> {
            webServiceSetting.CMN_Ping_ClientID__c,
            webServiceSetting.CMN_Ping_ClientSecret__c
        });

        HttpRequest httpRequest = new HttpRequest();

        //Set Request Headers
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
        httpRequest.setHeader(HEADER_XSRF, XSRF_PING);

        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);

        //Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();

            if (System.Test.isRunningTest()) {
                if (simulateError) {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponseError());
                }
                else {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponse());
                }
            }

            httpResponse = http.Send(httpRequest);

            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                CMN_DTO_AuthenticationResponse responseObject =
                    (CMN_DTO_AuthenticationResponse) JSON.deserialize(responseBody, CMN_DTO_AuthenticationResponse.class);
                return responseObject;
            }
            else {
                String message = 'Response status: ' + httpResponse.getStatusCode()+' '+httpResponse.getStatus();
                CMN_UTIL_Logger.error(message, 'CMN_API_GetAccessToken.getPingToken');
                throw new TokenException(message);
            }
        } 
        catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetAccessToken.getPingToken');
            throw new TokenException(ex.getMessage());
        }
    }
    
    /**
     * @description mocks a response returned from the Get Access API Token
     */
    @testVisible
    private class AccessTokenMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"token_type": "bearer","access_token": "201423083430380","expires_in": 33414050,"scope": "ojojiosa"}');
            return response;
        }
    }

      /**
     * @description mocks a response returned from the Get Access API Token WITH AN ERROR
     */
    @TestVisible
    private class AccessTokenMockResponseError implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
            response.setBody('{"message": "Sumulated error"}');
            return response;
        }
    }

    private class TokenException extends Exception {}
  
}