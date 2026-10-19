/**
 * @description Apex Rest point for upserting a LiveChatTranscript and LiveChatVisitor
 *
 * @see SVC_API_UpsertLiveChatTranscript VCCC-306-->VCCC-440
 * @see SVC_API_UpsertLiveChatTranscript_TEST
 *
 * @author Accenture
 *
 * @date 2020
 */
@RestResource(UrlMapping='/v1/AWSLiveChatTranscript/*')
global inherited sharing class SVC_URL_LiveChatTranscript
{
	/**
	 * @description Will create or update an existing Chat Transcript
	 * if case does not already exist for the Chat Transcript it will create case automatically
	 */
	@HttpPost
	global static void upsertLiveChat()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(SVC_API_UpsertLiveChatTranscript.SERVICE_NAME);
	}

	/**
	 * @description Will retrieve existing Chat Transcript records
	 */
	@HttpGet
	global static void retrieveLiveChat()
	{
		CMN_FACTORY_WebserviceManager.processInboundService(SVC_API_GetLiveChatTranscript.SERVICE_NAME);
	}
}