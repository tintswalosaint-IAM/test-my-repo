/***************************************************************************************
@ Author            :Jagadish thummala
@ Date              :July 2023
@ Name of the Class :CMN_CreateEnterpriseCustomer
@description       : Class for dealing with CMN_CreateEnterpriseCustomer api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  : Ravi Myaka 
@ Last Modified On  :24-04-2024
@ Modification Description : SFP-37845 
***************************************************************************************/
public class CMN_CreateEnterpriseCustomer {
    /** @description application/json */
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
     /** @description accept/json */
    private static final String HEADER_ACCEPT = 'accept';
     /** @description content/json */
    private static final String HEADER_CONTENT_TYPE = 'content-type';
     /** @description X-IBM-Client-Id/json */
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
     /** @description X-IBM-Client-Id/json */
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
     /** @description Certificate/json */
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
     /** @description Authorization/json */
    private static final String HEADER_AUTHORIZATION = 'Authorization';
     /** @description interaction/json */
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
     /** @description Bearer/json */
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
     /** @description POST/json */
    private static final String HTTP_METHOD_POST = 'POST';
       /** @description application/json */
     private static final String PARAM_COLON = ':';

   /** @description sysauth/json */
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
       /** @description register/json */
    private static final String PATH_CALLOUT = '/self-register/answers';
  /** @description register/json */
    @testVisible private static Integer mockHttpStatusCode;
      /** @description register/json */
    @testVisible private static String mockHttpStatus;
      /** @description register/json */
    @testVisible private static String mockHttpBody = ''; 

 /** 
    * @description This method used for invoking CreateEnterpriseCustomer callout
    * @param applicationList
    * @param questionsAndAnswers
    * @return String Returns a callout response in map format for remaining processing
    */
    public static String invocableMethod(List<Application_Participant__c> applicationList, String questionsAndAnswers) {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
           
            Map<String, Object> response =  makeQuestionsAndAnswersCallout(applicationList,questionsAndAnswers);
     
            if(response != null && response.containsKey('ErrorDescription') == true) {
                BCB_FlowController.createVerificationRecordForParticipant(applicationList[0], 'Self Registration Answers', 'Failed');
            } else {
                BCB_FlowController.createVerificationRecordForParticipant(applicationList[0], 'Self Registration Answers', 'Success');
            }
          
            return JSON.serialize(response);
        }

