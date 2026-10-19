/**
* @description Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date june 2022
*/
public class AOB_AccessTokenGenerator {
    
    //HTTP Constants
    private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    private static final String AUTHORIZATION_TYPE_BASIC = 'Basic ';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String HTTP_METHOD_POST = 'POST';

    //Generic Constants
    private static final String PARAM_COLON = ':';
    //API specific
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    // Using for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';

     /** 
    * @description This method is using for generating Access Token  
    * @param scope
    * @return Returns a callout response in map format for remaining processing
    */
    public static CMN_DTO_AuthenticationResponse getAccessToken(String scope) {
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        //Prepare Request
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_TOKEN;
        String requestBody = String.format(webServiceSetting.CMN_Path__c, new List<String> {scope});
        
        HttpRequest httpRequest = AOB_APIHandler.clientToken(AUTHORIZATION_TYPE_BASIC, webServiceSetting);
        
        //Set Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
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
                if(mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                } else {
                    System.Test.setMock(HttpCalloutMock.class, new AccessTokenMockResponse());
                }
            }
            httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (responseBody != null) {
                    CMN_DTO_AuthenticationResponse responseObject =
                        (CMN_DTO_AuthenticationResponse) JSON.deserialize(responseBody, CMN_DTO_AuthenticationResponse.class);
                    return responseObject;
                }
                else {
                    CMN_UTIL_Logger.error('No response body', 'CustomerAlertSubscription.getAccessToken');
                }
            }
            else {
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), 'CustomerAlertSubscription.getAccessToken');
            }
        } catch(Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CustomerAlertSubscription.getAccessToken');
        }
        return null;
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
}