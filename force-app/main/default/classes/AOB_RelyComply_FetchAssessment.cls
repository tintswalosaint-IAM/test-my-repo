/***************************************************************************************
@ Author            :Jagadish Thummala.
@ Date              :July 2024
@ Name of the Class :AOB_RelyComply_FetchAssessment
@ Description       : This class is used to fetch the Assessment done by the rely comply screening after a 30sec delay
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :22/07/2024.
@ Modification Description : SFP-40417
***************************************************************************************/
public without sharing class AOB_RelyComply_FetchAssessment {
    private AOB_RelyComply_FetchAssessment(){}
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
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_RelyComply_FetchAssessment');

    /**
     * @param applicationList List of applications.
     * @param assessmentId assessmentId received from relycomply screening.
     * @return A stringified response to be sent to AOB_FlowController.
     */    
    public static String invokeFetchAssessmentCallout(List<Application__c> applicationList, String assessmentId) {
        Application__c appRecord = new SEL_Application().selectAppById(applicationList[0].Id);
        if (applicationList.isEmpty()) {
            return null;
        }
    
        Map<String, Object> responseStatus = makeRelyComplyFetchAssessment(applicationList[0],assessmentId);
        String assessmentStatus = (String) responseStatus.get('assessmentStatus');
        String assessmentIdResp = (String) responseStatus.get('assessmentId');
        String sanctionStatus = (String) responseStatus.get('sanctionStatus');
        String pepStatus = (String) responseStatus.get('PEPStatus');
        
        Verification__c verificationInstance = new Verification__c(
            Application__c = applicationList[0].Id,
            Verification_Source__c = 'Rely Comply'
        );
    
        boolean isSuccess = responseStatus != null 
            && 'SUCCESS'.equals(responseStatus.get('status')) 
            && 'NotMatch'.equals(responseStatus.get('sanctionStatus')) 
            && 'NotMatch'.equals(responseStatus.get('PEPStatus'));
        
        verificationInstance.Verification_Status__c = isSuccess ? 'Success' : 'Failed';
        verificationInstance.AOB_DSX_Response__c = isSuccess ? 'RelyComply assessmentId : ' + assessmentIdResp : string.valueOf(responseStatus);
        verificationInstance.AOB_Risk_Score_Status__c = assessmentStatus;
        appRecord.AOB_Sanction_Status__c = 'Match'.equals(sanctionStatus) ? 'ACTIVE' : (sanctionStatus == null ? '' : sanctionStatus);
        appRecord.AOB_PEP_Status__c = 'Match'.equals(pepStatus) ? 'ACTIVE' : (pepStatus == null ? '': pepStatus);
    
        update appRecord;
        AOB_FlowController.createVerificationWithInstance(verificationInstance);
        return JSON.serialize(responseStatus);
    }
    /**
     * @param applicationList List of Application__c.
     * @param assessmentId assessmentId received from relycomply screening.
     * @return A stringified response to be sent to AOB_FlowController.
     */     
    
    public static Map<String, Object> makeRelyComplyFetchAssessment(Application__c applicationRecord, String assessmentId) {
        String endpoint = '?assessmentId=' + assessmentId;
        String accessToken = CMN_SRV_RelyComply.getAccessToken();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if (String.isNotBlank(accessToken)) {
            HttpRequest httpRequest = setupHttpRequest(accessToken, endpoint);
            try {
                HttpResponse httpResponse = sendHttpRequest(httpRequest);
                responseToReturnObject = processHttpResponse(httpResponse);
            } catch (Exception ex) {
                LOGGER.error('AOB_RelyComply_FetchAssessment.makeRelyComplyFetchAssessment: Unhandled Exception',new String[] {applicationRecord.Id, ex.getMessage()});
                responseToReturnObject.put('status', 'FAILED');
                responseToReturnObject.put('ErrorDescription', ex.getMessage());
            }
        } else {
            LOGGER.error('AOB_RelyComply_FetchAssessment.makeRelyComplyFetchAssessment: Access Token Failure', 
                        new String[] {applicationRecord.Id});
            responseToReturnObject.put('status', 'FAILED');
            responseToReturnObject.put('ErrorDescription', 'Access Token Failure');
        }
        return responseToReturnObject;
    }
    /**
     * @param webServiceSetting Metadata from the websettings.
     * @param accessToken accessToken received from relycomply accessToken.
     * @param endpoint concatinated endpoint from custom metatadata type
     * @return httpRequest
     */ 
    private static HttpRequest setupHttpRequest( String accessToken, String endpoint) {
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_ID,CLIENT_ID);
        httpRequest.setHeader(HEADER_CHANNELID, HEADER_SFUG);
        httpRequest.setEndpoint('callout:UG_BCB_PPB_RELYCOMPLY'+ FETCH_ASSESSMENT_PATH_CALLOUT + endpoint);
        httpRequest.setMethod(HTTP_METHOD_GET);
        httpRequest.setTimeout(120000);
        return httpRequest;
    }
    /**
     * @param httpRequest this is to be used by test class 
     * @return httpRequest
     */ 
    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        Http http = new Http();
        if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
            BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
        return http.send(httpRequest);
    }

    /**
     * @param httpResponse response for further processing
     * @param applicationRecord Application__c record.
     * @return A stringified response to be sent to AOB_FlowController.
     */ 
    private static Map<String, Object> processHttpResponse(HttpResponse httpResponse) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (httpResponse == null) {
            responseToReturnObject = new Map<String, Object>{
                'status' => 'FAILED', 
                'errorMessage' => 'Exception occurred while sending HTTP request'};
            return responseToReturnObject;
        }
        String responseBody = httpResponse.getBody();
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            responseToReturnObject = parseResponse(responseBody);
        } else {
            responseToReturnObject = handleErrorHttpResponse(httpResponse, responseBody);
        }
        return responseToReturnObject;
    }
 
    /**
     * Parses the HTTP response body and extracts relevant information.
     * @param responseBody The body of the HTTP response.
     * @return A map containing the parsed response data, such as PEP status and sanction status.
     */
    private static Map<String, Object> parseResponse(String responseBody) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (String.isNotBlank(responseBody)) {  
            AOB_DTO_RelyComply_Individual_Screening individualResponse =  (AOB_DTO_RelyComply_Individual_Screening)JSON.deserialize(responseBody, AOB_DTO_RelyComply_Individual_Screening.class);
            
            // Variables to store the mapped outcomes
            String sanctionScreening = '';
            String PEPStatus = '';
    
            // Iterate through the cases and map the outcomes
            for (AOB_DTO_RelyComply_Individual_Screening.cases caseItem : individualResponse.cases) {
                if (caseItem.name == 'ug_salesforce_sanctions_screening') {
                    sanctionScreening = caseItem.outcome;
                } else if (caseItem.name == 'ug_salesforce_pep_screening') {
                    PEPStatus = caseItem.outcome;
                }
            }

            responseToReturnObject = new Map<String, Object>{
                'status' => 'SUCCESS', 
                'statusCode' => 200, 
                'assessmentId' => individualResponse.assessmentId,
                'assessmentStatus' => individualResponse.result,
                'sanctionStatus' => sanctionScreening,
                'PEPStatus' => PEPStatus
            };
            
        } else {
            responseToReturnObject = new Map<String, Object>{
                'status' => 'NO_CONTENT',
                'statusCode' => 204,
                'ErrorDescription' => 'No response body'
            };
            
            LOGGER.error('AOB_RelyComply_FetchAssessment.parseResponse: No response body');
        }
    
        return responseToReturnObject;
    }
    
 
    /**
     * Handles error responses from the HTTP request.
     * @param httpResponse The HTTP response received.
     * @param responseBody The body of the HTTP response.
     * @param applicationRecord The application record related to the response.
     * @return A map containing the error response data, including status, error message, and HTTP status code.
     */
    private static Map<String, Object> handleErrorHttpResponse(HttpResponse httpResponse, String responseBody) {
        String errorMessage = 'No Response From Server';
        if (String.isNotBlank(responseBody)) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }
        Map<String, Object> responseToReturnObject = new Map<String, Object>{
            'status' => 'FAILED', 
            'statusCode' => httpResponse.getStatusCode(),
            'ErrorDescription' => errorMessage,
            'responseBody' =>responseBody
        };
       Logger.error('AOB_RelyComply_FetchAssessment:Response status: ' + httpResponse.getStatusCode(), new string[]{errorMessage});
        return responseToReturnObject;
    } 
 }