/***************************************************************************************
@Name of the Class : CMN_MobileWallet
@description       : Class for dealing with Mobile Fund and sending the money to the newly created Account.
@Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
@Date              : June 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 04-04-2024
@Modification Description : SFP-37302
@Last Modified By  : Alex Niyonsaba
@Last Modified On  : 06 JUL 2026
@Modification Description : [SFP-59073] Cast amount to Integer to fix 'Invalid amount' API error rsponse.
***************************************************************************************/
public without sharing class CMN_MobileWallet {
  
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
    
    private static final String PARAM_COLON = ':';
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/wallet/mobile/transaction'; 

    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_MobileWallet');
    
    
    /**
* @description Method for wallet response which will be invoked from parent class
* @param applicationList
* @param participantList
* @return null
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> participantList) {   
        if(applicationList != null && applicationList.isEmpty() == false) {
            
            Map<String, Object> responseMap =  makeMobileWalletCallout(applicationList[0],participantList[0]);
            return JSON.serialize(responseMap);
        }
        return null;
    }
    /**
* @description This method used for main callout that is MobileWallet API 
* @param applicationRecord
* @param applicationParticipantRecord
* @return responseToReturnObject
*/
    public static Map<String, Object> makeMobileWalletCallout(Application__c applicationRecord,Application_Participant__c applicationParticipantRecord) {
        
        BCB_MobileWalletBean mobileWalletBeanRecord = new BCB_MobileWalletBean();
        
        mobileWalletBeanRecord.function = 'cfmsRequestingFundsCollection';
        
        BCB_MobileWalletBean.Payload payloadRecord = new BCB_MobileWalletBean.Payload();
        payloadRecord.requestTime = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        payloadRecord.transactionReference = applicationRecord.Id;
        payloadRecord.name = (applicationParticipantRecord.CNGCU_First_Name__c != null ? applicationParticipantRecord.CNGCU_First_Name__c : '') + ' ' + applicationParticipantRecord.CNGCU_Last_Name__c;
        payloadRecord.amount = String.valueOf(applicationRecord.First_Deposit_Amount__c.intValue());
        payloadRecord.sessionNumber = String.valueOf(System.now().getTime());
        payloadRecord.mobileNumber = '256' + applicationRecord.AOB_Mobile_Money_Number__c;
        
        Map<String, BCB_Static_Value__mdt> bcbStaticValuesMap = BCB_Static_Value__mdt.getAll();
        String solePropCompanySearchFee = bcbStaticValuesMap.get('Sole_Prop_Company_Search_Fee').Value__c != NULL ? bcbStaticValuesMap.get('Sole_Prop_Company_Search_Fee').Value__c : '0';
        List<BCB_MobileWalletBean.Transfer> transferRecordList = new List<BCB_MobileWalletBean.Transfer>();
        BCB_MobileWalletBean.Transfer transferRecord = new BCB_MobileWalletBean.Transfer();
        transferRecord.accountNo = applicationRecord.AOB_Account_Number__c;
        transferRecord.amount = String.valueOf(applicationRecord.First_Deposit_Amount__c.intValue() - Integer.valueOf(solePropCompanySearchFee));
        transferRecord.name = (applicationParticipantRecord.CNGCU_First_Name__c != null ? applicationParticipantRecord.CNGCU_First_Name__c : '') + ' ' + applicationParticipantRecord.CNGCU_Last_Name__c;
        
        BCB_MobileWalletBean.Transfer transferRecord1 = new BCB_MobileWalletBean.Transfer();
        transferRecord1.accountNo = bcbStaticValuesMap.get('Sole_Prop_Company_Suspense_Account').Value__c != NULL ? bcbStaticValuesMap.get('Sole_Prop_Company_Suspense_Account').Value__c : '';
        transferRecord1.amount = solePropCompanySearchFee;
        transferRecord1.name = (applicationParticipantRecord.CNGCU_First_Name__c != null ? applicationParticipantRecord.CNGCU_First_Name__c : '') + ' ' + applicationParticipantRecord.CNGCU_Last_Name__c;
        
        transferRecordList.add(transferRecord);
        transferRecordList.add(transferRecord1);
        
        mobileWalletBeanRecord.payload = payloadRecord;
        mobileWalletBeanRecord.transfer = transferRecordList;
        
        
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        
        //Prepare Request
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
            httpRequest.setBody(JSON.serialize(mobileWalletBeanRecord));
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
                        //responseToReturnObject.put('statusCode', 200);
                        
                    } else {
                        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                            LOGGER.error('CMN_MobileWallet.makeMobileWalletCallout: No response body', new String[] {'CMN_MobileWallet.makeMobileWalletCallout', applicationParticipantRecord.Id});
                    }
                } else {
                    String errorMessage = 'No Response From Server';
                    
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                        LOGGER.error('CMN_MobileWallet.makeMobileWalletCallout:Response status:FAILED', new String[] {'CMN_MobileWallet.makeMobileWalletCallout', applicationParticipantRecord.Id, JSON.serialize(responseToReturnObject)});
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_MobileWallet.makeMobileWalletCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_MobileWallet.makeMobileWalletCallout', applicationParticipantRecord.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage(), 'statusCode' => 500};
                    }
        } else { 
            LOGGER.error('CMN_MobileWallet.makeMobileWalletCallout:Access Token Failure', new String[] {'CMN_MobileWallet.makeMobileWalletCallout', applicationParticipantRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure', 'statusCode' => 500};
                }
        return responseToReturnObject;
    }
/**
*  @description This method used for the sendMockResponseStatus
*/
    public static void sendMockResponseStatus(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
        }
    } 
}