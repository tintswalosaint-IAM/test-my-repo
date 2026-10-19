/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_MobileWalletStatus
@ Description       :Class for dealing Mobile Fund Status
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :3/14/2024.
@ Modification Description : SFP-28286
*****************************************************************************************
@ last Modified By  :Jagadish Thummala
@ last Modified On  :9/1/2026
@ user story : SFP-60131
@ Modification Description : Updated the mapping for requestId.
***************************************************************************************/

public class AOB_MobileWalletStatus {
private AOB_MobileWalletStatus(){}
    //HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String USER_AGENT = 'User-Agent';
    private static final String PATH_CALLOUT = '/wallet/mobile/transaction/status'; 
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_MobileWalletStatus');
    public static  Map<String, Object> responseToReturnObject;
    public static  Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_MobileWalletStatus');

    /**
    * @description Method for wallet status which will be invoked from parent class
    * @param applicationList
    * @return null
    */
   public static String invokeWalletStatus(List<Application__c> applicationList, String mobilewalletResponse) {
    if (applicationList == null || applicationList.isEmpty()) {
        return null;
    }

    Application__c applicationRecord = applicationList[0];
    Map<String, Object> responseMap = makeMobileWalletStatusCallout(applicationRecord, mobilewalletResponse);

    String status = (responseMap != null && 'SUCCESS'.equals(responseMap.get('status'))) ? 'Success' : 'Failed';
   
    return handleVerification(applicationRecord, responseMap, status);
    
    }

    private static String handleVerification(Application__c applicationRecord, Map<String, Object> responseMap, String status) {
        Verification__c verificationInstance = new Verification__c(
            Application__c = applicationRecord.Id,
            Verification_Source__c = 'Mobile Wallet Status Check',
            AOB_DSX_Response__c = JSON.serialize(responseMap),
            Verification_Status__c = status
        );
        AOB_FlowController.createVerificationWithInstance(verificationInstance);

        return JSON.serialize(responseMap);
    }

    
    
    /**
    * @description This method used to prepare headers
    * @param applicationRecord
    * @param mobilewalletResponse
    * @return responseToReturnObject
    */
    public static Map<String, Object> makeMobileWalletStatusCallout(Application__c applicationRecord, String mobilewalletResponse) {
        AOB_MobileWalletStatusBean mobileWalletStatusBeanRecord = prepareMobileWalletStatusBean(applicationRecord, mobilewalletResponse);
        HttpRequest httpRequest = prepareHttpRequest(mobileWalletStatusBeanRecord);
        return sendHttpRequest(httpRequest, applicationRecord);
    }
     /**
    * @description This method used to prepare MobileWallet Status Bean
    * @param applicationRecord
    * @param mobilewalletResponse
    * @return mobileWalletStatusBeanRecord
    */
    private static AOB_MobileWalletStatusBean prepareMobileWalletStatusBean(Application__c applicationRecord, String mobilewalletResponse) {
        AOB_MobileWalletStatusBean mobileWalletStatusBeanRecord = new AOB_MobileWalletStatusBean();
        mobileWalletStatusBeanRecord.mobileNumber = '256' + applicationRecord.AOB_Phone__c;
        mobileWalletStatusBeanRecord.requestId = applicationRecord.Id;
        mobileWalletStatusBeanRecord.merchantCode = String.valueOf(mData.get('walletStMerchantCode'))??'';
        Map<String, Object> mobilewalletResponseMap = (Map<String, Object>) JSON.deserializeUntyped(mobilewalletResponse);
        if (mobilewalletResponseMap != null && mobilewalletResponseMap.containsKey('transactionReference')) {
            mobileWalletStatusBeanRecord.requestId = (String) mobilewalletResponseMap.get('transactionReference');
        }
        return mobileWalletStatusBeanRecord;
    }
     /**
    *  @description This method used to prepare Http Request
    * @param mobileWalletStatusBeanRecord
    * @return HttpRequest
    */
    private static HttpRequest prepareHttpRequest(AOB_MobileWalletStatusBean mobileWalletStatusBeanRecord) {
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setHeader(USER_AGENT, String.valueOf(mData.get('walletStClient')));
        httpRequest.setBody(JSON.serialize(mobileWalletStatusBeanRecord));
        return httpRequest;
    }
     /**
    *  @description This method used to main callout 
    * @param httpRequest
    * @param applicationRecord
    * @return responseToReturnObject
    */
    private static Map<String, Object> sendHttpRequest(HttpRequest httpRequest, Application__c applicationRecord) {
        try {
            Http http = new Http();
            if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
              {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                }
            }

            HttpResponse httpResponse = http.Send(httpRequest);
    
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {

                String responseBody = httpResponse.getBody();

                if (string.isBlank(responseBody) == false) {
                    responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                } else {
                    responseToReturnObject = new Map<String, Object>{
                        'status' => 'NO_CONTENT', 
                        'statusCode' => 204, 
                        'ErrorDescription' => 'No response body'
                    };
                   Logger.error('AOB_MobileWalletStatus: No response body',  new string[]{applicationRecord.Id});
                }
            } else {
                String errorMessage = 'No Response From Server';
    
                responseToReturnObject = new Map<String, Object>{
                    'status' => 'FAILED', 
                    'statusCode' => httpResponse.getStatusCode(), 
                    'ErrorDescription' => errorMessage
                };
                Logger.error('AOB_MobileWalletStatus: Response status: ' + httpResponse.getStatusCode(), new string[]{applicationRecord.Id,errorMessage});
            }
        } catch (Exception ex) {
           Logger.error('AOB_MobileWalletStatus: Some Un-Handled Exception Occurred', ex);
            responseToReturnObject = new Map<String, Object>{
                'status' => 'FAILED', 
                'ErrorDescription' => ex.getMessage()
            };
        }
        return responseToReturnObject;
    }
    
}