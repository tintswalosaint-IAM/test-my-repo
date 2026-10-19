/**
 * @description Various Queries related LiveChatTranscript
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class SVC_DAL_LiveChatTranscript
{
	private static final String FIELD_CASE_ID = LiveChatTranscript.CaseId.getDescribe().getLocalName();
	public static final String OBJECT_NAME = LiveChatTranscript.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Case fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				LiveChatTranscript.AccountId.getDescribe().getLocalName(),
				FIELD_CASE_ID,
				LiveChatTranscript.ContactId.getDescribe().getLocalName(),
				LiveChatTranscript.Body.getDescribe().getLocalName(),
				LiveChatTranscript.LiveChatVisitorId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find all LiveChatTranscript  related to a given Case
	 *
	 * @param caseId The Id of the Case that should be matched on the LiveChatTranscript's standard caseId field
	 *
	 * @return Found LiveChatTranscript
	 */
	public static LiveChatTranscript findLiveChatTranscriptByCaseId(Id caseId)
	{
		return (LiveChatTranscript)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_CASE_ID, caseId, getDefaultFields(), true);
	}

	/**
	 * @description Will return all the LiveChatTranscript objects in the system
	 *
	 * @return A list of LiveChatTranscript objects
	 */
	@TestVisible
	private static List<LiveChatTranscript> getAll()
	{
		return CMN_DAL_Search.getAll(LiveChatTranscript.SObjectType, getDefaultFields());
	}
}