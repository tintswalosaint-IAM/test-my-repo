/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_SelfRegistration
@description       :Class for dealing with Self Registration api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_SelfRegistration {
    private AOB_SelfRegistration(){}
    //HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/self-register/questions';
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SelfRegistration');
    private static Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_SelfRegistration');
    
    /**
    * @description Method to invoke Self Registration Controller from flow controller
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static String invokeSelfRegisterCallout(List<Application__c> applicationList)  { 
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            AOB_SelfRegistrationBean.Response responseObject = invokeSelfRegistrationQuestionsCallout(applicationList);
            if(responseObject != null && responseObject.customLoginQNAResponse != null && responseObject.customLoginQNAResponse.Status == 'SUCCESS') { 
                AOB_FlowController.createVerificationRecord(applicationList[0], 'Self Registration_Questions', 'Success');
            } else {
                 Verification__c verificationInstance = new Verification__c(
                Application__c = applicationList[0].Id,
                Verification_Source__c = 'Self Registration_Questions',
                AOB_DSX_Response__c = String.valueOf(responseObject),
                Verification_Status__c = 'Failed'
                );
                AOB_FlowController.createVerificationWithInstance(verificationInstance);
        
            }
            return JSON.serialize(responseObject);
        }
        return null;
    }
    
    /**
    * @description This is used for main callout SelfRegistrationQuestions API
    * @param applicationList
    * @return Stringified Response from the callout
    */
    public static AOB_SelfRegistrationBean.Response invokeSelfRegistrationQuestionsCallout(List<Application__c> applicationList) {
        
        AOB_SelfRegistrationBean.Response responseToReturnObject = new AOB_SelfRegistrationBean.Response();
        if(applicationList == null || applicationList.isEmpty() == true) {
            return responseToReturnObject;
        }
        Application__c applicationRecord = applicationList[0];
        
        AOB_SelfRegistrationBean.BodyInfo bodyInfoRecord = new AOB_SelfRegistrationBean.BodyInfo();
        BodyInfoRecord.AccountNumber                      = applicationRecord.AOB_Account_Number__c; 
        BodyInfoRecord.AccountIndicator                   = String.valueOf(mData.get('AccountIndicator'))??'';
        
        AOB_SelfRegistrationBean selfRegisterationBeanRecord = new AOB_SelfRegistrationBean();
        selfRegisterationBeanRecord.header = constructHeaderBeanRecord();
        selfRegisterationBeanRecord.body = bodyInfoRecord;

        HttpRequest httpRequest =  AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(selfRegisterationBeanRecord));
        //Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
            httpResponse = http.Send(httpRequest);
            responseToReturnObject = constructResponse(httpResponse, applicationRecord);
            
        } catch (Exception ex) {
            LOGGER.error('AOB_SelfRegistration', new String[] {'AOB_SelfRegistration.invokeSelfRegistrationQuestionsCallout : Some Un-Handled Exception Occurred', applicationRecord.Id},ex);
            responseToReturnObject.status = 'FAILED';
            responseToReturnObject.ErrorDescription = ex.getMessage();
        }
        
        return responseToReturnObject;
    }

    /** 
    * @description Method to construct response map based on the callout response
    * @param httpResponse
    * @param applicationRecord
    * @return Returns a cosntructed callout response in wrapper format for remaining processing
    */
    private static AOB_SelfRegistrationBean.Response constructResponse(HttpResponse httpResponse, Application__c applicationRecord) {
        AOB_SelfRegistrationBean.Response responseToReturnObject = new AOB_SelfRegistrationBean.Response();
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();

            if (String.isNotBlank(responseBody) == true) {
                responseToReturnObject = (AOB_SelfRegistrationBean.Response) JSON.deserialize(responseBody, AOB_SelfRegistrationBean.Response.class);
            } else {
                responseToReturnObject.status = 'FAILED';
                responseToReturnObject.ErrorDescription = 'No response body';
                LOGGER.error('AOB_SelfRegistration', new String[] {'AOB_SelfRegistration.invokeSelfRegistrationQuestionsCallout :No response body', applicationRecord.Id});
            }
        } else {
            String errorMessage = 'No Response From Server';
            
            if(String.isNotBlank(httpResponse.getBody()) == true) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                errorMessage = (String) responseObject.get('moreInformation');
            }
            
            responseToReturnObject.status = 'FAILED';
            responseToReturnObject.ErrorDescription = errorMessage;
            LOGGER.error('AOB_SelfRegistration', new String[] {'AOB_SelfRegistration.invokeSelfRegistrationQuestionsCallout', applicationRecord.Id,errorMessage});

        }

        return responseToReturnObject;
    }

    /** 
    * @description Method to construct Request Body for signature and picture
    * @return Returns a prepared request for signature and picture file
    */
    private static AOB_SelfRegistrationBean.HeaderInfo constructHeaderBeanRecord() {
        AOB_SelfRegistrationBean.HeaderInfo headerInfoRecord = new AOB_SelfRegistrationBean.HeaderInfo();
        
        headerInfoRecord.serviceIdentifier                = String.valueOf(mData.get('serviceIdentifier'))??'';
        headerInfoRecord.operationFormat                  = String.valueOf(mData.get('operationFormat'))??'';
        headerInfoRecord.channelIdentifier                = String.valueOf(mData.get('channelIdentifier'))??'';
        headerInfoRecord.bankIdentifier                   = String.valueOf(mData.get('bankIdentifier'))??'';
        headerInfoRecord.ipFormat                         = String.valueOf(mData.get('ipFormat'))??'';
        headerInfoRecord.loginFlag                        = Integer.valueOf(mData.get('loginFlag'));
        headerInfoRecord.languageIdentifier               = String.valueOf(mData.get('languageIdentifier'))??'';
        headerInfoRecord.isMultirec                       = String.valueOf(mData.get('isMultirec'))??'';
        headerInfoRecord.userPrincipal                    = String.valueOf(mData.get('userPrincipal'))??'';
        headerInfoRecord.stateMode                        = String.valueOf(mData.get('stateMode'))??'';
        headerInfoRecord.formIdentifier                   = String.valueOf(mData.get('formIdentifier'))??'';
        headerInfoRecord.accessCode                       = String.valueOf(mData.get('accessCode'))??'';
        headerInfoRecord.loginType                        = String.valueOf(mData.get('loginType'))??'';
        headerInfoRecord.ipAddress                        = '';
        headerInfoRecord.deviceIdentifier                 = String.valueOf(mData.get('deviceIdentifier'))??'';
        headerInfoRecord.deviceType                       = String.valueOf(mData.get('deviceType'))??'';
        headerInfoRecord.machineFingerPrint               = '';

        return headerInfoRecord;
    }
}