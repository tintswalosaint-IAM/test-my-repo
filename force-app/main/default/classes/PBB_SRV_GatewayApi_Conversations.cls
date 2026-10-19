/**
 * @description A class that implements HTTP service to integrate SF data with the API.
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class PBB_SRV_GatewayApi_Conversations implements IService  {
        private static final SRV_HttpRequestSender.IService HTTP_SERVICE = new SRV_HttpRequestSender();
        private static final PBB_SRV_GatewayRequestProvider.IService REQUEST_PROVIDER = new PBB_SRV_GatewayRequestProvider();
        private static final String RESPONSE_ENDPOINT = '/smart-conversations/conversations-responses'; 
        private static final String REASON_ENDPOINT = '/smart-conversations/conversations-reasons';
    
        private static final String CMN_API_EXTERNAL_GATEWAY_DEV = 'CMN_API_EXTERNAL_GATEWAY_DEV';
        private static final String CMN_API_EXTERNAL_GATEWAY_PROD = 'CMN_API_EXTERNAL_GATEWAY_PROD';
    /**
     * @description Exception class for API errors
     */
    public class ApiException extends Exception { }
        /**
        * @description This is method Interface
        **/
        public interface IService {
            
            /**
            * @description This is List Reason
            * @return   results
            **/
            List<Smart2Reason> getReason();
            
            /**
            * @description This is List Response
            * @return   results
            **/
            List<Smart2Response> getResponse();
        }

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
    * @description This method is to get respones from Smart2
    * @return   response Object
    **/
    public List<Smart2Response> getResponse(){
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:' + getMetadataName() + RESPONSE_ENDPOINT);
        req.setMethod('GET');
        if(Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new GetResponseHttpMock());
        }
        HttpResponse res = HTTP_SERVICE.send(req, 5);    
        List<Smart2Response> s2Res = (List<Smart2Response>)JSON.deserialize(res.getBody(), List<Smart2Response>.class);
        return s2Res;
    }
    
   /**
    * @description This method is to get reasons from Smart 2
    * @return   Response object
    **/
    public List<Smart2Reason> getReason(){
        
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:'+ getMetadataName() + REASON_ENDPOINT);
        req.setMethod('GET');
        if(Test.isRunningTest()) {
            Test.setMock(HttpCalloutMock.class, new GetReasonHttpMock());
        }
        HttpResponse res = HTTP_SERVICE.send(req, 5);       
        List<Smart2Reason> s2Res = (List<Smart2Reason>)JSON.deserialize(res.getBody(), List<Smart2Reason>.class);
        return s2Res;
    }

    private static HttpRequest buildCallRequest() {
        HttpRequest req = REQUEST_PROVIDER.getRequestWithToken();
        req.setHeader('content-type', 'application/json');
        req.setTimeout(25000);
        req.setHeader('accept', 'application/json');
        return req;
    }
    /**
    * @description Wrapper Class for Response
    **/
                                                
    public class Smart2Response {
        
        public String subCategory;
        public String response;
        public Boolean futureDate;
    }
    /**
    * @description Wrapper Class for reasons
    **/
    public class Smart2Reason {
        
        public String response;
        public String reason;
        public Boolean futureDate;
    }

    /**
     * @description mocks a response returned from the Get Access API Token
     */
    @TestVisible
    private class GetResponseHttpMock implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('[{"subCategory": "Cash","response": "Accepted Offer","futureDate": false},{"subCategory": "Cash - Device Expiry","response": "Accepted Offer","futureDate": false}]');
            return response;
        }
    }

    @TestVisible
    private class GetReasonHttpMock implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('[{"reason": "Application submitted","response": "Accepted Offer","futureDate": false}]');
            return response;
        }
    }
}