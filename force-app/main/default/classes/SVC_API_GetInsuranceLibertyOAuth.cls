/**
 * @description Outbound Service class to retrieve an OAuth Token for Libery Insurance products
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
public inherited sharing class SVC_API_GetInsuranceLibertyOAuth extends SVC_API_GetInsuranceOAuthTokenBase
{
	public static final String SERVICE_NAME = SVC_API_GetInsuranceLibertyOAuth.class.getName();

	/**
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}
}