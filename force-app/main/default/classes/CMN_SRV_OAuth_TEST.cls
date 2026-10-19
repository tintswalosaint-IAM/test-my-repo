/**
 * @description Test the CMN_SRV_OAuth methods
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_SRV_OAuth
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date January 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_SRV_OAuth_TEST
{
	@IsTest
	private static void publishCodeVerifierInsert()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		String codeVerifier = CMN_UTIL_OAuth.generateRandomCode();
		String codeVerifierKey = CMN_UTIL_OAuth.generateHash(CMN_DAL_SObjectDomain.generateRandomName());

		CMN_SRV_OAuth.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

		Test.stopTest();

		CMN_OAuth__c returned = CMN_DAL_OAuth.readCodeVerifierByKey(codeVerifierKey);
		System.assert(returned != null, 'expected CMN_OAuth__c record to be published');
		System.assertEquals(codeVerifierKey, returned.CMN_CodeVerifierKey__c, 'expected codeVerifierKeys to match');
		System.assertEquals(codeVerifier, returned.CMN_CodeVerifier__c, 'expected codeVerifiers to match');

		String compareCodeVerifier = CMN_SRV_OAuth.retrieveCodeVerifier(returned.CMN_CodeVerifierKey__c);
		System.assertEquals(codeVerifier, compareCodeVerifier, 'expected codeVerifiers to match');
	}

	@IsTest
	private static void publishCodeVerifierInsertNegative()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = false;

		String codeVerifier = CMN_UTIL_OAuth.generateRandomCode();
		String codeVerifierKey = CMN_UTIL_OAuth.generateHash(CMN_DAL_SObjectDomain.generateRandomName());

		CMN_SRV_OAuth.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

		Test.stopTest();

		CMN_OAuth__c returned = CMN_DAL_OAuth.readCodeVerifierByKey(codeVerifierKey);
		System.assert(returned == null, 'expected CMN_OAuth__c record to be null');
	}

	@IsTest
	private static void publishCodeVerifierDelete()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		String codeVerifier = CMN_UTIL_OAuth.generateRandomCode();
		String codeVerifierKey = CMN_UTIL_OAuth.generateHash(CMN_DAL_SObjectDomain.generateRandomName());

		CMN_SRV_OAuth.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

		CMN_SRV_OAuth.publishCodeVerifierDelete(codeVerifierKey);

		Test.stopTest();

		CMN_OAuth__c returned = CMN_DAL_OAuth.readCodeVerifierByKey(codeVerifierKey);
		System.assert(returned == null, 'expected CMN_OAuth__c record to be deleted');
	}

	@IsTest
	private static void getUserAccessToken()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = false;

		String token = CMN_SRV_OAuth.getUserAccessToken(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);

		Test.stopTest();

		System.assert(token != null, 'expected a mock token to be returned');
	}

	@IsTest
	private static void refreshUserAccessToken()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = false;

		String token = CMN_SRV_OAuth.refreshUserAccessToken(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);

		Test.stopTest();

		System.assert(token != null, 'expected a mock refresh token to be returned');
	}

	@IsTest
	private static void refreshUserAccessTokenNegative()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		try
		{
			CMN_SRV_OAuth.refreshUserAccessToken(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);
			System.assert(false, 'expected a exception to be thrown');

		}
		catch(Exception e)
		{
			System.assert(true);
		}

		Test.stopTest();
	}

	@IsTest
	private static void logEventErrorsNegative()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		Account invalidEvent = new Account();

		List<Database.Error> errors = CMN_SRV_OAuth.publishOAuthEvent(invalidEvent);

		Test.stopTest();

		System.assert(errors.size() == 1, 'expected an error to be returned for invalid event sobject');
	}

	@IsTest
	private static void authProviderConfigToStringMap()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = false;

		CMN_AuthProviderConfig__mdt config = CMN_DAL_OAuth.readAuthProviderConfig(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);

		Map <String, String> configMap = CMN_SRV_OAuth.authProviderConfigToStringMap(config);

		Test.stopTest();

		System.assert(configMap != null, 'expected a configMap');
	}

	@IsTest
	private static void retrieveCodeVerifierMock()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = false;

		String random = CMN_SRV_OAuth.retrieveCodeVerifier(CMN_DAL_SObjectDomain.generateRandomName());

		Test.stopTest();

		System.assert(random != null, 'expected a mock random value to be returned');
	}

	@IsTest
	private static void getAccessTokenNegative()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		AuthProvider provider = CMN_DAL_OAuth.readAuthProviderByName(CMN_AUTH_PingStaff.PROVIDER_NAME);

		try
		{
			CMN_SRV_OAuth.getAccessToken(provider);
			System.assert(false, 'expected a exception to be thrown');

		}
		catch(Exception e)
		{
			System.assert(true);
		}

		Test.stopTest();
	}

	@IsTest
	private static void getRefreshAccessTokenNegative()
	{
		Test.startTest();

		CMN_SRV_OAuth.ignoreTestMode = true;

		AuthProvider provider = CMN_DAL_OAuth.readAuthProviderByName(CMN_AUTH_PingStaff.PROVIDER_NAME);

		try
		{
			CMN_SRV_OAuth.getRefreshAccessToken(provider, CMN_DAL_SObjectDomain.generateRandomName());
			System.assert(false, 'expected a exception to be thrown');

		}
		catch(Exception e)
		{
			System.assert(true);
		}

		Test.stopTest();
	}

}