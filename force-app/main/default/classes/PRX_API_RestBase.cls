/***************************************************************************************
@ Author            :prem.lingala@standardbank.co.za
@ Date              :August 2023
@ Name of the Class :PRX_API_RestBase
@description        :SFP-29221 - The Base class for all API Web Service Calls (outbound/inbound for REST API).
                     This abstract class serves as the foundation for implementing RESTful web service calls 
                     within the Salesforce integration framework for the Standard Bank API. It provides common
                     methods and structure that can be extended by specific API classes.
@ Last Modified By  :prem.lingala@standardbank.co.za
@ Last Modified On  :Jan 2024
@ Jira Ticket : SFP-29221  
* ---------------------------------------------------------------------------
*version   Date               Developer                  Description
* ---------------------------------------------------------------------------
  1.0    August 2023   prem.lingala@standardbank.co.za   60.0
***************************************************************************************/
public abstract class PRX_API_RestBase {  
     /* @description Logger instance for logging messages related to this class */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_API_RestBase');
     /**
     * @description Abstract method to be implemented by subclasses to provide the API endpoint URL.
     * @return A String representing the API endpoint URL.
     */
    protected abstract String getEndpoint();
     /**
     * @description Abstract method to be implemented by subclasses to provide the required HTTP request headers.
     * @return A Map<String, String> containing the HTTP request headers.
     */
    protected abstract Map<String, String> getRequestHeaders();
     /**
     * @description Abstract method to be implemented by subclasses to provide the request payload.
     * @return A String representing the serialized request body.
     */
    protected abstract String getRequestBody();
     /**
     * @description Virtual method to send an HTTP request. Can be overridden by subclasses if needed.
     * @param method The HTTP method (GET, POST, PUT, DELETE, etc.).
     * @return An HttpResponse object representing the response from the API.
     */
    @TestVisible
    protected virtual HttpResponse sendHttpRequest(String method) {
        HttpRequest req = new HttpRequest();
        HttpResponse resp = new HttpResponse();
        try{
            String url = getEndpoint();
            String requestBody = getRequestBody();
            req = genRequest(method, url);
            req = assignHeaders(getRequestHeaders(),req);
            if(!String.isBlank(requestBody)){
                req.setBody(requestBody);
            }
            resp = sendRequest(req);
            checkResponse(req, resp);
             
        }catch(Exception e){
            LOGGER.error(e.getMessage());
        }
         return resp;  
    }
    /**
     * @description Virtual method to generate an HttpRequest object.
     * @param method The HTTP method (GET, POST, PUT, DELETE, etc.).
     * @param url The API endpoint URL.
     * @return An HttpRequest object.
     */
    @TestVisible
    protected virtual HttpRequest genRequest(String method, String url){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        req.setTimeout(120000);
        return req;
    }
     /**
     * @description Virtual method to assign headers to an HttpRequest object.
     * @param headers A Map<String, String> containing the HTTP request headers.
     * @param req An HttpRequest object.
     * @return An HttpRequest object with assigned headers.
     */
    @TestVisible
    protected virtual HttpRequest assignHeaders(Map<String, String> headers,HttpRequest req){
        for (String key : headers.keySet()) {
            req.setHeader(key, headers.get(key));
        }
        return req;
    }
    /**
     * @description Virtual method to send an HttpRequest and receive an HttpResponse.
     * @param req An HttpRequest object.
     * @return An HttpResponse object.
     */
    @TestVisible
    protected virtual HttpResponse sendRequest(HttpRequest req){
        Http http = new Http();
        return http.send(req);
    }
     /**
     * @description Virtual method to check the HTTP response and throw an exception if the status code is >= 400.
     * @param req An HttpRequest object.
     * @param resp An HttpResponse object.
     */
    @TestVisible
    protected virtual void checkResponse(HttpRequest req, HttpResponse resp){
        if(resp.getStatusCode() >= 400){
            throw new HttpRequestException(req, resp);
        }
    }
    /**
     * @description Custom exception class for representing HTTP request failures.
     */
    public class HttpRequestException extends Exception {
        public HttpRequest req;
        public HttpResponse resp;
        /**
         * @description Constructor for the HttpRequestException class.
         * @param req An HttpRequest object.
         * @param resp An HttpResponse object.
         */
        public HttpRequestException(HttpRequest req, HttpResponse resp){
            this.req = req;
            this.resp = resp;
            this.setMessage('Failed HTTP Request! Status: ' + resp.getStatusCode() + ' - ' + resp.getStatus() + ' Body: ' + resp.getBody());
        }
    }
}