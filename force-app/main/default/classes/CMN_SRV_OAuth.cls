/**
 * @description Contains crud methods for ping oauth sobjects
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date November 2020
 */
public inherited sharing class CMN_SRV_OAuth
{
	/* event state types (used in oauth associated platform events) */
	public final static String EVENT_TYPE_CODE_VERIFIER_INSERT = 'CodeVerifierInsert';
	public final static String EVENT_TYPE_CODE_VERIFIER_DELETE = 'CodeVerifierDelete';

	/* refresh token map key fields */
	public final static String REFRESH_ERROR = 'RefreshError';
	public final static String ACCESS_TOKEN = 'AccessToken';

	/**
	 * @description When test is running, event will not be published unless ignoreTestMode is set to true
	 */
	@TestVisible
	private static Boolean ignoreTestMode = false;

	/**
	 * @description Set this to indicate that we are in mocking mode, will ensure a mocked token is returned
	 */
	public static Boolean mocking = false;

	/**
	 * @description insert oauth records
	 *
	 * @param records as input
	 */
	public static void deleteCodeVerifierOAuths(List<CMN_OAuth__c> records)
	{
		Set <String> codeVerifierKeys = new Set <String>();

		for(CMN_OAuth__c record : records)
		{
			codeVerifierKeys.add(record.CMN_CodeVerifierKey__c);
		}

		delete CMN_DAL_OAuth.readCodeVerifiersByKeys(codeVerifierKeys);
	}

	/**
	 * @description insert oauth records
	 *
	 * @param records as input
	 */
	public static void insertCodeVerifierOAuths(List<CMN_OAuth__c> records)
	{
		insert records;
	}

	/**
	 * @description extract the verifier code and clean up cache and database entry as well so no transient security details remain.
	 * Retrieve correlated code verifier to send to auth provider so it can do the same hash check
	 *
	 * @param codeVerifierKey or state to propagate as input
	 *
	 * @return the extract verifier code (one time use only)
	 */
	public static String retrieveCodeVerifier(String codeVerifierKey)
	{
		/* return a dummy response for multi event testing where the value is not important see CMN_AUTH_PingStaff_TEST.testHandleCallback */
		if(!ignoreTestMode && Test.isRunningTest())
		{
			return CMN_DAL_SObjectDomain.generateRandomName();
		}

		CMN_OAuth__c returned = CMN_DAL_OAuth.readCodeVerifierByKey(codeVerifierKey);
		return returned.CMN_CodeVerifier__c;
	}

	/**
	 * @description insert and publish pkce verifier code
	 *
	 * @param codeVerifierKey as input
	 * @param codeVerifier as input
	 */
	public static void publishCodeVerifierInsert(String codeVerifierKey, String codeVerifier)
	{
		CMN_OAuthEvent__e event = new CMN_OAuthEvent__e();

		event.CMN_EventType__c = EVENT_TYPE_CODE_VERIFIER_INSERT;
		event.CMN_CodeVerifier__c = codeVerifier;
		event.CMN_CodeVerifierKey__c = codeVerifierKey;

		publishOAuthEvent(event);
	}

	/**
	 * @description delete pkce verifier code
	 *
	 * @param codeVerifierKey as input (only require the key)
	 */
	public static void publishCodeVerifierDelete(String codeVerifierKey)
	{
		CMN_OAuthEvent__e event = new CMN_OAuthEvent__e();

		event.CMN_EventType__c = EVENT_TYPE_CODE_VERIFIER_DELETE;
		event.CMN_CodeVerifierKey__c = codeVerifierKey;

		/* temporary code verifier records and cache will be cleaned up in the deleteCodeVerifierOAuths method */
		publishOAuthEvent(event);
	}

	/**
	 * @description get access oauth access token for the current user
	 *
	 * @param providerDeveloperName as input e.g. pingstaff URL_Suffix
	 *
	 * @return access to the token
	 */
	public static String getUserAccessToken(String providerDeveloperName)
	{
		AuthProvider provider = CMN_DAL_OAuth.readAuthProviderByName(providerDeveloperName);

		String token = getAccessToken(provider);

		if(String.isNotBlank(token))
		{
			CMN_AUTH_PingStaff.DTO_Access tokenDto = CMN_AUTH_PingStaff.tokenStringToDto(token);

			/* check if current user token has expired against current system timestamp if so refresh token */
			if(tokenDto.expires <= System.currentTimeMillis())
			{
				token = refreshUserAccessToken(providerDeveloperName);
				tokenDto = CMN_AUTH_PingStaff.tokenStringToDto(token);
			}

			token = tokenDto.access_token;
		}

		return token;
	}

	/**
	 * @description returns random token if test or user access token based on provider
	 *
	 * @param provider as input
	 *
	 * @return random if test or user access token
	 */
	@TestVisible
	private static String getAccessToken(AuthProvider provider)
	{
		if(mocking || (!ignoreTestMode && Test.isRunningTest()))
		{
			return JSON.serialize(createMockAccessToken());
		}

		return Auth.AuthToken.getAccessToken(provider.Id, provider.FriendlyName);
	}

	/**
	 * @description creates and returns mocked access token for unit tests
	 *
	 * @return mocked access token
	 */
	public static CMN_AUTH_PingStaff.DTO_Access createMockAccessToken()
	{
		CMN_AUTH_PingStaff.DTO_Access accessToken = new CMN_AUTH_PingStaff.DTO_Access();

		accessToken.access_token = CMN_DAL_SObjectDomain.generateRandomName();
		accessToken.refresh_token = CMN_DAL_SObjectDomain.generateRandomName();
		accessToken.id_token = CMN_DAL_SObjectDomain.generateRandomName();
		accessToken.token_type = CMN_AUTH_PingStaff.TOKEN_TYPE_BEARER;
		accessToken.expires_in = 1000;
		accessToken.expires = 0;

		return accessToken;
	}

	/**
	 * @description refresh access token for the current user. The old access token is a key so needs to be the full
	 * dto of the original token to look it up.
	 *
	 * @param providerDeveloperName as input e.g. pingstaff URL_Suffix
	 *
	 * @return refreshed access token
	 */
	@TestVisible
	private static String refreshUserAccessToken(String providerDeveloperName)
	{
		AuthProvider provider = CMN_DAL_OAuth.readAuthProviderByName(providerDeveloperName);

		String oldAccessToken = getAccessToken(provider);

		Map <String, String> accessTokenMap = getRefreshAccessToken(provider, oldAccessToken);

		String refreshError = accessTokenMap.get(REFRESH_ERROR);

		if(refreshError == null)
		{
			return accessTokenMap.get(ACCESS_TOKEN);
		}

		throw new IllegalArgumentException('Invalid user access token refresh error: ' + refreshError);
	}

	/**
	 * @description returns random refresh token if test or user refreshed token based on provider
	 *
	 * @param provider as input
	 * @param oldAccessToken as input
	 *
	 * @return random if test or user access refresh token
	 */
	@TestVisible
	private static Map <String, String> getRefreshAccessToken(AuthProvider provider, String oldAccessToken)
	{
		if(mocking || (!ignoreTestMode && Test.isRunningTest()))
		{
			return createMockRefreshToken();
		}

		return Auth.AuthToken.refreshAccessToken(provider.Id, provider.FriendlyName, oldAccessToken);
	}

	/**
	 * @description creates a mock refresh token for testing
	 *
	 * @return map based on api assuming happy path
	 */
	private static Map <String, String> createMockRefreshToken()
	{
		Map <String, String> returned = new Map<String, String>();

		returned.put(REFRESH_ERROR, null);
		returned.put(ACCESS_TOKEN, JSON.serialize(createMockAccessToken ()));

		return returned;
	}

	/**
	 * @description convert config to map per the AuthProviderPluginClass method definition
	 *
	 * @param config as input
	 *
	 * @return config map of key value pairs
	 */
	public static Map <String, String> authProviderConfigToStringMap(CMN_AuthProviderConfig__mdt config)
	{
		Map <String, String> returned = new Map<String, String>();

		returned.put(CMN_AUTH_PingStaff.FIELD_CLIENT_ID, config.CMN_ClientId__c);
		returned.put(CMN_AUTH_PingStaff.FIELD_AUTH_URL, config.CMN_AuthUrl__c);
		returned.put(CMN_AUTH_PingStaff.FIELD_ACCESS_TOKEN_URL, config.CMN_AccessTokenUrl__c);
		returned.put(CMN_AUTH_PingStaff.FIELD_SCOPE, config.CMN_Scope__c);
		returned.put(CMN_AUTH_PingStaff.FIELD_REDIRECT_URL, config.CMN_RedirectUrl__c);
		returned.put(CMN_AUTH_PingStaff.FIELD_USERINFO_URL, config.CMN_UserInfoUrl__c);

		return returned;
	}

	/**
	 * @description publish oauth event CMN_OAuthEvent__e
	 *
	 * @param event as input
	 *
	 * @return list or errors
	 */
	@TestVisible
	private static List<Database.Error> publishOAuthEvent(SObject event)
	{
		/* don't publish event during unit tests unless ignoreTestMode is true */
		if(!ignoreTestMode && Test.isRunningTest())
		{
			return null;
		}

		Database.SaveResult saveResult = EventBus.publish(event);

		if(!saveResult.isSuccess())
		{
			for(Database.Error error : saveResult.getErrors())
			{
				CMN_UTIL_Logger.error('Error returned: ' + error.getStatusCode() + ' - ' + error.getMessage(), 'CMN_SRV_OAuth.publishEvent');
			}

			return saveResult.getErrors();
		}

		return null;
	}
}