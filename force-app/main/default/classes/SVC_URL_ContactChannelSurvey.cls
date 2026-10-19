/**
 * @description Apex Rest point for upserting a survey
 * VCCC-2011
 *
 * @author Accenture
 *
 * @date 2021
 */
@RestResource(UrlMapping='/v1/ContactChannelSurvey/*')
global inherited sharing class SVC_URL_ContactChannelSurvey
{
	/**
	 * @description Will create or update an existing survey
	 */
	@HttpPost
	global static void upsertSurvey()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(SVC_API_UpsertContactChannelSurvey.SERVICE_NAME);
	}
}