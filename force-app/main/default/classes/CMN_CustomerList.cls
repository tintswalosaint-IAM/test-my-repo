/***************************************************************************************
@Name of the Class : CMN_CustomerList
@description       : Dealing with a customer list in class API to determine if a customer is already in the system or not.
@Author            : Jagadish 
@Date              : May 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 16-05-2024
@Modification Description :  SFP-38572
***************************************************************************************/
public without sharing class CMN_CustomerList {
    /**description application*/
private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
  /**description Accept*/
private static final String HEADER_ACCEPT = 'Accept';
  /**description Content*/
private static final String HEADER_CONTENT_TYPE = 'Content-type';
  /**description Client*/
private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
  /**description Client*/
private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
  /**description certificate*/
private static final String HEADER_CLIENT_CERTIFICATE = 'X-client-certificate';
  /**description Authorization*/
private static final String HEADER_AUTHORIZATION = 'Authorization';
  /**description interaction*/
private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
  /**description application*/
private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
  /**description GET*/
private static final String HTTP_METHOD = 'GET';

/**description GET*/
private static final String PARAM_COLON = ':';

 /**description oauth2*/
private static final String PATH_TOKEN = '/sysauth/oauth2/token';
 /**description GET*/
private static final String PATH_CALLOUT = '/external-partners/customer-list';
 /**description partners*/
private static final string GET_PATH_CALLOUT = '/external-partners/customers/';
/**description mockHttpStatusCode*/
@testVisible private static Integer mockHttpStatusCode;
 /**description mockHttpStatus*/
@testVisible private static String mockHttpStatus;
 /**description mockHttpBody*/
@testVisible private static String mockHttpBody = '';
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CustomerList');

/** 
* @description This method used for main callout that is CMN_CustomerList API 
* @param preAppInputMap
* @return String Returns a callout response in map format for remaining processing
*/
public static String invocableMethod(Map<String, String> preAppInputMap)  {
    if(preAppInputMap != null) {
        Map<String, Object> responseObject = invokeCustomerCheckBeforeProceed(preAppInputMap);
        if(responseObject != null) {
            return JSON.serialize(responseObject);
        }
    }
    return null;
}
/** 
* @description This method used for main callout that is CMN_CustomerList API 
* @return Map<String, Object> Returns a callout response in map format for remaining processing
*/
public static  Map<String, Object> invokeCustomerCheckBeforeProceed(Map<String, String> preAppInputMap) {
    
    CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
    
    NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
    
    String dateOfBirth = preAppInputMap.get('dateOfBirth');
    Date dateValue = Date.valueOf(dateOfBirth);
    String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT 
        +'?firstName=' + (preAppInputMap.get('firstName') != null ? (EncodingUtil.urlEncode(preAppInputMap.get('firstName').toUppercase() , 'UTF-8').replace('+', '%20')) : '')
        +'&lastName=' + EncodingUtil.urlEncode(preAppInputMap.get('lastName').toUppercase() , 'UTF-8').replace('+', '%20') 
        +'&dob=' + Datetime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
    
    String fApiInteractionId = BCB_CTRL_FormCreator.createGUID();
    
    string accessToken = CMN_SRV_GetAccessToken.getAccessToken();   
    Map<String, Object> responseToReturnObject = new Map<String, Object>();
    if(accessToken != null && String.isNotBlank(accessToken) == true) {
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
        
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
        httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
        
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(HTTP_METHOD);
        httpRequest.setTimeout(120000);
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            if (Test.isRunningTest()) {
                mockGenerator(mockHttpStatusCode,mockHttpStatus);
            }
            httpResponse = http.Send(httpRequest);
            String uuIdNum = '';
            if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                responseToReturnObject = sendingApiResponse(responseBody); 
            } 
            else {   
                String errorMessage = 'No Response From Server';
                String responseBody = httpResponse.getBody();
                if(String.isNotBlank(responseBody) == true) {
                    Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    errorMessage = (String) responseObject.get('moreInformation');
                    LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed: Need More moreInformation', new String[] {'CMN_CustomerList.invokeCustomerCheckBeforeProceed',JSON.serialize(responseToReturnObject)});
                }
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed:Response status:FAILED', new String[] {'CMN_CustomerList.invokeCustomerCheckBeforeProceed',JSON.serialize(responseToReturnObject)});
            }
        } catch (Exception ex) {
            LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed:Some Un-Handled Exception Occurred', new String[] {'CMN_CustomerList.invokeCustomerCheckBeforeProceed',JSON.serialize(ex.getMessage())});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                }
    } else {
        LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed:Access Token Failure', new String[] {'CMN_CustomerList.invokeCustomerCheckBeforeProceed'});
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
            }
    
    return responseToReturnObject;
}

  /** 
* @description This method used for main callout that is CMN_CustomerList API 
* @param mockHttpStatusCode
* @param mockHttpStatus
*/
private static void mockGenerator(Integer mockHttpStatusCode,string mockHttpStatus){
    if(mockHttpStatusCode!=null && mockHttpStatus!=null){
        BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
    }
}


  /** 
* @description This method used for main callout that is CMN_CustomerList API 
* @param responseBody
* @return Map<String, Object>
*/
private static Map<String, Object> sendingApiResponse(string responseBody){
    Map<String, Object> responseToReturnObject = new Map<String, Object>();
    if (responseBody != null) {                
        BCB_CustomerListBean responseObject = (BCB_CustomerListBean) JSON.deserialize(responseBody, BCB_CustomerListBean.class);
        responseToReturnObject = checkResponseExistOrNot(responseObject);
    } else {
        LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed: No response body',new String[] {'CMN_CustomerList.sendingApiResponse', responseBody});
        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
    } 
    return responseToReturnObject;
}
  /** 
* @description This method used for main callout that is CMN_CustomerList API 
* @param responseObject
* @return Map<String, Object>
*/
private static Map<String, Object> checkResponseExistOrNot(BCB_CustomerListBean responseObject){
    Map<String, Object> responseToReturnObject = new Map<String, Object>();
    if (responseObject == null || responseObject.customers == null || responseObject.customers.isEmpty() || responseObject.customers[0].uuid == null) {
        responseToReturnObject = new Map<String, Object>{
            'status' => 'SUCCESS', 
            'statusCode' => 200
        };
    }else if(responseObject.customers[0].uuid != null){
        string uuIdNum = fetchCustomerDataId(responseObject);
        responseToReturnObject = new Map<String, Object>{
            'status' => 'SUCCESS', 
            'statusCode' => 200,
            'uuId' => uuIdNum
        };
    }
    else {
        responseToReturnObject = new Map<String, Object>{
            'status' => 'FAILED', 
            'statusCode' => 200
        };
        responseToReturnObject.put('ErrorDescription', 'Failed to get customer uuid number ');  
        LOGGER.error('CMN_CustomerList.invokeCustomerCheckBeforeProceed: Failed to get customer uuid number',new String[] {'CMN_CustomerList.checkResponseExistOrNot', JSON.serialize(responseObject)}); 
    }
    return responseToReturnObject;
}
 /** 
* @description This method used for main callout that is CMN_CustomerList API 
* @param responseObject
* @return String
*/
private static String fetchCustomerDataId(BCB_CustomerListBean responseObject){
    string uuIdNum = '';
    for(BCB_CustomerListBean.Customers eachcustomer : responseObject.Customers)
    {
        uuIdNum = eachcustomer.uuid;
    }
    return uuIdNum;
}
}