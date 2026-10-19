/**
 * @description Provides Query methods related to Service Type object
 *
 * @see SVC_ServiceType__c
 *
 * @author Accenture
 *
 * @date April 2021
 */
public inherited sharing class SVC_DAL_ServiceType
{

	public static final String OBJECT_NAME = SVC_ServiceType__c.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_NAME = SVC_ServiceType__c.Name.getDescribe().getLocalName();
	public static final String FIELD_ACTIVE = SVC_ServiceType__c.SVC_Active__c.getDescribe().getLocalName();

	private static final String FIELD_ID = SVC_ServiceType__c.Id.getDescribe().getLocalName();
	private static final Boolean STATUS_ACTIVE = true;

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Service Type fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				SVC_ServiceType__c.Id.getDescribe().getLocalName(),
				SVC_ServiceType__c.Name.getDescribe().getLocalName(),
				SVC_ServiceType__c.SVC_ExternalId__c.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve an Service Type using External Id
	 *
	 * @param externalId A unique External Id
	 *
	 * @return Either Item found or null
	 */
	public static SVC_ServiceType__c findByExternalId(String externalId)
	{
		return (SVC_ServiceType__c)CMN_DAL_SObjectSelector.findByField(SVC_ServiceType__c.SObjectType, SVC_ServiceType__c.SVC_ExternalId__c, externalId, getDefaultFields(), false);
	}

	/**
	 * @description Method to return a list of service types by field and search values
	 *
	 * @param field The field to search
	 * @param searchValues The values of the field
	 *
	 * @return List of Service Types
	 */
	private static List<SVC_ServiceType__c> getActiveRecords(String field, Set<String> searchValues)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, field, searchValues, getDefaultFields());
		searchParameters.searchConditions.add(setActiveOnly());

		List<SVC_ServiceType__c> foundServiceTypes = CMN_DAL_Search.getObjects(searchParameters);
		return foundServiceTypes.isEmpty() ? null : foundServiceTypes;
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
		newCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, STATUS_ACTIVE));

		return newCondition;
	}

	/**
	 * @description Method to return a list of service types by Ids
	 *
	 * @param ids The Ids to be used when filtering the service types
	 *
	 * @return List of Service Types
	 */
	public static List<SVC_ServiceType__c> findById(Set<String> ids)
	{
		return getActiveRecords(FIELD_ID, ids);
	}
}