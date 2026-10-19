/**
 * @description Testing the CMN_AUTH_PingStaff auth provider plugin
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date October 2020
 */
@IsTest(SeeAllData=false)
private class CMN_AUTH_PingStaff_TEST {
  private static final Integer EXPIRES_IN_VALUE = 1000;
  private static final Long ISSUED_AT_CLAIM_VALUE = 12345678;
  private static final Long NOT_BEFORE_CLAIM_VALUE = 12345678;
  private static final String ACCESS_TOKEN = 'testAccessToken'; /*i.e. returned oauth token */
  private static final String ACCESS_TOKEN_URL = 'http://www.ping.com/accessTokenUri';
  private static final String API_USER_URL = 'www.ping.com/user/api';
  private static final String AUTH_URL = 'http://www.pinghost.com/authurl';
  private static final String CLIENT_ID = 'testClientId';
  private static final String CODE = 'testCode';
  private static final String EMPLOYEE_NUMBER = 'C12345';
  private static final String ENTERPRISE_EMAIL = 'john.smith@email.com';
  private static final String FIELD_ISSUER_URL = 'testIssuer';
  private static final String ID_TOKEN = 'testIdToken';
  private static final String REDIRECT_URL = 'http://localhost/services/authcallback/orgId/pingstaff';
  private static final String REFRESH_TOKEN = 'testRefreshToken';
  private static final String SCOPE = 'openid profile';
  private static final String STATE_TO_PROPAGATE = 'testState';

  /**
   * @description in the real world scenario,
   * the key and value would be read from the (custom fields in) custom metadata type record
   *
   * @return mock auth provider config
   */
  private static Map<String, String> setupAuthProviderConfig() {
    Map<String, String> authProviderConfiguration = new Map<String, String>();

    authProviderConfiguration.put(
      CMN_AUTH_PingStaff.FIELD_CLIENT_ID,
      CLIENT_ID
    );
    authProviderConfiguration.put(CMN_AUTH_PingStaff.FIELD_SCOPE, SCOPE);
    authProviderConfiguration.put(CMN_AUTH_PingStaff.FIELD_AUTH_URL, AUTH_URL);
    authProviderConfiguration.put(
      CMN_AUTH_PingStaff.FIELD_ACCESS_TOKEN_URL,
      ACCESS_TOKEN_URL
    );
    authProviderConfiguration.put(
      CMN_AUTH_PingStaff.FIELD_USERINFO_URL,
      API_USER_URL
    );
    authProviderConfiguration.put(
      CMN_AUTH_PingStaff.FIELD_REDIRECT_URL,
      REDIRECT_URL
    );
    authProviderConfiguration.put(
      CMN_AUTH_PingStaff.FIELD_ISSUER_URL,
      FIELD_ISSUER_URL
    );

    return authProviderConfiguration;
  }

  private static Map<String, Object> returnCorrectJWTClaims(
    Map<String, String> authProviderConfiguration
  ) {
    return new Map<String, Object>{
      CMN_AUTH_PingStaff.AUDIENCE_CLAIM => authProviderConfiguration.get(
        CMN_AUTH_PingStaff.FIELD_CLIENT_ID
      ),
      CMN_AUTH_PingStaff.ISSUER_CLAIM => authProviderConfiguration.get(
        CMN_AUTH_PingStaff.FIELD_ISSUER_URL
      ),
      CMN_AUTH_PingStaff.EXPIRES_IN => EXPIRES_IN_VALUE
    };
  }

  /**
   * @description tests CMN_AUTH_PingStaff.getCustomMetadataType() used by salesforce plugin manager
   *
   * @see CMN_AUTH_PingStaff.getCustomMetadataType
   */
  @IsTest
  private static void getCustomMetadataType() {
    System.assertEquals(
      CMN_AUTH_PingStaff.CUSTOM_METADATA_TYPE,
      new CMN_AUTH_PingStaff().getCustomMetadataType(),
      'Expected metadata_types to match'
    );
  }

