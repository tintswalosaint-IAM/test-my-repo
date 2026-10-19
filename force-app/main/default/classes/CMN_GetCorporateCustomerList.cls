/**
* @description Dealing with a corporate customer list in class API to determine if a customer is already in the system or not
* @author Lokesh 
* @date July 2023
* Story Number : SFP-27033
*/
public class CMN_GetCorporateCustomerList {

    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'Accept';
    private static final String HEADER_CONTENT_TYPE = 'Content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD = 'GET';
    private static final String CIF_COUNTRY = 'cifCountry';
    private static final String CUSTOMER_TYPE = 'customerType';
    private static final String CIF_COUNTRY_CODE  = 'UG';
    private static final String CUSTOMER_TYPE_CODE = 'corporate';
    
    private static final String PARAM_COLON = ':';
    
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/external-partners/customers';
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_GetCorporateCustomerList');

    /** 
* @description This method used for main callout that is BCB_CorporateCustomerList API 
* @param applicationList
* @param applicationParticipant
* @return Returns a callout response in map format for remaining processing
*/
    public static String invocableMethod(List<Application__c> applicationList,Application_Participant__c applicationParticipant)  {
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> responseObject = invokeCorporateCustomerCheck(applicationList[0],applicationParticipant);
            if(responseObject != null) {
                return JSON.serialize(responseObject);
            }  
        }
        return null;
    }
    
    /** 
* @description This method used for main callout that is invokeCorporateCustomerCheck API 
* @param applicationRecord
* @param applicationParticipant
* @return String
*/
    public static Map<String, Object> invokeCorporateCustomerCheck(Application__c applicationRecord,Application_Participant__c applicationParticipant){
        
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        
        //Prepare Request
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT 
            +'?legalName=' + (applicationRecord.AOB_BusinessLegalName__c != null ? (EncodingUtil.urlEncode(applicationRecord.AOB_BusinessLegalName__c , 'UTF-8').replace('+', '%20')) : '');
        
        String fApiInteractionId = BCB_FlowController.createGUID();
        
        string bcbAccessToken = CMN_SRV_GetAccessToken.getAccessToken();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(String.isNotBlank(bcbAccessToken) == true) {
        
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, bcbAccessToken);

            
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            httpRequest.setHeader(CIF_COUNTRY, CIF_COUNTRY_CODE);
            httpRequest.setHeader(CUSTOMER_TYPE,CUSTOMER_TYPE_CODE);
            
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD);
            httpRequest.setTimeout(120000);
            
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
                    BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                }
                httpResponse = http.Send(httpRequest);
            
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    responseToReturnObject = sendingApiResponse(responseBody,applicationParticipant);  
                } else {
                    String errorMessage = 'No Response From Server';
                    if(httpResponse.getBody() != null) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                        LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Need More Information', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});

                    }
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                    LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Response status:FAILED', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Some Un-Handled Exception Occurred', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                }
        } else {
            LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Access Token Failure', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
     
     /** 
    * @description sendingApiResponse 
    * @param responseBody
    * @param applicationParticipant
    * @return String Returns String responseToReturnObject

    */
    private static Map<String, Object>  sendingApiResponse(string responseBody,Application_Participant__c applicationParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if (responseBody != null) {
            BCB_CorporateCustomerListBean responseObject = (BCB_CorporateCustomerListBean) JSON.deserialize(responseBody, BCB_CorporateCustomerListBean.class);
            if(responseObject != null && responseObject.customers != null  && responseObject.customers.isEmpty() == false && responseObject.customers[0].uuid != null) {
                string uuidNum = responseObject.customers[0].uuid;
                responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200,'uuId' => uuidNum};
                LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Customer has corporate cif number', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id});
                  
                    }else{
                        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => 200};
                            responseToReturnObject.put('ErrorDescription', 'Hello failed to get customer uuid number '); 
                            LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck:Hello failed to get customer uuid number', new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id});

                    }
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck: No response body',new String[] {'CMN_GetCorporateCustomerList.invokeCorporateCustomerCheck', applicationParticipant.Id});

        }
        return responseToReturnObject;
    }
}