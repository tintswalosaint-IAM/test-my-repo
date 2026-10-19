/**
 * @description Contains selector methods for ping oauth sobjects
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_SRV_OAuth
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date November 2020
 */
public inherited sharing class CMN_DAL_OAuth {
  /* OAuth records retrieval limit sizes */
  public final static Integer SIZE_LIMIT_DEFAULT = 1000;
  public final static Integer SIZE_LIMIT_SINGLE = 1;

  /* developer name of auth provider for ping staff */
  public final static String CONFIG_NAME_PING_STAFF = 'pingstaff';

  /* developer name is key for reoccurring calls in sames context keep a temporary copy of config available to reduce I/O */
  private static Map<String, CMN_AuthProviderConfig__mdt> authProviderConfigMap = new Map<String, CMN_AuthProviderConfig__mdt>();
  private static Map<String, AuthProvider> authProviderMap = new Map<String, AuthProvider>();

  /**
   * @description read verifier by correction key
   *
   * @param correlationKey as input
   *
   * @return single record
   */
  public static CMN_OAuth__c readCodeVerifierByKey(String correlationKey) {
    List<CMN_OAuth__c> records = readCodeVerifiersByKeys(
      new Set<String>{ correlationKey },
      SIZE_LIMIT_SINGLE
    );

    return records.isEmpty() ? null : records.iterator().next();
  }

  /**
   * @description reads verifiers by correction keys
   *
   * @param correlationKeys as input
   * @param sizeLimit as input
   *
   * @return List of oauth records
   */
  public static List<CMN_OAuth__c> readCodeVerifiersByKeys(
    Set<String> correlationKeys,
    Integer sizeLimit
  ) {
    return [
      SELECT Id, CMN_CodeVerifierKey__c, CMN_CodeVerifier__c
      FROM CMN_OAuth__c
      WHERE CMN_CodeVerifierKey__c IN :correlationKeys
      LIMIT :sizeLimit
    ];
  }

  /**
   * @description override method for readCodeVerifiersByKeys
   *
   * @param correlationKeys as input
   *
   * @return List of oauth records
   */
  public static List<CMN_OAuth__c> readCodeVerifiersByKeys(
    Set<String> correlationKeys
  ) {
    return readCodeVerifiersByKeys(correlationKeys, SIZE_LIMIT_DEFAULT);
  }

  /**
   * @description retrieve plugin configuration
   *
   * @param provider as input
   *
   * @return CMN_AuthProviderConfig__mdt config record by provider name
   */
  public static CMN_AuthProviderConfig__mdt readAuthProviderConfig(
    String provider
  ) {
    CMN_AuthProviderConfig__mdt config = authProviderConfigMap.get(provider);

    if (config == null) {
      List<CMN_AuthProviderConfig__mdt> returned = [
        SELECT
          Id,
          DeveloperName,
          CMN_UserInfoUrl__c,
          CMN_AccessTokenUrl__c,
          CMN_AuthUrl__c,
          CMN_ClientId__c,
          CMN_RedirectUrl__c,
          CMN_Scope__c
        FROM CMN_AuthProviderConfig__mdt
        WHERE DeveloperName = :provider
      ];

      config = returned.isEmpty() ? null : returned.iterator().next();
      authProviderConfigMap.put(provider, config);
    }

    return config;
  }

  /**
   * @description query the auth provider by provider name
   *
   * @param providerDeveloperName as input
   *
   * @return auth provider if found
   */
  public static AuthProvider readAuthProviderByName(
    String providerDeveloperName
  ) {
    AuthProvider provider = authProviderMap.get(providerDeveloperName);

    if (provider == null) {
      List<AuthProvider> returned = [
        SELECT
          Id,
          ConsumerKey,
          ConsumerSecret,
          CustomMetadataTypeRecord,
          DeveloperName,
          AuthorizeUrl,
          DefaultScopes,
          ErrorUrl,
          ExecutionUserId,
          FriendlyName,
          IdTokenIssuer,
          LinkKickoffUrl,
          OauthKickoffUrl,
          PluginId,
          ProviderType,
          RegistrationHandlerId,
          TokenUrl,
          UserInfoUrl
        FROM AuthProvider
        WHERE DeveloperName = :providerDeveloperName
      ];
      provider = returned.isEmpty() ? null : returned.iterator().next();
      authProviderMap.put(providerDeveloperName, provider);
    }

    return provider;
  }
}