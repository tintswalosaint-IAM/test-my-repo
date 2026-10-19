/**
 * @description Base Rest outbound handler for Ping Authenticated API Handlers
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing virtual class SVC_API_PingOutboundBase extends SVC_API_RestOutboundBase
{
	/**
	 * @description Will return the pingstaff authorisation token (if it exists)
	 *
	 * @return Authorisation Header value
	 *
	 * @see CMN_SRV_OAuth.getUserAccessToken
	 */
	protected override String getAuthorisationToken()
	{
		//This ensures that we retrieve a mock token if we are in mocking mode
		CMN_SRV_OAuth.mocking = isMocking();

		String pingAuthCode = CMN_SRV_OAuth.getUserAccessToken(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);
		CMN_UTIL_Logger.info('Ping Auth Token: ' + pingAuthCode, getServiceName() + '/getAuthorisationToken');
		return String.isBlank(pingAuthCode) ? null : HTTP_AUTH_TOKEN_BEARER + pingAuthCode;
	}
}