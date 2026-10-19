/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_NIRA
@ Description       :Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper 
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_NIRA {
    private AOB_NIRA(){}
    // HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/nira/personal-information';
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_NIRA');

    /**
     * @description This method used for invoking the main callout method
     * @param applicationList
     * @return Returns a callout response in map format for remaining processing
     */
    public static String invokeNiraCallout(List<Application__c> applicationList) {
        if(applicationList==null || applicationList.isEmpty() == true){
            throw new AuraHandledException('application is null');
        }
        if (applicationList != null && !applicationList.isEmpty()) {
            Map<String, Object> responseMap = makeNIRACallout(applicationList[0]);
            String matchingStatus = (String)responseMap.get('matchingStatus')??'';
            Verification__c verificationInstance = new Verification__c(
            Application__c = applicationList[0].Id,
            Verification_Source__c = 'NIRA'
        );
            if(string.isNotBlank(matchingStatus)){
                verificationInstance.Verification_Status__c = (matchingStatus != null && matchingStatus == 'true') ? 'Success' : 'Failed'; 
                 if (matchingStatus == 'false') {
                    verificationInstance.AOB_DSX_Response__c =string.valueOf(responseMap);
                } 
            }else{
                verificationInstance.AOB_DSX_Response__c = string.valueOf(responseMap);
                verificationInstance.AOB_DSX_Response__c = string.valueOf(responseMap.get('responseBody'));
                AOB_FlowController.createVerificationRecord(applicationList[0], 'NIRA','Failed');
            }
            AOB_FlowController.createVerificationWithInstance(verificationInstance);
            return JSON.serialize(responseMap);
        }
        return null;
    }

    /**
     * @description This method used for invoking NIRA callout
     * @param applicationRecord
     * @return Returns a callout response in map format for remaining processing
     */
    public static Map<String, Object> makeNIRACallout(Application__c applicationRecord) {
        AOB_NIRABean requestParams = createRequestParams(applicationRecord);
        HttpResponse httpResponse = sendHttpRequest(requestParams);
        Map<String, Object> responseToReturnObject = handleResponse(httpResponse, applicationRecord);
        return responseToReturnObject;
    }
    
    /**
     * @description Creates request parameters for the NIRACallout.
     * @param applicationRecord The application record.
     * @return AOB_NIRABean object containing request parameters.
     */
    private static AOB_NIRABean createRequestParams(Application__c applicationRecord) {
        return new AOB_NIRABean(
            Datetime.newInstance(applicationRecord.AOB_DOB__c, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy'),
            String.valueOf(applicationRecord.AOB_Document_Number__c),
            applicationRecord.AOB_FirstName__c,
            applicationRecord.AOB_Other_Name__c == null ? '': applicationRecord.AOB_Other_Name__c,
            applicationRecord.AOB_NIN__c,
            applicationRecord.AOB_LastName__c
        );
    }

    /**
     * @description Sends HTTP request for the NIRACallout.
     * 
     * @param requestParams AOB_NIRABean object containing request parameters.
     * @return HttpResponse object representing the response.
     */
    private static HttpResponse sendHttpRequest(AOB_NIRABean requestParams) {
        HttpRequest httpRequest =  AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(requestParams));
        
        try {
            Http http = new Http();
            if (System.Test.isRunningTest()) {
                if (mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                }
            }
            return http.send(httpRequest);
        } catch (Exception ex) {
            LOGGER.error('AOB_NIRA.makeNIRACallout', ex);
            return null;
        }
    }

    /**
     * @description Handles HTTP response for the NIRACallout.
     * 
     * @param httpResponse The HttpResponse object representing the response.
     * @param applicationRecord The application record.
     * @return Map containing response data.
     */
    private static Map<String, Object> handleResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if (httpResponse == null) {
            responseToReturnObject = new Map<String, Object>{
                'status' => 'FAILED',
                'ErrorDescription' => 'Failed to send HTTP request'
            };
            return responseToReturnObject;
        }
        
        if (httpResponse.getStatusCode() != CMN_API_HttpBase.HTTP_OK) {
            String errorMessage = 'No Response From Server';
            if (httpResponse.getBody() != null) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                errorMessage = (String) responseObject.get('moreInformation')??'';
            }
            responseToReturnObject = new Map<String, Object>{
                'status' => 'FAILED',
                'statusCode' => httpResponse.getStatusCode(),
                'ErrorDescription' => errorMessage
            };
            LOGGER.error('AOB_NIRA.makeNIRACallout: FAILED', new String[] {errorMessage, applicationRecord.Id});
            return responseToReturnObject;
        }
        
        String responseBody = httpResponse.getBody();
        if (String.isBlank(responseBody)) {
            responseToReturnObject = new Map<String, Object>{
                'status' => 'NO_CONTENT',
                'statusCode' => 204,
                'ErrorDescription' => 'No response body'
            };
            LOGGER.error('AOB_NIRA.makeNIRACallout: No response body', new String[] {'AOB_NIRA.makeNIRACallout', applicationRecord.Id});
            return responseToReturnObject;
        }
        
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (!responseObject.containsKey('verifyPersonInformationResponse')) {
            return responseToReturnObject;
        }
        
        Map<String, Object> verifyPersonInformationResponse = (Map<String, Object>) responseObject.get('verifyPersonInformationResponse');
        if (!verifyPersonInformationResponse.containsKey('return')) {
            return responseToReturnObject;
        }
        
        responseToReturnObject = (Map<String, Object>) verifyPersonInformationResponse.get('return');
        responseToReturnObject.put('statusCode', 200);
        
        return responseToReturnObject;
    }

    
}