/**
 * @description Base Rest outbound handler for API Gateway, to do common processing; for example required headers
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing virtual class SVC_API_RestOutboundBase extends CMN_API_RestBaseOutbound
{
	private static final String HTTP_HEADER_FAPI_INTERACTION_ID = 'x-fapi-interaction-id';

	/**
	 * @description Override the setting of the headers to include 'x-fapi-interaction-id'
	 */
	protected override virtual void setHeaders()
	{
		super.setHeaders();

		request.setHeader(HTTP_HEADER_FAPI_INTERACTION_ID, CMN_UTIL_Random.randomUUID());
	}
}