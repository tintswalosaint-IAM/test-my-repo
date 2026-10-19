/***************************************************************************************
@ Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za) 
@ Date              : June 2023
@ Name of the Class : CMN_MobileWalletStatus
@description        : Class for dealing with Mobile Fund Status
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 08-03-2024
@ Modification description : SFP-36156
***************************************************************************************/
public without sharing class CMN_MobileWalletStatus {
    private static final String AUTHORIZATION_TYPE_BASIC = 'Basic ';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String APACHE_HTTPCLIENT = 'User-HttpClient';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';

    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/wallet/mobile/transaction/status'; 
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_MobileWalletStatus');

    /**
    * @description Method for wallet status which will be invoked from parent class
    * @param applicationList
    * @param mobilewalletResponse
    * @return null
    */
    public static String invocableMethod(List<Application__c> applicationList, String mobilewalletResponse) {
        if(applicationList != null && applicationList.isEmpty() == false) {
           
            Map<String, Object> responseMap = makeMobileWalletStatusCallout(applicationList[0], mobilewalletResponse);
            
            return JSON.serialize(responseMap);
        }
        return null;
    }
    /**
    * * @description This method used for main callout that is MobileWalletStatus API 
    * @param applicationRecord
    * @param mobilewalletResponse
    * @return responseToReturnObject
    */
    public static Map<String, Object> makeMobileWalletStatusCallout(Application__c applicationRecord, String mobilewalletResponse) {
        
        BCB_MobileWalletStatusBean mobileWalletStatusBeanRecord = new BCB_MobileWalletStatusBean();

        String mwMerchantCode;
        Map<String, BCB_Static_Value__mdt> bcbStaticValuesMap = BCB_Static_Value__mdt.getAll();
        for(String bcbStaticVal : bcbStaticValuesMap.keySet()){
        BCB_Static_Value__mdt bcbValue = bcbStaticValuesMap.get(bcbStaticVal);
            if(bcbValue.Label == 'Mobile Wallet Status Merchant Code'){
                mwMerchantCode = bcbValue.Value__c;
            }
        }
        mobileWalletStatusBeanRecord.mobileNumber = '256' + applicationRecord.AOB_Mobile_Money_Number__c;
        mobileWalletStatusBeanRecord.requestId = applicationRecord.Id;
        mobileWalletStatusBeanRecord.merchantCode = mwMerchantCode;


       CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
       
       NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
       String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
       String fApiInteractionId = BCB_CTRL_FormCreator.createGUID();

       string accessToken = CMN_SRV_GetAccessToken.getAccessToken();

       Map<String, Object> responseToReturnObject = new Map<String, Object>();

       if(String.isNotBlank(accessToken) == true && accessToken != null) {
           HttpRequest httpRequest = new HttpRequest();

           httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
           httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
           httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
           httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
           httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
           httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
           httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
           
           httpRequest.setHeader('User-Agent', 'Salesforce_Client');
          
           httpRequest.setEndpoint(endpoint);
           httpRequest.setMethod(HTTP_METHOD_POST);
           httpRequest.setBody(JSON.serialize(mobileWalletStatusBeanRecord));
           httpRequest.setTimeout(120000);
           try {
               Http http = new Http();
               HttpResponse httpResponse = new HttpResponse();
               sendMockResponseStatus();

               httpResponse = http.Send(httpRequest);
     
               if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                   String responseBody = httpResponse.getBody();
                   if (responseBody != null) {
                       responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                   } else {
                       responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                       LOGGER.error('CMN_MobileWalletStatus.makeMobileWalletStatusCallout: No response body', new String[] {'CMN_MobileWalletStatus.makeMobileWalletStatusCallout', applicationRecord.Id});

                   }
               } else {
                   String errorMessage = 'No Response From Server';
                   responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                   LOGGER.error('CMN_MobileWalletStatus.makeMobileWalletStatusCallout:Response status:FAILED', new String[] {'CMN_MobileWalletStatus.makeMobileWalletStatusCallout', applicationRecord.Id, JSON.serialize(responseToReturnObject)});
               }
           } catch (Exception ex) {
               CMN_UTIL_Logger.error('Some Un-Handled Exception Occurred', ex.getMessage(), 'CMN_MobileWalletStatus.makeMobileWalletStatusCallout', applicationRecord.Id, ex);
               responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
           }
       } else {
            LOGGER.error('CMN_MobileWalletStatus.makeMobileWalletStatusCallout:Access Token Failure', new String[] {'CMN_MobileWalletStatus.makeMobileWalletStatusCallout', applicationRecord.Id});
           responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
       }
       return responseToReturnObject;
   }
     /**
    * @description  sendMockResponseStatus
    */
   public static void sendMockResponseStatus(){
    if (System.Test.isRunningTest()) {
        if(mockHttpStatusCode!=null && mockHttpStatus!=null){
             BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
         }
     }
   }
    
}