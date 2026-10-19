/***************************************************************************************
@ Author            :Lokesh
@ Date              :May 2023
@ Name of the Class :CMN_AlertCorpAdd
@ Story Number      :SFP-26346
@description       :Class for dealing with CMN_AlertCorpAdd api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh
@ Last Modified On  :July 2023
***************************************************************************************/

    /** 
    * @description This method used for main callout alert CorpAdd 
    *
    */
public class CMN_AlertCorpAdd {
     private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
     private static final String HEADER_ACCEPT = 'accept';
     private static final String HEADER_CONTENT_TYPE = 'content-type';
     private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
     private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
     private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
     private static final String HEADER_AUTHORIZATION = 'Authorization';
     private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
     private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
     private static final String HTTP_METHOD_POST = 'POST';
     private static final String PARAM_COLON = ':';

     private static final String PATH_TOKEN = '/sysauth/oauth2/token';
     private static final String PATH_CALLOUT = '/customer-alert/corp/profile';    

     @testVisible private static Integer mockHttpStatusCode;
     @testVisible private static String mockHttpStatus;
     @testVisible private static String mockHttpBody = '';  
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_AlertCorpAdd');


    /** 
    * @description This method used for main callout alert CorpAdd 
    * @param applicationList
    * @return String Returns a callout response in stringified format to process in the UI
    */
     public static String invocableMethod(List<Application__c> applicationList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> response =  makeAlertCorpAddCallout(applicationList);
            if(response != null && response.containsKey('ErrorDescription') == true) {
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Alert Corp Add', 'Failed');
            } 
            return JSON.serialize(response);
        }

        return null;
    }
  
    /** 
    * @description This method used for main callout alert CorpAdd 
    * @param applicationRecords
    * @return Returns a callout response in Map<String, Object> format to process in the UI
    */
    public static Map<String, Object> makeAlertCorpAddCallout(List<Application__c> applicationRecords){
        Application__c applicationRecord = applicationRecords[0];
        BCB_AlertCorpAddBean alertCorpAdd = new BCB_AlertCorpAddBean();
        alertCorpAdd.languageID = 'EN_US';
        alertCorpAdd.customerInternalID = applicationRecord.AOB_Customer_Id__c;
        alertCorpAdd.customerHostID = 'FIN';
        alertCorpAdd.legalName = applicationRecord.AOB_BusinessLegalName__c;

        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
    
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();

        string accessToken = CMN_SRV_GetAccessToken.getAccessToken();

        Map<String, Object> responseToReturnObject = new Map<String, Object>();

        if(String.isNotBlank(accessToken) == true && accessToken != null) {

            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);

            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(alertCorpAdd));
            httpRequest.setTimeout(120000);

            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                sendMockResponse();
                
                httpResponse = http.Send(httpRequest);

                responseToReturnObject = sendApiResponse(httpResponse,applicationRecord);

                
            } catch (Exception ex) {
                LOGGER.error(ex.getMessage(), new String[] {'CMN_AlertCorpAdd.makeAlertCorpAddCallout',ex.getMessage()}, ex);
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
            }
        } else {
            LOGGER.error('Access Token Failure :'+applicationRecord.Id);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
        }
        return responseToReturnObject;
    }
      /** 
    * @description This method used for callout alert CorpAdd 
    * 
    */
    private static void sendMockResponse(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }  
        }
    }
    /** 
    * @description This method used for main callout alert CorpAdd 
    * @param httpResponse
    * @param applicationRecord
    * @return map<string,Object> Returns a callout response in map<string,Object> format to process in the UI
    */
    private static map<string,Object> sendApiResponse(HttpResponse httpResponse, Application__c applicationRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();
            if (responseBody != null) {
                responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            } else {
                responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                LOGGER.error('CMN_AlertCorpAdd.makeAlertCorpAddCallout: No response body', new String[] {'CMN_AlertCorpAdd.makeAlertCorpAddCallout', applicationRecord.Id});
            }
        } else {
            String errorMessage = 'No Response From Server';
            if(httpResponse.getBody() != null) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                errorMessage = (String) responseObject.get('moreInformation');
            }

            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_AlertCorpAdd.makeAlertCorpAddCallout:Response status:FAILED', new String[] {'CMN_AlertCorpAdd.makeAlertCorpAddCallout', applicationRecord.Id, JSON.serialize(responseToReturnObject)});

        }
        return responseToReturnObject;
    }
}