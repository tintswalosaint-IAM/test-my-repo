/***************************************************************************************
@ Author            :jagadish thummala
@ Date              :May 2023
@ Name of the Class :CMN_SignatureVerify
@description       :This component is used to upload signature files and verify.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-07-2023
@ Modification Description : SFP-26347
***************************************************************************************/
public without sharing class CMN_SignatureVerify {
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'Accept';
    private static final String HEADER_CONTENT_TYPE = 'Content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret'; 
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String SIGNATURE_VERIIFICATION = 'Signature Verification';
    private static final String SUCCESS = 'SUCCESS';
    private static final String SUCCESS_SMALL = 'Success';
    private static final String FAILED = 'Failed';
    private static final String STATUS = 'status';
 
 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_SignatureVerify');
 
 
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/signature/verification';
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
    
    /**
    * @description Method to invoke Signature Verification from flow controller
    * @param participantList
    * @param  documentList
    * @return Stringified Response from the callout
    */
    public static String invocableMethod(List<Application_Participant__c> participantList, List<ContentVersion> documentList)  {
        List<Application__c> applicationList = new SEL_Application().selectAppsById(participantList[0].Application__c);
  
        if(participantList.isEmpty() == false) {
            Map<String, Object> responseObject = makeSignatureVerificationCallOut(participantList, documentList);
  
            if(responseObject != null && (String) responseObject.get(STATUS) == SUCCESS) {
                BCB_CTRL_FormCreator.createVerificationRecord(participantList[0], SIGNATURE_VERIIFICATION, SUCCESS_SMALL);
            } else {
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');           
                BCB_CTRL_FormCreator.createVerificationRecord(participantList[0], SIGNATURE_VERIIFICATION, FAILED);
            }
            return JSON.serialize(responseObject);
        }
        return null;
    }
    /** 
    * @description This method used for main callout signature verification API
    * @param participantList
    * @param documentList
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> makeSignatureVerificationCallOut(List<Application_Participant__c> participantList, List<ContentVersion> documentList) {
        
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(!(participantList != null && documentList != null)) {
            return responseToReturnObject;
        }
        Application_Participant__c participantRecord = participantList[0];
        
        BCB_SignatureVerifyBean.BodyInfo bodyRecord = new BCB_SignatureVerifyBean.BodyInfo();
        BodyRecord.signatureAddRequest = constructBeanBody(participantList, documentList);
 
        BCB_SignatureVerifyBean signatureVerificationRecord = new BCB_SignatureVerifyBean();
        signatureVerificationRecord.Body = bodyRecord;
 
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_CTRL_FormCreator.createGUID();
 
        string bcbAccessToken = CMN_SRV_GetAccessToken.getAccessToken();
        if(bcbAccessToken == null) {
            LOGGER.error('CMN_SignatureVerify:Access Token Failure',new String[] {'CMN_SignatureVerify.makeSignatureVerificationCallOut', participantRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
            return responseToReturnObject;
        }
 
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, bcbAccessToken);
        
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
        httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
        
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setBody(JSON.serialize(signatureVerificationRecord));
        httpRequest.setTimeout(120000);

        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
             BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
            httpResponse = http.Send(httpRequest);
            responseToReturnObject = constructResponse(httpResponse, participantRecord);
        } catch (Exception ex) {
            LOGGER.error('CMN_SignatureVerify:Some Un-Handled Exception Occurred',new String[] {'CMN_SignatureVerify.makeSignatureVerificationCallOut', participantRecord.Id},ex);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
        }
        
        return responseToReturnObject;
    }
 
    /** 
    * @description Method to construct response map based on the callout response
    * @param httpResponse
    * @param participantRecord
    * @return Returns a cosntructed callout response in map format for remaining processing
    */
    private static Map<String, Object> constructResponse(HttpResponse httpResponse, Application_Participant__c participantRecord) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        String responseBody = httpResponse.getBody();
       
        if (responseBody == null) {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_MobileNumberValidate:No response body',new String[] {'CMN_SignatureVerify.makeSignatureVerificationCallOut', participantRecord.Id});
            return responseToReturnObject;
        }
        
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if(responseObject != null && responseObject.containsKey('ErrorDescription') == true) {
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => responseObject.get('ErrorDescription')};
            }else if(responseObject != null && responseObject.containsKey('signatureAddResponse') == true) {
                Map<String, Object> signatureReponse = (Map<String, Object>) responseObject.get('signatureAddResponse');
                string statusReponse = (string) signatureReponse.get('signatureAddStatusCode');
                
                    if(Boolean.valueOf(statusReponse)== false){
                        
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'signatureAddStatusCode is false'};
                    }
            }    
            if(responseToReturnObject.isEmpty() == true) {
                responseToReturnObject.put('status', 'SUCCESS');
            }
        } else {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => responseObject.get('moreInformation')};
            LOGGER.error('CMN_SignatureVerify:Response status:FAILED ',new String[] {'CMN_SignatureVerify.makeSignatureVerificationCallOut',json.serialize(responseToReturnObject), participantRecord.Id});
        }
 
        return responseToReturnObject;
    }
 
    /** 
    * @description Method to construct Request Body for signature and picture
    * @param participantList
    * @param documentList
    * @return Returns a prepared request for signature and picture file
    */
    private static BCB_SignatureVerifyBean.SignatureAddRequestInfo constructBeanBody(List<Application_Participant__c> participantList, List<ContentVersion> documentList) {
        List<Application__c> applicationList = new SEL_Application().selectAppsById(participantList[0].Application__c);
        BCB_SignatureVerifyBean.SignatureAddRequestInfo signatureAddRequestRecord = new BCB_SignatureVerifyBean.SignatureAddRequestInfo();
        signatureAddRequestRecord.customerNumber  = applicationList[0].AOB_Customer_Id__c;
        signatureAddRequestRecord.accountNumber  = applicationList[0].AOB_Account_Number__c;
        signatureAddRequestRecord.bankIdentifier  =  applicationList[0].AOB_Country__c; 
        signatureAddRequestRecord.imageAccessCode = '01';
        if(documentList != null || documentList.isEmpty() == false) {
            signatureAddRequestRecord.signatureFile	= String.valueOf(EncodingUtil.base64Encode(documentList[0].VersionData));
            signatureAddRequestRecord.pictureFile = String.valueOf(EncodingUtil.base64Encode(documentList[1].VersionData));
         }      
        return signatureAddRequestRecord;
       }
 }