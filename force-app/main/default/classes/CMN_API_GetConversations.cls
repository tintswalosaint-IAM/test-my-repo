/**
* @description Class to perform API calls for retrieving Conversations
* @author Gnitsevich Anton
* @date October 2021
*
* @testclass CMN_CTRL_Conversation_Test 
*
* 2024-02-26    Derek Hughes    Added new methods to support the new AR conversations API actions
*/
public with sharing class CMN_API_GetConversations {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_GetConversations');

    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_CERTIFICATE = 'x-Client-Certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_GET = 'GET';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String HTTP_METHOD_PUT = 'PUT';
    //API specific
    private static final String CMN_API_EXTERNAL_GATEWAY_DEV = 'CMN_API_EXTERNAL_GATEWAY_DEV';
    private static final String CMN_API_EXTERNAL_GATEWAY_PROD = 'CMN_API_EXTERNAL_GATEWAY_PROD';
    private static final String PATH_PORTFOLIO = '/smart-conversations/portfolio-conversations';
    private static final String PATH_CONVERSATIONS = '/smart-conversations/conversations';
    private static final String PATH_NBA = '/smart-conversations/conversations-nba';
    private static final String PATH_COAP = '/smart-conversations/coap';
    private static final String PATH_POAP = '/smart-conversations/poap';

    // is current instance a Sandbox, query once per transaction
    public static Boolean isSandbox {
        get {
            if (isSandbox == null) {
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        private set;
    }
    // web service setting, query once per transaction
    public static CMN_WebserviceSetting__mdt webServiceSetting {
        get {
            if (webServiceSetting == null) {
                if (isSandbox) {
                    webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(CMN_API_EXTERNAL_GATEWAY_DEV);
                }
                else {
                    webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(CMN_API_EXTERNAL_GATEWAY_PROD);
                }
            }
            return webServiceSetting;
        }
        private set;
    }
    // named credential, query once per transaction
    public static NamedCredential namedCredential {
        get {
            if (namedCredential == null) {
                namedCredential = CMN_DAL_NamedCredential.findByName(webServiceSetting.CMN_NamedCredential__c);
            }
            return namedCredential;
        }
        private set;
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
     * @description Method to get conversations from SB API
     * @param accessToken API Access Token
     * @param aeNumber AE Number to get conversation for
     * @return CMN_DTO_ConversationsResponse
     */
    public static CMN_DTO_ConversationsResponse getRMConversations(String accessToken, String aeNumber) {
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_PORTFOLIO;
        HttpRequest httpRequest = new HttpRequest();
        //Prepare Request Data
        String requestBody = '{"aeNumber":"{0}"}';
        requestBody = requestBody.replace('{0}', aeNumber);
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        CMN_DTO_ConversationsResponse responseObject;
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockGetRMConversationsResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                responseObject = (CMN_DTO_ConversationsResponse) JSON.deserialize(
                    httpResponse.getBody(), CMN_DTO_ConversationsResponse.class
                );
            }
            else {
                CMN_UTIL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'CMN_API_GetConversations.getRMConversations');
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetConversations.getRMConversations');
        }
        return responseObject;
    }
    
    private class ServiceException extends Exception {}

    /**
     * @description Method to get conversations from SB API
     * @param accessToken API Access Token
     * @param bpId Account's ExternalCIFId__c / BP Id
     * @return CMN_DTO_ConversationsResponse
     */
    public static CMN_DTO_ConversationsResponse getAccountConversations(String accessToken, String bpId) {
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_CONVERSATIONS;
        HttpRequest httpRequest = new HttpRequest();
        //Prepare Request Data
        String requestBody = '{"newCustN":"{0}","onlyIndicated":"false"}';
        requestBody = requestBody.replace('{0}', bpId);
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        CMN_DTO_ConversationsResponse responseObject = new CMN_DTO_ConversationsResponse();
        List<CMN_DTO_ConversationsResponse.Conversation> conversations;
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockGetAccountConversationsResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                conversations = (List<CMN_DTO_ConversationsResponse.Conversation>) JSON.deserialize(
                    httpResponse.getBody(), List<CMN_DTO_ConversationsResponse.Conversation>.class
                );
            }
            else {
                CMN_UTIL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'CMN_API_GetConversations.getAccountConversations');
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetConversations.getAccountConversations');
        }
        responseObject.clientPortfolioConversationList = conversations;
        return responseObject;
    }

     /**
     * @description Method to get COAP from SB API
     * @param accessToken API Access Token
     * @param bpId Account's ExternalCIFId__c / BP Id
     * @return String
     */
    public static String getCustomerOnAPage(String accessToken, String bpId) {
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_COAP;
        HttpRequest httpRequest = new HttpRequest();
        //Prepare Request Data
        String requestBody = '{"newCustN":"{0}","onlyIndicated":"false"}';
        requestBody = requestBody.replace('{0}', bpId);
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        String responseObject;
        
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockGetCustomerOnAPageResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                responseObject = httpResponse.getBody();
            }
            else {
                CMN_UTIL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'CMN_API_GetConversations.getCustomerOnAPage');
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetConversations.getCustomerOnAPage');
        }
        
        return responseObject;
    }
    
    /**
     * @description Method to get POAP from SB API
     * @param accessToken API Access Token
     * @param  Account's rmAeCode
     * @return String
     */
    public static String getPortfolioOnAPage(String accessToken, String rmAeCode) {
        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_POAP;
        HttpRequest httpRequest = new HttpRequest();
        //Prepare Request Data
        String requestBody = '{"aeNumber":"{0}"}';
        requestBody = requestBody.replace('{0}', rmAeCode);
        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setTimeout(120000);
        //Make HTTP Request
        String responseObject;
        
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockGetCustomerOnAPageResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);
            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                responseObject = httpResponse.getBody();
            }
            else {
                CMN_UTIL_Logger.error('API response: ' + httpResponse.getStatusCode() + '; ' + httpResponse.getBody(), 'CMN_API_GetConversations.getPortfolioOnAPage');
            }
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetConversations.getPortfolioOnAPage');
        }
        
        return responseObject;
    }

    /**
     * @description Method to send conversation updates to SB API
     * @param accessToken API Access Token
     * @param conversations Conversation to send updates for
     */
    public static void sendConversations(String accessToken, List<CMN_Conversation__c> conversations) {

        //Prepare Request
        String fApiInteractionId = createGUID();
        String endpoint = namedCredential.Endpoint + PATH_NBA;
        HttpRequest httpRequest = new HttpRequest();

        //Prepare Request Data
        String requestBody;
        requestBody = '{"listNbas":[';
        for (CMN_Conversation__c conversation : conversations) {
            String conversationBody = '{';
            conversationBody += '"leadKey":"' + conversation.Lead_Key__c + '"';
            conversationBody += ',"response":"' + conversation.Response__c + '"';
            conversationBody += ',"reason":"' + conversation.Reason__c + '"';
            conversationBody += ',"additionalInfo":"' + conversation.Details__c + '"';
            conversationBody += '}';
            requestBody += conversationBody + ',';
        }
        requestBody = requestBody.removeEnd(',');
        requestBody += ']}';

        //Set HTTP Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
        httpRequest.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        
        //Set Request Details
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(HTTP_METHOD_PUT);
        httpRequest.setTimeout(120000);

        //Make HTTP Request
        try {
            Http http = new Http();
            if (Test.isRunningTest()) {
                Test.setMock(HttpCalloutMock.class, new MockSendConversationsResponseSuccess());
            }
            HttpResponse httpResponse = http.Send(httpRequest);

            if (httpResponse.getStatusCode() != CMN_API_HttpBase.HTTP_OK) {
                CMN_UTIL_Logger.error('Response status: ' + httpResponse.getStatusCode() + '; body: ' + httpResponse.getBody(), 'CMN_API_GetConversations.sendConversations');
            }
        } 
        catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_API_GetConversations.sendConversations');
        }
    }

    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockGetRMConversationsResponseSuccess implements HttpCalloutMock {
        String conversationId1;
        String conversationId2;
        String conversationId3;
        String conversationId4;
        String conversationId5;
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            prepareConversationIds();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"totalSize":4,"clientPortfolioConversationList":[{"newCustN":100001,"conversationId":"' + conversationId1 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":"testr_resp","reason":"test_reason","additionalInformation":"test_detes","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},{"newCustN":100001,"conversationId":"' + conversationId2 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"},{"newCustN":100002,"conversationId":"' + conversationId3 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789013"},{"newCustN":909090909,"conversationId":"' + conversationId4 +'","clientType":"B","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789014"},{"newCustN":123456789,"conversationId":"' + conversationId5 +'","clientType":"P","clientName":"MR TEST REST","identification":"123456789013","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer wants something else.","actionScript":"BIRTHDAY","contactType":"typeA","response":"testresponse","reason":"testreason","additionalInformation":"testdetails","expectedRevenue":0.0,"futureContactDate":"01-01-1991","leadKey":"000000123456789015"}]}');
            return response;
        }

        private void prepareConversationIds() {
            Date today = System.today();
            String year = String.valueOf(today.year()).substring(2,4);
            String month = String.valueOf(today.month());
            if (month.length() == 1) {
                month=0+month;
            }
            String day = String.valueOf(today.day());
            if (day.length() == 1) {
                day=0+day;
            }

            conversationId1 = year+month+day+1111;
            conversationId2 = year+month+day+2222;
            conversationId3 = year+month+day+3333;
            conversationId4 = year+month+day+4444;
            conversationId5 = year+month+day+5555;
        }
    }
    
    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockGetAccountConversationsResponseSuccess implements HttpCalloutMock {
        String conversationId1;
        String conversationId2;
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            prepareConversationIds();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('[{"conversationId":"' + conversationId1 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates birthday.","actionScript":"BIRTHDAY","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789011"},{"conversationId":"' + conversationId2 +'","clientType":"P","clientName":"MISS TEST REST","identification":"123456789012","identifier":"01","tier":"Other","aeNumber":"0054321","category":"Focused Conversations","catPosition":2,"subCategory":"Birthday","subCatPosition":2,"detail":"Customer celebrates something else.","actionScript":"BIRTHDAY","contactType":null,"response":"testresp","reason":"testreason","additionalInformation":"testinfo","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000123456789012"}]');
            return response;
        }

        private void prepareConversationIds() {
            Date today = System.today();
            String year = String.valueOf(today.year()).substring(2,4);
            String month = String.valueOf(today.month());
            if (month.length() == 1) {
                month=0+month;
            }
            String day = String.valueOf(today.day());
            if (day.length() == 1) {
                day=0+day;
            }

            conversationId1 = year+month+day+1111;
            conversationId2 = year+month+day+2222;
        }
    }
    
    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockSendConversationsResponseSuccess implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('true');
            return response;
        }
    }
    
    /**
     * @description mocks a response returned from the API call
     */
    @testVisible
    private class MockGetCustomerOnAPageResponseSuccess implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"profile": {"age": 45,"reportDate": "202109"},"valueAdded": {"prepaidElectricity": 0.1,"valueAddedService": 0.4}}');
            return response;
        }
    }
    
}