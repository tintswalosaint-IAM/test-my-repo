/***************************************************************************************
@ Author            :Jagadish Thummala.
@ Date              :July 2024
@ Name of the Class :AOB_RelyComply_Individual_Screening
@ Description       : This class is used for performing screening by RelyComply and sending to response to AOB_FormCreator.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :22/07/2024.
@ Modification Description : SFP-40417
***************************************************************************************/
public without sharing class AOB_RelyComply_Individual_Screening {
   private AOB_RelyComply_Individual_Screening(){}
    //HTTP Constants
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_SIGNATURE = 'x-signature';
    private static final String HEADER_CHANNELID = 'x-channel-id';
    private static final String HEADER_SFUG = 'SFUG';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String INDIVIDUAL_PATH_CALLOUT = '/account-screening/v1/person/screen'; 
    private static final String CLIENT_ID = '{!$Credential.UG_BCB_PPB_RELYCOMPLY_EC.client_id}';

    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_RelyComply_Individual_Screening');
    public static  Map<String, Object> responseToReturnObject;
    private static Map<String, String> empMapping = new Map<String, String>{
                                       '011'=>'salaried_bank',
                                       '001'=> 'salaried_other',
                                       '004'=> 'self_employed',
                                       '008'=> 'student',
                                       '007'=> 'pensioner',
                                       '006'=> 'dependent',
                                       '009'=> 'other_once_off',
                                       '013'=> 'other_recurring',
                                       '010'=> 'default'};
   /**
    * @description Method to Send SMS which will be invoked from parent class 
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static String invokeRelyComplyScreening(List<Application__c> applicationList) {
        Application__c appRecord = new SEL_Application().selectAppById(applicationList[0].Id);
        if (applicationList.isEmpty()) {
            return null;
        }
    
        Map<String, Object> responseStatus = makeScreeningCallout(applicationList[0]);
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
        UG_AOB_PPB_FlowController.createVerificationWithInstance(verificationInstance);
        return JSON.serialize(responseStatus);
    }
   

    /** 
   * @description This method used for main callout that is SMSAlert API 
   * @param applicationRecord
   * @return Returns a callout response in map format for remaining processing
   */
   public static Map<String, Object> makeScreeningCallout(Application__c applicationRecord) {
       AOB_DTO_RelyComply_Individual_Screening.individualScreening screeningRecord = prepareScreeningRecord(applicationRecord); 
       CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.relyComplyWebServices();
       string accessToken = CMN_SRV_RelyComply.getAccessToken();
       if (System.Test.isRunningTest()) {
           webServiceSetting = [SELECT Id,CMN_AdditionalKey__c FROM CMN_WebserviceSetting__mdt WHERE DeveloperName = 'CMN_API_RelyComply' LIMIT 1];
           if(mockHttpStatusCode!=null && mockHttpStatus!=null){
               AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
           }               
       }
       HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
       if(String.isNotBlank(accessToken) == true && accessToken != null) {
       httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
       httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
       Blob data = Blob.valueOf(JSON.serialize(screeningRecord));
       //we are using Private key as AdditionalKey from custom metadata type.
       Blob result = Crypto.sign('RSA-SHA256', data, EncodingUtil.base64Decode(webServiceSetting.CMN_AdditionalKey__c));
       httpRequest.setHeader(HEADER_SIGNATURE, EncodingUtil.base64Encode(result));
       httpRequest.setHeader(HEADER_CLIENT_ID,CLIENT_ID);
       httpRequest.setHeader(HEADER_CHANNELID, HEADER_SFUG);
       httpRequest.setEndpoint('callout:UG_BCB_PPB_RELYCOMPLY' + INDIVIDUAL_PATH_CALLOUT);
       httpRequest.setMethod(HTTP_METHOD_POST);
       httpRequest.setBody(JSON.serialize(screeningRecord));
       httpRequest.setTimeout(120000);
      
           HttpResponse httpResponse = new HttpResponse();   
           httpResponse = sendHttpRequest(httpRequest);
           system.debug('request body is ------>'+ JSON.serialize(screeningRecord));
       return processHttpResponse(httpResponse);
       }else {
           LOGGER.error('CMN_RelyComply.makeRelyComplyIndividualScreening:Access Token Failure', new String[] {'CMN_RelyComply.makeRelyComplyIndividualScreening', applicationRecord.Id});
           return responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
       }
   }
   
   /** 
   * @description This method used to prepare SanctionScreenRecord
   * @param applicationRecord
   * @return AOB_DTO_RelyComply_Individual_Screening.individualScreening prepareScreeningRecord
   */
   
   private static AOB_DTO_RelyComply_Individual_Screening.individualScreening prepareScreeningRecord(Application__c applicationRecord) {
       try{ 
       AOB_DTO_RelyComply_Individual_Screening.individualScreening individualScreening = new AOB_DTO_RelyComply_Individual_Screening.individualScreening();
       individualScreening.identifier = applicationRecord.AOB_NIN__c;
       individualScreening.firstName = applicationRecord.AOB_FirstName__c ??'';
       individualScreening.lastName = applicationRecord.AOB_LastName__c ??'' ;
       individualScreening.nationality = applicationRecord.AOB_Country__c;
       individualScreening.residence = applicationRecord.AOB_Country__c;
       individualScreening.birthDate = applicationRecord.AOB_DOB__c.format();
       Integer numOfYears = Date.today().year() - applicationRecord.AOB_DOB__c.year();
       Boolean isAdult = numOfYears >= 18;
       Boolean isUganda = applicationRecord.AOB_Country__c == 'UG';
       
       individualScreening.clientType = isUganda 
           ? (isAdult ? 'A5A' : 'A5C') 
           : (isAdult ? 'A5B' : 'A5D');


       individualScreening.occupationCategory = empMapping.get(applicationRecord.AOB_Employment_Type__c) ?? '';
       individualScreening.bankProduct = 'Transactional';
       return individualScreening; 
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
   private static Map<String, Object> processHttpResponse(HttpResponse httpResponse) {
       Map<String, Object> responseToReturnObject = new Map<String, Object>();
       if (httpResponse == null) {
           responseToReturnObject = new Map<String, Object>{
               'status' => 'FAILED', 
               'errorMessage' => 'Exception occurred while sending HTTP request'};
           return responseToReturnObject;
       }
       String responseBody = httpResponse.getBody();
       system.debug('responseBody is ------>'+responseBody);
       responseToReturnObject.put('status', 'SUCCESS');
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
            'sanctionStatus' =>  sanctionScreening ,
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
      Logger.error('AOB_RelyComply_Individual_Screening:Response status: ' + httpResponse.getStatusCode(), new string[]{errorMessage});
       return responseToReturnObject;
   } 
}