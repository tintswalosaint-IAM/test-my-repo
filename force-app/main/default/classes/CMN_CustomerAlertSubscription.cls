/**
* @description Class for dealing with Customeralert  api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa (lokesh.bothsa@standardbank.co.za)
* @date june 2022
*/
public class CMN_CustomerAlertSubscription {
    
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
    private static final String PATH_CALLOUT = '/customer-alerts/subscription';    
   
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';  
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CustomerAlertSubscription');
 
    /** 
* @description Method to alert subscription which will be invoked from parent class 
* @param applicationList
* @return null
*/
    public static String invocableMethod(List<Application__c> applicationList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            
            Map<String, Object> response =  makeAlertSubscriptionCallout(applicationList);
            
            return JSON.serialize(response);
        }
        
        return null;
    }
    /** 
* @description This method used for main callout that is CustomerAlertSubscription API 
* @param applicationRecords
* @return  responseToReturnObject
*/
    public static Map<String, Object> makeAlertSubscriptionCallout(List<Application__c> applicationRecords) {
        
        Application__c applicationRecord = applicationRecords[0];
        BCB_CustomerAlertSubscriptionBean customerAlertSub = new BCB_CustomerAlertSubscriptionBean();
        BCB_CustomerAlertSubscriptionBean.CustomerAlert customerAlert = new BCB_CustomerAlertSubscriptionBean.CustomerAlert();        
        BCB_CustomerAlertSubscriptionBean.EasCustomerInfo easCustomerInfo = new BCB_CustomerAlertSubscriptionBean.EasCustomerInfo();        
        BCB_CustomerAlertSubscriptionBean.AlertInfo alertInfo = new BCB_CustomerAlertSubscriptionBean.AlertInfo();        
        
        easCustomerInfo.customerType = 'E';
        easCustomerInfo.customerSubType = 'R';
        easCustomerInfo.customerIdentity = applicationRecord.AOB_Customer_Id__c; 
        easCustomerInfo.customerHostIdentity = 'FIN';
        easCustomerInfo.alertCustomerCategory = 'RETAILGOLD';
        
        alertInfo.alertName = 'FIN_LG_AMT';
        alertInfo.alertDescriptionCategoryIdentity = '';
        
        customerAlert.easCustomerInfo = easCustomerInfo;
        customerAlert.alertInfo = alertInfo;
        customerAlert.alertFrequency = '';
        customerAlert.uniqueIdentity = applicationRecord.AOB_Account_Number__c; 
        
        BCB_CustomerAlertSubscriptionBean.AlertCriticalRecord alertCriticalRecord = new BCB_CustomerAlertSubscriptionBean.AlertCriticalRecord();
        alertCriticalRecord.actualValue = '3.1';
        alertCriticalRecord.displayType = 'T';
        alertCriticalRecord.fieldName = 'AMOUNT';
        alertCriticalRecord.fieldValue = '55.37';
        alertCriticalRecord.fieldType = 'AMOUNT1';
        
        customerAlert.alertCriticalRecord = new List<BCB_CustomerAlertSubscriptionBean.AlertCriticalRecord>{alertCriticalRecord};
            
            List<BCB_CustomerAlertSubscriptionBean.ChannelInfo> channelInfoList = new List<BCB_CustomerAlertSubscriptionBean.ChannelInfo>();
        channelInfoList.add(new BCB_CustomerAlertSubscriptionBean.ChannelInfo('CHANNEL4', 'Y'));
        customerAlert.channelInfo = channelInfoList;
        
        customerAlertSub.customerAlert = customerAlert;
        
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
            
            httpRequest.setBody(JSON.serialize(customerAlertSub));
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
                    LOGGER.error('CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout:Response status:FAILED', new String[] {'CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout', applicationRecord.Id, JSON.serialize(responseToReturnObject)});

                }
            } catch (Exception ex) {
                LOGGER.error('CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout', applicationRecord.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout:Access Token Failure', new String[] {'CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout', applicationRecord.Id});
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
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            } 
        }
    }
      /** 
* @description Method to  sendApiResponse
* @param responseBody
* @param applicationRecord
* @return map<string,object>
*/
    private static map<string,object> sendApiResponse(string responseBody, Application__c applicationRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (responseBody != null) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            LOGGER.error('CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout:Status : SUCCESS', new String[] {'CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout', applicationRecord.Id});
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout: No response body', new String[] {'CMN_CustomerAlertSubscription.makeAlertSubscriptionCallout', applicationRecord.Id});
        }
        return responseToReturnObject;
    }
    
}