/**
 * @description Provides Query methods related to Team Member object
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class CMN_DAL_TeamMember
{
	public static final String OBJECT_NAME = CMN_TeamMember__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_TYPE = CMN_TeamMember__c.CMN_Type__c.getDescribe().getLocalName();
	private static final String FIELD_TEAM = CMN_TeamMember__c.CMN_Team__c.getDescribe().getLocalName();
	private static final String FIELD_NAME = CMN_TeamMember__c.Name.getDescribe().getLocalName();
	private static final String FIELD_TEAM_NAME = CMN_TeamMember__c.CMN_Team__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + CMN_DAL_Team.FIELD_NAME;

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Team fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_TEAM,
				CMN_TeamMember__c.Name.getDescribe().getLocalName(),
				FIELD_TYPE,
				FIELD_TEAM_NAME
		};
	}

	/**
	 * @description Will return all the Team Members in the system
	 *
	 * @return A list of Team Members
	 */
	@TestVisible
	private static List<CMN_TeamMember__c> getAll()
	{
		return CMN_DAL_Search.getAll(CMN_TeamMember__c.SObjectType, getDefaultFields());
	}

	/**
	 * @description Will return all the Team Members in the system by type
	 *
	 * @param type
	 *
	 * @return A list of Team Members
	 */
	public static List<CMN_TeamMember__c> findByType(String type)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_TYPE, new Set<String> {type}, getDefaultFields());
	}

	/**
	 * @description Will return all the Team Members by name and type
	 *
	 * @param name
	 * @param type
	 *
	 * @return A list of Team Members
	 */
	public static List<CMN_TeamMember__c> findByNameAndType(String name, String type)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_NAME, new Set<String> {name}, getDefaultFields());

		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();

		// Set the team member type
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_TYPE, CMN_SOQL_Query.Operator.EQUALS, type));

		searchParameters.searchConditions.add(newCondition);

		List<CMN_TeamMember__c> foundTeamMembers = CMN_DAL_Search.getObjects(searchParameters);
		return foundTeamMembers.isEmpty() ? null : foundTeamMembers;
	}


}