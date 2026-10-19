/**
 * @description Provides Query methods related to OrgWideEmailAddress object
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class CMN_DAL_OrgWideEmailAddress
{
	public static final String OBJECT_NAME = OrgWideEmailAddress.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_ADDRESS = OrgWideEmailAddress.Address.getDescribe().getLocalName();
	public static final String FIELD_ALL_PROFILES = OrgWideEmailAddress.IsAllowAllProfiles.getDescribe().getLocalName();

	/**
	 * @description Returns the default fields to return when querying the OrgWideEmailAddress Object
	 *
	 * @return A list of field names
	 */
	@TestVisible
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				OrgWideEmailAddress.Id.getDescribe().getLocalName(),
				OrgWideEmailAddress.DisplayName.getDescribe().getLocalName(),
				FIELD_ADDRESS,
				FIELD_ALL_PROFILES
		};
	}

	/**
	 * @description Will retrieve on or more OrgWideEmailAddresses
	 *
	 * @param addresses A list of Email Addresses
	 *
	 * @return A list of OrgWideEmailAddress
	 */
	public static List<OrgWideEmailAddress> findByName(Set<String> addresses)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_ADDRESS, addresses, getDefaultFields());
	}

	/**
	 * @description Will retrieve a random Org wide email address that is available to all profiles
	 *
	 * @return Either an email address object or null
	 */
	@TestVisible
	private static OrgWideEmailAddress getRandomItem()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME);

		searchParameters.randomSingle = true;
		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		searchParameters.searchFields.clear();

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = getDefaultFields();

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ALL_PROFILES, CMN_SOQL_Query.Operator.EQUALS, true));

		searchParameters.searchConditions.add(andCondition);

		List<OrgWideEmailAddress> foundAddresses = CMN_DAL_Search.getObjects(searchParameters);

		return foundAddresses.isEmpty() ? null : foundAddresses.iterator().next();
	}

}