/***************************************************************************************
* @description       :Test Class for dealing with Rely Comply
* @ Author            : Amarnath Reddy
* @ Date              :July 2023
* @ Name of the Class :BCB_RelyComplyBusinessScreening_Test
* @ Last Modified By  : Amarnath Reddy 
* @ Last Modified On  :25-05-2022 
* @ Modification description : SFP-26346
***************************************************************************************/
public without sharing class AOB_APIHandler {

    /** @description PARAM_COLON */ 
    private static final String PARAM_COLON = ':';
    /** @description HEADER_AUTHORIZATION */
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    /** @description NAMED_CREDENTIAL_ALLAPIS */
    private static final String NAMED_CREDENTIAL_ALLAPIS = 'AOB_API_EXTERNAL_GATEWAY';
    /** @description WEBSERVICE_RELYCOMPLY */
    private static final String WEBSERVICE_RELYCOMPLY = 'CMN_API_RelyComply';
    /** @description WEBSERVICE_RELYCOMPLY_ACCESSTOKEN */
    private static final String WEBSERVICE_RELYCOMPLY_ACCESSTOKEN = 'CMN_API_RelyComplyAccessToken';
    /** @description WEBSERVICE_ALLAPIS */
    private static final String WEBSERVICE_ALLAPIS = 'AOB_CUSTOMER_ONBOARDING';
    /** @description NAMED_CREDENTIAL_MCAFEE */
    private static final String NAMED_CREDENTIAL_MCAFEE = 'AOB_API_EXTERNAL_MCAFEE';
    /** 
    * @description This method used for authentication custom meta data 
    * @return Returns a callout response in map format for remaining processing
    */
    public static CMN_WebserviceSetting__mdt webservices() {
        
        if(Test.isRunningTest() == false) {
            return ([SELECT Id, CMN_ClientID__c, CMN_Client_Secret__c,CMN_CompanyID__c, CMN_Path__c, CMN_AdditionalKey__c FROM CMN_WebserviceSetting__mdt WHERE DeveloperName = :WEBSERVICE_ALLAPIS LIMIT 1]);
        } else {
            return new CMN_WebserviceSetting__mdt(CMN_ClientID__c = 'test client id', CMN_Client_Secret__c = 'test client secret key', CMN_Path__c = 'https://testrecordurl.com/', CMN_AdditionalKey__c = 'test additional key');
        }
    }
     /** 
    * @description This method used for authentication custom meta data 
    * @return CMN_WebserviceSetting__mdt Returns a callout response in map format for remaining processing
    */
    public static CMN_WebserviceSetting__mdt relyComplyWebServices() {
        
        if(Test.isRunningTest() == false) {
            return ([SELECT Id, CMN_ClientID__c, CMN_Client_Secret__c,CMN_CompanyID__c, CMN_Path__c, CMN_AdditionalKey__c FROM CMN_WebserviceSetting__mdt WHERE DeveloperName = :WEBSERVICE_RELYCOMPLY LIMIT 1]);
        } else {
            return new CMN_WebserviceSetting__mdt(CMN_ClientID__c = 'test client id', CMN_Client_Secret__c = 'test client secret key', CMN_Path__c = 'https://testrecordurl.com/', CMN_AdditionalKey__c = 'test additional key');
        }
    }
   
    /** 
    * @description This method used for authentication named credentials
    * @return Returns a callout response in map format for remaining processing
    */
    public static NamedCredential credentials() {
        
        return ([SELECT Endpoint FROM NamedCredential WHERE DeveloperName = :NAMED_CREDENTIAL_ALLAPIS LIMIT 1]);
    }

    /** 
    * @description This method used for authentication named credentials
    * @return Returns a callout response in map format for remaining processing
    */
    public static NamedCredential getMcAfeeCredentials() {
        
        return ([SELECT Endpoint FROM NamedCredential WHERE DeveloperName = :NAMED_CREDENTIAL_MCAFEE LIMIT 1]);
    }

    /** 
    * @description This method used for token
    * @param authType
    * @param webServiceSetting
    * @return Returns a callout response in map format for remaining processing
    */
    public static HttpRequest clientToken(String authType, CMN_WebserviceSetting__mdt webServiceSetting) {
        
        if(webServiceSetting != null && authType != null) {
            Blob token = Blob.valueOf(webServiceSetting.CMN_ClientID__c + PARAM_COLON + webServiceSetting.CMN_Client_Secret__c);
            String authorizationHeader = authType + EncodingUtil.base64Encode(token);
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setHeader(HEADER_AUTHORIZATION, authorizationHeader);
            return httpRequest;
        } 
        return null;
    }
    
    /** 
    * @description This method used for HttpRequest
    * @param authType
    * @param accessToken
    * @return Returns a callout response in map format for remaining processing
    */
    public static HttpRequest assignAccessToken(String authType, String accessToken) {
        
        if(authType != null && accessToken != null) {
            String authorizationHeader = authType +' '+ accessToken;
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setHeader(HEADER_AUTHORIZATION, authorizationHeader);
            return httpRequest;
        } 
        return null;
    }
}