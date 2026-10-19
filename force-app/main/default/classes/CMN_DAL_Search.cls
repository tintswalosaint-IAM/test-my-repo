/**
 * @description Class to  construct and  execute SOQL or SOSL queries generically.
 * Supports paging  on SOQL queries if  required
 *
 * @see CMN_DAL_Search_TEST @story: VCCC-378
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_Search
{
	private static final Integer MAX_OFFSET = 2000;
	private static final Integer MAX_PAGE_SIZE = 2000;
	private static final Integer MINIMUM_OFFSET = 1;
	private static final Integer MIN_LIMIT = 1;
	private static final Set<String> DEFAULT_SEARCH_FIELDS = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};
	private static final String FIELD_SEPARATOR = ',';
	private static final String LIKE_WILD_CARD_CHAR = '%';
	private static final String SOQL_IN = ' IN ';
	private static final String SOQL_NOT_IN = ' NOT IN ';
	private static final String SOQL_SEARCH_TERM_FMT = '{0}{1}{0}';
	private static final String SOSL_LIMIT_FMT = 'LIMIT {0} OFFSET {1}';
	private static final String SOSL_ORDER_BY = 'ORDER BY ';
	private static final String SOSL_WHERE = 'WHERE ';
	private static final String SOSL_WILD_CARD = '*';

	private static final String SOSL_QUERY_FMT =
			'FIND :searchTerm IN {0} ' + //search term required
					'RETURNING ' +
					'{1} ' + //object to be retrieved required
					'(' +
					'{2} ' + //fields to return required
					'{3} ' + //where clause optional
					'{4} ' + //order by clause optional
					'{5}' + //offset clause required
					')';

	/**
	 * @description An enum to specific which
	 */
	public enum SOSLSearchGroup
	{
		ALL_FIELDS, NAME_FIELDS, EMAIL_FIELDS, PHONE_FIELDS, SIDEBAR_FIELDS
	}

	/**
	 * @description Map used when composing a SOSL Query to set the Search Group
	 */
	private static final Map<SOSLSearchGroup, String> SOSL_SEARCH_GROUP_VALUES = new Map<SOSLSearchGroup, String>
	{
			SOSLSearchGroup.ALL_FIELDS => 'ALL FIELDS',
			SOSLSearchGroup.NAME_FIELDS => 'NAME FIELDS',
			SOSLSearchGroup.EMAIL_FIELDS => 'EMAIL FIELDS',
			SOSLSearchGroup.PHONE_FIELDS => 'PHONE FIELDS',
			SOSLSearchGroup.SIDEBAR_FIELDS => 'SIDEBAR FIELDS'
	};

	/**
	 * @description Class use for Result
	 */
	public virtual class ResultRow
	{
		public String id
		{
			get;
			set;
		}
		public String text;

		/**
		 * @description assign
		 *
		 * @param obj The object whose values must be assigned to the search result
		 */
		public virtual void assign(SObject obj)
		{
			id = obj.Id;

			SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(id);
			/* some Objects e.g. Solution don't have a "name" field */
			Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectType.getDescribe().getLocalName(), CMN_DAL_SObjectDomain.FIELD_NAME);
			text = isValid ? String.valueOf(obj.get(CMN_DAL_SObjectDomain.FIELD_NAME)) : text;
		}
	}

	/**
	 * @description Class use for Result
	 */
	public class ResultRowNoName extends ResultRow
	{
		public override void assign(SObject obj)
		{
			id = (Id)obj.get(CMN_DAL_SObjectDomain.FIELD_ID);
		}
	}

	/**
	 * @description Class use for store variables
	 */
	public virtual class SearchParameters
	{
		public Schema.SObjectType objectType;

		/**
		 * @description Setting enforceSecurity to true will enforce Field Level and Object Security
		 */
		public Boolean enforceSecurity;
		public String searchTerm;
		public Set<String> selectFields;
		public List<CMN_SOQL_Query.OrderBy> orderByFields;
		public CMN_SOQL_Query.NestableCondition searchConditions;
		public Integer offsetX;

		public Integer pageSize
		{
			get
			{
				return pageSize > MAX_PAGE_SIZE || pageSize < 0 ? MAX_PAGE_SIZE : pageSize;
			}
			set;
		}

		public Integer pageNumber
		{
			get
			{
				return pageNumber > 0 ? pageNumber - 1 : 0;
			}
			set;
		}

		public Type resultItemType;

		public String objectName
		{
			get
			{
				return objectType == null ? CMN_UTIL_String.EMPTY : objectType.getDescribe().getLocalName();
			}
		}

		public Integer offset
		{
			get
			{
				return Math.max(Math.min(pageSize * pageNumber, MAX_OFFSET), 0);
			}
		}

		public Boolean paged = false;

		/**
		 * @description set query security
		 *
		 * @param enforceSecurity sets query crud and fls security
		 */
		public void setSecurityEnforced(Boolean enforceSecurity)
		{
			this.enforceSecurity = enforceSecurity;
		}

		/**
		 * @description clears search fields populated with defaults
		 */
		public void clearSelectFields()
		{
			this.selectFields.clear();
		}

		/**
		 * @description Will ensure that on random record is returned
		 */
		public Boolean randomSingle = false;

		/**
		 * @description Constructor
		 */
		public SearchParameters()
		{
			enforceSecurity = false;
			resultItemType = ResultRow.class;
			searchConditions = new CMN_SOQL_Query.AndCondition();
			selectFields = new Set<String>(DEFAULT_SEARCH_FIELDS);
			orderByFields = new List<CMN_SOQL_Query.OrderBy>();
			pageSize = 0;
			pageNumber = 0;
		}

		/**
		 * @description default is result row use to clear name from returned results
		 */
		public void setResultRowNoName()
		{
			resultItemType = ResultRowNoName.class;
		}

		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchTerm as input
		 */
		public SearchParameters(SObjectType objectType, String searchTerm)
		{
			this();
			this.objectType = objectType;
			this.searchTerm = String.escapeSingleQuotes(searchTerm);
		}

		/**
		 * @description wrapper for searchConditions
		 *
		 * @param nestableCondition as input
		 */
		public void addSearchCondition(CMN_SOQL_Query.NestableCondition nestableCondition)
		{
			this.searchConditions.add(nestableCondition);
		}

		/**
		 * @description Will add an order by field to orderByFields list
		 *
		 * @param fieldName The name of the field to order results by
		 * @param sortDescending Set to true if you want to sort by field in descending order
		 */
		public void addOrderByField(String fieldName, Boolean sortDescending)
		{
			CMN_SOQL_Query.OrderBy orderByField = new CMN_SOQL_Query.OrderBy(fieldName);
			orderByField = sortDescending ? orderByField.descending() : orderByField.ascending();
			orderByFields.add(orderByField);
		}

		/**
		 * @description Will add an order by field to orderByFields list
		 *
		 * @param fieldName he name of the field to order results by; not this will ensure ordering is ascending
		 */
		public void addOrderByField(String fieldName)
		{
			addOrderByField(fieldName, false);
		}

		/**
		 * @description add to select field list
		 *
		 * @param selectField as input
		 */
		public void addSelectField(String selectField)
		{
			selectFields.add(selectField);
		}
	}

	/**
	 * @description Class use for parameters get in SOQL
	 */
	public virtual class SOQLSearchParameters extends SearchParameters
	{
		/* default soql search parameter */
		public Set<String> searchFields;
		public String groupBy;

		/* child soql search variables */
		public List<SOQLSearchParameters> childSearchParameters;
		public Boolean innerSelect;
		public String childPluralName;

		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchTerm as input
		 */
		public SOQLSearchParameters(SObjectType objectType, String searchTerm)
		{
			super(objectType, searchTerm);

			searchFields = new Set<String>();

			if(!String.isBlank(searchTerm))
			{
				this.searchTerm = String.format(SOQL_SEARCH_TERM_FMT, new List<String> {LIKE_WILD_CARD_CHAR, searchTerm});
				searchFields.add(CMN_DAL_SObjectDomain.FIELD_NAME);
			}

			childSearchParameters = new List<SOQLSearchParameters>();
			innerSelect = false;
			childPluralName = null;
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 * @param searchTerm as input
		 */
		public SOQLSearchParameters(String objectName, String searchTerm)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), searchTerm);
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 */
		public SOQLSearchParameters(String objectName)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), CMN_UTIL_String.EMPTY);
		}

		/**
		 * @description Constructor
		 *
		 * @param objectName as input
		 * @param selectFields as input
		 */
		public SOQLSearchParameters(String objectName, Set<String> selectFields)
		{
			this(CMN_UTIL_System.getSObjectTypeByName(objectName), CMN_UTIL_String.EMPTY);
			this.selectFields = selectFields;
		}

		/**
		 * @description Constructor for child inner SQL query
		 *
		 * @param objectName of the inner from object (not actually used)
		 * @param selectFields of the inner object
		 * @param childPluralName the from inner sobjectPlural_r e.g. OpportunityLineItems
		 */
		public SOQLSearchParameters(String objectName, Set<String> selectFields, String childPluralName)
		{
			this(objectName, selectFields);
			this.innerSelect = true;
			this.childPluralName = childPluralName;
			// this.enforceSecurity = false; /* make sure is false only allowed in outer query select */
		}

		/**
		 * @description
		 *
		 * @return object name or child plural name
		 */
		public String getObjectName()
		{
			return innerSelect ? childPluralName : this.objectName;
		}

		/**
		 * @description clears search fields populated with defaults
		 */
		public void clearSearchFields()
		{
			this.searchFields.clear();
		}
	}

	/**
	 * @description Class use for parameters search in SOQL
	 */
	public class SOSLSearchParameters extends SearchParameters
	{
		SOSLSearchGroup searchGroup = SOSLSearchGroup.ALL_FIELDS;
		/**
		 * @description Constructor
		 *
		 * @param objectType as input
		 * @param searchGroup as input
		 * @param searchTerm as input
		 */
		public SOSLSearchParameters(SObjectType objectType, SOSLSearchGroup searchGroup, String searchTerm)
		{
			super(objectType, searchTerm);

			this.searchTerm = searchTerm + SOSL_WILD_CARD;
			this.searchGroup = searchGroup;
		}
	}

	/**
	 * @description Class use search the response
	 */
	public class SearchResponse
	{
		private transient Type itemType;
		private List<ResultRow> items;
		public String queryString; /* query used to generate the search response */
		public Integer totalItems
		{
			get;
			set;
		}
		public List<ResultRow> itemList
		{
			get
			{
				return items;
			}
		}

		/**
		 * @description Constructor
		 */
		public SearchResponse()
		{
		}

		/**
		 * @description Constructor
		 *
		 * @param itemType as input
		 */
		public SearchResponse(Type itemType)
		{
			this();

			this.itemType = (itemType == null ? ResultRow.class : itemType);
			items = new List<ResultRow>();
		}

		/**
		 * @description Constructor
		 *
		 * @param obj as input
		 *
		 * @return result row
		 */
		public ResultRow add(SObject obj)
		{
			ResultRow result = (ResultRow)itemType.newInstance();

			result.assign(obj);

			itemList.add(result);

			return result;
		}

		/**
		 * @description method use to add the List of Sobject
		 *
		 * @param objects as input
		 */
		public void add(List<SObject> objects)
		{
			for(SObject obj : objects)
			{
				add(obj);
			}
		}
	}

	/**
	 * @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	 *
	 * @param parameters relevant search parameters for setting up a SOQL Query
	 * @param results a list of SObjects retrieved by the SOQL Query
	 *
	 * @return searchResponse details of the response which also additional values like number of rows retrieved
	 */
	private static SearchResponse soqlSearch(SOQLSearchParameters parameters, List<SObject> results)
	{
		SearchResponse searchResponse = soqlQuery(parameters);

		//Use a SOQL For Loop to avoid heap size limit
		for(List<SObject> items : Database.query(searchResponse.queryString))
		{
			searchResponse.add(items);
			results.addAll(items);
		}

		if(!parameters.paged)
		{
			searchResponse.totalItems = results.size();
		}

		return searchResponse;
	}

	/**
	 * @description prepares the select fields as inner child queries
	 *
	 * @param parameters prepares the select fields as inner child queries
	 */
	private static void soqlChildQueries(SOQLSearchParameters parameters)
	{
		for(SOQLSearchParameters childSearch : parameters.childSearchParameters)
		{
			String childQuery = '(' + soqlQuery(childSearch).queryString + ')';
			parameters.selectFields.add(childQuery);
		}
	}

	/**
	 * @description
	 *
	 * @param parameters as input
	 *
	 * @return soql query string
	 */
	private static SearchResponse soqlQuery(SOQLSearchParameters parameters)
	{
		SearchResponse searchResponse = new SearchResponse(parameters.resultItemType);

		CMN_SOQL_Query.OrCondition orConditions = new CMN_SOQL_Query.OrCondition();

		for(String searchField : parameters.searchFields)
		{
			orConditions.add(new CMN_SOQL_Query.FieldCondition(searchField, CMN_SOQL_Query.Operator.LIKEX, parameters.searchTerm));
		}

		parameters.searchConditions.add(orConditions);

		Boolean isPaged = parameters.paged || parameters.randomSingle;

		if(!parameters.innerSelect && isPaged)
		{
			// Will only run if above conditions are specified for paging
			// check how many rows we have, if there are no rows, we do not need to run a second query
			CMN_SOQL_Builder soqlCount =
					new CMN_SOQL_Builder()
							.selectCount()
							.fromX(parameters.objectName)
							.whereX(parameters.searchConditions);

			String countQuery = soqlCount.toSoql();

			searchResponse.totalItems = Database.countQuery(countQuery);
		}

		soqlChildQueries(parameters);

		CMN_SOQL_Builder builder =
				new CMN_SOQL_Builder()
						.selectX(parameters.selectFields)
						.fromX(parameters.getObjectName())
						.whereX(parameters.searchConditions)
						.groupByX(parameters.groupBy)
						.orderByX(parameters.orderByFields)
						.withSecurityEnforced(parameters.enforceSecurity);

		if(!parameters.innerSelect && (isPaged || parameters.pageSize > 0))
		{
			//When retrieving random results, we only return 1 row
			builder.limitX(parameters.randomSingle ? MINIMUM_OFFSET : parameters.pageSize);
		}

		if(isPaged)
		{
			//When retrieving random results, the offset is calculated randomly from the total number of available rows
			Integer offsetPage = parameters.randomSingle ? CMN_UTIL_System.getRandomInteger(searchResponse.totalItems - 1) : parameters.offset;

			//Generate the query append the offset manually as the SoqlBuilder class does not support offset term
			builder.offsetX(offsetPage);
		}

		searchResponse.queryString = builder.toSoql();

		return searchResponse;
	}

	/**
	 * @description This method will generate a paged SOQL Query up to maximum of 50,000 rows will be returned
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static List<SObject> getObjects(SOSLSearchParameters parameters)
	{
		List<SObject> results = new List<SObject>();

		soslSearch(parameters, results);

		return results;
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 *
	 * @param parameters as input
	 *
	 * @return results list
	 */
	public static List<SObject> getObjects(SOQLSearchParameters parameters)
	{
		List<SObject> results = new List<SObject>();

		soqlSearch(parameters, results);

		return results;
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 * This method is generally discourages over the paging and offset method provided in getObjects
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static Database.QueryLocator getQueryLocator(SOQLSearchParameters parameters)
	{
		SearchResponse searchResponse = soqlQuery(parameters);

		return Database.getQueryLocator(searchResponse.queryString);
	}

	/**
	 * @description This method will generate a paged SOQL Query based on the passed parameters
	 * This method returned grouped by aggregate query (important must include group by string)
	 *
	 * @param parameters as input
	 *
	 * @return results
	 */
	public static List<AggregateResult> getQueryAggregate(SOQLSearchParameters parameters)
	{
		SearchResponse searchResponse = soqlQuery(parameters);

		return Database.query(searchResponse.queryString);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectType as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(SObjectType objectType)
	{
		return getAll(objectType.getDescribe().getLocalName());
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectName as input
	 * @param selectFields The list of fields to query
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(String objectName, Set<String> selectFields)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName);

		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;

		searchParameters.searchFields.clear();
		searchParameters.selectFields = selectFields;
		searchParameters.pageSize = MAX_PAGE_SIZE;

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectType as input
	 * @param selectFields The list of fields to query
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(SObjectType objectType, Set<String> selectFields)
	{
		return getAll(objectType.getDescribe().getLocalName(), selectFields);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectName as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(String objectName)
	{
		return getAll(objectName, CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description This method will get the list of all SObject
	 *
	 * @param objectName as input
	 * @param searchTerm as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> getAll(String objectName, String searchTerm)
	{
		List<SObject> findResults = new List<SObject>();

		if(CMN_UTIL_System.objectQueryable(objectName))
		{
			Set<String> selectFields = CMN_UTIL_System.getAllFieldNames(objectName);

			CMN_DAL_Search.SOQLSearchParameters parameters = String.isBlank(searchTerm) ? new CMN_DAL_Search.SOQLSearchParameters(objectName) : new CMN_DAL_Search.SOQLSearchParameters(objectName, searchTerm);

			parameters.searchFields.clear();
			parameters.selectFields = selectFields;
			parameters.pageSize = MAX_PAGE_SIZE;

			findResults = getObjects(parameters);
		}

		return findResults;
	}

	/**
	 * @description This method is use to provide the parameters and store the result using in SOSL
	 *
	 * @param parameters as input
	 * @param results as input
	 *
	 * @return search response
	 */
	private static SearchResponse soslSearch(SOSLSearchParameters parameters, List<SObject> results)
	{
		SearchResponse searchResponse = new SearchResponse(parameters.resultItemType);

		//Compose individual SOSL Clauses to be joined into final Query
		String selectClause = CMN_UTIL_String.joinStrings(parameters.selectFields, FIELD_SEPARATOR);

		String whereClause = parameters.searchConditions.toSoql();

		if(String.isNotBlank(whereClause))
		{
			whereClause = SOSL_WHERE + whereClause;
		}

		String orderByClause = CMN_UTIL_String.EMPTY;

		List<String> orderByFields = new List<String>();

		for(CMN_SOQL_Query.OrderBy orderByField : parameters.orderByFields)
		{
			orderByFields.add(orderByField.toSoql());
		}

		orderByClause = orderByFields.isEmpty() ? orderByClause : SOSL_ORDER_BY + CMN_UTIL_String.joinArray(orderByFields, FIELD_SEPARATOR);

		String offsetClause = !parameters.paged ? CMN_UTIL_String.EMPTY : String.format(SOSL_LIMIT_FMT, new List<String> {String.valueOf(parameters.pageSize), String.valueOf(parameters.offset)});

		//Put together the final SOSL Statement
		String query = String.format(SOSL_QUERY_FMT, new List<String>
		{
				SOSL_SEARCH_GROUP_VALUES.get(parameters.searchGroup),
				parameters.objectName,
				selectClause == null ? CMN_DAL_SObjectDomain.FIELD_ID : selectClause,
				whereClause == null ? CMN_UTIL_String.EMPTY : whereClause,
				orderByClause,
				offsetClause
		});

		//Create a simple variable so that we can bind the search term directly into the query
		String searchTerm = parameters.searchTerm;

		CMN_UTIL_Logger.info(searchTerm, 'CMN_DAL_SEARCH.soslSearch');

		// searchResponse
		List<List<SObject>> searchResults = Search.query(query);

		if(!searchResults.isEmpty())
		{
			searchResponse.add(searchResults[0]);
			results.addAll(searchResults[0]);
			//Since we cannot do a Count query with SOSL the total items is arbitrary unless we the results returned are less than that requested
			searchResponse.totalItems = searchResponse.itemList.size() < parameters.pageSize ? searchResponse.itemList.size() : MAX_PAGE_SIZE;
		}

		return searchResponse;
	}

	/**
	 * @description This method will generate a paged SOSL Query based on the passed parameters
	 *
	 * @param parameters as input
	 *
	 * @return search response
	 */
	public static SearchResponse soslSearch(SOSLSearchParameters parameters)
	{
		List<SObject> results = new List<SObject>();

		return soslSearch(parameters, results);
	}

	/**
	 * @description This method will generate a paged SOSL Query based on the passed parameters
	 *
	 * @param objectType The type of object that should be queried
	 * @param searchGroup The SOSL Search group https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_in.htm
	 * @param searchTerm The piece of text that should be search for
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> soslSearch(SObjectType objectType, SOSLSearchGroup searchGroup, String searchTerm)
	{
		CMN_DAL_Search.SOSLSearchParameters parameters = new CMN_DAL_Search.SOSLSearchParameters(objectType, searchGroup, searchTerm);
		return getObjects(parameters);
	}

	/**
	 * @description Method will query all fields for given object, filtering list by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValue as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findAllByAnyValue(String objectName, String filterFieldName, Object filterValue)
	{
		return findAllByAnyValues(objectName, filterFieldName, new Set<Object>
		{
				filterValue
		});
	}

	/**
	 * @description Method will query all fields for given object, filtering list set of values
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 * @param getRelatedObject as input
	 *
	 * @return findResults
	 */
	public static List<SObject> findAllByAnyValues(String objectName, String filterFieldName, Set<Object> filterValues, Boolean getRelatedObject)
	{
		List<SObject> findResults = new List<SObject>();

		//if the current user has no access to object then return empty results
		if(CMN_UTIL_System.objectQueryable(objectName))
		{
			//Loop through all fields and put them in set if user has access to the field
			Set<String> selectFields = getRelatedObject ? CMN_UTIL_System.getNestableFieldNames(objectName) : CMN_UTIL_System.getAllFieldNames(objectName);

			//Now compose query and filter
			CMN_DAL_Search.SOQLSearchParameters parameters = new CMN_DAL_Search.SOQLSearchParameters(objectName);

			//Set up additional parameters for the search
			parameters.searchFields.clear();
			parameters.selectFields = selectFields;

			CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

			if(String.isNotBlank(filterFieldName) && !filterValues.isEmpty())
			{
				List<Object> inFilterValues = new List<Object>(filterValues);
				andCondition.add(new CMN_SOQL_Query.SetCondition(filterFieldName, CMN_SOQL_Query.Operator.INX, inFilterValues));
			}

			parameters.searchConditions = andCondition;

			findResults = getObjects(parameters);
		}

		return findResults;
	}

	/**
	 * @description Method will query all fields for given object, filtering list set of values
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 *
	 * @return findResults
	 */
	public static List<SObject> findAllByAnyValues(String objectName, String filterFieldName, Set<Object> filterValues)
	{
		return findAllByAnyValues(objectName, filterFieldName, filterValues, false);
	}

	/**
	 * @description Method will query all fields for given object by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValues as input
	 * @param getRelatedObject as input
	 *
	 * @return findAllByAnyValues
	 */
	public static List<SObject> findAllById(String objectName, String filterFieldName, Set<Id> filterValues, Boolean getRelatedObject)
	{
		Set<Object> objectValues = new Set<Object>();

		for(Id filterValue : filterValues)
		{
			if(filterValue != null)
			{
				objectValues.add(filterValue);
			}
		}

		return findAllByAnyValues(objectName, filterFieldName, objectValues, getRelatedObject);
	}

	/**
	 * @description Method will query all fields for given object by Id
	 *
	 * @param objectName as input
	 * @param filterFieldName as input
	 * @param filterValue as input
	 * @param getRelatedObject as input
	 *
	 * @return findAllByAnyValues
	 */
	public static List<SObject> findAllById(String objectName, String filterFieldName, Id filterValue, Boolean getRelatedObject)
	{
		return findAllById(objectName, filterFieldName, new Set<Id> {filterValue}, getRelatedObject);
	}

	/**
	 * @description used for inner select conditional queries (wrapper method)
	 *
	 * @param whereInField as input
	 * @param selectParameters as input
	 *
	 * @return new SelectWhereInCondition
	 */
	public static SelectWhereInCondition selectWhereIn(String whereInField, SOQLSearchParameters selectParameters)
	{
		return new SelectWhereInCondition(whereInField, selectParameters);
	}

	/**
	 * @description support SELECT where conditions to a lookup
	 * e.g. WHERE <whereInField> IN (SELECT Id FROM XYZ WHERE Active__c = TRUE)
	 */
	public class SelectWhereInCondition implements CMN_SOQL_Query.Condition
	{
		private String whereInField;
		private SOQLSearchParameters selectParameters;

		/**
		 * @description Construct the search conditions
		 *
		 * @param whereInField - The filed to filter
		 * @param selectParameters - The parameters used to construct the search condition
		 */
		public SelectWhereInCondition(String whereInField, SOQLSearchParameters selectParameters)
		{
			this.whereInField = whereInField;
			this.selectParameters = selectParameters;
		}

		/**
		 * @description Convert the SOQL statement to a string
		 *
		 * @return String - The SOQL statement as a string
		 */
		public String toSoql()
		{
			return whereInField + SOQL_IN + '(' + soqlQuery(selectParameters).queryString + ')';
		}

		/**
		 * @description Convert a SOQL Options (Param) to SOQL
		 *
		 * @param param - CMN_SOQL_Query.SoqlOptions
		 *
		 * @return - The SOQL Query String
		 */
		public String toSoql(CMN_SOQL_Query.SoqlOptions param)
		{
			return toSoql();
		}
	}

	/**
	 * @description used for inner select conditional queries (wrapper method)
	 *
	 * @param whereNotInField as input
	 * @param selectParameters as input
	 *
	 * @return select wSelectWhereNotInCondition
	 */
	public static SelectWhereNotInCondition selectWhereNotIn(String whereNotInField, SOQLSearchParameters selectParameters)
	{
		return new SelectWhereNotInCondition(whereNotInField, selectParameters);
	}

	/**
	 * @description support SELECT where conditions to a lookup
	 * e.g. WHERE <whereNotInField> NOT IN (SELECT Id FROM XYZ WHERE Active__c = TRUE)
	 */
	public class SelectWhereNotInCondition implements CMN_SOQL_Query.Condition
	{
		private String whereNotInField;
		private SOQLSearchParameters selectParameters;

		/**
		 * @description Construct the search conditions
		 *
		 * @param whereNotInField - The field representing the NOT IN
		 * @param selectParameters - The parameters used to construct the search condition
		 */

		public SelectWhereNotInCondition(String whereNotInField, SOQLSearchParameters selectParameters)
		{
			this.whereNotInField = whereNotInField;
			this.selectParameters = selectParameters;
		}

		/**
		 * @description Convert the SOQL statement to a string
		 *
		 * @return String - The SOQL statement as a string
		 */
		public String toSoql()
		{
			return whereNotInField + SOQL_NOT_IN + '(' + soqlQuery(selectParameters).queryString + ')';
		}

		/**
		 * @description Convert a SOQL Options (Param) to SOQL
		 *
		 * @param param - CMN_SOQL_Query.SoqlOptions
		 *
		 * @return - The SOQL Query String
		 */
		public String toSoql(CMN_SOQL_Query.SoqlOptions param)
		{
			return toSoql();
		}
	}
}