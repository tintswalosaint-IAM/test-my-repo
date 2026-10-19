/**
 * @description Class to perform API calls for retrieving Account Details
 * @author Gnitsevich Anton
 * @date September 2021
 */
public without sharing class CMN_API_GetAccountDetails {
    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_CERTIFICATE = 'x-client-certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
	private static final String HEADER_CLIENT_ID = 'x-ibm-client-id';
	private static final String HEADER_CLIENT_SECRET = 'x-ibm-client-secret';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_GET = 'GET';
    //API specific
    private static final String CMN_API_EXTERNAL_GATEWAY_DEV = 'CMN_API_EXTERNAL_GATEWAY_DEV';
    private static final String CMN_API_EXTERNAL_GATEWAY_PROD = 'CMN_API_EXTERNAL_GATEWAY_PROD';
    private static final String PATH_CUSTOMERS = '/external-partners/customers';
    private static final String PATH_COMPLIANCE_STATUSES = '/compliance-checks';
    private static final String PATH_STATUSES = '/statuses';
    private static final String PATH_IDENTIFICATIONS = '/identifications';
    private static final String PATH_DOCUMENTS = '/document-info/details';
    @TestVisible
    private static final String PING_TKN = 'PING_TKN';

    @TestVisible
    private static Boolean mockCustomerStatusErrorResponse = false;
    @TestVisible
    private static Boolean mockCustomerStatusBadResponse = false;
    @TestVisible
    private static Boolean mockCustomerStatusEmptyResponse = false;

    @TestVisible
    private static Boolean mockValidityInfoBadResponse = false;
    @TestVisible
    private static Boolean mockValidityInfoErrorResponse = false;
    
    /**
     * @description This method determines if the Current Organization is a Sandbox
     * @return Boolean isSandbox
     */
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    /**
     * @description This method returns name of the required metadata record
     * @return String Metadata Name
     */
    public static String getMetadataName() {
        if (isSandbox()) {
            return CMN_API_EXTERNAL_GATEWAY_DEV;
        }
        return CMN_API_EXTERNAL_GATEWAY_PROD;
    }
    
    /**
     * @description This method creates new unique guid value
     * @return String guid
     */
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }

    /**
     * @description This method performs an API request to ESB
     * @param customerGuid GUID of our Account record
     * @param accessToken Access Token generated from ESB
     * @return CMN_DTO_CustomerValidityInfoResponse responseObject
     */
    public static CMN_DTO_CustomerValidityInfoResponse getCustomerValidityInfo(String customerGuid, String accessToken) {
        CMN_WebserviceSetting__mdt webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(getMetadataName());
        if (webServiceSetting == null) {
            CMN_UTIL_Logger.error('Metadata record "' + getMetadataName() + '" is not available', 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
            return null;
        }
        NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
        if (namedCredential == null) {
            CMN_UTIL_Logger.error('Named credential "' + webServiceSetting.CMN_NamedCredential__c + '" is not available', 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
            return null;
        }
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_CUSTOMERS + '/' + customerGuid + PATH_COMPLIANCE_STATUSES;
        HttpRequest httpRequest = new HttpRequest();
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(HTTP_METHOD_GET);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockCustomerValidityInfoResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (responseBody != null) {
                    responseBody = responseBody.replace('"Desc":', '"Description":'); // replace API abbreviation
                    CMN_DTO_CustomerValidityInfoResponse responseObject =
                        (CMN_DTO_CustomerValidityInfoResponse) JSON.deserialize(responseBody, CMN_DTO_CustomerValidityInfoResponse.class);
                    return responseObject;
                }
                else {
                    CMN_UTIL_Logger.error('No response body', 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
                }
            }
            else {
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
            }
        } catch(Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
        }
        return null;
    }

    /**
     * @description This method performs an API request to ESB
     * @param customerGuid GUID of our Account record
     * @param accessToken Access Token generated from ESB
     * @return CMN_DTO_CustomerStatusesResponse responseObject
     */
    public static CMN_DTO_CustomerStatusesResponse getCustomerStatuses(String customerGuid, String accessToken) {
        CMN_WebserviceSetting__mdt webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(getMetadataName());
        if (webServiceSetting == null) {
            CMN_UTIL_Logger.error('Metadata record "' + getMetadataName() + '" is not available', 'CMN_API_GetAccountDetails.getCustomerStatuses');
            return null;
        }
        NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
        if (namedCredential == null) {
            CMN_UTIL_Logger.error('Named credential "' + webServiceSetting.CMN_NamedCredential__c + '" is not available', 'CMN_API_GetAccountDetails.getCustomerStatuses');
            return null;
        }
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_CUSTOMERS + '/' + customerGuid + PATH_STATUSES;
        HttpRequest httpRequest = new HttpRequest();
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(HTTP_METHOD_GET);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockCustomerStatusesResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = '{"CustomerStatuses":' + httpResponse.getBody().replace('"desc":', '"description":') + '}';
                CMN_DTO_CustomerStatusesResponse responseObject =
                    (CMN_DTO_CustomerStatusesResponse) JSON.deserialize(responseBody, CMN_DTO_CustomerStatusesResponse.class);
                return responseObject;
            }
            else {
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), 'CMN_API_GetAccountDetails.getCustomerStatuses');
            }
        } catch(Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetAccountDetails.getCustomerStatuses');
        }
        return null;
    }

    /**
     * @description This method performs an API request to ESB
     * @param customerGuid GUID of our Account record
     * @return String response
     */
    public static List<CMN_DTO_CustomerDocInfoResponse> getCustomerDocumentInfo(String bpId) {
        CMN_WebserviceSetting__mdt webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(getMetadataName());
        if (webServiceSetting == null) {
            CMN_UTIL_Logger.error('Metadata record "' + getMetadataName() + '" is not available', 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
            return null;
        }
        NamedCredential namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
        if (namedCredential == null) {
            CMN_UTIL_Logger.error('Named credential "' + webServiceSetting.CMN_NamedCredential__c + '" is not available', 'CMN_API_GetAccountDetails.getCustomerValidityInfo');
            return null;
        }
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_DOCUMENTS;
        String requestBody = '{ "getDocumentDetailsInput" : { "bpId" : "' + bpId + '" } }';
        CMN_Org_Token__c pingToken = getPingToken();
        HttpRequest httpRequest = new HttpRequest();
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
        httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + pingToken.CMN_Token__c);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_GET);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockCustomerDocumentInfoUnauthenticated());
            }
            HttpResponse httpResponse = http.send(httpRequest);
            if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_UNAUTHORISED || httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_BAD_REQUEST) {
                CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getPingToken();
                if (accessToken != null) {
                    httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken.access_token);
                    if (Test.isRunningTest()) {
                        Test.setMock(HttpCalloutMock.class, new MockCustomerDocumentInfoSuccess());
                    }
                    httpResponse = http.send(httpRequest);
                    refreshToken(pingToken, accessToken.access_token, PING_TKN);
                }
            }
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (String.isNotBlank(responseBody)) {
                    List<CMN_DTO_CustomerDocInfoResponse> responseObject = populateDocContentDescFromSF(
                            (List<CMN_DTO_CustomerDocInfoResponse>) JSON.deserialize(responseBody, List<CMN_DTO_CustomerDocInfoResponse>.class)
                    );
                    if (responseObject != null) {
                        return responseObject;
                    }
                    else {
                        CMN_UTIL_Logger.error('Failed to parse body: ' + responseBody, 'CMN_API_GetAccountDetails.getCustomerDocumentInfo');
                    }
                }
                else {
                    CMN_UTIL_Logger.error('No response body', 'CMN_API_GetAccountDetails.getCustomerDocumentInfo');
                }
            }
            else {
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode(), 'CMN_API_GetAccountDetails.getCustomerDocumentInfo');
            }
        } catch(Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetAccountDetails.getCustomerDocumentInfo');
        }
        return null;
    }

    private static CMN_Org_Token__c getPingToken() {
        List<CMN_Org_Token__c> orgToken = [SELECT Id, CMN_Token__c FROM CMN_Org_Token__c WHERE Name = :PING_TKN];
        CMN_Org_Token__c pingToken;
        if (orgToken.size() == 1) {
            pingToken = orgToken[0];
            pingToken.CMN_Token__c = OSB_SRV_EncryptionHelper.decryptString(pingToken.CMN_Token__c, PING_TKN);
        } else {
            pingToken = new CMN_Org_Token__c(Name = PING_TKN, CMN_Token__c = 'empty');
        }
        return pingToken;
    }

    private static void refreshToken(CMN_Org_Token__c recordToUpsert, String token, String idName) {
        recordToUpsert.CMN_Token__c = OSB_SRV_EncryptionHelper.encryptString(token, idName);
        upsert recordToUpsert;
    }

    private static List<CMN_DTO_CustomerDocInfoResponse> populateDocContentDescFromSF(List<CMN_DTO_CustomerDocInfoResponse> wrapperList) {
        Map<String, String> val2Label = new Map<String, String>();
        Schema.DescribeFieldResult objFieldDescribe = IdentityDocument.IdDocumentType.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            val2Label.put(objPickList.getValue(), objPickList.getLabel());
        }
        for (CMN_DTO_CustomerDocInfoResponse w : wrapperList) {
            w.docCategoryDesc = val2Label.get(w.docContentType);
        }
        return wrapperList;
    }
    
    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockCustomerValidityInfoResponseSuccess implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            if (mockValidityInfoErrorResponse) {
                response.setStatusCode(500);
            }
            if (mockValidityInfoBadResponse) {
                response.setBody('{');
            } else {
                response.setBody('{"GetCustomerValidityInfoResponse":{"ComplianceData":[{"ComplianceType":{"Desc":"Customer Role Exist"},"ComplianceStatus":{"Desc":"Yes"},"ComplianceInd":"true"},{"ComplianceType":{"Desc":"KYC Requirements"},"ComplianceStatus":{"Desc":"In progress"},"ComplianceInd":"false"}]}}');
            }
            return response;
        }
    }

    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockCustomerStatusesResponseSuccess implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            if (mockCustomerStatusErrorResponse) {
                response.setStatusCode(500);
                response.setBody('{"error":"error"}');
            } else {
                response.setStatusCode(200);
                if (mockCustomerStatusEmptyResponse) {
                    response.setBody('[]');
                } else if (mockCustomerStatusBadResponse) {
                    response.setBody('{}');
                } else {
                    response.setBody('[{"status":"93","desc":"IN COLLECTIONS","effDate":"2013-09-24","expDate":"9999-12-31"},{"status":"95","desc":"SARB BP DATA NOT COMPLIANT","effDate":"2014-05-28","expDate":"9999-12-31"},{"status":"15","desc":"IMPORTANT CUSTOMER","effDate":"","expDate":""}]');
                }
            }
            return response;
        }
    }

    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockCustomerDocumentInfoSuccess implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"docCategoryDesc":"somecat","docCategoryCode":"3","cnttURL":"https://eviews1.standardbank.co.za/mca-staff-common-ecm-app/pageManager?operation=getRepositoryDocument&documentId=000100000000000000000000000502774119","docTitle":"sometitle","docType":"045","docTypeName":"sometype","cnttId":"000100000000000000000000000502774119","docContentTypeName":"someconttype","docContentType":"10","createdDt":"2022-05-23T16:17:43.000+02:00","docContLastUpdateDt":"2022-05-23T16:17:43.000+02:00","creationUserID":"A207687","lastChangeUserID":"A207687","path":"deeppath","language":"en","additionalDoc":[]}]');
            return response;
        }
    }

    @testVisible
    private class MockCustomerDocumentInfoUnauthenticated implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400); // API is returning 400 instead of 401 so we are reflecting it in unit tests
            response.setBody('');
            return response;
        }
    }
}