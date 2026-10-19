/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :March 2022
@ Name of the Class :AOB_SanctionScreen
@ Description       :Class for dealing with sanction api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_SanctionScreen {
    
    //HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/sanction/screening';   
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SanctionScreen');
    public static  Map<String, Object> responseToReturnObject;
    public static  Map<String,Object> mData;
   /**
    * @description Method to Send SMS which will be invoked from parent class 
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static String invokeSanctionScreening(List<Application__c> applicationList) {
        if (!applicationList.isEmpty()) {
            Map<String, Object> responseStatus = makeSanctionCallout(applicationList[0]);
            Verification__c verificationInstance = new Verification__c(
                Application__c = applicationList[0].id,
                Verification_Source__c = 'PEP Sanction'
            );
            
            if (responseStatus != null && responseStatus.containsKey('status') && responseStatus.get('status').equals('SUCCESS')) {
                verificationInstance.Verification_Status__c = 'Success';
                verificationInstance.AOB_PEP_Status__c = (String) responseStatus.get('pepStatus');
                verificationInstance.AOB_Sanction_Status__c = (String) responseStatus.get('sanctionStatus');
                
                
            } else {
                verificationInstance.Verification_Status__c = 'Failed';
            }
            
            AOB_FlowController.createVerificationWithInstance(verificationInstance);
            return JSON.serialize(responseStatus);
        }
        return null;
    }
    
    /** 
    * @description This method used for main callout that is SMSAlert API 
    * @param applicationRecord
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> makeSanctionCallout(Application__c applicationRecord) {
        AOB_SanctionScreenBean sanctionScreenRecord = prepareSanctionScreenRecord(applicationRecord);
        HttpRequest httpRequest =  AOB_API_Utils.getHeaders(PATH_CALLOUT,HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(sanctionScreenRecord));
        HttpResponse httpResponse = sendHttpRequest(httpRequest);
        return processHttpResponse(httpResponse, applicationRecord);
    }

    /** 
    * @description This method used to prepareSanctionScreenRecord
    * @param applicationRecord
    * @return AOB_SanctionScreenBean sanctionScreenRecord
    */
    
    private static AOB_SanctionScreenBean prepareSanctionScreenRecord(Application__c applicationRecord) {
        try{ 
        mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_SanctionScreen');
        AOB_SanctionScreenBean sanctionScreenRecord = new AOB_SanctionScreenBean();
        sanctionScreenRecord.customFields = new List<String>();
        sanctionScreenRecord.providerTypes = new List<String>{string.valueOf(mData.get('providerTypes'))??''};
        sanctionScreenRecord.secondaryFields = new List<String>();
        sanctionScreenRecord.nameTransposition = FALSE;
        sanctionScreenRecord.entityType = string.valueOf(mData.get('entityType'))??'';
        sanctionScreenRecord.groupId = string.valueOf(mData.get('groupId'))??'';
        sanctionScreenRecord.caseId = applicationRecord.Id + '+' + DateTime.now().getTime();
        sanctionScreenRecord.name = (applicationRecord.AOB_FirstName__c ?? '') + ' ' + applicationRecord.AOB_LastName__c;
        return sanctionScreenRecord;
        }catch(Exception ex){
            LOGGER.error('AOB_SanctionScreen:un-handled exception occurred', ex);
            return null;
        }
    }
    
    /**
     * Sends an HTTP request and returns the HTTP response.
     * @param httpRequest The HTTP request to be sent.
     * @return The HTTP response received after sending the request, or null if an exception occurs.
     */
    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        try {
            Http http = new Http();
            if (System.Test.isRunningTest()) {
                if (mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                }
            }
            return http.send(httpRequest);
        } catch (Exception ex) {
            LOGGER.error('AOB_SanctionScreen: Exception occurred while sending HTTP request', ex);
            return null;
        }
    }

    /**
     * Processes the HTTP response and returns a map containing the response data.
     * @param httpResponse The HTTP response received.
     * @param applicationRecord The application record related to the response.
     * @return A map containing the response data, including status, error message, and other relevant information.
     */
    private static Map<String, Object> processHttpResponse(HttpResponse httpResponse, Application__c applicationRecord) {
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
            responseToReturnObject = handleErrorHttpResponse(httpResponse, responseBody, applicationRecord);
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
            AOB_SanctionScreenBean.Response responseObject = (AOB_SanctionScreenBean.Response) JSON.deserialize(responseBody, AOB_SanctionScreenBean.Response.class);

            String pepStatus = 'N/A';
            String sanctionStatus = 'N/A';

            for (AOB_SanctionScreenBean.Results result : responseObject.results) {
                if (result.categories.contains('PEP') && result.matchStrength == 'EXACT') {
                    pepStatus = result.pepStatus;
                } else if ((result.categories.contains('Regulatory Enforcement') || result.categories.contains('Sanctions')) && result.matchStrength == 'EXACT') {
                    sanctionStatus = 'ACTIVE';
                    responseToReturnObject.put('errorMessage', String.valueOf(mData.get('errorMessage')) ?? '');
                }
            }

            responseToReturnObject = new Map<String, Object>{
                'status'         => 'SUCCESS',
                'pepStatus'      => pepStatus,
                'sanctionStatus' => sanctionStatus
            };
            
        } else {
            responseToReturnObject = new Map<String, Object>{
                'status'          => 'NO_CONTENT',
                'statusCode'      => 204,
                'ErrorDescription' => 'No response body'
            };
            
            LOGGER.error('AOB_SanctionScreen: No response body');
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
    private static Map<String, Object> handleErrorHttpResponse(HttpResponse httpResponse, String responseBody, Application__c applicationRecord) {
        String errorMessage = 'No Response From Server';
        if (String.isNotBlank(responseBody)) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }
        Map<String, Object> responseToReturnObject = new Map<String, Object>{
            'status' => 'FAILED', 
            'statusCode' => httpResponse.getStatusCode(),
            'ErrorDescription' => errorMessage
        };
       Logger.error('AOB_SanctionScreen:Response status: ' + httpResponse.getStatusCode(), new string[]{errorMessage,applicationRecord.ID});
        return responseToReturnObject;
    }  
}