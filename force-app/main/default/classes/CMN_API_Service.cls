/**
 * @description       : API Service base class
 * @author            : Derek Hughes
 * @group             : API
 * @last modified on  : 18-03-2024
 * @last modified by  : Derek Hughes
  _____   ____    _   _  ____ _______   ______ _____ _____ _______ 
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |   
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |   
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |   
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|   
                                                                   
 THIS CODE IS CONTROLLED BY THE SALESFORCE COE PLATFORM TEAM
 For any changes requied please contact the platform team.       

 * 
 * References
 * 1. Secret Storage: https://help.salesforce.com/s/articleView?id=sf.nc_create_edit_external_credential.htm&type=5
 * 2. Partition Cache: https://developer.salesforce.com/docs/atlas.en-us.248.0.apexcode.meta/apexcode/apex_cache_namespace_overview.htm 
 * 3. Using Named Credential merge fields: https://developer.salesforce.com/docs/atlas.en-us.248.0.apexcode.meta/apexcode/apex_callouts_named_credentials_merge_fields.htm 
**/
public abstract with sharing class CMN_API_Service {

    private static final sbgplatform.rflib_Logger LOGGER0 = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_Service');
   
    // Constants
    public static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
	public static final String CONTENT_TYPE_FORM_URLENCODED = 'application/x-www-form-urlencoded';

    public static final String HEADER_ACCEPT = 'accept';
    public static final String HEADER_CONTENT_TYPE = 'content-type';

    public static final String HTTP_METHOD_GET = 'GET';
    public static final String HTTP_METHOD_POST = 'POST';
    public static final String HTTP_METHOD_PUT = 'PUT';

	//http status codes https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
	public static final Integer HTTP_OK = 200;
	public static final Integer HTTP_CREATED = 201;
	public static final Integer HTTP_ACCEPTED = 202;
	public static final Integer HTTP_NON_AUTH_INFO = 203;
	public static final Integer HTTP_NO_CONTENT = 204;
	public static final Integer HTTP_RESET_CONTENT = 205;
	public static final Integer HTTP_BAD_REQUEST = 400;
	public static final Integer HTTP_UNAUTHORISED = 401;
	public static final Integer HTTP_INTERNAL_SERVER_ERROR = 500;

	public static final Set<Integer> HTTP_VALID_CODES = new Set<Integer> {
        HTTP_OK, HTTP_CREATED, HTTP_ACCEPTED, HTTP_NON_AUTH_INFO, HTTP_NO_CONTENT, HTTP_RESET_CONTENT
	};

    // Instance Variables
    protected String namedCredential;
    private Type dtoType;

    /**
     * @description Constructor
     * @param namedCredential the developer name of the Named Credential to be used
     */
    public CMN_API_Service (String namedCredential) {
        LOGGER0.info('constructor: namedCredential: '+ namedCredential);
        this.namedCredential = namedCredential;
    }

    /**
    * @description Set the DTO class that is to be used to deserialise the response
    * @author Derek Hughes | 06-03-2024 
    * @param dtoType 
    * @return CMN_API_Service 
    **/
    public CMN_API_Service setDtoType (Type dtoType) {
        this.dtoType = dtoType;
        return this;
    }

    /**
    * @description does http get
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @return Object 
    **/
    public Object get(String path) {
        return send(path, HTTP_METHOD_GET, null);
    }

    /**
    * @description does http post
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param requestBody 
    * @return Object 
    **/
    public Object post(String path, String requestBody) {
        return send(path, HTTP_METHOD_POST, requestBody);
    }

    /**
    * @description does http post
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param requestBody 
    * @return Object 
    **/
    public Object put(String path, String requestBody) {
        return send(path, HTTP_METHOD_PUT, requestBody);
    }

    /**
    * @description Send an http request to the specified path with the optional request body
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return Object 
    **/
    public Object send(String path, String method, String requestBody) {

        LOGGER0.info('send('+namedCredential+'): '+method.toUpperCase()+': '+ path);
        if (String.isNotBlank(requestBody)) {
            LOGGER0.debug('send('+namedCredential+'): requestBody: '+requestBody);
        }

        Object response;

        try {
            HttpRequest httpRequest = prepareHttpRequest(path, method, requestBody);

            LOGGER0.debug('send('+namedCredential+'): httpRequest: '+ httpRequest);

            Http http = new Http();
            HttpResponse httpResponse = http.Send(httpRequest);

            LOGGER0.debug('send('+namedCredential+'): response body: '+ httpResponse.getBody());

            if (isSuccess(httpResponse.getStatusCode())) {
                response = convertResponseToDTO(httpResponse.getBody());
            }
            else {
                throw new ServiceException('API call failed: ' + httpResponse.getStatusCode() + ' - '  + httpResponse.getStatus());
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
    protected virtual Boolean isSuccess(Integer statusCode) {
        return HTTP_VALID_CODES.contains(statusCode);
    }

    /**
    * @description Abstract method to be implemented by sub-classes to convert the raw response to DTO
    * @author Derek Hughes | 04-03-2024 
    * @param responseBody 
    * @return abstract 
    **/
    protected virtual Object convertResponseToDTO(String responseBody) {
        if (String.IsNotBlank(responseBody)) {
            if (dtoType != null) {
                return System.JSON.deserialize(responseBody, dtoType);
            }
            else {
                return responseBody;
            }
        }
        return null;
    }

    /**
    * @description Prepares the http request with default headers
    * @author Derek Hughes | 04-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return httpRequest 
    **/
    protected virtual httpRequest prepareHttpRequest (String path, String method, String requestBody){
        
        if (path.left(1) != '/') {
            path = '/'+path;
        }

        String endpoint = 'callout:' + this.namedCredential + path;
        HttpRequest httpRequest = new HttpRequest();
        
        // Request Headers
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
        
        // Request Details
        httpRequest.setEndpoint(endpoint);
        if (String.isNotBlank(requestBody)) {
            httpRequest.setBody(requestBody);
        }
        httpRequest.setMethod(method);

        return httpRequest;
    }
   
    public class ServiceException extends Exception {}

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


public CMN_API_Service (String serviceName) {

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


public CMN_DTO_AuthenticationResponse requestAccessToken (String scope) {

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
    

public String getNewAccessToken() {
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