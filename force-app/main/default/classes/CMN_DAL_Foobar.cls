/**
 * @description Provides Query methods related to Foo object
 *
 * @see CMN_DAL_Foobar_TEST @story VCCC-378
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_Foobar
{
	public static final String RT_DEFAULT = 'CMN_DefaultFoobar';

	@TestVisible
	private static final String SOBJECT_NAME = CMN_Foobar__c.SObjectType.getDescribe().getLocalName();

	public static final Set <String> SOBJECT_FIELDS = new Set<String>
	{
			CMN_Foobar__c.Id.getDescribe().getName(),
			CMN_Foobar__c.Name.getDescribe().getName(),
			CMN_Foobar__c.CMN_NumberInteger__c.getDescribe().getName(),
			CMN_Foobar__c.CMN_Text__c.getDescribe().getName(),
			CMN_Foobar__c.CMN_Checkbox__c.getDescribe().getName(),
			'CMN_Lookup__r.Name'
	};

	/**
	 * @description Will return all the Foobar objects in the system
	 *
	 * @return A list of Foobar objects
	 */
	@TestVisible
	private static List<CMN_Foobar__c> getAll()
	{
		return CMN_DAL_Search.getAll(SOBJECT_NAME);
	}

	/**
	 * @description Select by Id (will use default fields)
	 *
	 * @param ids as input
	 *
	 * @return List of foobar sobjects with default fields
	 */
	public static List<CMN_Foobar__c> selectByIds(Set<Id> ids)
	{
		return (List<CMN_Foobar__c>)CMN_DAL_SObjectSelector.findById(SOBJECT_NAME, ids, SOBJECT_FIELDS);
	}

	/**
	 * @description Select by Ids (returning specific fields)
	 *
	 * @param ids as input
	 * @param fields as input
	 *
	 * @return list
	 */
	public static List<CMN_Foobar__c> selectByIdsFields(Set<Id> ids, Set<String> fields)
	{
		return (List<CMN_Foobar__c>)CMN_DAL_SObjectSelector.findById(SOBJECT_NAME, ids, fields);
	}

	/**
	 * @description returns queryLocator of foo bar sobjects
	 *
	 * @return queryLocator
	 */
	public static Database.QueryLocator queryLocatorAll()
	{
		CMN_DAL_Search.SOQLSearchParameters params = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME);
		params.setResultRowNoName();
		return CMN_DAL_Search.getQueryLocator(params);
	}

	/**
	 * @description returns query aggregated for grouped by records
	 *
	 * @return list of aggregate result data
	 */
	public static List<AggregateResult> queryAggregateAll()
	{
		CMN_DAL_Search.SOQLSearchParameters params = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME);
		params.setSecurityEnforced(false);
		params.clearSelectFields();
		params.clearSearchFields();
		params.selectFields.add('COUNT(Name)');
		params.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		params.groupBy = CMN_DAL_SObjectDomain.FIELD_ID;
		return CMN_DAL_Search.getQueryAggregate(params);
	}

	/**
	 * @description demonstrations a select by multiple criteria shows:
	 * <p/>
	 * ORDER BY
	 * NESTED AND ( OR ) CONDITIONS
	 * SUPPORTS LIMITS
	 * SUPPORT PAGINATION
	 * SUPPORT QUERY_LOCATOR
	 * SUPPORT AGGREGATE FUNCTIONS
	 * NESTED SELECTS NOT TESTED HERE
	 *
	 * @param ids as input
	 * @param fields as input
	 *
	 * @return list of records
	 */
	public static List<CMN_Foobar__c> selectByMultipleCriteria(List<Id> ids, Set<String> fields)
	{
		/* search object and fields */
		CMN_DAL_Search.SOQLSearchParameters params = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME, fields);

		/* where conditions */
		params.addSearchCondition(CMN_SOQL_Query.andX().inX(CMN_DAL_SObjectDomain.FIELD_ID, ids)
				.notEquals(CMN_DAL_SObjectDomain.FIELD_NAME, null));

		/* order by */
		params.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME, false);

		/* limit (e.g. 1000) */
		params.pageSize = 1000;

		return CMN_DAL_Search.getObjects(params);
	}

	/**
	 * @description
	 *
	 * @param ids as input (does support multiple level 1 nesting of up to 1 level per salesforce guidelines, but lookup up to 3 levels)
	 *
	 * @return list foobars
	 */
	public static List<CMN_Foobar__c> selectWithChildSelect(Set <Id> ids)
	{
		/* LEVEL 0*/
		CMN_DAL_Search.SOQLSearchParameters outerParams = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME, new Set<String> {'Id'});

		outerParams.addSelectField('Name');

		/* LEVEL 0 CONDITION IDS */
		outerParams.searchConditions.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_ID, CMN_SOQL_Query.Operator.INX, new List <Id> (ids)));

		/* - LEVEL 1 with multilevel lookup not plural used */
		CMN_DAL_Search.SOQLSearchParameters childParams = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME,
				new Set<String> {'Id', 'Name', 'Owner.Id'}, 'CMN_Foobars__r');

		outerParams.childSearchParameters.addAll(new Set <CMN_DAL_Search.SOQLSearchParameters> {childParams});

		return CMN_DAL_Search.getObjects(outerParams);
	}

	/**
	 * @description demonstrates select where in (select) e.g.
	 * <p/>
	 * SELECT Id, Name, ...
	 * FROM XYZ WHERE
	 * (Id IN (SELECT Id FROM ABC WHERE (Active__c = true))
	 *  AND Id IN ('a084K000000ZMXyQAO')) WITH SECURITY_ENFORCED
	 *
	 * @param ids as input
	 *
	 * @return list of product components where the family lookup is active
	 */
	public static List<CMN_Foobar__c> selectWithChildBasedOnLookupWhereIn(Set <Id> ids)
	{
		/* LEVEL 0*/
		CMN_DAL_Search.SOQLSearchParameters rootParams = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME,
				new Set<String> {'Id', 'Name', 'OwnerId'});

		/* WHERE SOQL parameter */
		CMN_DAL_Search.SOQLSearchParameters whereParams = new CMN_DAL_Search.SOQLSearchParameters('User',
				new Set<String> {'Id'});
		whereParams.enforceSecurity = false; /* only root */

		/* WHERE where conditions only return component if family is true */
		whereParams.addSearchCondition(CMN_SOQL_Query.orX().equalsX('IsActive', true));

		/* ROOT conditions */
		rootParams.searchConditions.add(CMN_DAL_Search.selectWhereIn('OwnerId', whereParams));
		rootParams.searchConditions.add(CMN_SOQL_Query.inX(CMN_DAL_SObjectDomain.FIELD_ID, new List <Id> (ids)));

		return CMN_DAL_Search.getObjects(rootParams);
	}

	/**
	 * @description demonstrates select where not in (select) e.g.
	 * <p/>
	 * SELECT Id, Name, ...
	 * FROM XYZ WHERE
	 * (Id NOT IN (SELECT Id FROM ABC WHERE (Active__c = true))
	 *  AND Id IN ('a084K000000ZMXyQAO')) WITH SECURITY_ENFORCED
	 *
	 * @param ids as input
	 *
	 * @return list of product components where the family lookup is active
	 */
	public static List<CMN_Foobar__c> selectWithChildBasedOnLookupWhereNotIn(Set <Id> ids)
	{
		/* LEVEL 0*/
		CMN_DAL_Search.SOQLSearchParameters rootParams = new CMN_DAL_Search.SOQLSearchParameters(SOBJECT_NAME,
				new Set<String> {'Id', 'Name', 'OwnerId'});

		/* WHERE SOQL parameter */
		CMN_DAL_Search.SOQLSearchParameters whereParams = new CMN_DAL_Search.SOQLSearchParameters('User',
				new Set<String> {'Id'});
		whereParams.enforceSecurity = false; /* only root */

		/* WHERE where conditions only return component if family is true */
		whereParams.addSearchCondition(CMN_SOQL_Query.orX().equalsX('IsActive', true));

		/* ROOT conditions */
		rootParams.searchConditions.add(CMN_DAL_Search.selectWhereNotIn('OwnerId', whereParams));
		rootParams.searchConditions.add(CMN_SOQL_Query.inX(CMN_DAL_SObjectDomain.FIELD_ID, new List <Id> (ids)));

		return CMN_DAL_Search.getObjects(rootParams);
	}
}