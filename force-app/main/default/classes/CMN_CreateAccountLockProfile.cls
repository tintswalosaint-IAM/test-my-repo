/**
* @description CMN_CreateAccountLockProfile will be called for locking of the account number.
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story number : SFP-25772
*/
public class CMN_CreateAccountLockProfile {
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
    private static final String PATH_CALLOUT = '/account-lock/profile';
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = ''; 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CreateAccountLockProfile');
    
    
    /** 
* @description This method used for main callout CMN_CreateAccountLockProfile
* @param applicationList
* @param appParticipant
* @return Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> appParticipant) {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            
            Map<String, Object> response =  makeAccountLockProfileCallout(applicationList,appParticipant);
            
            if(response != null && response.containsKey('ErrorDescription') == true) {
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Debit freeze', 'Failed');
              
                
            } 
            return JSON.serialize(response);
        }
        
        return null;
    }
    
    /** 
* @description This method used for main callout that is CMN_CreateAccountLockProfile API 
* @param applicationRecords
* @param appParticipant
* @return  responseToReturnObject
*/
    
    public static Map<String, Object> makeAccountLockProfileCallout(List<Application__c> applicationRecords,List<Application_Participant__c> appParticipant) {
        Application__c applicationRecord = applicationRecords[0];
        Application_Participant__c applicationParticipant =  appParticipant[0];
        
        BCB_CreateAccountLockProfileBean accountLockProfileBean = new BCB_CreateAccountLockProfileBean();
        
        accountLockProfileBean.lockIndicator = 'F';
        accountLockProfileBean.accountNumber = applicationRecord.AOB_Account_Number__c;
        accountLockProfileBean.lockCode = 'D';
        accountLockProfileBean.lockReason = '999';
        accountLockProfileBean.modLockIndicator = 'N';
        accountLockProfileBean.lockRemarks = 'Debit Freeze on Account';
        
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
            httpRequest.setBody(JSON.serialize(accountLockProfileBean));
            httpRequest.setTimeout(120000);
            
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                sendMockResponse();
                
                httpResponse = http.Send(httpRequest);
                
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    responseToReturnObject =  sendApiResponse(responseBody,applicationRecord,applicationParticipant);
                } else {
                    responseToReturnObject =  sendNoResponse(httpResponse,applicationRecord,applicationParticipant);
                    
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_CreateAccountLockProfile.makeAccountLockProfileCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CreateAccountLockProfile.makeAccountLockProfileCallout', applicationParticipant.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_CreateAccountLockProfile.makeAccountLockProfileCallout:Access Token Failure', new String[] {'CMN_CreateAccountLockProfile.makeAccountLockProfileCallout', applicationParticipant.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
    private static void sendMockResponse(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }
        }
    }
    private static map<string,object> sendApiResponse(string responseBody,Application__c applicationRecord,Application_Participant__c applicationParticipant ){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (responseBody != null) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            LOGGER.error('CMN_CreateAccountLockProfile.makeAccountLockProfileCallout: Status : SUCCESS', new String[] {'CMN_CreateAccountLockProfile.makeAccountLockProfileCallout', applicationParticipant.Id});
            
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                LOGGER.error('CMN_CreateAccountLockProfile.makeAccountLockProfileCallout: No response body', new String[] {'CMN_CreateAccountLockProfile.makeAccountLockProfileCallout', applicationParticipant.Id});
            
        }
        return responseToReturnObject;
    }
    private static map<string,object> sendNoResponse(HttpResponse httpResponse,Application__c applicationRecord,Application_Participant__c applicationParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        String errorMessage = 'No Response From Server';
        if(httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_CreateAccountLockProfile.makeAccountLockProfileCallout:Response status:FAILED', new String[] {'CMN_CreateAccountLockProfile.makeAccountLockProfileCallout', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
        
        return responseToReturnObject;
    }
}