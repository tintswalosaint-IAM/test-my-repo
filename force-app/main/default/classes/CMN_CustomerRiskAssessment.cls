/***************************************************************************************
@Name of the Class : CMN_CustomerRiskAssessment
@description       : Class for dealing with Customer Risk Assessment api and sending the result to the main container and storing the values in the wrapper.
@Author            : Lokesh Bothsa Reddy(lokesh.bothsa@standardbank.co.za) 
@Date              : june 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 29-05-2024
@Modification Description :  SFP-38783
***************************************************************************************/

public class CMN_CustomerRiskAssessment {
       /**description attribute*/
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
       /**description attribute*/
    private static final String HEADER_ACCEPT = 'accept';
       /**description attribute*/
    private static final String HEADER_CONTENT_TYPE = 'content-type';
       /**description attribute*/
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
       /**description attribute*/
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
       /**description attribute*/
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
       /**description attribute*/
    private static final String HEADER_AUTHORIZATION = 'Authorization';
       /**description attribute*/
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
       /**description attribute*/
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
       /**description attribute*/
    private static final String HTTP_METHOD_POST = 'POST';
    
    /**description attribute*/
    private static final String PARAM_COLON = ':';
       /**description attribute*/
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
       /**description attribute*/
    private static final String PATH_CALLOUT = '/riskassessment/status';
    
       /**description attribute*/
    @testVisible private static Integer mockHttpStatusCode;
       /**description attribute*/
    @testVisible private static String mockHttpStatus;
       /**description attribute*/
    @testVisible private static String mockHttpBody = '';
       /**description attribute*/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CustomerRiskAssessment');
    
    /** 
* @description This method used for main callout Risk Assessment 
* @param applicationList
* @param products
* @param appParticipant
* @return String Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList, List<Product2> products,List<Application_Participant__c> appParticipant) {
        
        if(applicationList != null && applicationList.isEmpty() == false && products != null && products.isEmpty() == false) {
            
            Map<String, Object> responseStatus = makeCustomerRiskAssessmentCallout(applicationList, products,appParticipant);
            Verification__c verificationInstance = new Verification__c(Application__c = applicationList[0].Id,Verification_Source__c = 'Customer Risk Assessment');
            
            if(responseStatus.containsKey('ErrorDescription') == true) {
                responseStatus.put('status', 'Error');
                BCB_FlowController.createVerificationRecordForParticipant(appParticipant[0], 'Customer Risk Assessment', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');           

            } else if(responseStatus.containsKey('RiskScoreStatus') == true ) {
                responseStatus.put('status', 'Success');
                verificationInstance.Verification_Status__c = 'Success';
                verificationInstance.AOB_Risk_Score_Rating__c = (String) responseStatus.get('RiskScoreRating');
                verificationInstance.AOB_Risk_Score_Status__c = (String) responseStatus.get('RiskScoreStatus');
            }
            return JSON.serialize(responseStatus);
        }
        return null;
    }
    /** 
* @description This method used for main callout customer risk assessment API
* @param applicationRecords
* @param productRecords
* @param appParticipant
* @return Map<String, Object> Returns a callout response in map format for remaining processing
*/
    public static Map<String, Object> makeCustomerRiskAssessmentCallout(List<Application__c> applicationRecords, List<Product2> productRecords,List<Application_Participant__c> appParticipant) {
        
        Application__c applicationRecord = applicationRecords[0]; 
        Product2 productRecord = productRecords[0];
        Application_Participant__c applicationParticipant =appParticipant[0];
        BCB_CustomerRiskAssessmentWrapper customRiskAssessmentBeanRecord = new BCB_CustomerRiskAssessmentWrapper();
        customRiskAssessmentBeanRecord.CustomerEntityType = 'R';
        customRiskAssessmentBeanRecord.ProductSchemeCode = productRecord.AOB_Memo_Code__c;
        customRiskAssessmentBeanRecord.DistributionChannel = 'B';
        
        if(applicationRecord.AOB_Country__c == 'UG') {
            customRiskAssessmentBeanRecord.NonResidentIndicator = 'Y';
            customRiskAssessmentBeanRecord.ForeignCustomerIndicator = 'N';
        } else {
            customRiskAssessmentBeanRecord.NonResidentIndicator = 'N';
            customRiskAssessmentBeanRecord.ForeignCustomerIndicator = 'Y';
        }
        
        if(applicationRecord.AOB_PEP_Status__c == 'ACTIVE') { 
            customRiskAssessmentBeanRecord.PEPIndicator = 'Y';
        } else {
            customRiskAssessmentBeanRecord.PEPIndicator = 'N';
        }                                    
        customRiskAssessmentBeanRecord.CustomerEmploymentType = '004';
        customRiskAssessmentBeanRecord.HomeAddressCountryCode = applicationRecord.AOB_Country__c;
        customRiskAssessmentBeanRecord.MailingAddressCountryCode = 'UG';
        customRiskAssessmentBeanRecord.NationalityOfCustomer = applicationRecord.AOB_Country__c;
        customRiskAssessmentBeanRecord.CountryOfBirth = applicationRecord.AOB_Country__c;
        customRiskAssessmentBeanRecord.SegmentOfCustomer = '001'; 
        customRiskAssessmentBeanRecord.SubSegmentOfCustomer = '102'; 
        
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
            httpRequest.setBody(JSON.serialize(CustomRiskAssessmentBeanRecord));
            httpRequest.setTimeout(120000);

            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                if (System.Test.isRunningTest()) {
                    mockGenerator(mockHttpStatusCode,mockHttpStatus);
                }
                httpResponse = http.Send(httpRequest);
                
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    responseToReturnObject = sendApiResponse(responseBody,applicationRecord,applicationParticipant);
                } else {
                    String errorMessage = 'No Response From Server';
                    String responseBody = httpResponse.getBody();
                    
                    errorMessage = fetchingErrorInformation(responseBody,errorMessage);
                    
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                        LOGGER.error('CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout:Response status:FAILED', new String[] {'CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
                    
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout', applicationParticipant.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout:Access Token Failure', new String[] {'CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout', applicationParticipant.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        
        return responseToReturnObject;
    }
      /** 
* @description This method used for main callout customer risk assessment API
* @param mockHttpStatusCode
* @param mockHttpStatus
*/
    private static void mockGenerator(Integer mockHttpStatusCode,string mockHttpStatus){
        if(mockHttpStatusCode!=null && mockHttpStatus!=null){
            BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
    }
         /** 
* @description This method used for main callout customer risk assessment API
* @param responseBody
* @param applicationRecord
* @param applicationParticipant
* @return Map<String, Object>
*/
    private static  Map<String, Object> sendApiResponse(string responseBody,Application__c applicationRecord,Application_Participant__c applicationParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (String.isNotBlank(responseBody) == true) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                LOGGER.error('CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout: No response body', new String[] {'CMN_CustomerRiskAssessment.makeCustomerRiskAssessmentCallout', applicationParticipant.Id});
        }
        return responseToReturnObject;
    }

            /** 
* @description This method used for main callout customer risk assessment API
* @param responseBody
* @param errorMessage
* @return string
*/
    private static string fetchingErrorInformation(string responseBody,string errorMessage){
        if(String.isNotBlank(responseBody) == true) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            errorMessage = (String) responseObject.get('moreInformation');
        }
        return errorMessage;
    }
}