        return null;
    }
    

  /** 
   * @description This method used for main callout that is CreateEnterpriseCustomer API 
   * @param applicationRecords
    * @param questionsAndAnswers
   * @return  Map<String, Object>
  */
  public static Map<String, Object> makeQuestionsAndAnswersCallout(List<Application_Participant__c> applicationRecords, String questionsAndAnswers) {

    Application_Participant__c applicationRecord = applicationRecords[0];
    List<Application__c> applicationList = new SEL_Application().selectAppsById(applicationRecord.Application__c);
    BCB_SelfRegistrationBean.Response questionsAndAnswersObject = (BCB_SelfRegistrationBean.Response) JSON.deserialize(questionsAndAnswers, BCB_SelfRegistrationBean.Response.class);
    BCB_CreateEnterpriseCustomerBean customerRegisterQNABeanRecord = new BCB_CreateEnterpriseCustomerBean();

   
    

    List<BCB_CreateEnterpriseCustomerBean.customerRegisterQna> crcQnaRecList = new List<BCB_CreateEnterpriseCustomerBean.customerRegisterQna>();
    for(BCB_SelfRegistrationBean.Questions questionAndAnswer : questionsAndAnswersObject.customLoginQNAResponse.Questions) {
        BCB_CreateEnterpriseCustomerBean.customerRegisterQna craQnaRec = new BCB_CreateEnterpriseCustomerBean.customerRegisterQna();
        craQnaRec.selectedIndexArray = 'Y';
        craQnaRec.chosenAnswerArray = questionAndAnswer.answer;
        craQnaRec.questionIdentifyArray = questionAndAnswer.questionIdentifier;
        crcQnaRecList.add(craQnaRec);
    }

    BCB_CreateEnterpriseCustomerBean.CustomerRegisterQuestion customerRegisterQuestionRec = new BCB_CreateEnterpriseCustomerBean.CustomerRegisterQuestion();
    customerRegisterQuestionRec.accountNumber =  applicationList[0].AOB_Account_Number__c;
    customerRegisterQuestionRec.isCoreRequest = true;
    customerRegisterQuestionRec.linkedchannels = 'String';
    customerRegisterQuestionRec.customerNumber = applicationList[0].AOB_Customer_Id__c; 
    customerRegisterQuestionRec.requestIdentity = questionsAndAnswersObject.customLoginQNAResponse.userIdentity;
    customerRegisterQuestionRec.customerRegisterQnaRec = crcQnaRecList;
    
    BCB_CreateEnterpriseCustomerBean.CustomerRegisterHeader customerRegisterHeaderRec = new BCB_CreateEnterpriseCustomerBean.CustomerRegisterHeader();
    customerRegisterHeaderRec.serviceIdentifier = 'CENTR';
    customerRegisterHeaderRec.operationFormat = 'XML';
    customerRegisterHeaderRec.channelIdentifier = 'I';
    customerRegisterHeaderRec.bankIdentifier = 'UG';
    customerRegisterHeaderRec.ipFormat = 'XML';
    customerRegisterHeaderRec.loginFlag = 2;
    customerRegisterHeaderRec.languageIdentifier = '001';
    customerRegisterHeaderRec.isMultirec = 'Y';
    customerRegisterHeaderRec.userPrincipal = 'UG.VUSER4';
    customerRegisterHeaderRec.stateMode = 'N';
    customerRegisterHeaderRec.formIdentifier = '7036b33a-7407-4112-b23c-0148f1d8720b';
    customerRegisterHeaderRec.accessCode = 'N';
    customerRegisterHeaderRec.loginType = 'SPWD';
    customerRegisterHeaderRec.ipAddress = '172.69.239.156';
    customerRegisterHeaderRec.deviceIdentifier = ''; 
    customerRegisterHeaderRec.deviceType = '5c6440b8-60a0-4ec9-b246-e23c97e8ccd7';
    customerRegisterHeaderRec.machineFingerPrint = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML like Gecko) Chrome/98.0.4758.80 Safari/537.36';

    customerRegisterQNABeanRecord.header               = customerRegisterHeaderRec;
    customerRegisterQNABeanRecord.customerQuestionNA   = customerRegisterQuestionRec; 

    String customerRegisterQNABeanRecordSerialized = JSON.serialize(customerRegisterQNABeanRecord);
    
    CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
    

    NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
    String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
    String fApiInteractionId = BCB_FlowController.createGUID();

    string accesstoken = CMN_SRV_GetAccessToken.getAccessToken();
    Map<String, Object> responseToReturnObject = new Map<String, Object>();

    if(String.isNotBlank(accesstoken) == true) {

        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accesstoken);

    
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
        httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
        
        httpRequest.setHeader('User-Agent', 'Salesforce_Client');

        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setBody(customerRegisterQNABeanRecordSerialized);
        httpRequest.setTimeout(120000);
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                    BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                }
            }
            httpResponse = http.Send(httpRequest);
            if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (responseBody != null) {
                    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                    if(responseObject != null && responseObject.containsKey('customRegisterQNAResponse') == true) {
                        Map<String, Object> customRegisterQNAResponse = (Map<String, Object>) responseObject.get('customRegisterQNAResponse');
                        if(customRegisterQNAResponse.containsKey('userIdentity') == true ) {
                            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'successMessage' => 'Registration for security questions successful.'};
                        }
                    }
                } else {
                    responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                    CMN_UTIL_Logger.error('No response body', null, 'BCB_CreateEnterpriseCustomer.makeQuestionsAndAnswersCallout', applicationRecord.Id, null);
                }
            } else {
                String errorMessage = 'No Response From Server';
                if(httpResponse.getBody() != null) {
                    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    errorMessage = (String) responseObject.get('moreInformation');
                }

                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), errorMessage, 'BCB_CreateEnterpriseCustomer.makeQuestionsAndAnswersCallout', applicationRecord.Id, null);
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error('Some Un-Handled Exception Occurred', ex.getMessage(), 'BCB_CreateEnterpriseCustomer.makeQuestionsAndAnswersCallout', applicationRecord.Id, ex);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
        }
    } else {
        CMN_UTIL_Logger.error('Access Token Failure', null, 'BCB_CreateEnterpriseCustomer.makeQuestionsAndAnswersCallout', applicationRecord.Id, null);
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
    }
    return responseToReturnObject;
}
  
}