  /**
   * @description tests CMN_AUTH_PingStaff.getUserNames()
   *
   * @see CMN_AUTH_PingStaff.getUserNames
   */
  @IsTest
  private static void getUserNames() {
    CMN_AUTH_PingStaff.UserNames names = CMN_AUTH_PingStaff.getUserNames(
      ENTERPRISE_EMAIL
    );

    System.assertEquals('John', names.firstName);
    System.assertEquals('Smith', names.lastName);
    System.assertEquals('John Smith', names.fullName);

    names = CMN_AUTH_PingStaff.getUserNames('xyz@email.com');
    System.assertEquals('Xyz', names.firstName);
    System.assertEquals('', names.lastName);
    System.assertEquals('Xyz', names.fullName);

    names = CMN_AUTH_PingStaff.getUserNames('bob.j.jones@email.co.za');
    System.assertEquals('Bob', names.firstName);
    System.assertEquals('J Jones', names.lastName);
    System.assertEquals('Bob J Jones', names.fullName);

    names = CMN_AUTH_PingStaff.getUserNames(null);
    System.assertEquals('', names.firstName);
    System.assertEquals('', names.lastName);
    System.assertEquals('', names.fullName);
  }

  /**
   * @description tests CMN_AUTH_PingStaff.initiate method (step 1)
   *
   * @see CMN_AUTH_PingStaff.initiate
   */
  @IsTest
  private static void testInitiateMethod() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    Test.startTest();

    PageReference actualUrl = pingStaff.initiate(
      authProviderConfiguration,
      STATE_TO_PROPAGATE
    );

    Test.stopTest();

