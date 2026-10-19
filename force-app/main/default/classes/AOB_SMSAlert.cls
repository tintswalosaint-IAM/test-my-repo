/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_SMSAlert
@ Description       :Class for dealing with SMS Alert api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :3/14/2024.
@ Modification Description : SFP-28286
***************************************************************************************/
public  class AOB_SMSAlert {
    
	//HTTP Constants
 
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/sms/alert';
    
    //using for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SMSAlert');
    public static  Map<String,Object> mData= new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_SMSAlert');


    /**
    * @description Method to Send SMS which will be invoked from parent class 
    * @param leadList 
    * @return null / Stringified Response from the callout
    */
    public static String sendSMS(List<Lead> leadList)  {
        
        if(leadList.isEmpty() == false) {
            String otp = AOB_OtpHandler.generateOtpForPhone();
            String useOTP = (String.valueOf(mData.get('useOTP')) != null) ? String.valueOf(mData.get('useOTP')) : '';
            String otpText = (String.valueOf(mData.get('otpText')) != null) ? String.valueOf(mData.get('otpText')) : '';
            leadList[0].Description = useOTP + otp +' '+ otpText;
            Map<String, Object> returnResponse = makeSMSCallout(leadList);
            returnResponse.put('phoneOTP', otp);
            return JSON.serialize(returnResponse);
        } 

        return null;
    }
    /** 
    * @description This method used for main callout that is SMSAlert API 
    * @param leadList
    * @return responseToReturnObject Returns a callout response in map format for remaining processing
    */
    private static Map<String, Object> makeSMSCallout(List<Lead> leadList) {

        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(leadList.isEmpty() == true) {
            return responseToReturnObject;
        }
        AOB_SMSAlertBean smsAlertBeanRecord = new AOB_SMSAlertBean();
        
        smsAlertBeanRecord.cellphoneNumber = String.valueOf(mData.get('cellPrefix'))+ leadList[0].Phone;
        smsAlertBeanRecord.message = leadList[0].Description;
        smsAlertBeanRecord.trackingNumber = String.valueOf(mData.get('cellPrefix')) + leadList[0].Phone;
        smsAlertBeanRecord.countryISO = String.valueOf(mData.get('countryIso'));
        smsAlertBeanRecord.sourceSystem =  String.valueOf(mData.get('sourceSystem'));

    
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(smsAlertBeanRecord));

        //Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
            httpResponse = http.Send(httpRequest);
            responseToReturnObject = constructResponse(httpResponse);
        } catch (Exception ex) {
            Logger.error('AOB_SMSAlert:Some Un-Handled Exception Occurred', ex);
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
        }   
        
        return responseToReturnObject;
    }

    /** 
    * @description Method to construct response map based on the callout response
    * @param response
    * @return responseToReturnObject Returns a cosntructed callout response in map format for remaining processing
    */
    private static Map<String, Object> constructResponse(HttpResponse response) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(response.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = response.getBody();
            if (String.isNotBlank(responseBody) == true) {
                responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            } else {
                Logger.error('AOB_SMSAlert: No response body');
                responseToReturnObject = new Map<String, Object>{
                    'status' => 'NO_CONTENT', 
                    'statusCode' => 204, 
                    'ErrorDescription' => 'No response body'};
            }
        } else {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Logger.error('AOB_SMSAlert: Response status: ' + response.getStatusCode(),new string[] {(String) responseToReturnObject.get('moreInformation')});
        }

        return responseToReturnObject;
    }
}