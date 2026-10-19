/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :cmn_RelyComply
@description       :Class for dealing with Rely Comply
@ Last Modified By  :Jagadish Thummala  
@ Last Modified On  :29-07-2024
@ Modification description : SFP-40483
***************************************************************************************/
public  class CMN_RelyComply {
    
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_SIGNATURE = 'x-signature';
    private static final String HEADER_CHANNELID = 'x-channel-id';
    private static final String HEADER_SFUG = 'SFUG';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String CLIENT_ID = '{!$Credential.UG_BCB_PPB_RELYCOMPLY_EC.client_id}';
    private static final String INDIVIDUAL_PATH_CALLOUT = '/account-screening/v1/person/screen';    
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';  
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_RelyComply');
    
    
    /** 
* @description This method used for main callout for individual screening 
* @param applicationList
* @param applicationParticipantList
* @return Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> applicationParticipantList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> response =  makeRelyComplyIndividualScreening(applicationList,applicationParticipantList);
            if(response != null && (response.containsKey('ErrorDescription') == true || response.containsKey('moreInformation') == true)) {
                BCB_FlowController.createVerificationRecordForParticipant(applicationParticipantList[0], 'Rely Comply', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Sanctioned Customer_Queue'); 
            }
            return JSON.serialize(response);
        }
        
        return null;
    }
    /** 
* @description This method used for main callout that is alert CorpAdd 
* @param applicationRecords
* @param applicationParticipantList
* @return Map<String, Object> responseToReturnObject
*/
    public static Map<String, Object> makeRelyComplyIndividualScreening(List<Application__c> applicationRecords, List<Application_Participant__c> applicationParticipantList) {
    Application__c applicationRecord = applicationRecords[0];
    Application_Participant__c applicationParticipantRecord = applicationParticipantList[0];

    BCB_RelyComplyBean.individualScreening individualScreening = createIndividualScreening(applicationRecord, applicationParticipantRecord);

    CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.relyComplyWebServices();
    String accessToken = CMN_SRV_RelyComply.getAccessToken();
    Map<String, Object> responseToReturnObject = new Map<String, Object>();
    if (System.Test.isRunningTest()) {
            setupTestMock();
        }

   if (String.isBlank(accessToken)) {
        return handleAccessTokenFailure(responseToReturnObject, applicationParticipantRecord);
    }  
        HttpRequest httpRequest = createHttpRequest(individualScreening, accessToken, webServiceSetting);
        HttpResponse httpResponse = sendHttpRequest(httpRequest);
        handleHttpResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        return responseToReturnObject;
}

    private static BCB_RelyComplyBean.individualScreening createIndividualScreening(Application__c applicationRecord, Application_Participant__c applicationParticipantRecord) {
        BCB_RelyComplyBean.individualScreening individualScreening = new BCB_RelyComplyBean.individualScreening();
        individualScreening.identifier = applicationParticipantRecord.AOB_IDNumber__c;
        individualScreening.firstName = applicationParticipantRecord.CNGCU_First_Name__c;
        individualScreening.lastName = applicationParticipantRecord.CNGCU_Last_Name__c;
        individualScreening.nationality = applicationRecord.AOB_Country__c;
        individualScreening.residence = applicationRecord.AOB_Country__c;
        individualScreening.birthDate = String.valueOf(applicationParticipantRecord.AOB_DateofBirth__c);

        Integer numOfYears = System.today().year() - applicationParticipantRecord.AOB_DateofBirth__c.year();
        individualScreening.clientType = getClientType(applicationRecord.AOB_Country__c, numOfYears);
        individualScreening.occupationCategory = 'self_employed';
        individualScreening.bankProduct = 'Transactional';

        return individualScreening;
    }

    private static String getClientType(String country, Integer numOfYears) {
        if (country == 'UG') {
            return numOfYears >= 18 ? 'A5A' : 'A5C';
        }
        return numOfYears >= 18 ? 'A5B' : 'A5D';
    }

    private static void setupTestMock( ) {
        if (mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
    }

    private static Map<String, Object> handleAccessTokenFailure(Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        responseToReturnObject.put('status', 'FAILED');
        responseToReturnObject.put('ErrorDescription', 'Access Token Failure');
        LOGGER.error('CMN_RelyComply.makeRelyComplyIndividualScreening: Access Token Failure', new String[] {'CMN_RelyComply.makeRelyComplyIndividualScreening', applicationParticipantRecord.Id});
        return responseToReturnObject;
    }

    private static HttpRequest createHttpRequest(BCB_RelyComplyBean.individualScreening individualScreening, String accessToken, CMN_WebserviceSetting__mdt webServiceSetting) {
        
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        Blob data = Blob.valueOf(JSON.serialize(individualScreening));
        if (!System.Test.isRunningTest()){
                Blob result = Crypto.sign('RSA-SHA256', data, EncodingUtil.base64Decode(webServiceSetting.CMN_AdditionalKey__c));      
        httpRequest.setHeader(HEADER_SIGNATURE, EncodingUtil.base64Encode(result));
        }
        httpRequest.setHeader(HEADER_CLIENT_ID, CLIENT_ID);
        httpRequest.setHeader(HEADER_CHANNELID, HEADER_SFUG);
        httpRequest.setEndpoint('callout:UG_BCB_PPB_RELYCOMPLY' + INDIVIDUAL_PATH_CALLOUT);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setBody(JSON.serialize(individualScreening));
        httpRequest.setTimeout(120000);

        return httpRequest;
    }

    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        Http http = new Http();
        return http.send(httpRequest);
    }

    private static void handleHttpResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            handleSuccessResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        } else {
            handleErrorResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        }
    }

    private static void handleSuccessResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        String responseBody = httpResponse.getBody();
        if (String.isNotBlank(responseBody)) {
            BCB_RelyComplyIndiScreeningResponse individualResponse = (BCB_RelyComplyIndiScreeningResponse) JSON.deserialize(responseBody, BCB_RelyComplyIndiScreeningResponse.class);
            responseToReturnObject.put('status', 'SUCCESS');
            responseToReturnObject.put('statusCode', 200);
            responseToReturnObject.put('assessmentId', individualResponse.assessmentId);
            responseToReturnObject.put('assessmentStatus', individualResponse.result);
        } else {
            responseToReturnObject.put('status', 'SUCCESS');
            responseToReturnObject.put('statusCode', 200);
            responseToReturnObject.put('ErrorDescription', 'No response body');
            LOGGER.error('CMN_RelyComply.makeRelyComplyIndividualScreening: No response body', new String[] {'CMN_RelyComply.makeRelyComplyIndividualScreening', applicationParticipantRecord.Id});
        }
    }

    private static void handleErrorResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        String errorMessage = 'No Response From Server';
        if (String.isNotBlank(httpResponse.getBody())) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
            responseToReturnObject.put('status', 'FAILED');
            responseToReturnObject.put('statusCode', httpResponse.getStatusCode());
            responseToReturnObject.put('ErrorDescription', errorMessage);
            LOGGER.error('CMN_RelyComply.makeRelyComplyIndividualScreening: Response status: Need more Information', new String[] {'CMN_RelyComply.makeRelyComplyIndividualScreening', applicationParticipantRecord.Id, JSON.serialize(responseObject)});
        } else {
            responseToReturnObject.put('status', 'FAILED');
            responseToReturnObject.put('statusCode', httpResponse.getStatusCode());
            responseToReturnObject.put('ErrorDescription', errorMessage);
        }
    }  
}