    System.assert(actualUrl.getUrl() != null);
    System.assert(actualUrl.getParameters().get('code_challenge') != null);
    System.assertEquals(
      CLIENT_ID,
      actualUrl.getParameters().get('client_id'),
      'Expected client_ids to match'
    );
    System.assertEquals(
      SCOPE,
      actualUrl.getParameters().get('scope'),
      'Expected scopes to match'
    );
    System.assertEquals(
      REDIRECT_URL,
      actualUrl.getParameters().get('redirect_uri'),
      'Expected redirect_uris to match'
    );
    System.assertEquals(
      STATE_TO_PROPAGATE,
      actualUrl.getParameters().get('state'),
      'Expected states to match'
    );
    System.assertEquals(
      CMN_AUTH_PingStaff.RESPONSE_TYPE_CODE,
      actualUrl.getParameters().get('response_type'),
      'Expected response_types to match'
    );
    System.assertEquals(
      CMN_AUTH_PingStaff.CODE_CHALLENGE_METHOD_S256,
      actualUrl.getParameters().get('code_challenge_method'),
      'Expected code_challenge_methods to match'
    );
  }

  /**
   * @description tests CMN_AUTH_PingStaff.handleCallback method (step 2)
   *
   * @see CMN_AUTH_PingStaff.handleCallback
   */
  @IsTest
  private static void testHandleCallback() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

    PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    Map<String, String> queryParams = new Map<String, String>();

    queryParams.put(CMN_AUTH_PingStaff.RESPONSE_TYPE_CODE, CODE);
    queryParams.put(CMN_AUTH_PingStaff.RESPONSE_STATE, STATE_TO_PROPAGATE);

    Test.startTest();

    Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(
      null,
      null,
      queryParams
    );

    Auth.AuthProviderTokenResponse actualAuthProviderResponse = pingStaff.handleCallback(
      authProviderConfiguration,
      callbackState
    );

    CMN_AUTH_PingStaff.DTO_Access actualTokenDto = CMN_AUTH_PingStaff.tokenStringToDto(
      actualAuthProviderResponse.oauthToken
    );

    CMN_AUTH_PingStaff.DTO_Access expectedToken = createMockAccessToken();

    Auth.AuthProviderTokenResponse expectedAuthProviderResponse = new Auth.AuthProviderTokenResponse(
      CMN_AUTH_PingStaff.PROVIDER_NAME,
      JSON.serialize(expectedToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );

    Test.stopTest();

    System.assertEquals(
      expectedAuthProviderResponse.provider,
      actualAuthProviderResponse.provider,
      'Expected providers to match'
    );
    System.assertEquals(
      expectedToken.access_token,
      actualTokenDto.access_token,
      'Expected oauthTokens to match'
    );
    System.assertEquals(
      expectedAuthProviderResponse.oauthSecretOrRefreshToken,
      actualAuthProviderResponse.oauthSecretOrRefreshToken,
      'Excepted oauthSecretOrRefreshTokens to match'
    );
    System.assertEquals(
      expectedAuthProviderResponse.state,
      actualAuthProviderResponse.state,
      'Expected states to match'
    );
  }

  /**
   * @description tests negative http response callback scenario
   */
  @IsTest
  private static void testHandleCallbackNegative() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

    Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());

    Map<String, String> queryParams = new Map<String, String>();

    queryParams.put(CMN_AUTH_PingStaff.RESPONSE_TYPE_CODE, CODE);
    queryParams.put(CMN_AUTH_PingStaff.RESPONSE_STATE, STATE_TO_PROPAGATE);

    Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(
      null,
      null,
      queryParams
    );

    try {
      Test.startTest();

      pingStaff.handleCallback(authProviderConfiguration, callbackState);

      Test.stopTest();

      System.assert(false, 'Expected http response error');
    } catch (CalloutException e) {
      System.assert(true);
    }
  }

  /**
   * @description tests CMN_AUTH_PingStaff.GetUserInfo method (step 3)
   *
   * @see CMN_AUTH_PingStaff.GetUserInfo
   */
  @IsTest
  private static void testGetUserInfo() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    PingStaffMockHttpUserInfoResponse mockHttpTokenResponse = new PingStaffMockHttpUserInfoResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    Map<String, Object> jwtClaims = returnCorrectJWTClaims(
      authProviderConfiguration
    );
    CMN_AUTH_PingStaff.DTO_Access accessToken = createMockAccessTokenWithIdToken(
      jwtClaims
    );

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
      CMN_AUTH_PingStaff.PROVIDER_NAME,
      JSON.serialize(accessToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );

    Auth.UserData actualUserData = pingStaff.getUserInfo(
      authProviderConfiguration,
      response
    );

    Map<String, String> attributes = new Map<String, String>{
      CMN_AUTH_PingStaff.ISSUED_AT_CLAIM => String.valueOf(
        ISSUED_AT_CLAIM_VALUE
      ),
      CMN_AUTH_PingStaff.NOT_BEFORE_CLAIM => String.valueOf(
        NOT_BEFORE_CLAIM_VALUE
      )
    };

    Test.startTest();

    CMN_AUTH_PingStaff.UserNames names = CMN_AUTH_PingStaff.getUserNames(
      ENTERPRISE_EMAIL
    );

    Test.stopTest();

    Auth.UserData expectedUserData = new Auth.UserData(
      EMPLOYEE_NUMBER,
      names.firstName,
      names.lastName,
      names.fullName,
      ENTERPRISE_EMAIL,
      null,
      ENTERPRISE_EMAIL,
      null,
      CMN_AUTH_PingStaff.PROVIDER_NAME,
      null,
      attributes
    );

    System.assertNotEquals(
      expectedUserData,
      null,
      'Expected UserData not to be null'
    );
    System.assertEquals(
      expectedUserData.firstName,
      actualUserData.firstName,
      'Expected firstNames to match'
    );
    System.assertEquals(
      expectedUserData.lastName,
      actualUserData.lastName,
      'Expected lastNames to match'
    );
    System.assertEquals(
      expectedUserData.fullName,
      actualUserData.fullName,
      'Expected fullNames to match'
    );
    System.assertEquals(
      expectedUserData.email,
      actualUserData.email,
      'Expected emails to match'
    );
    System.assertEquals(
      expectedUserData.username,
      actualUserData.username,
      'Expected usernames to match'
    );
    System.assertEquals(
      expectedUserData.locale,
      actualUserData.locale,
      'Expected locales to match'
    );
    System.assertEquals(
      expectedUserData.provider,
      actualUserData.provider,
      'Expected providers to match'
    );
    System.assertEquals(
      expectedUserData.siteLoginUrl,
      actualUserData.siteLoginUrl,
      'Expected siteLoginUrls to match'
    );
  }

  /**
   * @description tests negative get user info http response scenario
   */
  @IsTest
  private static void testGetUserInfoNegative() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());

    Map<String, Object> jwtClaims = returnCorrectJWTClaims(
      authProviderConfiguration
    );
    CMN_AUTH_PingStaff.DTO_Access accessToken = createMockAccessTokenWithIdToken(
      jwtClaims
    );

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
      CMN_AUTH_PingStaff.PROVIDER_NAME,
      JSON.serialize(accessToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );

    try {
      Test.startTest();

      pingStaff.getUserInfo(authProviderConfiguration, response);

      Test.stopTest();

      System.assert(false, 'Expected http response error');
    } catch (CalloutException e) {
      System.assert(true);
    }
  }

  /**
   * @description tests CMN_AUTH_PingStaff.refresh method (step 4)
   *
   * @see CMN_AUTH_PingStaff.refresh
   */
  @IsTest
  private static void testRefreshToken() {
    setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    CMN_AuthProviderConfig__mdt config = CMN_DAL_OAuth.readAuthProviderConfig(
      CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF
    );

    Test.startTest();

    Auth.OAuthRefreshResult actualAuthRefreshResult = pingStaff.refresh(
      CMN_SRV_OAuth.authProviderConfigToStringMap(config),
      REFRESH_TOKEN
    );

    CMN_AUTH_PingStaff.DTO_Access actualTokenDto = CMN_AUTH_PingStaff.tokenStringToDto(
      actualAuthRefreshResult.accessToken
    );

    Test.stopTest();

    CMN_AUTH_PingStaff.DTO_Access expectedToken = createMockAccessToken();

    Auth.OAuthRefreshResult expectedAuthRefreshResult = new Auth.OAuthRefreshResult(
      JSON.serialize(expectedToken),
      REFRESH_TOKEN,
      null
    );

    System.assertEquals(
      expectedToken.access_token,
      actualTokenDto.access_token,
      'Expected accessTokens to match'
    );
    System.assertEquals(
      expectedAuthRefreshResult.refreshToken,
      actualAuthRefreshResult.refreshToken,
      'Excepted refreshTokens to match'
    );
    System.assertEquals(
      expectedAuthRefreshResult.error,
      actualAuthRefreshResult.error,
      'Expected errors to match'
    );
  }

  /**
   * @description Tests if exception is thrown when token is invalid
   */
  @IsTest
  private static void validIdToken() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    Map<String, Object> jwtClaims;
    Exception thrownException;

    // Set a mock because the validation will pass and make a web callout
    PingStaffMockHttpUserInfoResponse mockHttpTokenResponse = new PingStaffMockHttpUserInfoResponse();
    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    // Standard config
    Test.startTest();
    jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
    thrownException = getGetUserInfoExceptionForJWTClaims(
      jwtClaims,
      authProviderConfiguration
    );
    Test.stopTest();

    System.assertEquals(
      null,
      thrownException,
      'Unexpected exception was thrown'
    );
  }

  @IsTest
  private static void invalidIdTokenIss() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    Map<String, Object> jwtClaims;
    Exception thrownException;

    // Incorrect ISS
    Test.startTest();
    jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
    jwtClaims.put(
      CMN_AUTH_PingStaff.ISSUER_CLAIM,
      CMN_DAL_SObjectDomain.generateRandomName()
    );
    thrownException = getGetUserInfoExceptionForJWTClaims(
      jwtClaims,
      authProviderConfiguration
    );
    Test.stopTest();

    System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
    System.assertEquals(
      'System.IllegalArgumentException',
      thrownException.getTypeName(),
      'Unexpected Exception Type'
    );
    System.assertEquals(
      CMN_AUTH_PingStaff.ERROR_INVALID_ISSUER,
      thrownException.getMessage(),
      'Unexpected exception was thrown.'
    );
  }

  @IsTest
  private static void testInvalidIdTokenAUD() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    Map<String, Object> jwtClaims;
    Exception thrownException;

    // Incorrect AUD
    Test.startTest();
    jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
    jwtClaims.put(
      CMN_AUTH_PingStaff.AUDIENCE_CLAIM,
      CMN_DAL_SObjectDomain.generateRandomName()
    );
    thrownException = getGetUserInfoExceptionForJWTClaims(
      jwtClaims,
      authProviderConfiguration
    );
    Test.stopTest();

    System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
    System.assertEquals(
      'System.IllegalArgumentException',
      thrownException.getTypeName(),
      'Unexpected Exception Type'
    );
    System.assertEquals(
      CMN_AUTH_PingStaff.ERROR_INVALID_CLIENT_ID,
      thrownException.getMessage(),
      'Unexpected exception was thrown.'
    );
  }

  @IsTest
  private static void testInvalidIdTokenEXP() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
    Map<String, Object> jwtClaims;
    Exception thrownException;

    // Incorrect EXP
    Test.startTest();
    jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
    jwtClaims.put(
      CMN_AUTH_PingStaff.EXPIRES_IN,
      -CMN_DAL_SObjectDomain.generateRandomInteger()
    );
    thrownException = getGetUserInfoExceptionForJWTClaims(
      jwtClaims,
      authProviderConfiguration
    );
    Test.stopTest();

    System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
    System.assertEquals(
      'System.IllegalArgumentException',
      thrownException.getTypeName(),
      'Unexpected Exception Type'
    );
    System.assertEquals(
      CMN_AUTH_PingStaff.ERROR_TOKEN_EXPIRED,
      thrownException.getMessage(),
      'Unexpected exception was thrown:'
    );
  }

  private static Exception getGetUserInfoExceptionForJWTClaims(
    Map<String, Object> jwtClaims,
    Map<String, String> authProviderConfiguration
  ) {
    Exception thrownException;
    try {
      runGetUserInfo(authProviderConfiguration, jwtClaims);
    } catch (Exception e) {
      thrownException = e;
    }
    return thrownException;
  }

  private static void runGetUserInfo(
    Map<String, String> authProviderConfiguration,
    Map<String, Object> jwtClaims
  ) {
    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();
    CMN_AUTH_PingStaff.DTO_Access accessToken = createMockAccessTokenWithIdToken(
      jwtClaims
    );

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
      CMN_AUTH_PingStaff.PROVIDER_NAME,
      JSON.serialize(accessToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );

    pingStaff.getUserInfo(authProviderConfiguration, response);
  }

  /**
   * @description tests negative get refresh http response scenario
   */
  @IsTest
  private static void testRefreshTokenNegative() {
    setupAuthProviderConfig();

    CMN_AUTH_PingStaff pingStaff = new CMN_AUTH_PingStaff();

    Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());

    CMN_AuthProviderConfig__mdt config = CMN_DAL_OAuth.readAuthProviderConfig(
      CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF
    );

    Auth.OAuthRefreshResult returned = pingStaff.refresh(
      CMN_SRV_OAuth.authProviderConfigToStringMap(config),
      REFRESH_TOKEN
    );

    System.assertNotEquals(
      returned.error,
      null,
      'Expected http response error'
    );
  }

  /**
   * @description mocks the token access response returned by ping
   *
   * @see CMN_AUTH_PingStaff_TEST.testHandleCallback
   */
  public class PingStaffMockHttpTokenResponse implements HttpCalloutMock {
    private String responseBody;

    /**
     * @description Class constructure which will setup the response body
     */
    public PingStaffMockHttpTokenResponse() {
      this.responseBody = createResponseBody();
    }

    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();

      response.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_JSON
      );

      response.setBody(this.responseBody);
      response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

      return response;
    }

    private String createResponseBody() {
      CMN_AUTH_PingStaff.DTO_Access accessToken = createMockAccessToken();

      return JSON.serialize(accessToken);
    }
  }

  /**
   * @description creates and returns mocked access token for unit tests
   *
   * @return mocked access token
   */
  public static CMN_AUTH_PingStaff.DTO_Access createMockAccessToken() {
    CMN_AUTH_PingStaff.DTO_Access accessToken = new CMN_AUTH_PingStaff.DTO_Access();

    accessToken.access_token = ACCESS_TOKEN;
    accessToken.refresh_token = REFRESH_TOKEN;
    accessToken.id_token = ID_TOKEN;
    accessToken.token_type = CMN_AUTH_PingStaff.TOKEN_TYPE_BEARER;
    accessToken.expires_in = EXPIRES_IN_VALUE;
    accessToken.expires = null;

    return accessToken;
  }

  public static CMN_AUTH_PingStaff.DTO_Access createMockAccessTokenWithIdToken(
    Map<String, Object> jwtClaims
  ) {
    Auth.JWT idtokenpayload = new Auth.JWT();
    idtokenpayload.setIss(
      (String) jwtClaims.get(CMN_AUTH_PingStaff.ISSUER_CLAIM)
    );
    idtokenpayload.setAud(
      (String) jwtClaims.get(CMN_AUTH_PingStaff.AUDIENCE_CLAIM)
    );
    idtokenpayload.setValidityLength(
      (Integer) jwtClaims.get(CMN_AUTH_PingStaff.EXPIRES_IN)
    );
    String idtoken = EncodingUtil.base64Encode(
        Blob.valueOf(idtokenpayload.toJSONString())
      )
      .replaceAll('=', '');

    CMN_AUTH_PingStaff.DTO_Access accessToken = createMockAccessToken();
    accessToken.id_token = 'test.' + idtoken + '.test';
    return accessToken;
  }

  /**
   * @description mocks the user info response returned by ping
   *
   * @see CMN_AUTH_PingStaff_TEST.testGetUserInfo
   */
  public class PingStaffMockHttpUserInfoResponse implements HttpCalloutMock {
    private String responseBody;

    public PingStaffMockHttpUserInfoResponse() {
      this.responseBody = createResponseBody();
    }

    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();

      response.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_JSON
      );

      response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

      response.setBody(this.responseBody);

      return response;
    }

    private String createResponseBody() {
      CMN_AUTH_PingStaff.DTO_UserInfo userInfo = new CMN_AUTH_PingStaff.DTO_UserInfo();

      userInfo.sub = ENTERPRISE_EMAIL;
      userInfo.employee_number = EMPLOYEE_NUMBER;
      userInfo.iat = ISSUED_AT_CLAIM_VALUE;
      userInfo.nbf = NOT_BEFORE_CLAIM_VALUE;

      return JSON.serialize(userInfo);
    }
  }

  /**
   * @description mocks a bad response returned by ping for negative testing
   *
   * @see CMN_AUTH_PingStaff
   */
  public class PingStaffMockHttpBadResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();

      response.setStatusCode(CMN_API_HttpBase.HTTP_BAD_REQUEST);

      response.setBody('Bad Request');

      return response;
    }
  }
}