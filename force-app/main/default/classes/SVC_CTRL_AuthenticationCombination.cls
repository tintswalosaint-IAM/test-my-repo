/**
 * @description Controller class for the SVC LWC Authentication Combination component
 *
 * @see SVC_CTRL_AuthenticationCombination_TEST
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class SVC_CTRL_AuthenticationCombination
{
	/**
	 * @description Will find all authentication methods against the authentication level
	 *
	 * @param authenticationLevel The String of the authentication level
	 *
	 * @return List of Authentication Methods
	 */
	@AuraEnabled(Cacheable = true)
	public static List<SVC_AuthenticationCombination__c> getAuthenticationMethods(String authenticationLevel)
	{
		return SVC_DAL_AuthenticationCombination.findByAuthLevel(authenticationLevel);
	}

	/**
	 * @description Will find an authentication level against the authentication method
	 *
	 * @param authenticationMethod The String of the authentication method
	 *
	 * @return An Authentication Level
	 */
	@AuraEnabled(Cacheable = true)
	public static SVC_AuthenticationCombination__c getAuthenticationLevel(String authenticationMethod)
	{
		return SVC_DAL_AuthenticationCombination.findByAuthMethod(authenticationMethod);
	}
}