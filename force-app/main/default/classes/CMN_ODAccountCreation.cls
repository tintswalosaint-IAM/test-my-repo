/**
* @description Class for dealing with account creation api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story Number : SFP-25770
*/
public without sharing class CMN_ODAccountCreation {

    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
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
    private static final String PATH_CALLOUT = '/create-account-retail/creation';

    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_ODAccountCreation');
    
    
    /** 
* @description This method used for main account creation 
* @param applicationList
* @param products
* @param appParticipant
* @return Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList, List<Product2> products,List<Application_Participant__c> appParticipant)  {   
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> responseMap =  makeAccountCreationCallout(applicationList[0], products[0],appParticipant[0]);
            
            if(responseMap != null && responseMap.containsKey('ErrorDescription') == true) {
                responseMap.put('status', 'Error');
                BCB_FlowController.createVerificationRecord(applicationList[0], 'OD Account Create', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Account_Opened_Queue');
            } 
            return JSON.serialize(responseMap);
        }
        return null;
    }
    /** 
* @description This method used for main callout account creation API
* @param  applicationRecord
* @param  productRecord
* @param  appParticipant
* @return Returns a callout response in map format for remaining processing
*/
    public static Map<String, Object> makeAccountCreationCallout(Application__c applicationRecord, Product2 productRecord,Application_Participant__c appParticipant) {
        
        BCB_ODAccountCreationWrapper accountCreationBeanRecord = new BCB_ODAccountCreationWrapper();
        
        BCB_ODAccountCreationWrapper.AccountType accountType = new BCB_ODAccountCreationWrapper.AccountType();
        accountType.schemaCode = productRecord.AOB_Memo_Code__c;
        
        
        BCB_ODAccountCreationWrapper.BankInfo bankInfo = new BCB_ODAccountCreationWrapper.BankInfo();
        bankInfo.bankId = applicationRecord.AOB_Country__c; 
        bankInfo.branchId = applicationRecord.AOB_Preferred_Branch__c; 
        
        BCB_ODAccountCreationWrapper.ODAcctGeneralInfo acctGeneralInfo = new BCB_ODAccountCreationWrapper.ODAcctGeneralInfo();
        acctGeneralInfo.despatchMode = 'N';
        
        BCB_ODAccountCreationWrapper.AccountLimits accountLimits = new BCB_ODAccountCreationWrapper.AccountLimits();
        accountLimits.expiryDate = '2099-12-31T00:00:00.000'; 
        accountLimits.documentDate = '2023-06-21T19:00:00.000'; 
        accountLimits.drawingPowerIndicator = 'E';
        
        BCB_ODAccountCreationWrapper.ODAccountAddRq accountAddRq = new BCB_ODAccountCreationWrapper.ODAccountAddRq();
        accountAddRq.customerNumber     = applicationRecord.AOB_Customer_Id__c;
        accountAddRq.accountType        = accountType;
        accountAddRq.accountCurrency    = applicationRecord.AOB_Selected_Currency__c; 
        accountAddRq.bankInfo           = bankInfo;
        accountAddRq.ODAcctGeneralInfo  = acctGeneralInfo;
        accountAddRq.accountLimits      = accountLimits;
        accountAddRq.localCalculationFlag   = 'N';
        
        BCB_ODAccountCreationWrapper.ODaccountAddCustomData accountAddCustomData = new BCB_ODAccountCreationWrapper.ODaccountAddCustomData();
        accountAddCustomData.missEntered            = '1';
        accountAddCustomData.pricingCode            = productRecord.AOB_Pricing_Option__c;
        accountAddCustomData.PHCode                 = 'BRBAN';
        accountAddCustomData.EFTFlag                = 'N';
        accountAddCustomData.WPBFlag                = 'Y';
        accountAddCustomData.INTCRAccountFlag       = applicationRecord.AOB_Schema_Code__c == 'OD005' ? 'S':'S';
        accountAddCustomData.INTDRAccountFlag       = applicationRecord.AOB_Schema_Code__c == 'OD005' ? 'S':'S'; 
        accountAddCustomData.selfPrintChequeBook    = 'Y';
        accountAddCustomData.channelID              = 'SAF';
        accountAddCustomData.PFNum                  = 'ED2';  
        accountAddCustomData.applicationHealthCode  = '001';
        accountAddCustomData.saleBackendBO = null;
        
        Boolean isMobileMoneySelected = applicationRecord.AOB_Mode_Of_Payment__c == 'Mobile Money' ? true : false;
        
        accountAddCustomData.alternativeInstitutionName = isMobileMoneySelected ? applicationRecord.AOB_Operator_Name__c : [select id,Name, AOB_SAPField__c,AOB_Code__c from AOB_ReferencedData__c where AOB_CountryCode__c='Uganda' AND AOB_Code__c=:applicationRecord.AOB_Name_Of_Bank__c].Name; 
        accountAddCustomData.alternativeAccountName = isMobileMoneySelected ? applicationRecord.AOB_MNO_Customer_Name__c : applicationRecord.AOB_Alternative_Account_Name__c;
        accountAddCustomData.alternativeAccountNumber = isMobileMoneySelected ? applicationRecord.AOB_Mobile_Money_Number__c : applicationRecord.AOB_Alternative_Account_Number__c;
        
        accountCreationBeanRecord.ODAccountAddRq          = accountAddRq;
        accountCreationBeanRecord.ODAccountAddCustomData  = accountAddCustomData;
        
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        
    
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();
        
        string accessToken = CMN_SRV_GetAccessToken.getAccessToken();
        
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if(String.isNotBlank(accessToken) == true && accessToken != null) {
            
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
            
          
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            
        
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
        
            httpRequest.setBody(JSON.serialize(accountCreationBeanRecord));
            httpRequest.setTimeout(120000);
     
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                sendMockResponse();
                
                httpResponse = http.Send(httpRequest);
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
               
                    responseToReturnObject = sendResponseBody(responseBody,applicationRecord,appParticipant);  
                } else {
                    responseToReturnObject = sendNoResponseServer(httpResponse,applicationRecord,appParticipant);
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout:Access Token Failure', new String[] {'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
    
      /**
    * @description This method used for main callout that is MobileWalletStatus API 
    * @param responseBody
    * @param applicationRecord
    * @param appParticipant
    * @return map<string,object>  responseToReturnObject
    */
    private static map<string,object> sendResponseBody(string responseBody,Application__c applicationRecord,Application_Participant__c appParticipant){
        if (String.isBlank(responseBody)) {
            Map<String, Object> responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout: No response body', new String[]{'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id});
            return responseToReturnObject;
        }
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (!responseObject.containsKey('ODAccountAddRes')) {
            LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout: Response status: FAILED', new String[]{'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id, JSON.serialize(responseObject)});
            return responseObject;
        }
        Map<String, Object> odAccountAddRes = (Map<String, Object>) responseObject.get('ODAccountAddRes');
        if (!odAccountAddRes.containsKey('ODaccountNumber')) {
            LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout: Response status: FAILED', new String[]{'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id, JSON.serialize(responseObject)});
            return odAccountAddRes;
        }
        Map<String, Object> odaccountNumber = (Map<String, Object>) odAccountAddRes.get('ODaccountNumber');
        return fetchAccountNumber(odaccountNumber, appParticipant);
    } 
    
     /**
    * @description This method used for main callout that is MobileWalletStatus API 
    * @param odaccountNumber
    * @param appParticipant
    * @return map<string,object> responseToReturnObject
    */
    private static map<string,object> fetchAccountNumber( Map<String, Object> odaccountNumber,Application_Participant__c appParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(odaccountNumber.containsKey('accountNumber') == true ) {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'accountNumber' =>  odaccountNumber.get('accountNumber')};
                LOGGER.error('BCB_ODAccountCreation.makeAccountCreationCallout: Status : SUCCESS', new String[] {'BCB_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id});
            
        }
        return responseToReturnObject;
    }
    /**
*  @description This method used for the sendMockResponseStatus
*/
    private static void sendMockResponse(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }  
        }
    }
     /**
    * @description This method used for main callout that is MobileWalletStatus API 
    * @param httpResponse
    * @param applicationRecord
    * @param appParticipant
    * @return map<string,object> responseToReturnObject
    */
    private static map<string,object> sendNoResponseServer(HttpResponse httpResponse,Application__c applicationRecord,Application_Participant__c appParticipant){
        string errorMessage;
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_ODAccountCreation.makeAccountCreationCallout:Response status:FAILED', new String[] {'CMN_ODAccountCreation.makeAccountCreationCallout', appParticipant.Id, JSON.serialize(responseToReturnObject)});
        
        return responseToReturnObject;
    }
}