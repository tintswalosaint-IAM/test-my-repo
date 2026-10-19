/**
 * @description API and DTO to facilitate the callout to Remove Soft Block
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class SVC_API_RemoveSoftBlock extends SVC_API_SoftBlockBase
{
	@TestVisible
	private static final String SERVICE_NAME = SVC_API_RemoveSoftBlock.class.getName();

	/**
	 * @description Name of your service to be used when looking up custom settings for you service
	 *
	 * @return the service name
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override the HTTP verb to use
	 *
	 * @return HTTP Verb
	 */
	protected override String getVerb()
	{
		return HTTP_VERB_PUT;
	}
}