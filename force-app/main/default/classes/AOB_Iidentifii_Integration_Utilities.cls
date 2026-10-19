/**
* @description Class for dealing with identity api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date may 2022
*/
public inherited sharing class AOB_Iidentifii_Integration_Utilities {
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpbody = '';
     /**
   * @description sends request to identifii
   * @param methodP
   * @param endPointP
   * @param bodyP
   * @return String
   */
    public static httpResponse sendRequest(String methodP, String endPointP, String bodyP){
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        httpRequest.setEndpoint(endPointP);
        
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setMethod(methodP);
        httpRequest.setBody(bodyP);
        
        
        try{
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                } else {
                    System.Test.setMock(HttpCalloutMock.class, new GetIdentifiiMockResponse());
                }
            }
            httpResponse = http.send(httpRequest);
        } catch(exception ex){
            throw new AOB_CustomException(ex.getMessage());
        }
   
        return httpResponse;
    }
   /**
   * @description sends request to identifii
   * @param endPointP
   * @param methodP
   * @param bodyP
   * @param amxP
   * @return String
   */
    
    public static httpResponse sendRequest1(String endPointP, String methodP, String bodyP, String amxP){
        String amxToken = 'amx';
        
        String body = bodyP;
        amxToken += ' ' + amxP.deleteWhitespace();
       
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        httpRequest.setEndpoint(endPointP);
         httpRequest.setheader('Authorization', amxToken.trim());
      
        httpRequest.setheader('Content-Type', 'application/json');
        httpRequest.setMethod(methodP);
        httpRequest.setBody(body);
      
       
        try{
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                } else {
                    System.Test.setMock(HttpCalloutMock.class, new GetIdentifiiMockResponse());
                }
            }
            httpResponse = http.send(httpRequest);
           
        }catch(exception ex){
            throw new AOB_CustomException(ex.getMessage());
        }
   
        return httpResponse;
        
    }
    
    /**
   * @description get request to identifii
   * @param endPointP
   * @param methodP
   * @param urlParams
   * @param authorization
   * @return String
   */
    public static httpResponse getRequest(String endPointP, String methodP, String urlParams, iiDENTiFii_API_Setting__mdt authorization){
        String amxToken = 'amx';
        String amxP = generateGetAMX(authorization.ApiKey__c, authorization.Secret__c, endPointP);
       
        amxToken += ' ' + amxP.deleteWhitespace();
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        httpRequest.setEndpoint(endPointP + '?' + urlParams);
        httpRequest.setMethod(methodP);
        httpRequest.setheader('Authorization', amxToken.trim());
        httpRequest.setheader('Content-Type', 'application/json');
        try{
            if (System.Test.isRunningTest()) {
                if(mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
                } else if (urlParams =='$expand=IdentityImages($expand=ImageType)'){
                    System.Test.setMock(HttpCalloutMock.class, new GetIdentifiiMockResponse());
                }else {
                    System.Test.setMock(HttpCalloutMock.class, new GetIdentifiiMockResponse1());

                }
            }
            httpResponse = http.send(httpRequest);
        }catch(exception ex){
            throw new AOB_CustomException(ex.getMessage());
        }
        return httpResponse;
    }
    /**
   * @description get request to identifii
   * @param key
   * @param secret
   * @param url
   * @return String
   */
    public static String generateGetAMX(String key, String secret, String url) {
        String finalItem = generateAMX(key, secret, '', url, 'GET');
        return finalItem;
    }
    /**
   * @description get request to identifii
   * @param key
   * @param secret
   * @param body
   * @param url
   * @return String
   */
    public static String generatePostAMX(String key, String secret, String body, String url) {
        return generateAMX(key, secret, body, url, 'POST');
    }
    
    /**
   * @description get request to identifii
   * @param key
   * @param secret
   * @param body
   * @param url
   * @param method
   * @return String
   */
    
    private static String generateAMX(String key, String secret, String body, String url, String method) {
        String nonce = generateGuid();
        String timestamp = getUnix();
        String encodedBody = toBase64(body);
        
        String cleanUri = url.toLowercase();
        Integer qSep = cleanUri.indexOf('?');
        if (qSep > 0)
            {
                cleanUri = cleanUri.substring(0, qSep);
            }
        
        String signature = createSignature(key, encodedBody, method, cleanUri, nonce, timestamp);
        
        return createAMXFinal(key, signature, nonce, timestamp, secret);
    }
     /**
   * @description get request to identifii
   * @param key
   * @param hash
   * @param method
   * @param url
   * @param nonce
   * @param timestamp
   * @return String
   */
    private static String createSignature(String key, String hash, String method, String url, String nonce, String timestamp) {
        String signature = key+method+url+timestamp+nonce+hash;
        return signature;
    }
     /**
   * @description get request to identifii
   * @param key
   * @param signature
   * @param nonce
   * @param timestamp
   * @param secret
   * @return String
   */
    private static String createAMXFinal(String key, String signature, String nonce, String timestamp, String secret) {
        String secretString = uppercaseGUID(secret);
        
        Blob data = crypto.generateMac('HmacSHA256', Blob.valueOf(signature), Blob.valueOf(secretString));
        String base64 = EncodingUtil.base64Encode(data);
        String finalString = key+':'+base64+':'+nonce+':'+timestamp;
        return finalString;        
    }
     /**
   * @description get request to identifii
   * @param oldGUID
   * @return String
   */
    private static String uppercaseGUID(String oldGUID) {
        String newGUID = '';
        List<String> characterList = oldGUID.split('');
        for(String charac: characterList){
            newGUID += charac.toUpperCase();
        }
        return newGUID;
    }
    
     /**
   * @description get request to identifii
   * @return String
   */
    private static String generateGuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    
     /**
   * @description get request to identifii
   * @return String
   */
    
    private static String getUnix() {
        return String.valueOf((DateTime.now().getTime() / 1000));
    }
     /**
   * @description get request to identifii
   * @param body
   * @return String
   */
    private static String toBase64(String body) {
        Blob dataBolb = Blob.valueOf(body);
        String b64 = EncodingUtil.base64Encode(dataBolb);
        return b64;
    }   
    @testVisible
    private class GetIdentifiiMockResponse implements HttpCalloutMock {        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"IdentifyRequestID":"6ddac955-d8aa-4713-8e6e-23b8f8c7b193","DocumentNumber":"123456","ID":"12345","LivenessFRMatch":true,"LivenessFRScore":9.078,"isAlive":true,"IdentityImages":[{"IdentityID":"c29a743a-91e9-4707-8138-3cc1e3f3b67f","Image":"Sample Blob","ImageType":{"Description":"FrontImage","ID":"Sample Id"}}]}');
            return response;
        }
    }

    @testVisible
    private class GetIdentifiiMockResponse1 implements HttpCalloutMock {        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"ID":"668182a3-18a6-4486-bfb2-9328dd9eb601","FirstName":null,"Surname":null,"DocumentTypeDetected":{"ID":"9097c763-b71a-46ca-9244-344f3aa7258a","Name":"Card ID","Description":"Ugandan Card ID","DocType":7,"IssueCountryCode":"UGA"},"DocumentTypeSelected":{"ID":"9097c763-b71a-46ca-9244-344f3aa7258a","Name":"Card ID","Description":"Ugandan Card ID","DocType":7,"IssueCountryCode":"UGA"},"IdentityDocumentMetadatas":[{"ID":"8af44a35-5ae6-4024-82ad-5762014921b4","Metadata":null,"FrontTypeIDDetected":"9097c763-b71a-46ca-9244-344f3aa7258a","BackTypeIDDetected":"9097c763-b71a-46ca-9244-344f3aa7258a","FrontVIZFields":{"DocumentNumber":"001885714","LastName":"MAGEZI","FirstName":"RAYMOND SSEBYALA","DateOfExpiry":"28.11.2024","Nationality":"UGA","PersonalNumber":"CM930121003EGE","DateOfBirth":"28.05.1993","Gender":"SEX"},"BackVIZFields":{"District":"KAMPALA","Location":"MAKINDYE DIVISION","MRTD":"IDUGA0018857142CM930301022P7A< 9305281M2411288UGA141128 <<<<< 9 MAGEZI << RAYMOND<SSEBYALA <<<<<<","SubLocation":"MAKINDYE DIVISION","Division":"KANSANGA","Village":"£"},"FrontMRZFields":{},"BackMRZFields":{},"DocumentTypeFront":{"ID":"9097c763-b71a-46ca-9244-344f3aa7258a","Name":"Card ID","Description":"Ugandan Card ID","DocType":7,"IssueCountryCode":"UGA"},"DocumentTypeBack":{"ID":"9097c763-b71a-46ca-9244-344f3aa7258a","Name":"Card ID","Description":"Ugandan Card ID","DocType":7,"IssueCountryCode":"UGA"}}]}');
            return response;
        }
    }

    
}