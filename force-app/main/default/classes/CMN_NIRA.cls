/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :May 2023
@ Name of the Class :CMN_NIRA
@description       :Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-05-2023
@ Modification Description : SFP-24855
***************************************************************************************/
/**
 * @description  Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper
 */
public  class CMN_NIRA {
    
    
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
    private static final String PATH_CALLOUT = '/nira/personal-information';    

    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_NIRA');
    /** 
    * @description This method used for invoking the main callout method 
    * @param participantList
    * @return String Returns a callout response in map format for remaining processing
    */
    public static String invocableMethod(List<Application_Participant__c> participantList)  {
        List<Application__c> applicationList = new SEL_Application().selectAppsById(participantList[0].Application__c);

        if(participantList != null && participantList.isEmpty() == false) {
            Map<String, Object> responseMap = makeNIRACallout(participantList[0]);
            if(responseMap != null && responseMap.isEmpty() == false 
                && responseMap.containsKey('matchingStatus') && (String) responseMap.get('matchingStatus') == 'true') {
                    BCB_CTRL_FormCreator.createVerificationRecord(participantList[0], 'NIRA', 'Success');
            } else {
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');  
                BCB_CTRL_FormCreator.createVerificationRecord(participantList[0], 'NIRA','Failed');
            }
            return JSON.serialize(responseMap);
        }
        return null;
    }
    /** 
    * @description This method used for invoking NIRA callout
    * @param participantRecord
    * @return Map<String, Object> Returns a callout response in map format for remaining processing
    */
    private static Map<String, Object> makeNIRACallout(Application_Participant__c participantRecord) {
        string appid = participantRecord.Application__c;
       
        
       
        BCB_NiraBean requestParams = new BCB_NiraBean(
            Datetime.newInstance(participantRecord.AOB_DateofBirth__c, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy'),
            participantRecord.AOB_Card_Number__c,
           (participantRecord.AOB_Preferred_Name__c != null ? participantRecord.AOB_Preferred_Name__c : ''),
            participantRecord.CNGCU_First_Name__c, 
            participantRecord.AOB_IDNumber__c,
            participantRecord.CNGCU_Last_Name__c
        );
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();        

        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();
        string bcbAccessToken = CMN_SRV_GetAccessToken.getAccessToken();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(String.isNotBlank(bcbAccessToken) == true) {
        
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, bcbAccessToken);

            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(requestParams));
            httpRequest.setTimeout(120000);

            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
            
                if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                    BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                }
            
                httpResponse = http.Send(httpRequest);
            
                if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (responseBody != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        Map<String, Object> verifyPersonInformationResponse = (Map<String, Object>) responseObject.get('verifyPersonInformationResponse');
                        responseToReturnObject = (Map<String, Object>) verifyPersonInformationResponse.get('return');
                        responseToReturnObject.put('statusCode', 200);
                    } else {
                        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                        LOGGER.error('CMN_NIRA.makeNIRACallout: No response body', new String[] {'CMN_NIRA.makeNIRACallout', participantRecord.Id});
                    }
                } else {
                    String errorMessage = 'No Response From Server';
                    if (httpResponse.getBody() != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                    }
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                    LOGGER.error('CMN_NIRA.makeNIRACallout:Response status:FAILED', new String[] {'CMN_NIRA.makeNIRACallout', participantRecord.Id, JSON.serialize(responseToReturnObject)});
                }
            } catch (Exception ex) {
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                LOGGER.error('CMN_NIRA.makeNIRACallout:Some Un-Handled Exception Occurred', new String[] {'CMN_NIRA.makeNIRACallout', participantRecord.Id,JSON.serialize( ex.getMessage())});
            }
            
        } else {
           LOGGER.error('CMN_NIRA.makeNIRACallout:Access Token Failure', new String[] {'CMN_NIRA.makeNIRACallout', participantRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
        }
        return responseToReturnObject;
    }
    
}