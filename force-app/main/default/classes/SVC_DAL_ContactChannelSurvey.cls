/**
 * @description Various Queries related ContactChannelSurvey
 *
 * @author Accenture
 *
 * @date 2021
 */
public inherited sharing class SVC_DAL_ContactChannelSurvey
{
	public static final String OBJECT_NAME = SVC_ContactChannelSurvey__c.SObjectType.getDescribe().getLocalName();
	private static final String CONTACT_CHANNEL_ID = SVC_ContactChannelSurvey__c.SVC_ACContactChannel__c.getDescribe().getLocalName();

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Case fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				SVC_ContactChannelSurvey__c.Id.getDescribe().getLocalName(),
				SVC_ContactChannelSurvey__c.Name.getDescribe().getLocalName(),
				SVC_ContactChannelSurvey__c.OwnerId.getDescribe().getLocalName(),
				CONTACT_CHANNEL_ID,
				SVC_ContactChannelSurvey__c.SVC_AchievedPurpose__c.getDescribe().getLocalName(),
				SVC_ContactChannelSurvey__c.SVC_AgentRating__c.getDescribe().getLocalName(),
				SVC_ContactChannelSurvey__c.SVC_NetPromoterScoreRating__c.getDescribe().getLocalName(),
				SVC_ContactChannelSurvey__c.SVC_SurveyComplete__c.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will find all SVC_DAL_ContactChannelSurvey's  related to a given Case
	 *
	 * @param contactChannelId The Id of the Case that should be matched on the SVC_DAL_ContactChannelSurvey's standard caseId field
	 *
	 * @return Null of Contact Channel Survey Object
	 */
	public static SVC_ContactChannelSurvey__c findSurveyResponseByContactChannelId(Id contactChannelId)
	{
		return (SVC_ContactChannelSurvey__c)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, CONTACT_CHANNEL_ID, contactChannelId, getDefaultFields(), true);
	}

	/**
	 * @description Will return all the SVC_ContactChannelSurvey__c objects in the system
	 *
	 * @return A list of SVC_ContactChannelSurvey__c objects
	 */
	@TestVisible
	private static List<SVC_ContactChannelSurvey__c> getAll()
	{
		return CMN_DAL_Search.getAll(SVC_ContactChannelSurvey__c.SObjectType, getDefaultFields());
	}
}