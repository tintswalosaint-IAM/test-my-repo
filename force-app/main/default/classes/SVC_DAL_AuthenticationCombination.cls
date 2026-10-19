/**
 * @description Provides Query methods related to Authentication Combination object
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class SVC_DAL_AuthenticationCombination
{
	public static final Integer MAX_AUTHENTICATION_LEVEL = 3;
	public static final Integer MIN_AUTHENTICATION_LEVEL = 1;
	public static final String AUTH_LEVEL1 = '1';
	public static final String AUTH_LEVEL2 = '2';
	public static final String AUTH_LEVEL3 = '3';
	public static final String FIVE_POINT_SECURITY_QUESTIONS = '5 points security questions';
	public static final String NIUSSD = 'NIUSSD';
	public static final String OTP = 'OTP';
	public static final String STRONG_AUTH = 'Strong Auth';
	public static final String VOICE_BIOMETRICS = 'Voice Biometrics';
	public static final String XDS = 'XDS';

	/**
	 * @description Will retrieve an authentication methods using authentication level
	 *
	 * @param authenticationLevel An Authentication Level
	 *
	 * @return Either Item found or null
	 */
	public static List<SVC_AuthenticationCombination__c> findByAuthLevel(String authenticationLevel)
	{
		return
		[
				SELECT SVC_AuthenticationMethod__c
				FROM SVC_AuthenticationCombination__c
				WHERE Authentication_Level__c INCLUDES (:authenticationLevel)
		];
	}

	/**
	 * @description Will retrieve an authentication level using authentication method
	 *
	 * @param authenticationMethod An Authentication Method
	 *
	 * @return Either Item found or null
	 */
	public static SVC_AuthenticationCombination__c findByAuthMethod(String authenticationMethod)
	{
		List<SVC_AuthenticationCombination__c> authenticationCombinations =
		[
				SELECT Authentication_Level__c
				FROM SVC_AuthenticationCombination__c
				WHERE SVC_AuthenticationMethod__c INCLUDES (:authenticationMethod)
		];

		return authenticationCombinations.isEmpty() ? null : authenticationCombinations.iterator().next();
	}
}