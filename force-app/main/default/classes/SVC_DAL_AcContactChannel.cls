/**
 * @description Provides Query methods related to AC Contact Channel object
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class SVC_DAL_AcContactChannel
{
	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of AC Contact Channel fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				amazonconnect__AC_ContactChannels__c.amazonconnect__AfterContactWorkDuration__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__AgentCustomerHoldDuration__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__AgentLoginUsername__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__AgentName__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__Attributes__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CallEndTimestamp__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CallRecording__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CallStartTimestamp__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CallStatus__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__Case__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__Channel__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__ContactId__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CustomerCallbackNumber__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__CustomerNumber__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__DialedNumber__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__InitiationMethod__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__InteractionDuration__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__QueueName__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__RelatedToWhatId__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.amazonconnect__RelatedToWhoId__c.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.Id.getDescribe().getLocalName(),
				amazonconnect__AC_ContactChannels__c.OwnerId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return an AC Contact Channel based on Id given return base fields
	 *
	 * @param contactId The unique Contact Id for the Contact Channel
	 *
	 * @return either null or the AC Contact Channel that was found
	 */
	public static amazonconnect__AC_ContactChannels__c findByContactId(String contactId)
	{
		return (amazonconnect__AC_ContactChannels__c)CMN_DAL_SObjectSelector.findByField(amazonconnect__AC_ContactChannels__c.SObjectType, amazonconnect__AC_ContactChannels__c.amazonconnect__ContactId__c, String.valueOf(contactId), getDefaultFields(), true);
	}

	/**
	 * @description Will return all the AC Contact Channels in the system
	 *
	 * @return A list of AC Contact Channels
	 */
	@TestVisible
	private static List<amazonconnect__AC_ContactChannels__c> getAll()
	{
		return CMN_DAL_Search.getAll(amazonconnect__AC_ContactChannels__c.SObjectType, getDefaultFields());
	}

}