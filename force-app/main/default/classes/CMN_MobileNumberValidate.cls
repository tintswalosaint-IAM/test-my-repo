/***************************************************************************************
@Name of the Class : CMN_MobileNumberValidate
@Description       : Class for dealing with MNO api and sending the result to the main container and storing the values in the wrapper
@Author            : Jagadish Thummala 
@Date              : May 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 29-02-2024
@Modification Description : SFP-36156
***************************************************************************************/
public class CMN_MobileNumberValidate {
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
    private static final String PATH_CALLOUT = '/mobile-number/validation';
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody  = '';

    private static Set<String> mobileCodeMTNSet = new Set<String>{'76', '77', '78'};
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_MobileNumberValidate');

    /**
     * @description invoke mobile number validation
     * @param participantList
     * @return String
     */
    public static String invocableMethod(List<Application_Participant__c> participantList) {
       
                if(participantList.isEmpty() == false) {
                    Map<String, Object> responseObject = makeMobilMoneyVerifyCallout(participantList[0]);
                    if(responseObject != null) {
                        return JSON.serialize(responseObject);
                    }
                    
                }
                return null;   
      
    }
    
    
    /**
     * @description invoke mobile number validation
     * @param participantRecord
     * @return String
     */    
    public static Map<String, Object> makeMobilMoneyVerifyCallout(Application_Participant__c participantRecord) {
        List<Application__c> applicationList = new SEL_Application().selectAppsById(participantRecord.Application__c);

        BCB_MobileNumberValidateBean mobileNumberValidateBeanRecord = new BCB_MobileNumberValidateBean();
        BCB_MobileNumberValidateBean.PayLoad payload = new BCB_MobileNumberValidateBean.PayLoad();
        BCB_MobileNumberValidateBean.RequestData requestData = new BCB_MobileNumberValidateBean.RequestData();
        BCB_MobileNumberValidateBean.ValidateCustomer validateCustomer = new BCB_MobileNumberValidateBean.ValidateCustomer();
        BCB_MobileNumberValidateBean.Body body = new BCB_MobileNumberValidateBean.Body();
        payload.area = 'WALLET';
        payload.CustomerRef = '256'+ participantRecord.CNGCU_Phone__c.replaceFirst('^0+', '');
        String serviceCode = '12';
        /* Verifying Mobile Number starts with MTN */
        if(mobileCodeMTNSet.contains(participantRecord.CNGCU_Phone__c.substring(0, 2)) == true) {
            serviceCode = '13';
        }
        payload.ServiceCode = serviceCode; 
        requestData.PayLoad = payload;
        validateCustomer.requestData = requestData;
        body.ValidateCustomer = validateCustomer;
        mobileNumberValidateBeanRecord.Body = body;
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();  
        //Prepare Request
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_CTRL_FormCreator.createGUID();
   
        string bcbAccessToken = CMN_SRV_GetAccessToken.getAccessToken();
        
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(String.isNotBlank(bcbAccessToken) == true) {
          
            //Set HTTP Request Headers
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, bcbAccessToken);
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
       
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            //Set Request details
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(mobileNumberValidateBeanRecord));
            httpRequest.setTimeout(120000);
            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest()) {
                    if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                    	BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody );
                    }
                }
                httpResponse = http.Send(httpRequest);
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (responseBody != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        if(responseObject != null && responseObject.containsKey('Body') == true) {
                            Map<String, Object> responseBodyObject = (Map<String, Object>) responseObject.get('Body');
                            if(responseBodyObject != null && responseBodyObject.containsKey('ValidateCustomerResponse') == true) {
                                Map<String, Object> validateCustomerResponse = (Map<String, Object>) responseBodyObject.get('ValidateCustomerResponse');
                                if(validateCustomerResponse != null && validateCustomerResponse.containsKey('ValidateCustomerResult') == true) {
                                    Map<String, Object> validateCustomerResult = (Map<String, Object>) validateCustomerResponse.get('ValidateCustomerResult');
                                    if(validateCustomerResult != null && validateCustomerResult.containsKey('Details') == true) {
                                        Map<String, Object> details = (Map<String, Object>) validateCustomerResult.get('Details');
                                        if(details != null && details.containsKey('Status') == true) {
                                            Map<String, Object> status = (Map<String, Object>) details.get('Status');
                                            if(status.containsKey('StatusCode') && status.containsKey('Description')) {
                                                responseToReturnObject = status;
                                            }
                                        }
                                        if(details != null && details.containsKey('Resultz') == true) {
                                            Map<String, Object> resultz = (Map<String, Object>) details.get('Resultz');
                                            if(resultz.containsKey('CustomerName') == true && responseToReturnObject.isEmpty() == false) {
                                              
                                                responseToReturnObject.put('CustomerName', (String) resultz.get('CustomerName'));
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                        LOGGER.error('CMN_MobileNumberValidate:No response body ',new String[] {'CMN_MobileNumberValidate.makeMobilMoneyVerifyCallout', participantRecord.Id});
                    }
                } else {
                    String errorMessage = 'No Response From Server';
                    String responseBody = httpResponse.getBody();
                    if(String.isNotBlank(responseBody) == true) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                    }
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                    BCB_CTRL_FormCreator.createVerificationRecord(participantRecord, 'MNO', 'Failed');
                   BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');  
                    LOGGER.error('CMN_MobileNumberValidate:status:FAILED ',new String[] {'CMN_MobileNumberValidate.makeMobilMoneyVerifyCallout', JSON.serialize(responseToReturnObject), participantRecord.Id});
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_MobileNumberValidate:Some Un-Handled Exception Occurred',new String[] {'CMN_MobileNumberValidate.makeMobilMoneyVerifyCallout', participantRecord.Id},ex);
                BCB_CTRL_FormCreator.createVerificationRecord(participantRecord, 'MNO', 'Failed');
               BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');  
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
            }
        } else {        
            LOGGER.error('CMN_MobileNumberValidate:Access Token Failure',new String[] {'CMN_MobileNumberValidate.makeMobilMoneyVerifyCallout', participantRecord.Id});
            BCB_CTRL_FormCreator.createVerificationRecord(participantRecord, 'MNO', 'Failed');
           BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');  
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
        }
        return responseToReturnObject;
    }
}