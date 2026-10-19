/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :CMN_RelyComplyFetchAssessment
@description       :Test Class for dealing with Rely Comply
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :25-05-2023
@Modification Description : SFP-26345
***************************************************************************************/
public class CMN_RelyComplyFetchAssessment {
    
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CHANNELID = 'x-channel-id';
    private static final String HEADER_SFUG = 'SFUG';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_GET = 'GET';
    private static final String CLIENT_ID = '{!$Credential.UG_BCB_PPB_RELYCOMPLY_EC.client_id}';

    private static final String FETCH_ASSESSMENT_PATH_CALLOUT = '/account-screening/v1/status/fetch';    
    
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_RelyComplyFetchAssessment');
    
    /** 
* @description This method used for main callout for individual screening 
* @param applicationList
* @param applicationParticipantList
* @param screenName
* @return Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> applicationParticipantList,string screenName)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> response =  makeRelyComplyFetchAssessment(applicationList,applicationParticipantList,screenName);
            
            if(response != null && response.containsKey('ErrorDescription') == true) {
                BCB_FlowController.createVerificationRecordForParticipant(applicationParticipantList[0], 'Rely Comply', 'Failed');
            }
            return JSON.serialize(response);
        }
        
        return null;
    }
    
    /** 
* @description This method used for main callout for individual screening 
* @param applicationRecords
* @param applicationParticipantList
* @param screenName
* @return Returns a callout response in stringified format to process in the UI
*/
    public static Map<String, Object> makeRelyComplyFetchAssessment(List<Application__c> applicationRecords, List<Application_Participant__c> applicationParticipantList, String screenName) {
    Application__c applicationRecord = applicationRecords[0];
    Application_Participant__c applicationParticipantRecord = applicationParticipantList[0];
    Map<String, Object> mapAssessmentId = extractAssessmentId(applicationRecord, applicationParticipantRecord, screenName);
    String assessmentId = (String) mapAssessmentId.get(screenName == 'IDV' ? 'individualAssessmentId' : 'businessAssessmentId');
    String endpoint = '?assessmentId=' + assessmentId;

    String accessToken = CMN_SRV_RelyComply.getAccessToken();
    Map<String, Object> responseToReturnObject = new Map<String, Object>();

    if (System.Test.isRunningTest()) {
        setupTestMock();
    }
    if (String.isBlank(accessToken)) {
        return handleAccessTokenFailure(responseToReturnObject, applicationParticipantRecord);
    }
    HttpRequest httpRequest = createHttpRequestForFetchAssessment(endpoint, accessToken);
    HttpResponse httpResponse = sendHttpRequest(httpRequest);
    handleFetchAssessmentResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
    return responseToReturnObject;
    }

    private static Map<String, Object> extractAssessmentId(Application__c applicationRecord, Application_Participant__c applicationParticipantRecord, String screenName) {
        Map<String, Object> mapAssessmentId = new Map<String, Object>();
        if (screenName == 'IDV') {
            String inflightData = applicationParticipantRecord.Inflight__c;
            mapAssessmentId = (Map<String, Object>) JSON.deserializeUntyped(inflightData);
        } else if (screenName == 'Uganda MVP2 Company Details') {
            String inflightData = applicationRecord.Inflight__c;
            mapAssessmentId = (Map<String, Object>) JSON.deserializeUntyped(inflightData);
        }
        return mapAssessmentId;
    }

    private static void setupTestMock() {
        if (mockHttpStatusCode != null && mockHttpStatus != null) {
            BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
    }

    private static Map<String, Object> handleAccessTokenFailure(Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        LOGGER.error('CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment: Access Token Failure', new String[] { 'CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment', applicationParticipantRecord.Id });
        responseToReturnObject.put('status', 'FAILED');
        responseToReturnObject.put('ErrorDescription', 'Access Token Failure');
        return responseToReturnObject;
    }

    private static HttpRequest createHttpRequestForFetchAssessment(String endpoint, String accessToken) {
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_ID, CLIENT_ID);
        httpRequest.setHeader(HEADER_CHANNELID, HEADER_SFUG);
        httpRequest.setEndpoint('callout:UG_BCB_PPB_RELYCOMPLY' + FETCH_ASSESSMENT_PATH_CALLOUT + endpoint);
        httpRequest.setMethod(HTTP_METHOD_GET);
        httpRequest.setTimeout(120000);

        return httpRequest;
    }

    private static HttpResponse sendHttpRequest(HttpRequest httpRequest){
        Http http = new Http();
        return http.send(httpRequest);
    }

    private static void handleFetchAssessmentResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
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
                LOGGER.error('CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment: No response body', new String[] { 'CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment', applicationParticipantRecord.Id });
            }
        } else {
            handleErrorResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        }
    }

    private static void handleErrorResponse(HttpResponse httpResponse, Map<String, Object> responseToReturnObject, Application_Participant__c applicationParticipantRecord) {
        String errorMessage = 'No Response From Server';
        if (httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
            LOGGER.error('CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment: Response status:FAILED Need More Information', new String[] { 'CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment', applicationParticipantRecord.Id, JSON.serialize(responseObject) });
        }
        responseToReturnObject.put('status', 'FAILED');
        responseToReturnObject.put('statusCode', httpResponse.getStatusCode());
        responseToReturnObject.put('ErrorDescription', errorMessage);
        LOGGER.error('CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment: Response status:FAILED', new String[] { 'CMN_RelyComplyFetchAssessment.makeRelyComplyFetchAssessment', applicationParticipantRecord.Id, JSON.serialize(responseToReturnObject) });
    }   
}