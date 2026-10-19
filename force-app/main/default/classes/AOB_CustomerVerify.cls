/**
* @description Dealing with a customer get in class API to determine if a CIF ID is already in the system or not
* @author Amarnath Reddy(amarnath.reddy@standardbank.co.za)
* @date July 2022
*/

public class AOB_CustomerVerify {

   	//HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'Accept';
    private static final String HEADER_CONTENT_TYPE = 'Content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD = 'GET';

    //Generic Constants
    private static final String PARAM_COLON = ':';

    //API specific
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/external-partners/customers/';
    
    //using for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    
    /** 
    * @description This method used for invocableMethod
    * @param applicationList
    * @return Returns a callout response in map format for remaining processing
    */
    public static String invocableMethod(List<Application__c> applicationList)  {

        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> responseObject = makeGETCustomerVerifyCallout(applicationList);
            if(responseObject != null && (String) responseObject.get('status') == 'SUCCESS') {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer 3.0.0 Verify', 'Success');
            } else {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer 3.0.0 Verify', 'Failed');
            }
            return JSON.serialize(responseObject);
        }
        return null;
    }

    /** 
    * @description This method is used for main callout Customer verify API
    * @param applicationRecords
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> makeGETCustomerVerifyCallout(List<Application__c> applicationRecords) {

        Application__c applicationRecord = applicationRecords[0];
        //pending
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();

        //pending
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT + applicationRecord.AOB_Customer_Id__c;
        String fApiInteractionId = AOB_FlowController.createGUID();
	
        //pending
        CMN_DTO_AuthenticationResponse accessTokenResponse = AOB_AccessTokenGenerator.getAccessToken('customer prod');
		
        Map<String, Object> responseToReturnObject = new Map<String, Object>();

        if(String.isNotBlank(accessTokenResponse.access_token) == true) {

            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessTokenResponse.access_token);
            //Set HTTP Request Headers
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            
            //Set Request Details
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD);
            httpRequest.setTimeout(120000);

            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest()) {
                     if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                    	AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                    }
                }
                httpResponse = http.Send(httpRequest);

                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (responseBody != null) {
                        AOB_CustomerVerifyBean responseObject = (AOB_CustomerVerifyBean) JSON.deserialize(responseBody, AOB_CustomerVerifyBean.class);
                        if(responseObject != null && responseObject.customers != null 
                            && responseObject.customers.isEmpty() == false && responseObject.customers[0].uuid != null) {
                            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS'};
                        } else {
                            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED'};
                            responseToReturnObject.put('ErrorDescription', 'Some unexpected error has occurred while processing your application. Please contact your nearest branch');
                        }
                    } else {
                        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                        CMN_UTIL_Logger.error('No response body', null, 'AOB_CustomerVerify.makeGETCustomerVerifyCallout', applicationRecord.Id, null);
                    }
                } else {
                    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => responseObject.get('moreInformation')};
                    CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), (String) responseObject.get('moreInformation'), 'AOB_CustomerVerify.makeGETCustomerVerifyCallout', applicationRecord.Id, null);
                }
            } catch (Exception ex) {
                CMN_UTIL_Logger.error('Some Un-Handled Exception Occurred', ex.getMessage(), 'AOB_CustomerVerify.makeGETCustomerVerifyCallout', applicationRecord.Id, ex);
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
            }
        } else {
            CMN_UTIL_Logger.error('Access Token Failure', null, 'AOB_CustomerVerify.makeGETCustomerVerifyCallout', applicationRecord.Id, null);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
        }

        return responseToReturnObject;
    }

}