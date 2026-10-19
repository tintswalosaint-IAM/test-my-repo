/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 * <p/>
 * <p>Read record wrapper around CMN_SOQL_Query</p>
 * Provides methods to query SObjects generically wrappers CMN_DAL_Search for common search functions
 * on SObjects
 * SObjectSelector can be used statically (static methods for convenience or as its own instance)
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_SObjectSelector implements ISObjectSelector
{
	public final static Set<String> NULL_SET_OF_STRINGS = null;

	public final static Set<String> DEFAULT_FIELDS = new Set<String>
	{
			CMN_DAL_SObjectDomain.FIELD_ID,
			CMN_DAL_SObjectDomain.FIELD_NAME
	};

	private SObjectType sobjectType;

	/**
	 * @description Constructor
	 *
	 * @param sObjectType
	 */
	public CMN_DAL_SObjectSelector(SObjectType sObjectType)
	{
		this.sobjectType = sObjectType;
	}

	/**
	 * @description Interface to ISObjectSelector
	 */
	public interface ISObjectSelector
	{
		Schema.SObjectType sObjectType();
		List<SObject> selectSObjectsById(Set<Id> idSet);
	}

	/**
	 * @description Determine the object selector object type
	 *
	 * @return SObjectType
	 */
	public SObjectType sObjectType()
	{
		return this.sobjectType;
	}

	/**
	 * @description Select SObjects by Id
	 *
	 * @param idSet = Id's to search
	 *
	 * @return A list of the filtered SObjects
	 */
	public virtual List<SObject> selectSObjectsById(Set<Id> idSet)
	{
		return findById(this.sobjectType, idSet, DEFAULT_FIELDS);
	}

	/**
	 * @description This method is use initialise search parameters so that Developer can insert additional search parameters like `addOrderByField`
	 *
	 * @param objectName object against which to search
	 * @param searchField the field against which to filter
	 * @param searchValues the values to match
	 * @param selectedFields fields to query
	 *
	 * @return a populated search parameter object
	 */
	public static CMN_DAL_Search.SOQLSearchParameters initialiseParameters(String objectName, String searchField, Set<String> searchValues, Set<String> selectedFields)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(objectName);

		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		searchParameters.searchFields.clear();

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = selectedFields;

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(searchField, CMN_SOQL_Query.Operator.INX, CMN_UTIL_System.setToList(searchValues)));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(searchField, CMN_SOQL_Query.Operator.NOT_EQUALS, null));

		searchParameters.searchConditions.add(andCondition);

		return searchParameters;
	}

	/**
	 * @description This method is use to get the List of SObject
	 *
	 * @param objectName as input
	 * @param searchField as input
	 * @param searchValues as input
	 * @param selectedFields as input
	 *
	 * @return searchParameters
	 */
	public static List<SObject> findByField(
			String objectName,
			String searchField,
			Set<String> searchValues,
			Set<String> selectedFields
	)
	{
		//No point in running query with empty search values; also a set condition is invalid if empty.
		if(searchValues.isEmpty())
		{
			return new List<SObject>();
		}

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(
				objectName
		);

		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		searchParameters.searchFields.clear();

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = selectedFields;

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(
				new CMN_SOQL_Query.SetCondition(
						searchField,
						CMN_SOQL_Query.Operator.INX,
						CMN_UTIL_System.setToList(searchValues)
				)
		);
		andCondition.add(
				new CMN_SOQL_Query.FieldCondition(
						searchField,
						CMN_SOQL_Query.Operator.NOT_EQUALS,
						null
				)
		);

		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description This method is use to get the unique record of SObject
	 *
	 * @param objectName as input
	 * @param searchField as input
	 * @param searchValue as input
	 * @param selectedFields as input
	 * @param mustBeUnique as input
	 *
	 * @return searchParameters
	 */
	public static SObject findByField(
			String objectName,
			String searchField,
			String searchValue,
			Set<String> selectedFields,
			Boolean mustBeUnique
	)
	{
		List<SObject> foundObjects = findByField(
				objectName,
				searchField,
				new Set<String> {searchValue},
				selectedFields
		);

		if(foundObjects.isEmpty())
		{
			return null;
		}
		else if(foundObjects.size() > 1)
		{
			if(mustBeUnique)
			{
				throw new SearchException(
						'More than one ' +
								objectName +
								' found when querying ' +
								searchField +
								' with ' +
								searchValue
				);
			}
			else
			{
				return null;
			}
		}
		else
		{
			return foundObjects[0];
		}
	}

	/**
	 * @description This method is use to get fields
	 *
	 * @param objectType as input
	 * @param searchField as input
	 * @param searchValue as input
	 * @param selectedFields as input
	 * @param mustBeUnique as input
	 *
	 * @return sobject
	 */
	public static SObject findByField(
			SObjectType objectType,
			SObjectField searchField,
			String searchValue,
			Set<String> selectedFields,
			Boolean mustBeUnique
	)
	{
		return findByField(
				objectType.getDescribe().getLocalName(),
				searchField.getDescribe().getLocalName(),
				searchValue,
				selectedFields,
				mustBeUnique
		);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectName as input
	 * @param itemId as input
	 * @param requiredFields as input
	 *
	 * @return sobject
	 */
	public static SObject findById(
			String objectName,
			Id itemId,
			Set<String> requiredFields
	)
	{
		return findByField(
				objectName,
				CMN_DAL_SObjectDomain.FIELD_ID,
				String.valueOf(itemId),
				requiredFields,
				true
		);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectName as input
	 * @param searchField as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findById(
			String objectName,
			String searchField,
			Set<Id> itemIds,
			Set<String> requiredFields
	)
	{
		Set<String> itemIdStrings = new Set<String>();

		for(Id itemId : itemIds)
		{
			itemIdStrings.add(String.valueOf(itemId));
		}

		return findByField(objectName, searchField, itemIdStrings, requiredFields);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectName as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> findById(
			String objectName,
			Set<Id> itemIds,
			Set<String> requiredFields
	)
	{
		return findById(
				objectName,
				CMN_DAL_SObjectDomain.FIELD_ID,
				itemIds,
				requiredFields
		);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectType as input
	 * @param itemId as input
	 * @param requiredFields as input
	 *
	 * @return sobject
	 */
	public static SObject findById(
			SObjectType objectType,
			Id itemId,
			Set<String> requiredFields
	)
	{
		return findByField(
				objectType.getDescribe().getLocalName(),
				CMN_DAL_SObjectDomain.FIELD_ID,
				String.valueOf(itemId),
				requiredFields,
				true
		);
	}

	/**
	 * @description This method is use to get Ids
	 *
	 * @param objectType as input
	 * @param itemIds as input
	 * @param requiredFields as input
	 *
	 * @return list of sobjects found by ids
	 */
	public static List<SObject> findById(
			SObjectType objectType,
			Set<Id> itemIds,
			Set<String> requiredFields
	)
	{
		return findById(
				objectType.getDescribe().getLocalName(),
				itemIds,
				requiredFields
		);
	}

	/**
	 * @description This method is use to get name
	 *
	 * @param objectName as input
	 * @param nameValue as input
	 * @param requiredFields as input
	 *
	 * @return sobject found by name
	 */
	public static SObject findByName(
			String objectName,
			String nameValue,
			Set<String> requiredFields
	)
	{
		return findByField(
				objectName,
				CMN_DAL_SObjectDomain.FIELD_NAME,
				nameValue,
				requiredFields,
				true
		);
	}

	/**
	 * @description This method is use to get name
	 *
	 * @param objectType as input
	 * @param nameValue as input
	 * @param requiredFields as input
	 *
	 * @return sobject found by name
	 */
	public static SObject findByName(
			SObjectType objectType,
			String nameValue,
			Set<String> requiredFields
	)
	{
		return findByName(
				objectType.getDescribe().getLocalName(),
				nameValue,
				requiredFields
		);
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 *
	 * @return sobject
	 */
	public static SObject query(String id)
	{
		return first(query(new Set<String> {id}, NULL_SET_OF_STRINGS));
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 * @param fields to return
	 *
	 * @return sobject
	 */
	public static SObject query(String id, List<String> fields)
	{
		return first(query(new Set<String> {id}, fields));
	}

	/**
	 * @description query by id only
	 *
	 * @param id as input
	 * @param fields to return
	 *
	 * @return sobject
	 */
	public static SObject query(String id, Set<String> fields)
	{
		return first(query(new Set<String> {id}, fields));
	}

	/**
	 * @description query by list of same type ids
	 *
	 * @param ids as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids)
	{
		return query(ids, NULL_SET_OF_STRINGS);
	}

	/**
	 * @description query by set of same type ids
	 *
	 * @param ids as input
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids)
	{
		return query(ids, NULL_SET_OF_STRINGS);
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids, List<String> fields)
	{
		return query(CMN_UTIL_Set.listToSet(ids), CMN_UTIL_Set.listToSet(fields));
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(List<String> ids, Set<String> fields)
	{
		return query(CMN_UTIL_Set.listToSet(ids), fields);
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids, List<String> fields)
	{
		return query(ids, CMN_UTIL_Set.listToSet(fields));
	}

	/**
	 * @description query by ids and specify fields to return
	 *
	 * @param ids as input
	 * @param fields to return
	 *
	 * @return list of sobjects
	 */
	public static List<SObject> query(Set<String> ids, Set<String> fields)
	{
		if(ids == null || ids.size() <= 0)
		{
			throw new IllegalArgumentException(
					'ids argument must not be empty: ' + ids
			);
		}
		final Set<String> distinctKeyPrefixes = left(trim(ids), 3);
		if(distinctKeyPrefixes.size() > 1)
		{
			//ruh-roh, someone mixed types
			throw new IllegalArgumentException(
					'ids argument invalid:  multiple SObject types detected: ' +
							distinctKeyPrefixes
			);
		}
		final CMN_SOQL_Builder soql = new CMN_SOQL_Builder()
				.fromX(
						retrieveObjectName(CMN_UTIL_Set.setToList(distinctKeyPrefixes).get(0))
				)
				.whereX(
						new CMN_SOQL_Query.SetCondition('id').inX(CMN_UTIL_Set.setToList(ids))
				);
		if(fields == null || fields.size() <= 0)
		{
			soql.selectAll();
		}
		else
		{
			soql.selectX(fields);
		}
		return Database.query(soql.toSoql());
	}

	/**
	 * @description get object from record id
	 *
	 * @param recordId as input
	 *
	 * @return sobject type name
	 */
	public static String retrieveObjectName(String recordId)
	{
		String returnValue = null;
		final String keyPrefixToMatch = CMN_UTIL_String.left(recordId, 3);
		String keyPrefix = null;
		final Map<String, Schema.SObjectType> publicDescribe = Schema.getGlobalDescribe();
		for(String objectNameKey : publicDescribe.keySet())
		{
			keyPrefix = publicDescribe.get(objectNameKey)
					.getDescribe()
					.getKeyPrefix();
			if(
					CMN_UTIL_String.isNotBlank(keyPrefix) &&
							CMN_UTIL_String.equals(keyPrefix, keyPrefixToMatch)
					)
			{
				returnValue = objectNameKey;
				break;
			}
		}
		if(CMN_UTIL_String.isBlank(returnValue))
		{
			throw new IllegalArgumentException(
					'ids argument invalid: key prefix not found: ' + keyPrefixToMatch
			);
		}
		return returnValue;
	}

	/**
	 * @description utility to left substring a collection of strings
	 *
	 * @param strings as input
	 * @param len as input to indicate lenght of left substring operation
	 *
	 * @return trimmed strings collection
	 */
	private static Set<String> left(Set<String> strings, Integer len)
	{
		Set<String> returnValue = null;
		if(strings != null || !strings.isEmpty())
		{
			returnValue = new Set<String>();
			for(String str : strings)
			{
				returnValue.add(CMN_UTIL_String.left(str, len));
			}
		}
		return returnValue;
	}

	/**
	 * @description utility to trim collection of strings
	 *
	 * @param strings as input
	 *
	 * @return trimmed strings collection
	 */
	private static Set<String> trim(Set<String> strings)
	{
		Set<String> returnValue = null;
		if(strings != null || !strings.isEmpty())
		{
			returnValue = new Set<String>();
			for(String str : strings)
			{
				returnValue.add(CMN_UTIL_String.trim(str));
			}
		}
		return returnValue;
	}

	/**
	 * @description utility to return first record in record list
	 *
	 * @param records as input
	 *
	 * @return first sobject
	 */
	public static SObject first(List<SObject> records)
	{
		SObject returnValue = null;
		if(records != null && records.size() > 0)
		{
			returnValue = records.get(0);
		}
		return returnValue;
	}
}