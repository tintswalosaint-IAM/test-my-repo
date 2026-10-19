/**
 * @description Provides Query methods related to Service Team object
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class SVC_DAL_ServiceTeam
{
	public static final String OBJECT_NAME = SVC_ServiceTeam__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_ID = SVC_ServiceTeam__c.Id.getDescribe().getLocalName();
	public static final String FIELD_TEAM = SVC_ServiceTeam__c.CMN_Team__c.getDescribe().getLocalName();
	public static final String FIELD_APPLICABLE_PRODUCT_CATEGORY = SVC_ServiceTeam__c.SVC_ApplicableProductCategories__c.getDescribe().getLocalName();
	public static final String FIELD_GROUPID = SVC_ServiceTeam__c.SVC_GroupId__c.getDescribe().getLocalName();
	public static final String FIELD_CASEROUTINGQUEUE = SVC_ServiceTeam__c.SVC_CaseRoutingQueue__c.getDescribe().getLocalName();
	public static final String FIELD_SERVICE_TYPE = SVC_ServiceTeam__c.SVC_ServiceType__c.getDescribe().getLocalName();
	public static final String FIELD_QUEUE_BASED_ROUTING = SVC_ServiceTeam__c.SVC_QueueBasedRouting__c.getDescribe().getLocalName();
	
	private static final String FIELD_ACTIVE = SVC_ServiceTeam__c.SVC_Active__c.getDescribe().getLocalName();

	// Service Type
	private static final String FIELD_SERVICE_TYPE_NAME = SVC_ServiceTeam__c.SVC_ServiceType__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + SVC_DAL_ServiceType.FIELD_NAME;
	private static final String FIELD_SERVICE_TYPE_ACTIVE = SVC_ServiceTeam__c.SVC_ServiceType__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + SVC_DAL_ServiceType.FIELD_ACTIVE;

	// Team
	private static final String FIELD_TEAM_NAME = SVC_ServiceTeam__c.CMN_Team__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + CMN_DAL_Team.FIELD_NAME;

	private static final String FIELD_ENTITLEMENT_NAME = SVC_ServiceTeam__c.SVC_Entitlement__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + SVC_DAL_Entitlement.FIELD_NAME;

	private static final Boolean ACTIVE_TRUE = true;

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Service Team fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				SVC_ServiceTeam__c.Name.getDescribe().getLocalName(),
				SVC_ServiceTeam__c.SVC_Entitlement__c.getDescribe().getLocalName(),
				FIELD_SERVICE_TYPE,
				SVC_ServiceTeam__c.CMN_Team__c.getDescribe().getLocalName(),
				FIELD_APPLICABLE_PRODUCT_CATEGORY,
				FIELD_GROUPID,
				FIELD_CASEROUTINGQUEUE,
				FIELD_QUEUE_BASED_ROUTING,
				FIELD_SERVICE_TYPE_NAME,
				FIELD_TEAM_NAME,
				FIELD_ENTITLEMENT_NAME,
				FIELD_ID
		};
	}

	/**
	 * @description Method append additional condition to force only active records
	 *
	 * @return CMN_SOQL_Query.AndCondition
	 *
	 * @see CMN_SOQL_Query.AndCondition
	 */
	private static CMN_SOQL_Query.AndCondition setActiveOnly()
	{
		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));

		return newCondition;
	}

	/**
	 * @description Method to return a list of service teams by field and search values
	 *
	 * @param field
	 * @param searchValues
	 *
	 * @return List of Service Teams
	 */
	private static List<SVC_ServiceTeam__c> getActiveRecords(String field, Set<String> searchValues)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, field, searchValues, getDefaultFields());
		searchParameters.searchConditions.add(setActiveOnly());

		return (List<SVC_ServiceTeam__c>)CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to return a list of service teams by Team Id
	 *
	 * @param teamIds
	 *
	 * @return List of Service Teams
	 */
	public static List<SVC_ServiceTeam__c> findByTeamId(Set<String> teamIds)
	{
		return getActiveRecords(FIELD_TEAM, teamIds);
	}

	/**
	 * @description Method to return a list of service teams by Team Id
	 *
	 * @param teamIds
	 *
	 * @return List of Service Teams
	 */
	public static List<SVC_ServiceTeam__c> getServiceTypesByTeamId(Set<String> teamIds)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_TEAM, teamIds, getDefaultFields());

		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_SERVICE_TYPE_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));

		searchParameters.searchConditions.add(newCondition);

		return (List<SVC_ServiceTeam__c>)CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Method to return a list of service teams by service type and team
	 *
	 * @param serviceTypeId
	 * @param teamId
	 *
	 * @return List of Service Teams
	 */
	public static List<SVC_ServiceTeam__c> findByServiceTypeAndTeam(Id serviceTypeId, Id teamId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_SERVICE_TYPE, new Set<String> {serviceTypeId}, getDefaultFields());

		CMN_SOQL_Query.AndCondition newCondition = new CMN_SOQL_Query.AndCondition();
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, ACTIVE_TRUE));
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_TEAM, CMN_SOQL_Query.Operator.EQUALS, teamId));

		searchParameters.searchConditions.add(newCondition);

		return (List<SVC_ServiceTeam__c>)CMN_DAL_Search.getObjects(searchParameters);
	}

		/**
	 * @description Method to return an Id of service type
	 *
	 * @param serviceTeamId
	 *
	 * @return String
	 */
	public static String getServiceTypeId(Set<String> serviceTeamId)
	{
		return getActiveRecords(FIELD_ID, serviceTeamId)[0].SVC_ServiceType__c;
	}

}