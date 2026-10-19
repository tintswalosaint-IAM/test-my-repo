/**
* @description Class for dealing with AOB_CustomerAlertsProfile api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa (lokesh.bothsa@standardbank.co.za)
* Story Number- SFP-26345
* @date June 2023
*/
public class CMN_CustomerAlertsProfile {
    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'Accept';
    private static final String HEADER_CONTENT_TYPE = 'Content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    
    private static final String PARAM_COLON = ':';
    

    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/customer-alert/eas/profile'; 
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CustomerAlertsProfile');

    
    /** 
* @description Method to Profile Alerts which will be invoked from parent class 
* @param applicationList
* @param participantList
* @return null
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> participantList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            
            Map<String, Object> response =  makeAlertProfileCallout(applicationList,participantList);
            return JSON.serialize(response);
        }
        
        return null;
    }
    /** 
* @description This method used for main callout that is CustomerAlertsProfile API 
* @param applicationRecords
* @param participantList
* @return  responseToReturnObject
*/
    public static Map<String, Object> makeAlertProfileCallout(List<Application__c> applicationRecords,List<Application_Participant__c> participantList) {
        
        Application__c applicationRecord = applicationRecords[0];
        Application_Participant__c applicationParticipantRecord = participantList[0];
        
        BCB_CustomerAlertsProfileBean customerAlertsProfileBeanRecord = new BCB_CustomerAlertsProfileBean();
        
        BCB_CustomerAlertsProfileBean.General generalRecord = new BCB_CustomerAlertsProfileBean.General();
        generalRecord.customerInternalID    = applicationRecord.AOB_Customer_Id__c;
        generalRecord.customerHostID        = 'FIN';
        generalRecord.languageID            = 'EN_US';
        generalRecord.firstName             = applicationParticipantRecord.CNGCU_First_Name__c != null ? applicationParticipantRecord.CNGCU_First_Name__c : '';
        generalRecord.lastName              = applicationParticipantRecord.CNGCU_Last_Name__c;
        
        BCB_CustomerAlertsProfileBean.ContactInformation contactInformationRecord = new BCB_CustomerAlertsProfileBean.ContactInformation();
        contactInformationRecord.mobileNumber   = '256'+ applicationRecord.AOB_Phone__c.replaceFirst('^0+', '');
        contactInformationRecord.emailID        = applicationRecord.CNGCU_CSEmail__c;
        contactInformationRecord.addressLine1   = applicationRecord.AOB_Street__c;
        contactInformationRecord.addressLine2   = '';
        contactInformationRecord.city           = applicationRecord.AOB_City__c;
        contactInformationRecord.state          = applicationRecord.AOB_State__c;
        contactInformationRecord.countryCode    = applicationRecord.AOB_Country__c;
        
        BCB_CustomerAlertsProfileBean.BillingInformation billingInformationRecord = new BCB_CustomerAlertsProfileBean.BillingInformation();
        billingInformationRecord.debitAccountNumber = applicationRecord.AOB_Account_Number__c;
        
        BCB_CustomerAlertsProfileBean.SchemaRecords schemaRecordsRecord = new BCB_CustomerAlertsProfileBean.SchemaRecords();
        schemaRecordsRecord.schemeID            = '6';
        schemaRecordsRecord.billingInformation  = billingInformationRecord;
        schemaRecordsRecord.startTimestamp      = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        schemaRecordsRecord.endDateTimestamp    = '2099-12-31T00:00:00.000';
        
        BCB_CustomerAlertsProfileBean.BillingInformation billingInformationRecord1 = new BCB_CustomerAlertsProfileBean.BillingInformation();
        billingInformationRecord1.debitAccountNumber = applicationRecord.AOB_Account_Number__c;
        
        BCB_CustomerAlertsProfileBean.SchemaRecords schemaRecordsRecord1 = new BCB_CustomerAlertsProfileBean.SchemaRecords();
        schemaRecordsRecord1.schemeID           = '2';
        schemaRecordsRecord1.billingInformation = billingInformationRecord1;
        schemaRecordsRecord1.startTimestamp     = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        schemaRecordsRecord1.endDateTimestamp   = '2099-12-31T00:00:00.000';
        
        customerAlertsProfileBeanRecord.General = GeneralRecord;
        customerAlertsProfileBeanRecord.contactInformation = contactInformationRecord;
        customerAlertsProfileBeanRecord.schemaRecords = new List<BCB_CustomerAlertsProfileBean.SchemaRecords>{schemaRecordsRecord, schemaRecordsRecord1};
            
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
            
            httpRequest.setBody(JSON.serialize(customerAlertsProfileBeanRecord));
            httpRequest.setTimeout(120000);
            
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                sendMockResponse();
                
                httpResponse = http.Send(httpRequest);
                
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    responseToReturnObject = sendApiResponse(responseBody,applicationRecord); 
                    
                } else {
                    String errorMessage = 'No Response From Server';
                    if(httpResponse.getBody() != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                    }
                    
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                    LOGGER.error('CMN_CustomerAlertsProfile.makeAlertProfileCallout:Response status:FAILED', new String[] {'CMN_CustomerAlertsProfile.makeAlertProfileCallout', applicationRecord.Id, JSON.serialize(responseToReturnObject)});
                }
                
            } catch (Exception ex) {
                LOGGER.error('CMN_CustomerAlertsProfile.makeAlertProfileCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CustomerAlertsProfile.makeAlertProfileCallout', applicationRecord.Id,JSON.serialize( ex.getMessage())});

                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_CustomerAlertsProfile.makeAlertProfileCallout:Access Token Failure', new String[] {'CMN_CustomerAlertsProfile.makeAlertProfileCallout', applicationRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
    
    /** 
* @description Method to alert subscription which will be invoked from parent class 
*/
    private static void sendMockResponse(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }
        }
    }
     /** 
* @description Method to  sendApiResponse
* @param responseBody
* @param applicationRecord
* @return map<string,object>
*/
    private static map<string,Object> sendApiResponse(string responseBody, Application__c applicationRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (responseBody != null) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            LOGGER.error('CMN_CustomerAlertsProfile.makeAlertProfileCallout: Status : SUCCESS', new String[] {'CMN_CustomerAlertsProfile.makeAlertProfileCallout', applicationRecord.Id});
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_CustomerAlertsProfile.makeAlertProfileCallout: No response body', new String[] {'CMN_CustomerAlertsProfile.makeAlertProfileCallout', applicationRecord.Id});

        }
        return responseToReturnObject;
    }
}