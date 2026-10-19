/***************************************************************************************
@Name of the Class : CMN_SelfRegistration
@description       : Class for dealing with Self Registration api and sending the result to the main container and storing the values in the wrapper.
@Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za) 
@Date              : july 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 29-05-2024
@Modification Description :  SFP-38783
***************************************************************************************/
public without sharing class CMN_SelfRegistration {
    
    //HTTP Constants
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
    
    //API specific
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/self-register/questions';
    //using for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_SelfRegistration');

    
    /**
    * @description Method to invoke Self Registration Controller from flow controller
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static String invocableMethod(List<Application__c> applicationList)  { 
        if(applicationList != null && applicationList.isEmpty() == false) {
            map<string,object> responseObject = new map<string,object>();
            responseObject  =invokeSelfRegistrationQuestionsCallout(applicationList);
            if(responseObject != null && responseObject.containsKey('ErrorDescription') == true) { 
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Self Registration_Questions', 'Failed');
            } 
            return JSON.serialize(responseObject);
        }
        return null;
    }
    
    /**
    * @description This is used for main callout SelfRegistrationQuestions API
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static map<string,object> invokeSelfRegistrationQuestionsCallout(List<Application__c> applicationList) {
        map<string,object> responseToReturnObject = new map<string,object>();

        if(applicationList == null || applicationList.isEmpty() == true) {
            return responseToReturnObject;
        }
        Application__c applicationRecord = applicationList[0];
        
        BCB_SelfRegistrationBean.BodyInfo bodyInfoRecord = new BCB_SelfRegistrationBean.BodyInfo();
        BodyInfoRecord.AccountNumber                      = applicationRecord.AOB_Account_Number__c; 
        BodyInfoRecord.AccountIndicator                   = 'S';
        BodyInfoRecord.customerNumber                     = applicationRecord.AOB_Customer_Id__c;
         
        BCB_SelfRegistrationBean selfRegisterationBeanRecord = new BCB_SelfRegistrationBean();
        selfRegisterationBeanRecord.header = constructHeaderBeanRecord();
        selfRegisterationBeanRecord.body = bodyInfoRecord;
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();
        
        string accessToken = CMN_SRV_GetAccessToken.getAccessToken();
        if(accessToken != null && accessToken != '') {
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
        
            //Set HTTP Request Headers
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            
            //Set Request Details
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(selfRegisterationBeanRecord));
            httpRequest.setTimeout(120000);
            
            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                    BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                }
                httpResponse = http.Send(httpRequest);
                responseToReturnObject = constructResponse(httpResponse, applicationRecord); 
            } catch (Exception ex) {
                LOGGER.error('CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout', applicationRecord.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
            }
        }
        else {
            LOGGER.error('CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout:Access Token Failure', new String[] {'CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout', applicationRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
        }
        return responseToReturnObject;
    }

    /** 
    * @description Method to construct response map based on the callout response
    * @param httpResponse
    * @param applicationRecord
    * @return Returns a cosntructed callout response in wrapper format for remaining processing
    */
    private static map<string,object> constructResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        map<string,object> responseToReturnObject = new map<string,object>();
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();
            if (responseBody != null) {
                responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

            } else {
                responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                LOGGER.error('CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout: No response body', new String[] {'CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout', applicationRecord.Id});

            }
        } else {
            String errorMessage = 'No Response From Server';
            if(String.isNotBlank(httpResponse.getBody()) == true) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                errorMessage = (String) responseObject.get('moreInformation');
            }
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout:Response status:FAILED', new String[] {'CMN_SelfRegistration.invokeSelfRegistrationQuestionsCallout', applicationRecord.Id, JSON.serialize(responseToReturnObject)});
        }

        return responseToReturnObject;
    }

    /** 
    * @description Method to construct Request Body for signature and picture
    * @return Returns a prepared request for signature and picture file
    */
    private static BCB_SelfRegistrationBean.HeaderInfo constructHeaderBeanRecord() {
        BCB_SelfRegistrationBean.HeaderInfo headerInfoRecord = new BCB_SelfRegistrationBean.HeaderInfo();
        
        headerInfoRecord.serviceIdentifier                = 'LGNINT';
        headerInfoRecord.operationFormat                  = 'XML';
        headerInfoRecord.channelIdentifier                = 'I';
        headerInfoRecord.bankIdentifier                   = 'UG';
        headerInfoRecord.ipFormat                         = 'XML';
        headerInfoRecord.loginFlag                        = 2;
        headerInfoRecord.languageIdentifier               = '001';
        headerInfoRecord.isMultirec                       = 'Y';
        headerInfoRecord.userPrincipal                    = 'UG.VUSER4';
        headerInfoRecord.stateMode                        = 'N';
        headerInfoRecord.formIdentifier                   = '7036b33a-7407-4112-b23c-0148f1d8720b';
        headerInfoRecord.accessCode                       = 'N';
        headerInfoRecord.loginType                        = 'SSOLOGIN';
        headerInfoRecord.ipAddress                        = '162.158.48.125';
        headerInfoRecord.deviceIdentifier                 = 'https//smebankinguat.stanbicbank.co.ug/#/registration';
        headerInfoRecord.deviceType                       = '77041240-02e6-4a46-b759-e6a8b582d589';
        headerInfoRecord.machineFingerPrint               = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML like Gecko) Chrome/98.0.4758.80 Safari/537.36';

        return headerInfoRecord;
    }
}