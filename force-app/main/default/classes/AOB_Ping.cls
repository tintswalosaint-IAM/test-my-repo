/**
 * @description Ping Authentication
 * ACTION  TICKET    DATE       OWNER               COMMENT
 * Changed SFP-32618 21-11-2023 Tatenda Muzondiona  removed commented code, logger and use of native String class
 */
global class AOB_Ping extends Auth.AuthProviderPluginClass {
  /* provider plugin name (matches the plugin name) */
  public final static String PROVIDER_NAME = 'AOB_Ping';

  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Ping');

  public final static String CUSTOM_METADATA_TYPE = CMN_AuthProviderConfig__mdt.SObjectType.getDescribe()
    .getLocalName();
  public final static String FIELD_ACCESS_TOKEN_URL = CMN_AuthProviderConfig__mdt.CMN_AccessTokenUrl__c.getDescribe()
    .getLocalName();
  public final static String FIELD_AUTH_URL = CMN_AuthProviderConfig__mdt.CMN_AuthUrl__c.getDescribe()
    .getLocalName();
  public final static String FIELD_CLIENT_ID = CMN_AuthProviderConfig__mdt.CMN_ClientId__c.getDescribe()
    .getLocalName();
  public final static String FIELD_CLIENT_SECRET = CMN_AuthProviderConfig__mdt.CMN_ClientSecret__c.getDescribe()
    .getLocalName();
  public final static String FIELD_ISSUER_URL = CMN_AuthProviderConfig__mdt.CMN_Issuer__c.getDescribe()
    .getLocalName();
  public final static String FIELD_REDIRECT_URL = CMN_AuthProviderConfig__mdt.CMN_RedirectUrl__c.getDescribe()
    .getLocalName();
  public final static String FIELD_SCOPE = CMN_AuthProviderConfig__mdt.CMN_Scope__c.getDescribe()
    .getLocalName();
  public final static String FIELD_USERINFO_URL = CMN_AuthProviderConfig__mdt.CMN_UserInfoUrl__c.getDescribe()
    .getLocalName();

  @TestVisible
  private final static String ACCESS_TOKEN = 'access_token';
  @TestVisible
  private final static String EXPIRES_IN = 'expires_in';
  @TestVisible
  private final static String ISSUED_AT_CLAIM = 'iat';
  @TestVisible
  private final static String ID_TOKEN = 'id_token';
  @TestVisible
  private final static String NOT_BEFORE_CLAIM = 'nbf';
  @TestVisible
  private final static String REFRESH_TOKEN = 'refresh_token';
  @TestVisible
  private final static String TOKEN_TYPE = 'token_type';
  @TestVisible
  private final static String CODE_CHALLENGE_METHOD_S256 = 'S256';
  @TestVisible
  private final static String RESPONSE_STATE = 'state';
  @TestVisible
  private final static String RESPONSE_TYPE_CODE = 'code';
  @TestVisible
  private final static String ISSUER_CLAIM = 'iss'; // Issuer claim (JWT)
  @TestVisible
  private final static String AUDIENCE_CLAIM = 'aud'; // Audience claim (JWT) - Client ID
  private final static String EXPIRY_CLAIM = 'exp'; // Expiry claim (JWT)

  @TestVisible
  private final static String ERROR_INVALID_ISSUER = 'Id Token validation failed due to invalid issuer';
  @TestVisible
  private final static String ERROR_INVALID_CLIENT_ID = 'Id Token validation failed due to invalid client id';
  @TestVisible
  private final static String ERROR_TOKEN_EXPIRED = 'Id Token validation failed due to token having expired';

  private final static String GRANT_TYPE_AUTHORIZATION_CODE = 'authorization_code';
  private final static String GRANT_TYPE_REFRESH_TOKEN = 'refresh_token';

  public final static String TOKEN_TYPE_BEARER = CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER.trim();
/**
   * @description DTO_Access
   * @param access_token, token_type, expires_in, refresh_token, id_token, expires
   * @return data
  */
  public class DTO_Access {
    public String access_token;
    public String token_type;
    public Integer expires_in;
    public String refresh_token;
    public String id_token;
    public Long expires;
  }

  /**
   * @description user info received from ping
   */
  public class DTO_UserInfo {
    public String sub; /* enterprise id email */
    public String email;
    public String employee_number; /* c-number */
    public Long nbf; /* not before claim (JWT) */
    public Long iat; /* issued at claim (JWT) */
    public String id;
    public String bpId;
    public String bpidguid;
    public String first_name;
    public String last_name;
  }

  /**
   * @description transient dto used to hold the user names i.e. firstname, last name and full name from the sub
   * variable returned as the enterprise id / email
   */
  public class UserNames {
    public String firstName;
    public String lastName;
    public String fullName;
  }

  /**
   * @description Returns the custom metadata type API name for a custom OAuth-based
   * authentication provider for single sign-on to Salesforce
   *
   * @return Returns the custom metadata type API name for a custom OAuth-based authentication provider for single sign-on to Salesforce.
   * The getCustomMetadataType() method returns only custom metadata type names. It does not return custom metadata record names
   */
  global String getCustomMetadataType() {
    return CUSTOM_METADATA_TYPE;
  }
    
 /**
   * @description get User Info
   * @param authProviderConfiguration
   * @param tokenResponse
   * @return data
  */
  global Auth.UserData getUserInfo(
    Map<String, String> authProviderConfiguration,
    Auth.AuthProviderTokenResponse tokenResponse
  ) {
      
    try {
      DTO_Access dtoAccessToken = tokenStringToDto(tokenResponse.oauthToken);

      validateIdToken(dtoAccessToken, authProviderConfiguration);

      HttpRequest request = new HttpRequest();
      String userInfoUrl = authProviderConfiguration.get(FIELD_USERINFO_URL);
      request.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ACCEPT_JSON_WITH_CHARSET
      );
      request.setHeader(
        CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION,
        TOKEN_TYPE_BEARER +
        ' ' +
        dtoAccessToken.access_token
      );
      request.setEndpoint(userInfoUrl);
      request.setMethod(CMN_API_HttpBase.HTTP_VERB_GET);

      Http http = new Http();
      HttpResponse response = http.send(request);
      checkValidHttpResponse(response);
      String responseBody = response.getBody();
      DTO_UserInfo userInfo = (DTO_UserInfo) JSON.deserialize(
        responseBody,
        DTO_UserInfo.class
      );
      
      /* resolve user names from sub */
      UserNames userNames = getUserNames(userInfo.first_name,userInfo.last_name);
        /* Used to pass token attributes to the handler - if first time user will user new user method other will use update user method */
       Map<String, String> attributes = new Map<String, String>{
        ISSUED_AT_CLAIM => String.valueOf(userInfo.iat),
        NOT_BEFORE_CLAIM => String.valueOf(userInfo.nbf),
        AOB_Constants.PING_LAST_NAME=> String.isBlank(userNames.lastName)?userInfo.sub:userNames.lastName,
        AOB_Constants.PING_FIRST_NAME=> userNames.firstName,
        AOB_Constants.PING_SUB=>userInfo.email,
        AOB_Constants.PING_BPID=>userInfo.bpId,
        AOB_Constants.PING_BPGUID=>userInfo.bpidguid,
        AOB_Constants.ID_STRING=>userInfo.id
      };
      return new Auth.UserData(
        userInfo.id,
        userNames.firstName,
        userNames.lastName,
        userNames.fullName,
        userInfo.sub,
        null,
        userInfo.sub,
        null,
        PROVIDER_NAME,
        null,
        attributes
      );
    } catch (Exception e) {
      LOGGER.error(e.getMessage(), new String[] {'AOB_PingAuth.getUserInfo', e.getMessage()}, e);
      throw e;
    }
  }

  /**
   * @description handle call back
   * @param authProviderConfiguration
   * @param callbackState
   * @return data
  */
  public Auth.AuthProviderTokenResponse handleCallback(
    Map<String, String> authProviderConfiguration,
    Auth.AuthProviderCallbackState callbackState
  ) {
    try {
      String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
      String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
      String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
      String accessTokenUrl = authProviderConfiguration.get(
        FIELD_ACCESS_TOKEN_URL
      );
      Map<String, String> queryParams = callbackState.queryParameters;

      String code = queryParams.get(RESPONSE_TYPE_CODE);
      String state = queryParams.get(RESPONSE_STATE);

      /* resolve the correlation key from the propagated user state (returned back from ping on callback) */
      String codeVerifierKey = CMN_UTIL_OAuth.generateAlphanumericHash(state);

      /* resolve the correlation key from the propagated user state */
      /* retrieve correlated code verifier to send to ping so it can do the same hash check and free up cache space */
      String codeVerifier = CMN_SRV_OAuth.retrieveCodeVerifier(codeVerifierKey);
      /* clean up verifier code cache and data and not to block the following callout which should fire asap */
      CMN_SRV_OAuth.publishCodeVerifierDelete(codeVerifierKey);

      String body =
        'code=' +
        code +
        '&redirect_uri=' +
        redirectUrl +
        '&grant_type=' +
        GRANT_TYPE_AUTHORIZATION_CODE +
        '&client_id=' +
        clientId +
        '&client_secret=' +
        clientSecret +
        '&code_verifier=' +
        codeVerifier;
      HttpRequest request = new HttpRequest();

      request.setEndpoint(accessTokenUrl);
      request.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_FORM_URL_ENCODED
      );
      request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
      request.setBody(body);

      Http http = new Http();

      HttpResponse response = http.send(request);
      checkValidHttpResponse(response);

      String responseBody = response.getBody();
      DTO_Access accessTokenDto = tokenStringToDto(responseBody);

      updateTokenExpires(accessTokenDto);
      String token = JSON.serialize(accessTokenDto);
      // populate and returned the provider token response based on spec (note the token value is the serialised dto)
      return new Auth.AuthProviderTokenResponse(
        PROVIDER_NAME,
        token,
        accessTokenDto.refresh_token,
        state
      );
    } catch (Exception e) {
      LOGGER.error(e.getMessage(), new String[] {'AOB_PingAuth.handleCallback', e.getMessage()}, e);
      throw e;
    }
  }

  /**
   * @description handle call back
   * @param authProviderConfiguration
   * @param stateToPropagate
   * @return data
  */
  global PageReference initiate(
    Map<String, String> authProviderConfiguration,
    String stateToPropagate
  ) {
    String codeVerifier = CMN_UTIL_OAuth.generateRandomCode();
    /* code challenge is first part of the pkce puzzle sent to ping */
    String codeChallenge = CMN_UTIL_OAuth.generateChallenge(codeVerifier);
    /* create a correlation key to match state with code verifier */
    String codeVerifierKey = CMN_UTIL_OAuth.generateAlphanumericHash(
      stateToPropagate
    );

    CMN_SRV_OAuth.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

    String authUrl = authProviderConfiguration.get(FIELD_AUTH_URL);
    String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
    String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
    String scope = authProviderConfiguration.get(FIELD_SCOPE);
    String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);

    /* It is critical ping send back the state on the call back as this is the thread across sfdc and ping */
    String url =
      authUrl +
      '?client_id=' +
      clientId +
     '&client_secret=' +
      clientSecret +
      '&response_type=' +
      RESPONSE_TYPE_CODE +
      '&scope=' +
      scope +
      '&redirect_uri=' +
      redirectUrl +
      '&code_challenge=' +
      codeChallenge +
      '&code_challenge_method=' +
      CODE_CHALLENGE_METHOD_S256 +
      '&state=' +
      stateToPropagate;
    return new PageReference(url);
  }

   /**
    * SFP-27234 changed parameters from sub to firstname,lastname
    * @description get user names
    * @param firstname
    * @param lastname
    * @return names
  */  
  public static UserNames getUserNames(String firstname,String lastname) {
    UserNames names = new UserNames();
    if(firstname != null && lastname != null){
      names.firstName = firstname.capitalize();
      names.lastName = lastname.capitalize();
    }
    names.fullName = (new CMN_UTIL_StringBuffer(names.firstName).append(' ').append(names.lastName).toStr()).trim();
     return names;
  }
  /**
   * @description refresh
   * @param authProviderConfiguration
   * @param refreshToken
   * @return names
  */  
  global override Auth.OAuthRefreshResult refresh(
    Map<String, String> authProviderConfiguration,
    String refreshToken
  ) {
    try {
      String refreshTokenUrl = authProviderConfiguration.get(
        FIELD_ACCESS_TOKEN_URL
      );
      String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
      String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
      String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
      
      String url =
        refreshTokenUrl +
        '?grant_type=' +
        GRANT_TYPE_REFRESH_TOKEN +
        '&redirect_uri=' +
        redirectUrl +
        '&refresh_token=' +
        refreshToken;

      HttpRequest request = new HttpRequest();

      request.setEndpoint(url);
      request.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_FORM_URL_ENCODED
      );
      request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
      request.setBody('client_id=' + clientId+'&client_secret='+clientSecret);

      Http http = new Http();

      HttpResponse response = http.send(request);
      
      checkValidHttpResponse(response);

      String responseBody = response.getBody();

      DTO_Access refreshedTokenDto = tokenStringToDto(responseBody);

      updateTokenExpires(refreshedTokenDto);

      String refreshedToken = JSON.serialize(refreshedTokenDto);
    
      /* note the refreshed token is the serialised dto not the access token value so token must be extracted */
      return new Auth.OAuthRefreshResult(
        refreshedToken,
        refreshedTokenDto.refresh_token,
        null
      );
    } catch (Exception e) {
      LOGGER.error(e.getMessage(), new String[] {'AOB_PingAuth.refresh', e.getMessage()}, e);
      return new Auth.OAuthRefreshResult(null, null, e.getMessage());
    }
  }

  /**
   * @description convert token string to dto
   *
   * @param jsonString as input
   *
   * @return access token dto
   */
  public static DTO_Access tokenStringToDto(String jsonString) {
    return (DTO_Access) JSON.deserialize(jsonString, DTO_Access.class);
  }

  /**
   * @description sets the expiry timestamp in milliseconds of the access token
   *
   * @param accessTokenDto as input (the dto field value is updated)
   */
  private static void updateTokenExpires(DTO_Access accessTokenDto) {
    Long expires =
      System.currentTimeMillis() + (accessTokenDto.expires_in * 1000);
    accessTokenDto.expires = expires;
  }

  /**
   * @description checks if response from ping was successful else throw callout exception
   *
   * @param response from ping as input
   */
  @TestVisible
  private static void checkValidHttpResponse(HttpResponse response) {
    if (!CMN_API_HttpBase.HTTP_VALID_CODES.contains(response.getStatusCode())) {
      throw new CalloutException(
        'Code: ' +
        response.getStatusCode() +
        '; Status: ' +
        response.getStatus() +
        '; Body: ' +
        response.getBody()
      );
    }
  }

  /**
   * @description Validates JWT and throws exception if token is invalid
   *
   * @param dtoAccess A DTO representing the JWT
   * @param authProviderConfiguration Various parameters to be used while performing validation
   */
  public static void validateIdToken(
    DTO_Access dtoAccess,
    Map<String, String> authProviderConfiguration
  ) {
    // convert string to base64 instead of base64URL (since apex has no base64url support)
    String id = dtoAccess.id_token.replaceAll('\\-', '+')
      .replaceAll('\\_', '/');
    List<String> jwt = id.split('\\.');

    // Validate ID Token Payload
    String payload = EncodingUtil.base64Decode(jwt[1]).toString();
    
    
    Map<String, Object> payloadMap ;
      try{
         payloadMap = (Map<String, Object>) JSON.deserializeUntyped( payload );
      }
      catch(Exception e){ 
        LOGGER.error(e.getMessage(), new String[] {'payloadMap Error: '+payload,'AOB_Ping', e.getMessage()}, e);
      }

    // Get time in seconds for exp compare
    Integer currentDateTimeInSeconds = (Integer) (Datetime.now().getTime() /
    1000);

    String validationMessage;

    // Incorrect issuer
    if (
      payloadMap.get(ISSUER_CLAIM) !=
      authProviderConfiguration.get(FIELD_ISSUER_URL)
    ) {
      validationMessage = ERROR_INVALID_ISSUER;
    } else if (
      payloadMap.get(AUDIENCE_CLAIM) !=
      authProviderConfiguration.get(FIELD_CLIENT_ID)
    ) {
      // Incorrect Audience (oauth client id)
      validationMessage = ERROR_INVALID_CLIENT_ID;
    } else if (
      currentDateTimeInSeconds > Integer.valueOf(payloadMap.get(EXPIRY_CLAIM))
    ) {
      // Check that the token hasn't expired
      validationMessage = ERROR_TOKEN_EXPIRED;
    }

    if (String.isNotBlank(validationMessage)) {
      throw new IllegalArgumentException(validationMessage);
    }
  }
}