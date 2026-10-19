/**
 * @description Base Rest outbound handler for Insurance API's, since these API's can make use of multiple
 * OAuth access token endpoints based on product, descendants of this class must indicate which policy they
 * are dealing with for a particular callout
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing abstract class SVC_API_InsuranceBase extends SVC_API_OAuthOutboundBase
{
	private static final Integer POLICY_NUMBER_PREFIX_LENGTH = 3;

	/**
	 * @description Used to match OAuth Service based on Policy Number prefix
	 */
	public static final Map<String, String> POLICY_NUMBER_PREFIX_OAUTH_HANDLER_MAP = new Map<String, String>
	{
			'SIL' => SVC_API_GetInsuranceDirectOAuth.SERVICE_NAME,
			'FNL' => SVC_API_GetInsuranceFlexiOAuth.SERVICE_NAME,
			'FNR' => SVC_API_GetInsuranceFlexiOAuth.SERVICE_NAME,
			'FUN' => SVC_API_GetInsuranceFlexiOAuth.SERVICE_NAME,
			'SHL' => SVC_API_GetInsuranceLibertyOAuth.SERVICE_NAME,
			'SHS' => SVC_API_GetInsuranceLibertyOAuth.SERVICE_NAME,
			'STB' => SVC_API_GetInsuranceLibertyOAuth.SERVICE_NAME,
			'STH' => SVC_API_GetInsuranceLibertyOAuth.SERVICE_NAME
	};

	/**
	 * @description Must be implemented by descendant classes and should return the policy number for the policy current being processed
	 *
	 * @return Policy number
	 */
	protected abstract String getPolicyNumber();

	/**
	 * @description Will provide the webservice name for the handler that should get the access token
	 *
	 * @return The name of the handler
	 */
	protected virtual override String getOauthServiceName()
	{
		String policyPrefix = CMN_UTIL_String.upperCase(CMN_UTIL_String.substring(getPolicyNumber(), 0, POLICY_NUMBER_PREFIX_LENGTH));
		String serviceName = POLICY_NUMBER_PREFIX_OAUTH_HANDLER_MAP.get(policyPrefix);
		return String.isBlank(serviceName) ? SVC_API_GetInsuranceDirectOAuth.SERVICE_NAME : serviceName;
	}
}