/**
 * @description Provides Query methods related to Team object
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class CMN_DAL_Team
{
	@TestVisible
	private static final String OBJECT_NAME = CMN_Team__c.SObjectType.getDescribe().getLocalName();
	private static final String FIELD_ID = CMN_Team__c.Id.getDescribe().getLocalName();
	private static final String FIELD_ACTIVE = CMN_Team__c.CMN_Active__c.getDescribe().getLocalName();
	private static final String FIELD_EMAIL = CMN_Team__c.CMN_Email__c.getDescribe().getLocalName();
	@TestVisible

	private static final String FIELD_COUNTRY = CMN_Team__c.CMN_Country__c.getDescribe().getLocalName();
	private static final String FIELD_COUNTRY_CODE = CMN_Team__c.CMN_CountryCode__c.getDescribe().getLocalName();
	public static final String FIELD_NAME = CMN_Team__c.Name.getDescribe().getLocalName();
	public static final String TEAM_MEMBER_TYPE_USER = 'User';
	private static final Boolean ACTIVE_TRUE = true;
	private static final String ENABLED_FOR_COMPLAINTS = CMN_Team__c.SVC_EnableComplaintsManagement__c.getDescribe().getLocalName();

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Team fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				FIELD_NAME,
				CMN_Team__c.CMN_BusinessHours__c.getDescribe().getLocalName(),
				CMN_Team__c.CMN_BusinessUnit__c.getDescribe().getLocalName(),
				CMN_Team__c.CMN_Country__c.getDescribe().getLocalName(),
				FIELD_COUNTRY_CODE,
				CMN_Team__c.CMN_Division__c.getDescribe().getLocalName(),
				FIELD_EMAIL,
				ENABLED_FOR_COMPLAINTS
		};
	}

	/**
	 * @description Will return all the Teams in the system
	 *
	 * @return A list of Teams
	 */
	public static List<CMN_Team__c> getAll()
	{
		return CMN_DAL_Search.getAll(CMN_Team__c.SObjectType, getDefaultFields());
	}

	/**
	 * @description Will return all the Active Teams
	 *
	 * @return A list of Teams
	 */
	public static List<CMN_Team__c> getAllActive()
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME);

		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;

		searchParameters.searchFields.clear();
		searchParameters.selectFields = getDefaultFields();

		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();

		// Set active only
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));
		searchParameters.searchConditions.add(newCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to return a list of teams by field and values
	 *
	 * @param field
	 * @param searchValues
	 *
	 * @return List of Teams
	 */
	private static List<CMN_Team__c> getActiveRecords(String field, Set<String> searchValues)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, field, searchValues, getDefaultFields());
		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();
		// Set active only
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));
		searchParameters.searchConditions.add(newCondition);
		List<CMN_Team__c> foundTeams = CMN_DAL_Search.getObjects(searchParameters);
		return foundTeams.isEmpty() ? null : foundTeams;
	}

	/**
	 * @description Method to return a list of teams by Id
	 *
	 * @param teamIds
	 *
	 * @return List of Teams
	 */
	public static List<CMN_Team__c> findById(Set<String> teamIds)
	{
		return getActiveRecords(FIELD_ID, teamIds);
	}

	/**
	 * @description Will return all the Teams by email
	 *
	 * @param email
	 *
	 * @return A list of Teams
	 */
	public static List<CMN_Team__c> getByEmail(String email)
	{
		return getActiveRecords(FIELD_EMAIL, new Set<String> {email});
	}

	/**
	 * @description Will retrieve all teams by country code
	 *
	 * @param countryCode
	 *
	 * @return A list of Teams or null
	 */
	public static List<CMN_Team__c> findByCountryCode(String countryCode)
	{
		return getActiveRecords(FIELD_COUNTRY_CODE, new Set<String> {countryCode});
	}

	/**
	 * @description Retrieve the wrapper containing the Team information based on the team name
	 *
	 * @param teamName - the name of the team to filter
	 *
	 * @return A wrapper containing the team name and Id
	 *
	 * @see CMN_DAL_Team.TeamIdAndNameWrapper
	 */
	@AuraEnabled
	public static TeamIdAndNameWrapper getTeamIdFromName(String teamName)
	{
		CMN_Team__c foundTeam =
		[
				SELECT
						Id,
						Name
				FROM
						CMN_Team__c
				WHERE
				Name = :teamName
				AND CMN_Active__c = TRUE

		];

		TeamIdAndNameWrapper wrapper = new TeamIdAndNameWrapper();
		wrapper.teamName = foundTeam.Name;
		wrapper.teamId = foundTeam.Id;

		return wrapper;
	}
	/**
	 * @description Wrapper Class to create Team Object with Team ID And Name
	 */
	public class TeamIdAndNameWrapper
	{
		@AuraEnabled public String teamId;
		@AuraEnabled public String teamName;

	}

	/**
	 * @description Retrieve the teams for a specific user id
	 *
	 * @param userId - The Id of the user
	 *
	 * @return - A list of teams that the user is assigned to
	 */
	public static List<CMN_TeamMember__c> getTeamsByUserId(Id userId)
	{
		List<CMN_TeamMember__c> teams =
		[
				SELECT
						CMN_Team__c,
						CMN_Team__r.Name
				FROM
						CMN_TeamMember__c
				WHERE
					CMN_User__c = :userId AND
					CMN_Team__r.CMN_Active__c = TRUE
				WITH SECURITY_ENFORCED
		];

		return !teams.isEmpty() ? teams : new List<CMN_TeamMember__c>();
	}

	/**
	 * @description Retrieve the teams for a specific username
	 *
	 * @param teamMemberName - The name of the user
	 *
	 * @return - A list of teams that the user is assigned to
	 */
	public static List<CMN_TeamMember__c> getTeamsByUsername(String teamMemberName)
	{

		List<CMN_TeamMember__c> teams =
		[
				SELECT
						CMN_Team__c,
						CMN_Team__r.Name
				FROM
						CMN_TeamMember__c
				WHERE
				Name = :teamMemberName
				AND
				CMN_Type__c = :TEAM_MEMBER_TYPE_USER AND
				CMN_Team__r.CMN_Active__c = TRUE
				WITH SECURITY_ENFORCED
		];

		return !teams.isEmpty() ? teams : new List<CMN_TeamMember__c>();
	}
}