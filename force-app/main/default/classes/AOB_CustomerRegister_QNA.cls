/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerRegister_QNA
@description        :Class used to do an API callout to register security questions and answers
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_CustomerRegister_QNA {
   private AOB_CustomerRegister_QNA(){}
	//HTTP Constant
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/self-register/answers'; 
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CustomerRegister_QNA'); 
    public static  Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_CustomerRegister_QNA');
    public static Map<String, Object> responseToReturnObject;
/** 
* @description Method to Register QNA which will be invoked from parent class 
* @param applicationList
* @param questionsAndAnswers
* @return null
*/
    public static String invokeRegisterAnswerCallout(List<Application__c> applicationList, String questionsAndAnswers) {
        if(applicationList != null && applicationList.isEmpty() == false) {

            Map<String, Object> responseMap =  makeQuestionsAndAnswersCallout(applicationList, questionsAndAnswers);
            if(responseMap != null && responseMap.containsKey('status') && responseMap.get('status') == 'SUCCESS') {
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer Register_QNA', 'Success');
            } else {
                Verification__c verificationInstance = new Verification__c(
                    Application__c = applicationList[0].Id,
                    Verification_Source__c = 'Customer Register_QNA',
                    AOB_DSX_Response__c = String.valueOf(responseMap),
                    Verification_Status__c = 'Failed'
                    );
                    AOB_FlowController.createVerificationWithInstance(verificationInstance);
            
            }
            return JSON.serialize(responseMap);
        }
        return null;
    }

/** 
* @description This method used for main callout that is CustomerRegister QNA API 
* @param applicationRecords
* @param questionsAndAnswers
* @return responseToReturnObject
*/
    public static Map<String, Object> makeQuestionsAndAnswersCallout(List<Application__c> applicationRecords, String questionsAndAnswers) {
        Application__c applicationRecord = applicationRecords[0];
        AOB_CustomerRegister_QNABean customerRegisterQNABeanRecord = new AOB_CustomerRegister_QNABean();
        
        // Construct the request body
        String requestBody = constructRequestBodyForQna(applicationRecord, customerRegisterQNABeanRecord, questionsAndAnswers);
        
        // Get HTTP request and set the body
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(requestBody);

        // Make the callout and process the response
        return processHttpCallout(httpRequest, applicationRecord);
    }

    // Method to construct the request body
    private static String constructRequestBodyForQna(Application__c applicationRecord, AOB_CustomerRegister_QNABean customerRegisterQNABeanRecord, String questionsAndAnswers) {
        AOB_CustomerRegister_QNA.constructRequestBody(applicationRecord, customerRegisterQNABeanRecord, questionsAndAnswers);
        String customerRegisterQNABeanRecordSerialized = JSON.serialize(customerRegisterQNABeanRecord);
        return customerRegisterQNABeanRecordSerialized.replace('accountNumber', 'account-number');
    }

    // Method to handle the HTTP callout and response processing
    private static Map<String, Object> processHttpCallout(HttpRequest httpRequest, Application__c applicationRecord) {
        
        
        try {
            Http http = new Http();
            HttpResponse httpResponse;

            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }

            httpResponse = http.send(httpRequest);

            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                responseToReturnObject = handleSuccessResponse(httpResponse);
            } else {
                responseToReturnObject = handleErrorResponse(httpResponse, applicationRecord);
            }
        } catch (Exception ex) {
            responseToReturnObject = handleException(ex);
        }

        return responseToReturnObject;
    }

    // Method to handle successful HTTP response
    private static Map<String, Object> handleSuccessResponse(HttpResponse httpResponse) {
        String responseBody = httpResponse.getBody(); 

        if (String.isBlank(responseBody) == false) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            if (responseObject != null && responseObject.containsKey('customRegisterQNAResponse')) {
                Map<String, Object> customRegisterQNAResponse = (Map<String, Object>) responseObject.get('customRegisterQNAResponse');
                
                if (customRegisterQNAResponse.containsKey('userIdentity')) {
                    return new Map<String, Object>{
                        'status' => 'SUCCESS', 
                        'statusCode' => 200, 
                        'successMessage' => 'Registration for security questions successful.'
                    };
                }
            }
        } else {
            Logger.error('No response body :AOB_CustomerRegister_QNA');
            return new Map<String, Object>{
                'status' => 'NO_CONTENT', 
                'statusCode' => 204, 
                'ErrorDescription' => 'No response body'
            };
        }
        
        return null;
    }

    // Method to handle error HTTP response
    private static Map<String, Object> handleErrorResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        String errorMessage = 'No Response From Server';
        
        if (httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }

        Logger.error('Response status: ' + httpResponse.getStatusCode(), new String[]{errorMessage, applicationRecord.Id});
        
        return new Map<String, Object>{
            'status' => 'FAILED', 
            'statusCode' => httpResponse.getStatusCode(), 
            'ErrorDescription' => errorMessage
        };
    }

    // Method to handle any exceptions
    private static Map<String, Object> handleException(Exception ex) {
        Logger.error('Some Un-Handled Exception Occurred', ex);
        return new Map<String, Object>{
            'status' => 'FAILED', 
            'ErrorDescription' => ex.getMessage()
        };
    }

    /** 
* @description Method to construct request body for callout
* @param applicationRecord
* @param customerRegisterQNABeanRecord
* @param questionsAndAnswers
* @return AOB_CustomerRegister_QNABean
*/
    private static AOB_CustomerRegister_QNABean constructRequestBody(Application__c applicationRecord,AOB_CustomerRegister_QNABean customerRegisterQNABeanRecord,String questionsAndAnswers){
        List<AOB_CustomerRegister_QNABean.customerRegisterQna> crcQnaRecList = new List<AOB_CustomerRegister_QNABean.customerRegisterQna>();
        AOB_SelfRegistrationBean.Response questionsAndAnswersObject = (AOB_SelfRegistrationBean.Response) JSON.deserialize(questionsAndAnswers, AOB_SelfRegistrationBean.Response.class);
            for(AOB_SelfRegistrationBean.Questions questionAndAnswer : questionsAndAnswersObject.customLoginQNAResponse.Questions) {
                AOB_CustomerRegister_QNABean.customerRegisterQna craQnaRec = new AOB_CustomerRegister_QNABean.customerRegisterQna();
                craQnaRec.selectedIndexArray =  string.valueOf(mData.get('selectedIndexArray'))??''??'';
                craQnaRec.chosenAnswerArray = questionAndAnswer.answer;
                craQnaRec.questionIdentifyArray = questionAndAnswer.questionIdentifier;
                crcQnaRecList.add(craQnaRec);
            }

            AOB_CustomerRegister_QNABean.CustomerRegisterQuestion customerRegisterQuestionRec = new AOB_CustomerRegister_QNABean.CustomerRegisterQuestion();
            customerRegisterQuestionRec.accountNumber = applicationRecord.AOB_Account_Number__c;
            customerRegisterQuestionRec.isCoreRequest = true;
            customerRegisterQuestionRec.linkedchannels =  string.valueOf(mData.get('linkedchannels'))??'';
            customerRegisterQuestionRec.customerNumber = applicationRecord.AOB_Customer_Id__c; 
            customerRegisterQuestionRec.requestIdentity = questionsAndAnswersObject.customLoginQNAResponse.userIdentity;
            customerRegisterQuestionRec.customerRegisterQnaRec = crcQnaRecList;
            
            AOB_CustomerRegister_QNABean.CustomerRegisterHeader customerRegisterHeaderRec = new AOB_CustomerRegister_QNABean.CustomerRegisterHeader();
            customerRegisterHeaderRec.serviceIdentifier =  string.valueOf(mData.get('qna.serviceIdentifier'))??'';
            customerRegisterHeaderRec.operationFormat =  string.valueOf(mData.get('qna.operationFormat'))??'';
            customerRegisterHeaderRec.channelIdentifier =  string.valueOf(mData.get('qna.channelIdentifier'))??'';
            customerRegisterHeaderRec.bankIdentifier =  string.valueOf(mData.get('qna.bankIdentifier'))??'';
            customerRegisterHeaderRec.ipFormat =  string.valueOf(mData.get('qna.ipFormat'))??'';
            customerRegisterHeaderRec.loginFlag = integer.valueOf(mData.get('qna.loginFlag'));
            customerRegisterHeaderRec.languageIdentifier =  string.valueOf(mData.get('qna.languageIdentifier'))??'';
            customerRegisterHeaderRec.isMultirec =  string.valueOf(mData.get('qna.isMultirec'))??'';
            customerRegisterHeaderRec.userPrincipal =  string.valueOf(mData.get('qna.userPrincipal'))??'';
            customerRegisterHeaderRec.stateMode =  string.valueOf(mData.get('qna.stateMode'))??'';
            customerRegisterHeaderRec.formIdentifier =  string.valueOf(mData.get('qna.formIdentifier'))??'';
            customerRegisterHeaderRec.accessCode =  string.valueOf(mData.get('qna.accessCode'))??'';
            customerRegisterHeaderRec.loginType =  string.valueOf(mData.get('qna.loginType'))??'';
            customerRegisterHeaderRec.ipAddress =  string.valueOf(mData.get('qna.ipAddress'))??'';
            customerRegisterHeaderRec.deviceIdentifier = ''; 
            customerRegisterHeaderRec.deviceType =  string.valueOf(mData.get('qna.deviceType'))??'';
            customerRegisterHeaderRec.machineFingerPrint = applicationRecord.AOB_Device_Details__c;

            customerRegisterQNABeanRecord.header               = customerRegisterHeaderRec;
            customerRegisterQNABeanRecord.customerQuestionNA   = customerRegisterQuestionRec; 

            return customerRegisterQNABeanRecord;
    }
}