/**
 * @description Inbound Apex Rest handler which will process requests related to retrieving LiveChatTranscript
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class SVC_API_GetLiveChatTranscript extends CMN_API_RestBaseInbound
{
	@TestVisible
	private static final String CASE_NOT_FOUND = 'Case record not found.';
	@TestVisible
	private static final String CHAT_TRANSCRIPT_NOT_FOUND = 'No chat transcript found.';

	@TestVisible
	private static final String QUERY_PARAM_CONTACT_ID = 'contactId';
	@TestVisible
	private static final String ERROR_PARAM_NO_VALUE = 'Did not receive a value for query parameter: "' + QUERY_PARAM_CONTACT_ID + '"';

	public static final String SERVICE_NAME = SVC_API_GetLiveChatTranscript.class.getName();

	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Will review the query params, and the execute a query
	 */
	protected override void processRequest()
	{
		super.processRequest();

		DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;

		String contactId = request.params.get(QUERY_PARAM_CONTACT_ID);

		if(String.isBlank(contactId))
		{
			throw new SearchException(ERROR_PARAM_NO_VALUE);
		}

		Case foundCase = SVC_DAL_Case.findByAmazonConnectContactId(contactId);

		if(foundCase == null)
		{
			throw new SearchException(CASE_NOT_FOUND);
		}

		LiveChatTranscript foundTranscript = SVC_DAL_LiveChatTranscript.findLiveChatTranscriptByCaseId(foundCase.Id);

		if(foundTranscript == null)
		{
			throw new SearchException(CHAT_TRANSCRIPT_NOT_FOUND);
		}

		dtoResponse.populate(foundTranscript);
	}

	/**
	 * @description Response DTO which contains a list of found LiveChatTranscripts
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public String id;
		public String chatTranscript;

		/**
		 * @description Populate DTO with informationo from a transcript
		 *
		 * @param foundTranscript A live chat transcript
		 */
		public void populate(LiveChatTranscript foundTranscript)
		{
			id = foundTranscript.Id;
			chatTranscript = foundTranscript.Body;
		}
	}
}