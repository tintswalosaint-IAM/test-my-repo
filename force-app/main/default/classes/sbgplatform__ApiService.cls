/**
 * @description       : API Service base class
 * @author            : Derek Hughes
 * @group             : API
 * @last modified on  : 18-04-2024
 * @last modified by  : Derek Hughes
 * 
 * @last modified on  : 02-07-2025
 * @last modified by  : Milica Milicevic
 * @description       : Additional constructor to handle custom metadata type record that holds header parameter and values. 
 *                      Retrieval of the values to be added to header in prepareHttpRequest.
 *                      Additional method for new prepareHttpRequest with object request body.
 * @User-Story        : SFP-50927
 * 
 * 2025-08-20   Derek Hughes    SFP-52319 
 *                              Added new getters for status code and response body to allow access to the last HTTP response details.
 *                              Added DTO types for error responses to be returned with isSuccess() false. NO LONGER throws ServiceException on error.
 * 
 * 2025-09-07   Derek Hughes    Added new setting to control if an exception is thrown on call out error.  Default is true for backward compatibility.
 * References
 * 1. Secret Storage: https://help.salesforce.com/s/articleView?id=sf.nc_create_edit_external_credential.htm&type=5
 * 2. Partition Cache: https://developer.salesforce.com/docs/atlas.en-us.248.0.apexcode.meta/apexcode/apex_cache_namespace_overview.htm 
 * 3. Using Named Credential merge fields: https://developer.salesforce.com/docs/atlas.en-us.248.0.apexcode.meta/apexcode/apex_callouts_named_credentials_merge_fields.htm 
**/
global virtual with sharing class ApiService {

    private static final sbgplatform.rflib_Logger LOGGER0 = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ApiService');
   
    // Constants
    global static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    global static final String CONTENT_TYPE_APPLICATION_XML = 'application/xml';
    global static final String CONTENT_TYPE_APPLICATION_OCTET_STREAM = 'application/octet-stream';  // binary content
    global static final String CONTENT_TYPE_APPLICATION_PDF = 'application/pdf';  
    global static final String CONTENT_TYPE_APPLICATION_ZIP = 'application/zip';  
	global static final String CONTENT_TYPE_APPLICATION_FORM_URLENCODED = 'application/x-www-form-urlencoded';

	global static final String CONTENT_TYPE_TEXT_PLAIN = 'text/plain';
	global static final String CONTENT_TYPE_TEXT_HTML = 'text/html';
	global static final String CONTENT_TYPE_TEXT_CSS = 'text/css';
	global static final String CONTENT_TYPE_TEXT_CSV = 'text/csv';
	global static final String CONTENT_TYPE_TEXT_JAVASCRIPT = 'text/javascript';

    global static final String HEADER_ACCEPT = 'accept';
    global static final String HEADER_CONTENT_TYPE = 'content-type';

    global static final String HTTP_METHOD_GET = 'GET';
    global static final String HTTP_METHOD_POST = 'POST';
    global static final String HTTP_METHOD_PUT = 'PUT';
    global static final String HTTP_METHOD_PATCH = 'PATCH';

	//http status codes https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	global static final Integer HTTP_OK = 200;
	global static final Integer HTTP_CREATED = 201;
	global static final Integer HTTP_ACCEPTED = 202;
	global static final Integer HTTP_NON_AUTH_INFO = 203;
	global static final Integer HTTP_NO_CONTENT = 204;
	global static final Integer HTTP_RESET_CONTENT = 205;
	global static final Integer HTTP_BAD_REQUEST = 400;
	global static final Integer HTTP_UNAUTHORISED = 401;
	global static final Integer HTTP_INTERNAL_SERVER_ERROR = 500;

	global static final Set<Integer> HTTP_VALID_CODES = new Set<Integer> {
        HTTP_OK, HTTP_CREATED, HTTP_ACCEPTED, HTTP_NON_AUTH_INFO, HTTP_NO_CONTENT, HTTP_RESET_CONTENT
	};

    // Instance Variables
    protected String namedCredential;
    protected API_Credential__mdt apiCredential;
    private Type responseDtoType;
    private Type errorDtoType;

    private Boolean exceptionOnError = true; // if true (default) then throw exception on error response, otherwise return the error response DTO

    private Integer timeout = 60000; // default timeout in milliseconds
    private String correlationIdHeader; // the header name for the correlation ID if required

    protected HttpResponse httpResponse; // stores the response of the most recent call out

    /**
     * @description Constructor
     * @param namedCredential the developer name of the Named Credential to be used
     * @param apiCredential the label name of the API Credential Custom Metadata Type
     */
    global ApiService (String namedCredential, String apiCredentialName) {
        LOGGER0.info('constructor: namedCredential: '+ namedCredential + ', apiCredentialName: ' + apiCredentialName);

        this.namedCredential = namedCredential;

        this.apiCredential = API_Credential__mdt.getInstance(apiCredentialName);

        if (this.apiCredential == null && !Test.isRunningTest()) {
            throw new ServiceException('ApiService constructor('+namedCredential+' , '+apiCredentialName+'): Unsuccessful retrieve of api credentials');
        }
        LOGGER0.info('constructor: apiCredential successful found: '+ apiCredential);
    }

    /**
     * @description Constructor
     * @param namedCredential the developer name of the Named Credential to be used
     */
    global ApiService (String namedCredential) {
        LOGGER0.info('constructor: namedCredential: '+ namedCredential);
        this.namedCredential = namedCredential;
    }
   
    /**
    * @description Set the DTO class that is to be used to deserialise the response body
    * @author Derek Hughes | 06-03-2024 
    * @param responseDtoType 
    * @return ApiService 
    **/
    global ApiService setResponseDtoType (Type responseDtoType) {
        this.responseDtoType = responseDtoType;
        return this;
    }

    /**
    * @description Set the DTO class that is to be used to deserialise the error response body
    * @author Derek Hughes | 20-08-2025 
    * @param errorDtoType 
    * @return ApiService 
    **/
    global ApiService setErrorDtoType (Type errorDtoType) {
        this.errorDtoType = errorDtoType;
        if (errorDtoType != null) {
            this.exceptionOnError = false; // if an error DTO type is set, then do not throw exceptions on error responses
        }
        return this;
    }

    /**
    * @description Set the timeout for the HTTP request.  The default is 60 seconds (60000 milliseconds).
    * @author Derek Hughes | 21-08-2025 
    * @param timeout 
    * @return ApiService 
    **/
    global ApiService setTimeout (Integer timeout) {
        this.timeout = timeout;
        return this;
    }

    /**
    * @description Set the header name for the correlation ID if required.  This will be added to the HTTP request headers.
    * @author Derek Hughes | 21-08-2025 
    * @param correlationIdHeader 
    * @return ApiService 
    **/
    global ApiService setCorrelationIdHeader (String correlationIdHeader) {
        this.correlationIdHeader = correlationIdHeader;
        return this;
    }

    /**
    * @description Set whether to throw an exception on error response or return the error DTO.  Default is true (throw exception).
    * @author Derek Hughes | 08-09-2025 
    * @param exceptionOnError 
    * @return ApiService 
    **/
    global ApiService setExceptionOnError (Boolean exceptionOnError) {
        this.exceptionOnError = exceptionOnError;
        return this;
    }

    /**
    * @description Sets both the DTO Types (Response, Error) in one go
    * @author Derek Hughes | 20-08-2025 
    * @param responseDtoType 
    * @param errorDtoType 
    * @return ApiService 
    **/
    global ApiService setDtoTypes (Type responseDtoType, Type errorDtoType) {
        return setResponseDtoType(responseDtoType)
            .setErrorDtoType(errorDtoType);
    }

    /**
    * @description does http get 
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @return Object 
    **/
    global Object get(String path) {
        Object requestBody = null;  // need a null object to match the method signature for send
        return send(path, HTTP_METHOD_GET, requestBody, null);
    }

    /**
    * @description does http post (content type defaults to application/json)
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param requestBody 
    * @return Object 
    **/
    global Object post(String path, String requestBody) {  // Default to application/json 
        return post(path, requestBody, CONTENT_TYPE_APPLICATION_JSON);
    }

    /**
    * @description does http put with specified content type
    * @author Derek Hughes | 08-09-2025 
    * @param path 
    * @param requestBody 
    * @param contentType 
    * @return Object 
    **/
    global Object post(String path, Object requestBody, String contentType) {
        return send(path, HTTP_METHOD_POST, requestBody, contentType);
    }

    /**
    * @description does http put (content type defaults to application/json)
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param requestBody 
    * @return Object 
    **/
    global Object put(String path, String requestBody) {
        return put(path, requestBody, CONTENT_TYPE_APPLICATION_JSON);
    }

    /**
    * @description does http put with specified content type
    * @author Derek Hughes | 08-09-2025 
    * @param path 
    * @param requestBody 
    * @param contentType 
    * @return Object 
    **/
    global Object put(String path, Object requestBody, String contentType) {
        return send(path, HTTP_METHOD_PUT, requestBody, contentType);
    }

    /**
    * @description does http patch (content type defaults to application/json)
    * @author Derek Hughes | 20-08-2024 
    * @param path 
    * @param requestBody 
    * @return Object 
    **/
    global Object patch(String path, String requestBody) {
        return patch(path, requestBody, CONTENT_TYPE_APPLICATION_JSON);
    }

    /**
    * @description does http patch with specified content type
    * @author Derek Hughes | 08-09-2025 
    * @param path 
    * @param requestBody 
    * @param contentType 
    * @return Object 
    **/
    global Object patch(String path, Object requestBody, String contentType) {
        return send(path, HTTP_METHOD_PATCH, requestBody, contentType);
    }

    /**
    * @description Returns the status code of the last http response
    * @author Derek Hughes | 20-08-2025 
    * @return Integer 
    **/
    global Integer getStatusCode() {
        if (httpResponse != null) {
            return httpResponse.getStatusCode();
        }
        return null;
    }

    /**
    * @description Returns the body of the last http response
    * @author Derek Hughes | 20-08-2025 
    * @return String 
    **/
    global String getResponseBody() {
        if (httpResponse != null) {
            return httpResponse.getBody();
        }
        return null;
    }
    
    /**
    * @description Returns the most recent http response object
    * @author Derek Hughes | 25-09-2025 
    * @return String 
    **/
    global String getHttpResponse() {
        return this.httpResponse.toString();
    }

    /**
    * @description Returns the most recent http response object
    * @author Milica | 11-11-2025 
    * @return HttpResponse 
    **/
    global HttpResponse getHttpResponseObject() {
        return this.httpResponse;
    }


    /**
    * @description Send an http request to the specified path with the optional request body
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return Object 
    *
    * V1 method kept for backward compatibility, but it is recommended to use the new method with Object requestBody.
    * Defaults to JSON content type.
    **/
    global Object send(String path, String method, String requestBody) {
        return send(path, method, requestBody, CONTENT_TYPE_APPLICATION_JSON);
    }

    global Object send(String path, String method, String requestBody, String contentType) {
        return send(path, method, (Object)requestBody, contentType);
    }

    global Object send(String path, String method, Object requestBody) {
        return send(path, method, requestBody, null);
    }

    global Object send(String path, String method, Object requestBody, String contentType) {

        LOGGER0.info('send('+namedCredential+'): '+method.toUpperCase()+': '+ path);

        Object response;

        try {
            HttpRequest httpRequest = prepareHttpRequest(path, method, requestBody, contentType);

            LOGGER0.debug('send('+namedCredential+'): httpRequest: '+ httpRequest);

            Http http = new Http();
            httpResponse = http.Send(httpRequest);

            LOGGER0.trace('send('+namedCredential+'): response body: '+ httpResponse.getBody());

            if (isSuccess(httpResponse.getStatusCode())) {
                response = convertResponseToDTO(httpResponse.getBody());
            }
            else {
                if (this.exceptionOnError) {
                    throw new ServiceException('API call failed: ' + httpResponse.getStatusCode() + ' - '  + httpResponse.getStatus());
                }   
                response = convertErrorResponseToDTO(httpResponse.getBody());
            }
        } 
        catch (Exception ex) {
            LOGGER0.error('send('+namedCredential+'): Unhandled Exception', ex);
            throw ex;
        }

        LOGGER0.info('send('+namedCredential+'): SUCCESS');

        return response;
    }
       
    /**
    * @description Virtual method to check if the response should be treated as a success
    * @author Derek Hughes | 04-03-2024 
    * @param statusCode 
    * @return virtual 
    **/
    global virtual Boolean isSuccess(Integer statusCode) {
        return HTTP_VALID_CODES.contains(statusCode);
    }

    /**
    * @description virtual method that can be overridden by sub-classes to convert the raw success response to DTO
    * @author Derek Hughes | 04-03-2024 
    * @param responseBody 
    * @return Object 
    **/
    global virtual Object convertResponseToDTO (String responseBody) {
        if (String.IsNotBlank(responseBody)) {
            if (responseDtoType == null) {
                return responseBody;
            }
            else {
                return System.JSON.deserialize(responseBody, responseDtoType);
            }
        }
        return null;
    }

    /**
    * @description virtual method that can be overridden by sub-classes to convert the raw error response to DTO
    * @author Derek Hughes | 20-08-2025 
    * @param responseBody 
    * @return virtual 
    **/
    global virtual Object convertErrorResponseToDTO (String errorResponseBody) {
        if (String.IsNotBlank(errorResponseBody)) {
            if (errorDtoType == null) {
                return errorResponseBody;
            }
            else {
                return System.JSON.deserialize(errorResponseBody, errorDtoType);
            }
        }
        return null;
    }


    /**
    * @description Prepares the http request with default headers and request body
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return httpRequest 
    *
    * For backward compatibility, this method accepts a String requestBody and then calls the new method with an Object requestBody 
    * and JSON content type.
    **/
    global virtual HttpRequest prepareHttpRequest (String path, String method, String requestBody) {

        return prepareHttpRequest(path, method, (Object)requestBody, CONTENT_TYPE_APPLICATION_JSON);

    }

    /**
    * @description Prepares the http request with based on provided body type
    * @author Milica Milicevic | 02-07-2025
    * @param path 
    * @param method 
    * @param requestBody 
    * @return httpRequest  
    *
    * @last modified on  : 02-07-2025
    * @last modified by  : Milica Milicevic
    * @description : Addition of retrieval of header parameters and values from custom metadata types. * 
    **/
    global virtual HttpRequest prepareHttpRequest (String path, String method, Object requestBody, String contentType) {
        
        if (path.left(1) != '/') {
            path = '/'+path;
        }

        String endpoint = 'callout:' + this.namedCredential + path;

        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setMethod(method);
        httpRequest.setTimeout(this.timeout);

        // 2025-08-20 Derek Hughes - removing this as a default.  ONly 7 implementations at present and all should be unaffected.
        //httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        
        // if a content type is provided, set it in the header.  
        // if not defined it may have been set in the Named Credential
        if (String.isNotBlank(contentType)) {
            httpRequest.setHeader(HEADER_CONTENT_TYPE, contentType);
        }

        // if a correlation ID header is set, add it to the request
        if (String.isNotBlank(this.correlationIdHeader)) {
            httpRequest.setHeader(this.correlationIdHeader, this.createPseudoGUID());
        }

        addSecureHeaders(httpRequest);
    
        // Request Details
        httpRequest.setEndpoint(endpoint);

        if (requestBody != null) {
            if (requestBody instanceof String) {
            
                String transformedRequestBody = (String)requestBody;
                if (String.isNotBlank(transformedRequestBody)) {
                    LOGGER0.info('prepareHttpRequest Object: requestBody is in the instance of a String and is not empty.');
                    httpRequest.setBody(transformedRequestBody);
                }
            }
            else if (requestBody instanceof Blob) {
                Blob transformedRequestBody = (Blob)requestBody;
                if (String.isNotBlank(transformedRequestBody.toString())) {
                    LOGGER0.info('prepareHttpRequest Object: requestBody is in the instance of a Blob and is not empty.');
                    httpRequest.setBodyAsBlob(transformedRequestBody);   
                }
            }
            else if (requestBody instanceof Dom.Document) {
                Dom.Document transformedRequestBody = (Dom.Document)requestBody;
                if (String.isNotBlank(transformedRequestBody.toXmlString())) {
                    LOGGER0.info('prepareHttpRequest Object: requestBody is in the instance of a DOM Document and is not empty.');
                    httpRequest.setBodyDocument(transformedRequestBody);
                }
            }
            else {
                //Throw an exception if the requestBody is not a supported type
                LOGGER0.fatal('prepareHttpRequest: Unsupported request body type: Supported types are String, Blob, and Dom.Document.');
                throw new ServiceException('prepareHttpRequest: Unsupported request body type: Supported types are String, Blob, and Dom.Document.');
            }
        }

        return httpRequest;
    }

    /**
    * @description 
    * @author Derek Hughes | 21-08-2025 
    * @param httpRequest 
    **/
    private void addSecureHeaders (HttpRequest httpRequest) {
        
        if (this.apiCredential == null) {
            return;
        }
        try {
            List<API_Credential_Value__mdt> credentialValues = [
                SELECT Id, Label, Header_Value__c, Header_Parameter__c 
                FROM API_Credential_Value__mdt 
                WHERE API_Credential__c = :apiCredential.Id
            ];

            for (API_Credential_Value__mdt credentialValue : credentialValues) {
                if (String.isNotBlank(credentialValue.Header_Parameter__c) && String.isNotBlank(credentialValue.Header_Value__c)) {
                    httpRequest.setHeader(credentialValue.Header_Parameter__c, credentialValue.Header_Value__c);
                } 
                else{
                    LOGGER0.error('addSecureHeaders('+namedCredential+' , '+apiCredential+'): Empty parameter or value for: ' + credentialValue.Label);
                }
            }
            
        } 
        catch (Exception ex) {
            LOGGER0.error('addSecureHeaders('+namedCredential+' , '+apiCredential+'): Unsuccessful retrieve of api credentials header and parameters', ex);
        }
       
    }
    

    /**
     * @description This method creates new pseudo guid value that can be used as a correlation ID for the API call.
     * @return String guid
     */
    private String createPseudoGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }

    /**
    * @description Allows test classes outside the namespace to provide a Http Mock class
    * @author Derek Hughes | 18-04-2024 
    * @param mock 
    **/
    global static void setMock(Type interfaceType, HttpCalloutMock mockClass) {
        Test.setMock(interfaceType, mockClass);
    }

    global class ServiceException extends Exception {}

}


