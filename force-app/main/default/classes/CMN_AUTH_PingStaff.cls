/**
 * @description Contains methods to create a custom OAuth-based authentication provider plug-in for single sign-on in to Salesforce.
 * Use this class to create a custom authentication provider plug-in
 * if you can’t use one of the authentication providers that Salesforce provides.
 * <p/>
 * There current isn't an existing auth provider plugin class for ping staff and PING is the group wide strategy
 * for cloud AuthN and AuthZ
 * <p/>
 * <p>VCCC-63</p>
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date October 2020
 */
global class CMN_AUTH_PingStaff extends Auth.AuthProviderPluginClass {
  /* provider plugin name (matches the plugin name) */
  public final static String PROVIDER_NAME = 'Ping Staff';

  /* auth config fields */
  public final static String CUSTOM_METADATA_TYPE = CMN_AuthProviderConfig__mdt.SObjectType.getDescribe()
    .getLocalName();
  public final static String FIELD_ACCESS_TOKEN_URL = CMN_AuthProviderConfig__mdt.CMN_AccessTokenUrl__c.getDescribe()
    .getLocalName();
  public final static String FIELD_AUTH_URL = CMN_AuthProviderConfig__mdt.CMN_AuthUrl__c.getDescribe()
    .getLocalName();
  public final static String FIELD_CLIENT_ID = CMN_AuthProviderConfig__mdt.CMN_ClientId__c.getDescribe()
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
   * @description access token received from ping
   * https://tools.ietf.org/html/rfc6749#section-4.2.2
   * <p/>
   * access_token
   * REQUIRED. The access token issued by the authorization server.
   * <p/>
   * token_type
   * REQUIRED. The type of the token issued as described in
   * Section 7.1.  Value is case insensitive.
   * <p/>
   * expires_in
   * RECOMMENDED. The lifetime in SECONDS of the access token. For
   * example, the value "3600" denotes that the access token will
   * expire in one hour from the time the response was generated.
   * If omitted, the authorization server SHOULD provide the
   * expiration time via other means or document the default value.
   * <p/>
   * scope
   * OPTIONAL, if identical to the scope requested by the client;
   * otherwise, REQUIRED.  The scope of the access token as
   * described by Section 3.3.
   * <p/>
   * state
   * REQUIRED if the "state" parameter was present in the client
   * authorization request.  The exact value received from the
   * client.
   */
  public class DTO_Access {
    public String access_token;
    public String token_type;
    public Integer expires_in;
    public String refresh_token;
    public String id_token;
    public Long expires; /* added addition variable for expiry calculated timestamp in milliseconds */
  }

  /**
   * @description user info received from ping
   */
  public class DTO_UserInfo {
    public String sub; /* enterprise id email */
    public String employee_number; /* c-number */
    public Long nbf; /* not before claim (JWT) */
    public Long iat; /* issued at claim (JWT) */
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
   * @description Returns information from the custom authentication provider about the current user.
   * This information is used by the registration handler and in other authentication provider flows
   *
   * @param authProviderConfiguration The configuration for the custom authentication provider.
   * When you create a custom metadata type in Salesforce, the configuration populates with the custom metadata type default values.
   * Or you can set the configuration with values you enter when you create the custom provider in Auth. Providers in Setup
   * @param tokenResponse The OAuth access token, OAuth secret or refresh token,
   * and state provided by the authentication provider to authenticate the current user
   *
   * @return user data
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

      /* Used to pass token attributes to the handler - if first time user will user new user method other will use update user method */
      Map<String, String> attributes = new Map<String, String>{
        ISSUED_AT_CLAIM => String.valueOf(userInfo.iat),
        NOT_BEFORE_CLAIM => String.valueOf(userInfo.nbf)
      };

      /* resolve user names from sub */
      UserNames userNames = getUserNames(userInfo.sub);

      return new Auth.UserData(
        userInfo.employee_number,
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
      CMN_UTIL_Logger.error(e, 'CMN_AUTH_PingStaff.getUserInfo');
      throw e;
    }
  }

  /**
   * @description Uses the authentication provider’s supported authentication protocol to return an OAuth access token,
   * OAuth secret or refresh token, and the state passed in when the request for the current user was initiated
   * <p/>
   * handleCallback does not share the same context or CMN_AUTH_PingStaff class instance information
   * When callback is initiated by ping a brand new instance of CMN_AUTH_PingStaff os created therefore caching is used
   * to maintain the link between code_verifier and the code_challenge (hash)
   *
   * @param authProviderConfiguration The configuration for the custom authentication provider.
   * When you create a custom metadata type in Salesforce, the configuration populates with the custom metadata type default values.
   * Or you can set the configuration with values you enter when you create the custom provider in Auth. Providers in Setup
   * @param callbackState The class that contains the HTTP headers, body, and queryParams of the authentication request.
   *
   * @return Creates an instance of the AuthProviderTokenResponse class
   */
  public Auth.AuthProviderTokenResponse handleCallback(
    Map<String, String> authProviderConfiguration,
    Auth.AuthProviderCallbackState callbackState
  ) {
    try {
      String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
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
      CMN_UTIL_Logger.error(e, 'CMN_AUTH_PingStaff.handleCallback');
      throw e;
    }
  }

  /**
   * @description Returns the URL where the user is redirected for authentication
   * <p/>
   * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_platform_cache_limitations.htm
   * <p/>
   * Cache isn’t persisted. There’s no guarantee against data loss.
   * Some or all cache is invalidated when you modify an Apex class in your org.
   * Data in the cache isn’t encrypted.
   * <p/>
   * Salesforce does not allow direct persistence of sobjects at the initiate stage so cache and platform events are used
   * to keep track of the code verifier and user state (which are linked)
   * <p/>
   * We have tried various permutations of a record insert even with UoW - this may be because the user is not identified yet
   * at this stage of the oauth flow and salesforce should probably not be persisting against an unconfirmed user identity
   *
   * @param authProviderConfiguration The configuration for the custom authentication provider.
   * When you create a custom metadata type in Salesforce, the configuration populates with the custom metadata type default values.
   * Or you can set the configuration with values you enter when you create the custom provider in Auth. Providers in Setup
   * @param stateToPropagate The state passed in to initiate the authentication request for the user
   *
   * @return PageReference
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

    /* for some reason sobject records cannot be persisted within the
		   initiate phase so platform events are used as back up for cache and org cache does not work as per api 50.0
		   the cache saves the value but on the call back cache is flushed or does not contain the value in cache
		   therefore platform events are used instead.
		*/
    CMN_SRV_OAuth.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

    String authUrl = authProviderConfiguration.get(FIELD_AUTH_URL);
    String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
    String scope = authProviderConfiguration.get(FIELD_SCOPE);
    String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);

    /* It is critical ping send back the state on the call back as this is the thread across sfdc and ping */
    String url =
      authUrl +
      '?client_id=' +
      clientId +
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
   * @description utility method specific to this class to extract names from email (sub)
   * this method should not fail on invalid or varying input
   *
   * @param sub as input e.g. email or enterprise id email e.g. bob.jones@email.com
   *
   * @return DTO_UserNames populated with extracted / resolved names
   */
  public static UserNames getUserNames(String sub) {
    UserNames names = new UserNames();

    sub = CMN_UTIL_String.defaultIfEmpty(sub, CMN_UTIL_String.EMPTY);

    String[] subSegments = CMN_UTIL_String.split(sub, '@');
    String[] nameSegments = CMN_UTIL_String.split(
      subSegments.size() == 0 ? CMN_UTIL_String.EMPTY : subSegments[0],
      '\\.'
    );

    names.firstName = CMN_UTIL_String.capitalize(
      nameSegments.size() >= 1 ? nameSegments[0] : CMN_UTIL_String.EMPTY
    );
    names.lastName = CMN_UTIL_Word.capitalize(
      CMN_UTIL_String.joinArray(nameSegments, ' ', 1, nameSegments.size())
    );
    names.fullName = CMN_UTIL_String.trim(
      new CMN_UTIL_StringBuffer(names.firstName)
        .append(' ')
        .append(names.lastName)
        .toStr()
    );

    return names;
  }

  /**
   * @description Returns a new access token, which is used to update an expired access token
   * <p/>
   *
   * @param authProviderConfiguration The configuration for the custom authentication provider.
   * When you create a custom metadata type in Salesforce, the configuration populates with the custom metadata type default values.
   * Or you can set the configuration with values you enter when you create the custom provider in Auth. Providers in Setup
   * @param refreshToken as input
   *
   * @return OAuthRefreshResult
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
      request.setBody('client_id=' + clientId);

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
      CMN_UTIL_Logger.error(e, 'CMN_AUTH_PingStaff.refresh');
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
   * 
   * Lastmodified 12 Nov 2025 - SFP-54345 - Update JWT Payload Deserialization Fix - COE Platform
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
      
    Map<String, Object> payloadMap =
    (Map<String, Object>) JSON.deserializeUntyped(payload);
      
      System.debug('Payload during SSO >> '+payload);

    // Get time in seconds for exp compare
    Integer currentDateTimeInSeconds = (Integer) (Datetime.now().getTime() /
    1000);

    String validationMessage;

    // Incorrect issuer
    if (
      String.valueOf(payloadMap.get(ISSUER_CLAIM)) !=
      authProviderConfiguration.get(FIELD_ISSUER_URL)
    ) {
      validationMessage = ERROR_INVALID_ISSUER;
    } else if (
      String.valueOf(payloadMap.get(AUDIENCE_CLAIM)) !=
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