/******************************************************************************************************
 * USEFUL CODE TO RUN IN DEVELOPER CONSOLE FOR TESTING

PBB_SRV_GatewayRequestProvider grp = new PBB_SRV_GatewayRequestProvider();
HttpRequest httpReq = grp.getRequestWithToken();
System.debug('httpReq: '+httpReq);


Cache.OrgPartition orgPart = Cache.Org.getPartition('Tokens');
Set<String> keys = orgPart.getKeys();
System.debug('keys: '+keys);
System.debug('getMissRate():' +orgPart.getMissRate());

Object token = orgPart.get('gwnp');
System.debug('token: '+(String)token);

orgPart.remove('gwnp'); 

new PER_API_NBA_GetSingleResponses('XXX_API_Test').requestAccessToken('customer prod retail');

new PER_API_NBA_GetSingleResponses('XXX_API_Test').call('UG');
new PER_API_NBA_GetSingleReasons().call('UG');
new PER_API_NBA_GetSinglePoap().call('PV01');

********************************************************************************************************/


/******************************************************************************************************
 * MUST KEEP UNTIL SURE ALL API's WORK WITH THE NEW DESIGN 

private class TokenException extends Exception {}
private class AuthException extends Exception { }

private CMN_WebserviceSetting__mdt webServiceSetting;
private NamedCredential namedCredential;
private String tokenKeyName;

protected CMN_WebserviceSetting__mdt webServiceSetting() {
    return webServiceSetting;
} 

protected NamedCredential namedCredential() {
    return namedCredential;
}


global ApiService (String serviceName) {

    LOGGER0.info('CONSTRUCTOR: serviceName: '+ serviceName);

    // this.webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(serviceName);
    this.webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(serviceName);

    LOGGER0.debug('CONSTRUCTOR: webServiceSetting: '+webServiceSetting);

    if (this.webServiceSetting==null) {
        throw new ServiceException('INTERNAL SYSTEM ERRROR: Unable to load API settings: '+serviceName);
    }

    // Remove underscords
    // DH Maybe this should be a specific attribute and not the developer name
    this.tokenKeyName = this.webServiceSetting.DeveloperName.replaceAll('_', '');

    this.namedCredential = CMN_DAL_NamedCredential.findByName(this.webServiceSetting.CMN_NamedCredential__c);
    if (this.namedCredential == null) {
        throw new ServiceException('INTERNAL SYSTEM ERRROR: Unable to load Named Credential: '+this.webServiceSetting.CMN_NamedCredential__c);
    }
    
}
 
//*********************************  OLD GET ACCESS TOKEN  *************************************
private static final String PARTITION_TOKENS = 'Tokens';
private static final String HEADER_CLIENT_CERTIFICATE = 'x-Client-Certificate';
private static final String HEADER_AUTHORIZATION = 'Authorization';
private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';

private static final String PATH_TOKEN = '/sysauth/oauth2/token';
private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';


global CMN_DTO_AuthenticationResponse requestAccessToken (String scope) {

    LOGGER0.info('requestAccessToken: START: scope: '+scope);

    //Prepare Request
    // Blob clientToken = Blob.valueOf(webServiceSetting.CMN_ClientID__c + ':' + webServiceSetting.CMN_Client_Secret__c);
    // String endpoint = namedCredential.Endpoint + PATH_TOKEN;
    String endpoint = 'callout:' + 'XXX_API_Test' + PATH_TOKEN;
    String requestBody = String.format('grant_type=client_credentials&scope={0}', new List<String> {scope});

    LOGGER0.info('requestAccessToken: endpoint: '+endpoint);

    HttpRequest httpRequest = new HttpRequest();

    //Set Request Headers
    httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
    httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
    // httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
    //httpREquest.setClientCertificateName(this.webServiceSetting.DeveloperName);
    // httpRequest.setHeader(HEADER_AUTHORIZATION, 'Basic ' + EncodingUtil.base64Encode(clientToken));
    httpRequest.setHeader(HEADER_AUTHORIZATION, 'Basic {!$Credential.AuthorizationHeaderValue}');
    
    //Set Request Details
    httpRequest.setEndpoint(endpoint);
    httpRequest.setBody(requestBody);
    httpRequest.setMethod(HTTP_METHOD_POST);
    httpRequest.setTimeout(120000);

    String responseBody;
    //Make HTTP Request
    try {
        Http http = new Http();
        HttpResponse httpResponse = new HttpResponse();
        httpResponse = http.Send(httpRequest);

        LOGGER0.debug('requestAccessToken: API response body: '+ httpResponse.getBody());
        
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            responseBody = httpResponse.getBody();
            CMN_DTO_AuthenticationResponse responseObject =
                (CMN_DTO_AuthenticationResponse) JSON.deserialize(responseBody, CMN_DTO_AuthenticationResponse.class);

            LOGGER0.info('requestAccessToken: SUCCESS');
            
            return responseObject;
        }
        else {
            String message = 'Response status: ' + httpResponse.getStatusCode()+' '+httpResponse.getStatus()+(String.IsNotBlank(responseBody) ? '\nAPI response body:\n'+responseBody : '');
            throw new TokenException(message);
        }
    } 
    catch (Exception ex) {
        LOGGER0.error('requestAccessToken: Unhandled Exception', ex);
        throw new TokenException(ex.getMessage());
    }
}
    

global String getNewAccessToken() {
    // CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
    CMN_DTO_AuthenticationResponse authResponse = requestAccessToken('customer prod retail');
    
    if (authResponse == null || authResponse.access_token == null) {
        String errorMessage = 'SYSTEM ERROR: Unabled to obtain an access token';
        LOGGER0.error('getAccessToken: '+errorMessage);
        throw new TokenException(errorMessage);
    }
    return authResponse.access_token;
}
    
private CMN_DTO_AuthenticationResponse authenticate() {
    // CMN_DTO_AuthenticationResponse authResponse = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
    CMN_DTO_AuthenticationResponse authResponse = requestAccessToken('customer prod retail');
    return authResponse;
}
    
private String getAccessToken() {

    LOGGER0.info('getToken: START');

    Cache.OrgPartition orgPart = Cache.Org.getPartition(PARTITION_TOKENS);
    String token = (String) orgPart.get(this.tokenKeyName);

    if (token == null) {
        LOGGER0.debug('getToken: No token in cache: Authenticating to get new token...');
        CMN_DTO_AuthenticationResponse newToken = authenticate();
        if (newToken == null) {
            LOGGER0.error('getToken: NULL token returned.  Throwing exception: Authentication is temporary unavailable');
            throw new AuthException('Authentication is temporary unavailable');
        }
        LOGGER0.info('getToken: Caching new token: newToken.expires_in='+newToken.expires_in+' secs');
        orgPart.put(this.tokenKeyName, newToken.access_token, Integer.valueOf(newToken.expires_in) - 60, cache.Visibility.NAMESPACE, false);
        token = (String) orgPart.get(this.tokenKeyName);
    }
    else {
        LOGGER0.debug('getToken: Retrieved token from Cache');
    }

    LOGGER0.info('getToken: FINISH: token.length='+token?.length());

    return token;
}

********************************************************************************************************/