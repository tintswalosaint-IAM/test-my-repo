/**
 * @description General Utility Class which will contain common routines that can be reused within the system
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_UTIL_System
{
	private static Map<String, Schema.DescribeSObjectResult> objectDescribeMap = new Map<String, DescribeSObjectResult>();
	private static Map<String, Map<String, Schema.SObjectField>> objectFieldByNameMap = new Map<String, Map<String, Schema.SObjectField>>();
	private static Map<String, Map<String, Schema.SObjectField>> objectFieldByReferenceMap = new Map<String, Map<String, Schema.SObjectField>>();
	private static final String XM_ASSERT_VALUE = 'Value mismatch on {0}, for {1}. Expected {2}, got {3}. {4}';
	private static final String ERROR_NULL_POINTER_TYPE = 'NullPointerException - Input object is null';
	@TestVisible
	private static final Integer DEFAULT_NESTED_LEVELS = 1;
	private static final Integer MAX_NESTED_LEVELS = 5;
	private static final String RELATIONSHIP_SUFFIX = '__r';
	private static final String CUSTOM_FIELD_SUFFIX = '__c';
	private static final String ID_FIELD_SUFFIX = 'Id';
	private static final String DATE_TYPE = 'Date';

  /**
   * @description Class using for Exceptions
   */
  public class AssertionException extends Exception {
  }

  /**
   * @description Class using for Exceptions
   */
  public virtual class JlException extends Exception {
  }

  /**
   * @description Class using to throw Exceptions
   */
  public static void justThrow() {
    throw new JlException();
  }

  /**
   * @description Class using to throw Exceptions
   *
   * @param message as input
   */
  public static void justThrow(String message) {
    throw new JlException(message);
  }

  /**
   * @description Class using to throw Exceptions
   *
   * @param subject as input
   * @param fieldName as input
   * @param expected as input
   * @param got as input
   * @param message as input
   */
	public static void throwFieldValueAssertionException(String subject, String fieldName, Object expected, Object got, String message)
	{
		throw new AssertionException(String.format(XM_ASSERT_VALUE, new List<String>
		{
				subject, fieldName, String.valueOf(expected), String.valueOf(got), message
		}));
	}

  /**
   * @description Will combine all the objects in all the maps list into a single object list
   *
   * @param objectMap A map where the value is a list of object
   *
   * @return objectList
   */
	public static List<SObject> extractListFromMap(Map<String, List<SObject> > objectMap)
	{
		List<SObject> objectList = new List<SObject>();

		if((objectMap != null) && (objectMap.values() != null) && !objectMap.values().isEmpty())
		{
			for(List<SObject> valuesList : objectMap.values())
			{
				objectList.addAll(valuesList);
			}
		}

		return objectList;
	}

  /**
   * @description Will check the the match
   *
   * @param obj as input
   * @param filter as input
   *
   * @return result
   */
	public static Boolean matches(SObject obj, Map<String, Object> filter)
	{
		Boolean bMatches;

		for(String name : filter.keySet())
		{
			Object fieldVal = obj.get(name);
			Object filterVal = filter.get(name);

      // Special case: we assume a match when [Boolean] false == null.
      // Extend these special cases, as needed (e.g. String null = ''). Also, we may want to specify a "strict match" at some stage.
			bMatches = filterVal instanceof Boolean && ((Boolean)filterVal == false) ? fieldVal == false || fieldVal == null : fieldVal == filterVal;
			if(!bMatches)
			{
				return false;
      }
    }

    return true;
  }

  /**
   * @description Will check and find the object
   *
   * @param objects as input
   * @param fieldName as input
   * @param value as input
   *
   * @return result
   */
	public static List<SObject> findWhere(List<SObject> objects, String fieldName, Object value)
	{
		return findWhere(objects, new Map<String, Object>
		{
				fieldName => value
		});
	}

  /**
   * @description Will check and find the object
   *
   * @param objects as input
   * @param filter as input
   *
   * @return result
   */
  public static List<SObject> findWhere(
    List<SObject> objects,
    Map<String, Object> filter
  ) {
    List<SObject> result = new List<SObject>();

    for (SObject obj : objects) {
      if (matches(obj, filter)) {
        result.add(obj);
      }
    }

    return result;
  }

  /**
   * @description Will check and find the record in the object
   *
   * @param objects as input
   * @param fieldName as input
   * @param values as input
   *
   * @return result
   */
  public static List<SObject> findWhereIn(
    List<SObject> objects,
    String fieldName,
    List<Object> values
  ) {
    Set<Object> valueSet = new Set<Object>(values);
    Object fieldVal;
    List<SObject> result = new List<SObject>();

    for (SObject obj : objects) {
      fieldVal = obj.get(fieldName);

      if (valueSet.contains(fieldVal)) {
        result.add(obj);
      }
    }

    return result;
  }

  /**
   * @description Will check the object which not found
   *
   * @param objects as input
   * @param fieldName as input
   * @param value as input
   *
   * @return omitWhere
   */
  public static List<SObject> omitWhere(
    List<SObject> objects,
    String fieldName,
    Object value
  ) {
    return omitWhere(objects, new Map<String, Object>{ fieldName => value });
  }

  /**
   * @description This method is use to find the list of Sobject
   *
   * @param objects as input
   * @param filter as input
   *
   * @return result
   */
  public static List<SObject> omitWhere(
    List<SObject> objects,
    Map<String, Object> filter
  ) {
    List<SObject> result;

    if (objects != null) {
      result = new List<SObject>();

      for (SObject obj : objects) {
        if (!matches(obj, filter)) {
          result.add(obj);
        }
      }
    }

    return result;
  }

  /**
   * @description This method is use to get the set Id of of Sobject
   *
   * @param masterList as input
   * @param toBeOmitted as input
   *
   * @return result
   */
  public static Set<Id> omit(Set<Id> masterList, Set<Id> toBeOmitted) {
    Set<Id> result;

    if (masterList != null) {
      result = masterList.clone();
      result.removeAll(toBeOmitted);
    }

    return result;
  }

  /**
   * @description This method is use to concat
   *
   * @param set1 as input
   * @param set2 as input
   *
   * @return result
   */
  public static Set<Id> concat(Set<Id> set1, Set<Id> set2) {
    Set<Id> result = new Set<Id>(set1);

    result.addAll(set2);
    return result;
  }

  /**
   * @description This method is use to check the items exclude from list
   *
   * @param sourceItems as input
   * @param excludeItems as input
   *
   * @return resultList
   */
  public static List<SObject> excludeItemsFromList(
    List<SObject> sourceItems,
    List<SObject> excludeItems
  ) {
    List<SObject> resultList = new List<SObject>();

    if (sourceItems != null) {
      Set<SObject> objectSet = new Set<SObject>(sourceItems);
      objectSet.removeAll(excludeItems);
      resultList.addAll(objectSet);
    }

    return resultList;
  }

  /**
   * @description This method is use to check the object field
   *
   * @param so as input
   * @param fieldName as input
   *
   * @return exceptions
   */
  public static Boolean hasSObjectField(SObject so, String fieldName) {
    try {
      so.get(fieldName);
      return true;
    } catch (Exception ex) {
      return false;
    }
  }

  /**
   * @description This method is use to get the list of Object based on Ids
   *
   * @param objects as input
   * @param fieldName as input
   * @param removeNulls as input
   *
   * @return Ids
   */
  public static Set<Id> extractListIds(
    List<SObject> objects,
    String fieldName,
    Boolean removeNulls
  ) {
    Set<Id> idSet = new Set<Id>();

    Id itemId;

    if (objects != null) {
      for (SObject item : objects) {
        itemId = (Id) item.get(fieldName);
        if (!removeNulls || (itemId != null)) {
          idSet.add(itemId);
        }
      }
    }

    return idSet;
  }

  /**
   * @description This method is use to get the list of Object with field name
   *
   * @param objects as input
   * @param fieldName as input
   *
   * @return extractListIds
   */
  public static Set<Id> extractListIds(
    List<SObject> objects,
    String fieldName
  ) {
    return extractListIds(objects, fieldName, false);
  }

  /**
   * @description This method is use to get the list of Object
   *
   * @param objects as input
   *
   * @return extractListIds
   */
  public static Set<Id> extractListIds(List<SObject> objects) {
    return extractListIds(objects, false);
  }

  /**
   * @description This method is use to get the list of Object filter by Null value.
   *
   * @param objects as input
   * @param removeNulls as input
   *
   * @return result
   */
  public static Set<Id> extractListIds(
    List<SObject> objects,
    Boolean removeNulls
  ) {
    Set<Id> result = new Set<Id>();

    if (objects != null) {
      for (SObject item : objects) {
        if (!removeNulls || item.Id != null) {
          result.add(item.Id);
        }
      }
    }

    return result;
  }

  /**
   * @description This method is use to get the list of Object filter by field name.
   *
   * @param objects as input
   * @param fieldName as input
   *
   * @return result
   */
  public static List<String> extractListValues(
    List<SObject> objects,
    String fieldName
  ) {
    List<String> result = new List<String>();

    if (objects != null) {
      for (SObject item : objects) {
        result.add((String) item.get(fieldName));
      }
    }

    return result;
  }

  /**
   * @description This method is use to get the single Object by field name
   *
   * @param objects as input
   * @param fieldName as input
   *
   * @return result
   */
  public static Set<String> extractSetValues(
    List<SObject> objects,
    String fieldName
  ) {
    Set<String> result = new Set<String>();

    if (objects != null) {
      for (SObject item : objects) {
        result.add((String) item.get(fieldName));
      }
    }

    return result;
  }

  /**
   * @description This method is use to check trimset
   *
   * @param idList as input
   *
   * @return result
   */
  public static Set<Id> trimSet(Set<Id> idList) {
    Set<Id> result = new Set<Id>();

    for (Id item : idList) {
      if (item != null) {
        result.add(item);
      }
    }

    return result;
  }

  /**
   * @description This method is use to check trimset
   *
   * @param stringSet as input
   *
   * @return result
   */
  public static Set<String> trimSet(Set<String> stringSet) {
    Set<String> result = new Set<String>();

    for (String item : stringSet) {
      if (String.isNotBlank(item)) {
        result.add(item);
      }
    }

    return result;
  }

  /**
   * @description This method is use to get the list of string converted from list
   *
   * @param delimitedString as input
   * @param delimiter as input
   *
   * @return stringsList
   */
  public static List<String> convertStringToList(
    String delimitedString,
    String delimiter
  ) {
    List<String> stringsList = new List<String>();

    if (String.isNotBlank(delimitedString)) {
      stringsList = CMN_UTIL_String.splitByWholeSeparator(
        delimitedString,
        delimiter
      );
    }

    return stringsList;
  }

  /**
   * @description This method is use to get the list of string converted from set
   *
   * @param delimitedString as input
   * @param delimiter as input
   *
   * @return stringsSet
   */
  public static Set<String> convertStringToSet(
    String delimitedString,
    String delimiter
  ) {
    Set<String> stringsSet = new Set<String>();

    stringsSet.addAll(convertStringToList(delimitedString, delimiter));

    return stringsSet;
  }

  /**
   * @description This method is use to get the set of Map converted from list --1
   *
   * @param objectList as input
   * @param objectFieldName as input
   * @param keyFieldName as input
   *
   * @return objectMap
   */
  public static Map<Id, Set<Id>> convertListToMapSet(
    List<SObject> objectList,
    String objectFieldName,
    String keyFieldName
  ) {
    Map<Id, Set<Id>> objectMap = new Map<Id, Set<Id>>();

    if (objectList != null) {
      for (SObject item : objectList) {
        Id idFromField = (Id) item.get(objectFieldName);

        if (!objectMap.containsKey(idFromField)) {
          Set<Id> setInMap = new Set<Id>();
          setInMap.add((Id) item.get(keyFieldName));
          objectMap.put(idFromField, setInMap);
        } else {
          Set<Id> setInMap = objectMap.get(idFromField);
          setInMap.add((Id) item.get(keyFieldName));
        }
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the Map converted from list --2
   *
   * @param objectList as input
   * @param objectFieldName as input
   *
   * @return objectMap
   */
  public static Map<Id, List<SObject>> convertListToMap(
    List<SObject> objectList,
    String objectFieldName
  ) {
    Map<Id, List<SObject>> objectMap = new Map<Id, List<SObject>>();

    if (objectList != null) {
      for (SObject item : objectList) {
        Id idFromField = (Id) item.get(objectFieldName);

        if (!objectMap.containsKey(idFromField)) {
          List<SObject> listInMap = new List<SObject>();
          listInMap.add(item);
          objectMap.put(idFromField, listInMap);
        } else {
          List<SObject> listInMap = objectMap.get(idFromField);
          listInMap.add(item);
        }
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the single Map converted from list --3
   *
   * @param objectList as input
   * @param objectFieldName as input
   *
   * @return objectMap
   */
  public static Map<Id, SObject> convertListToSingleMap(
    List<SObject> objectList,
    String objectFieldName
  ) {
    Map<Id, SObject> objectMap = new Map<Id, SObject>();

    if (objectList != null) {
      for (SObject item : objectList) {
        Id idFromField = (Id) item.get(objectFieldName);
        objectMap.put(idFromField, item);
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the List map coverted from string map
   *
   * @param objectList as input
   * @param objectFieldName as input
   *
   * @return objectMap
   */
  public static Map<String, List<SObject>> convertListToStringMap(
    List<SObject> objectList,
    String objectFieldName
  ) {
    Map<String, List<SObject>> objectMap = new Map<String, List<SObject>>();

    if (objectList != null) {
      for (SObject item : objectList) {
        String idFromField = (String) item.get(objectFieldName);

        List<SObject> listInMap = objectMap.get(idFromField);

        if (listInMap == null) {
          listInMap = new List<SObject>();
          objectMap.put(idFromField, listInMap);
        }

        listInMap.add(item);
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the single Map converted from list
   *
   * @param objectList as input
   * @param objectFieldName as input
   *
   * @return objectMap
   */
  public static Map<String, SObject> convertListToSingleStringMap(
    List<SObject> objectList,
    String objectFieldName
  ) {
    Map<String, SObject> objectMap = new Map<String, SObject>();

    if (objectList != null && !objectList.isEmpty()) {
      for (SObject item : objectList) {
        String idFromField = (String) item.get(objectFieldName);
        objectMap.put(idFromField, item);
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to create the map of uppercase key and sobject record from list of sObject
   * key is identified based on objectFieldName
   *
   * @param objectList as input
   * @param objectFieldName as input
   *
   * @return objectMap
   */
  public static Map<String, SObject> convertListToSingleUpperStringMap(
    List<SObject> objectList,
    String objectFieldName
  ) {
    Map<String, SObject> objectMap = new Map<String, SObject>();

    if (objectList != null && !objectList.isEmpty()) {
      for (SObject item : objectList) {
        String idFromField = (String) item.get(objectFieldName);
        objectMap.put(idFromField.toUpperCase(), item);
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the component key
   *
   * @param obj as input
   * @param objectFieldNames as input
   *
   * @return result
   */
  public static String getCompoundKey(SObject obj, String[] objectFieldNames) {
    String result = CMN_UTIL_String.EMPTY;

    for (String field : objectFieldNames) {
      result += String.valueOf(obj.get(field));
    }

    return result;
  }

  /**
   * @description This method is use to get the single Map of SObject converted from single map
   *
   * @param objectList as input
   * @param objectFieldNames as input
   *
   * @return objectMap
   */
  public static Map<String, SObject> convertListToSingleMap(
    List<SObject> objectList,
    String[] objectFieldNames
  ) {
    Map<String, SObject> objectMap = new Map<String, SObject>();

    if (objectList != null) {
      for (SObject item : objectList) {
        objectMap.put(getCompoundKey(item, objectFieldNames), item);
      }
    }

    return objectMap;
  }

  /**
   * @description This method is use to get the List of Ids
   *
   * @param aSet as input
   *
   * @return set
   */
  public static List<Id> setToList(Set<Id> aSet) {
    return aSet != null ? new List<Id>(aSet) : null;
  }

  /**
   * @description This method is use to get the List of string
   *
   * @param aSet as input
   *
   * @return returnValue
   */
  public static List<String> setToList(Set<String> aSet) {
    List<String> returnValue = null;

    if (aSet != null) {
      returnValue = new List<String>(aSet);
    }
    return returnValue;
  }

  /**
   * @description This method is use to get the Object Id from SObject
   *
   * @param objectId as input
   *
   * @return returnValue
   */
  public static String getObjectNameFromId(Id objectId) {
    Schema.SObjectType sobjectType = getSObjectTypeById(objectId);
    return sobjectType.getDescribe().getName();
  }
  /**
   * @description method is use return Object type
   *
   * @param objectId as input
   *
   * @return result
   **/
  public static Schema.SObjectType getSObjectTypeById(Id objectId) {
    return objectId.getSobjectType();
  }


  /**
   * @description This method is use to get the Object by name
   *
   * @param objectTypeName as input
   *
   * @return result
   */
  public static SObjectType getSObjectTypeByName(String objectTypeName) {
    DescribeSObjectResult result = getObjectResult(objectTypeName);

    return result == null ? null : result.getSObjectType();
  }

  /**
   * @description This method is use to get the list of picklist entry
   *
   * @param objectName as input
   * @param fieldName as input
   *
   * @return getPicklistEntries
   */
  public static List<Schema.PicklistEntry> getPicklistEntries(
    String objectName,
    String fieldName
  ) {
    Schema.SObjectType token = getSObjectTypeByName(objectName);

    return getPicklistEntries(token, fieldName);
  }

  /**
   * @description This method is use to get the list of picklist entry
   *
   * @param token as input
   * @param fieldName as input
   *
   * @return getPicklistValues
   */
  public static List<Schema.PicklistEntry> getPicklistEntries(
    Schema.SObjectType token,
    String fieldName
  ) {
    Schema.DescribeSObjectResult describe = token.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = describe.fields.getMap();
    return fieldMap.get(fieldName).getDescribe().getPicklistValues();
  }

  /**
   * @description This method is use to get the map of picklist entry
   *
   * @param token as input
   * @param fieldName as input
   *
   * @return getPicklistValues
   */
  public static Map<String, String> getPicklistEntriesMap(
    Schema.SObjectType token,
    String fieldName
  ) {
    List<Schema.PicklistEntry> picklistEntries = getPicklistEntries(
      token,
      fieldName
    );
    Map<String, String> picklistEntriesMap = new Map<String, String>();

    for (Schema.PicklistEntry picklistEntry : picklistEntries) {
      picklistEntriesMap.put(
        picklistEntry.getLabel(),
        picklistEntry.getValue()
      );
    }

    return picklistEntriesMap;
  }

  /**
   * @description Returns a list of values for the relevant field for the passed in SObject name
   *
   * @param objectName as input
   * @param fieldName as input
   *
   * @return list of pickvalues for a particular pick field
   */
  public static List<String> getPicklistValues(
    String objectName,
    String fieldName
  ) {
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
    return getPicklistEntriesMap(objType, fieldName).values();
  }

  /**
   * @description method is use return the date from dateTime
   *
   * @param inDate as input
   *
   * @return result
   **/
  public static Date dateTimeToDate(Datetime inDate) {
    return Date.newInstance(inDate.year(), inDate.month(), inDate.day());
  }


  /**
   * @description Using this method to test helper methods
   *
   * @param items as input
   * @param message as input
   **/
  public static void assertEmptyList(List<SObject> items, String message) {
    assertSizeEquals(items, 0, message);
  }

  /**
   * @description Using this method to test helper methods
   *
   * @param items as input
   * @param size as input
   * @param message as input
   **/
  public static void assertSizeEquals(
    List<SObject> items,
    Integer size,
    String message
  ) {
    if (items.size() != size) {
      String msg = String.format(
        'Assertion error: List is size {0}, and should be {1}. {2}',
        new List<String>{
          String.valueOf(items.size()),
          String.valueOf(size),
          message != null ? ', for: ' + message : ''
        }
      );
      throw new AssertionException(msg);
    }
  }

  /**
   * @description Using this method to test helper methods
   *
   * @param set1 as input
   * @param set2 as input
   * @param message as input
   **/
  public static void assertIDSetEquals(
    Set<Id> set1,
    Set<Id> set2,
    String message
  ) {
    if (set1.size() != set2.size()) {
      String msg = String.format(
        'Assertion error: Lists of mismatching size {0} and {1}. {2}',
        new List<String>{
          String.valueOf(set1.size()),
          String.valueOf(set2.size()),
          message != null ? ', for: ' + message : ''
        }
      );
      throw new AssertionException(msg);
    }

    for (Id s : set1) {
      if (!set2.contains(s)) {
        String msg = String.format(
          'Assertion error: List content mismatch - Element {0} not found. {1}',
          new List<String>{ s, message != null ? ', for: ' + message : '' }
        );
        throw new AssertionException(msg);
      }
    }
  }

  /**
   * @description Using this method to test helper methods
   *
   * @param set1 as input
   * @param set2 as input
   * @param message as input
   **/
  public static void assertDateSetEquals(
    Set<Date> set1,
    Set<Date> set2,
    String message
  ) {
    if (set1.size() != set2.size()) {
      String msg = String.format(
        'Assertion error: Lists of mismatching size {0} and {1}. {2}',
        new List<String>{
          String.valueOf(set1.size()),
          String.valueOf(set2.size()),
          message != null ? ', for: ' + message : ''
        }
      );
      throw new AssertionException(msg);
    }

    for (Date s : set1) {
      if (!set2.contains(s)) {
        String msg = String.format(
          'Assertion error: List content mismatch - Element {0} not found. {1}',
          new List<String>{
            s.format(),
            message != null ? ', for: ' + message : ''
          }
        );
        throw new AssertionException(msg);
      }
    }
  }

  /**
   * @description Using this method to test helper methods
   *
   * @param obj as input
   * @param fieldNames as input
   * @param values as input
   * @param message as input
   **/
  public static void assertObjectValues(
    SObject obj,
    String[] fieldNames,
    Object[] values,
    String message
  ) {
    String objName = obj.getSObjectType().getDescribe().getLocalName();

    for (Integer i = 0; i < Math.min(fieldNames.size(), values.size()); i++) {
      if (obj.get(fieldNames[i]) != values[i]) {
        throwFieldValueAssertionException(
          objName,
          fieldNames[i],
          values[i],
          obj.get(fieldNames[i]),
          message
        );
      }
    }
  }

  /**
   * @description Remove all matching items from a list
   *
   * @param sourceItems The list containing the original source items
   * @param deleteItems The set of items we want to remove
   *
   * @return A list containing the remaining items after removing matching deleteItems
   */
  public static List<String> removeItems(
    List<String> sourceItems,
    Set<String> deleteItems
  ) {
    List<String> result = new List<String>(sourceItems);

    if (sourceItems.isEmpty() || deleteItems.isEmpty()) {
      return result;
    }

    //Loop backwards through the list so that the index remains valid
    for (Integer i = result.size() - 1; i >= 0; i--) {
      if (deleteItems.contains(result[i])) {
        result.remove(i);
      }
    }

    return result;
  }

  /**
   * @description Get the map of SObjects Field Names
   *
   * @param objectName The name of the object to retrieve fields for
   *
   * @return A Map of SObject Fields, with the key being the FieldName
   */
  public static Map<String, Schema.SObjectField> getObjectFieldMap(
    String objectName
  ) {
    if (objectFieldByNameMap.containsKey(objectName)) {
      return objectFieldByNameMap.get(objectName);
    } else {
      Schema.DescribeSObjectResult describeSObjectResult = getObjectResult(
        objectName
      );

      Map<String, Schema.SObjectField> fieldMap;

      //If the name given doesn't exist, then return empty results
      if (describeSObjectResult != null) {
        fieldMap = describeSObjectResult.fields.getMap();
      }

      objectFieldByNameMap.put(objectName, fieldMap);

      return fieldMap;
    }
  }

  /**
   * @description Get the map of SObjects Fields by Reference
   *
   * @param objectName The name of the object to retrieve fields map for
   *
   * @return A Map of SObject Fields, with the key being the RelationShipName of the field, fields without reference will be excluded
   */
  public static Map<String, SObjectField> getObjectFieldReferenceMap(
    String objectName
  ) {
    Map<String, SObjectField> referenceFieldMap = objectFieldByReferenceMap.get(
      objectName
    );

    if (referenceFieldMap == null) {
      getObjectFieldMap(objectName);

      DescribeSObjectResult describe = getObjectResult(objectName);

      if (describe != null) {
        referenceFieldMap = new Map<String, SObjectField>();

        for (SObjectField objectField : describe.fields.getMap().values()) {
          DescribeFieldResult fieldDescribe = objectField.getDescribe();

          if (fieldDescribe.getType() == DisplayType.REFERENCE) {
            referenceFieldMap.put(
              fieldDescribe.getRelationshipName(),
              objectField
            );
          }
        }
      }

      objectFieldByReferenceMap.put(objectName, referenceFieldMap);
    }

    return referenceFieldMap;
  }

  /**
   * @description method to check the SObjects result
   *
   * @param objectName as input
   *
   * @return result
   */
  public static Schema.DescribeSObjectResult getObjectResult(
    String objectName
  ) {
    if (objectDescribeMap.containsKey(objectName)) {
      return objectDescribeMap.get(objectName);
    } else {
      try {
        List<Schema.DescribeSObjectResult> describeSObjectResults = Schema.describeSObjects(
          new List<String>{ objectName }
        );

        Schema.DescribeSObjectResult describeSObjectResult;

        if (!describeSObjectResults.isEmpty()) {
          describeSObjectResult = describeSObjectResults[0];
        }

        objectDescribeMap.put(objectName, describeSObjectResult);

        return describeSObjectResult;
      } catch (InvalidParameterValueException e) {
        return null;
      }
    }
  }

  /**
   * @description Method to check the Object
   *
   * @param objectName as input
   *
   * @return result
   */
  public static Boolean objectQueryable(String objectName) {
    Schema.DescribeSObjectResult describeSObjectResult = getObjectResult(
      objectName
    );

    //If the name given doesn't exist, then return empty results
    return describeSObjectResult == null
      ? false
      : describeSObjectResult.isQueryable();
  }

  /**
   * @description This method will walk the object tree and return all fields for all objects related by look, it will only walk one level in the tree
   *
   * @param objectName The name of the starting object
   *
   * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
   */
  public static Set<String> getNestableFieldNames(String objectName) {
    return getNestableFieldNames(objectName, DEFAULT_NESTED_LEVELS);
  }

  /**
   * @description This method will walk the object tree and return all fields for all objects related by look
   *
   * @param objectName The name of the starting object
   * @param levels e number of Levels up the tree to go, maximum allowedz for number is 5
   *
   * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
   */
  public static Set<String> getNestableFieldNames(
    String objectName,
    Integer levels
  ) {
    return getNestableFieldNames(
      CMN_UTIL_String.EMPTY,
      objectName,
      Math.min(MAX_NESTED_LEVELS, levels),
      0
    );
  }

  /**
   * @description his method will walk the object tree and return all fields for all objects related by look
   *
   * @param objectPrefix The prefix that should applied to field name for related object
   * @param objectName The name of the starting object
   * @param levels The number of Levels up the tree to go
   * @param currentLevel The level we're currently att
   *
   * @return A list of fields using multipart dot notation; such as for given Contact, you would get Account.Name
   */
  private static Set<String> getNestableFieldNames(
    String objectPrefix,
    String objectName,
    Integer levels,
    Integer currentLevel
  ) {
    Set<String> currentLevelFieldNames = new Set<String>();

    currentLevel++;

    //Only process to a particular level
    if (currentLevel > levels) {
      return currentLevelFieldNames;
    }

    Map<String, Schema.SObjectField> fieldMap = getObjectFieldMap(objectName);

    if (fieldMap != null) {
      for (Schema.SObjectField field : fieldMap.values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();

        if (!IGNORED_SELECT_FIELDS.contains(describe.getLocalName())) {
          String fieldName = describe.getLocalName();

          if (currentLevel > 1) {
            fieldName = objectPrefix + CMN_UTIL_String.DOT + fieldName;
          }

          currentLevelFieldNames.add(fieldName);

          //Make sure we add related object lookup fields into query
          //Ignore any references to objects that could be of multiple types, like owner (which could be a queue or user)
          if (
            describe.getType() == DisplayType.REFERENCE &&
            !describe.namePointing
          ) {
            for (SObjectType objType : describe.getReferenceTo()) {
              String relationshipPrefixName = describe.getRelationshipName();
              String referenceObjectName = objType.getDescribe().getLocalName();

              //Some ID fields cannot be used to follow as a join in a query
              if (String.isBlank(relationshipPrefixName)) {
                continue;
              }

              if (currentLevel > 1) {
                relationshipPrefixName =
                  objectPrefix +
                  CMN_UTIL_String.DOT +
                  relationshipPrefixName;
              }

              currentLevelFieldNames.addAll(
                getNestableFieldNames(
                  relationshipPrefixName,
                  referenceObjectName,
                  levels,
                  currentLevel
                )
              );
            }
          }
        }
      }
    }

    return currentLevelFieldNames;
  }

  /**
   * @description This method is use to get the all field name of Object based on record type
   *
   * @param objectName as input
   * @param includeRecordType as input
   *
   * @return fieldNames
   */
  public static Set<String> getAllFieldNames(
    String objectName,
    Boolean includeRecordType
  ) {
    Set<String> fieldNames = new Set<String>();

    Map<String, Schema.SObjectField> fieldMap = getObjectFieldMap(objectName);

    if (fieldMap != null) {
      for (Schema.SObjectField field : fieldMap.values()) {
        Schema.DescribeFieldResult describe = field.getDescribe();

        if (!IGNORED_SELECT_FIELDS.contains(describe.getLocalName())) {
          fieldNames.add(describe.getLocalName());

          //If we have Record Types then make sure we inject fields for recordtype name
          if (
            !describe.namePointing &&
            !describe.getReferenceTo().isEmpty() &&
            includeRecordType
          ) {
            SObjectType objType = describe.getReferenceTo()[0];
            String relatedObjName = objType.getDescribe().getLocalName();

            if(CMN_DAL_RecordType.OBJECT_NAME.equalsIgnoreCase(relatedObjName)) {
              Set<String> relatedFieldNames = getAllFieldNames(
                relatedObjName,
                false
              );

              for (String relatedFieldName : relatedFieldNames) {
                fieldNames.add(
                  describe.getRelationshipName() +
                  CMN_UTIL_String.DOT +
                  relatedFieldName
                );
              }
            }
          }
        }
      }
    }

    return fieldNames;
  }

  /**
   * @description This method is use to get the all field name of Object based on type
   *
   * @param objectType as input
   *
   * @return Set<String>
   */
  public static Set<String> getAllFieldNames(SObjectType objectType) {
    return getAllFieldNames(objectType.getDescribe().getLocalName());
  }

  /**
   * @description This method is use to get the all field name of Object based on type
   *
   * @param objectName as input
   *
   * @return Set<String>
   */
  public static Set<String> getAllFieldNames(String objectName) {
    return getAllFieldNames(objectName, true);
  }

  /**
   * @description This method is use to get the List of SObject those are split from the list
   *
   * @param sobjectListToSplit as input
   * @param splitSize as input
   *
   * @return sobjectSplitList
   */
  public static List<List<SObject>> splitSobjectList(
    List<SObject> sobjectListToSplit,
    Integer splitSize
  ) {
    List<List<SObject>> sobjectSplitList = new List<List<SObject>>();

    if (sobjectListToSplit.size() > splitSize) {
      List<SObject> sobjectList;

      for (
        Integer i = 0;
        i <
        Math.ceil(
          Decimal.valueOf(sobjectListToSplit.size())
            .divide(Math.max(splitSize, 1), 1)
        );
        i++
      ) {
        sobjectList = new List<SObject>();

        for (
          Integer j = (i * splitSize);
          (j < (i * splitSize) + splitSize) && j < sobjectListToSplit.size();
          j++
        ) {
          sobjectList.add(sobjectListToSplit.get(j));
        }

        sobjectSplitList.add(sobjectList);
      }
    } else {
      sobjectSplitList.add(sobjectListToSplit);
    }

    return sobjectSplitList;
  }

  /**
   * @description Method will return an random item from the list
   *
   * @param objects A List of SObjects
   *
   * @return Depending on List being Empty or not, a Random SObject or Null will be returned;
   */
  public static SObject getRandomItem(List<SObject> objects) {
    return objects == null || objects.isEmpty()
      ? null
      : objects.get(getRandomInteger(objects.size() - 1));
  }

  /**
   * @description Will return a random valid index for a List, note, whilst passing a list of object, any list should be passable
   *
   * @param objects A list, we are just using a list of objects, lists aren't typed
   *
   * @return Either null or a random valid list index
   */
  public static Integer getRandomIndex(List<Object> objects) {
    return objects == null || objects.isEmpty()
      ? null
      : getRandomInteger(objects.size() - 1);
  }

  /**
   * @description Will generate a random positive integer
   *
   * @param maxInteger the largest size the random integer may be that is generated, sets the bounds
   *
   * @return Either null or integer
   */
  public static Integer getRandomInteger(Integer maxInteger) {
    return maxInteger == null ? null : CMN_UTIL_Random.nextInteger(maxInteger);
  }

  /**
   * @description Will check to see if the given field api name exists for the given object
   *
   * @param objectName The object API name on which the field must exist for example Opportunity
   * @param fieldName The Field API name for example "Account.RecordType.DeveloperName"
   *
   * @return indicates that both the object and related field exist
   */
  public static Boolean isValidObjectFieldName(
    String objectName,
    String fieldName
  ) {
    if (String.isBlank(fieldName)) {
      return false;
    }

    SObjectType objectType = Schema.getGlobalDescribe().get(objectName);

    if (objectType == null) {
      return false;
    }

    Boolean isValid;

    List<String> fieldNameParts = convertStringToList(
      fieldName,
      CMN_UTIL_String.DOT
    );

    Boolean isMultipartReference = fieldNameParts.size() > 1;

    String objectNameToUse = objectName;

    for (Integer i = 0; i < fieldNameParts.size(); i++) {
      String fieldPart = fieldNameParts[i];

      Map<String, Schema.SObjectField> fieldMap = getObjectFieldMap(
        objectNameToUse
      );

      String fieldNameToUse = fieldPart;

      //Change the name for field except for the last field in the list
      if (
        isMultipartReference &&
        i < fieldNameParts.size() - 1 &&
        String.isNotBlank(fieldPart)
      ) {
        if (fieldPart.endsWith(RELATIONSHIP_SUFFIX)) {
          fieldNameToUse = fieldNameToUse.replace(
            RELATIONSHIP_SUFFIX,
            CUSTOM_FIELD_SUFFIX
          );
        } else {
          fieldNameToUse = fieldNameToUse + ID_FIELD_SUFFIX;
        }
      }

      SObjectField objectField = fieldMap.get(fieldNameToUse.toLowerCase());

      isValid = String.isBlank(fieldNameToUse) || fieldMap == null
        ? false
        : objectField != null;

      if (!isValid) {
        break;
      }

      DescribeFieldResult describe = objectField.getDescribe();

      objectNameToUse = !describe.namePointing &&
        !describe.getReferenceTo().isEmpty()
        ? describe.getReferenceTo()[0].getDescribe().getLocalName()
        : fieldPart;
    }

    return isValid;
  }

  /**
   * @description Will retrieve the value for an SObject generically
   *
   * @param anObject The SObject data, can include references to related object
   * @param fieldName A single field name or field names using DOT notation; such as Case.Contact.Name, we assume last value is a field name
   *
   * @return The value of the field
   */
  public static Object getFieldValue(SObject anObject, String fieldName) {
    Object fieldValue = null;

    List<String> fieldNameParts = CMN_UTIL_System.convertStringToList(
      fieldName,
      CMN_UTIL_String.DOT
    );

    Boolean isMultipartReference = fieldNameParts.size() > 1;

    SObject objectToUse = anObject;

    for (Integer i = 0; i < fieldNameParts.size(); i++) {
      if (
        objectToUse != null //WHILST the field name may be field, the object references is null...
      ) {
        String fieldPart = fieldNameParts[i];

        //If we are not at the end of the field parts, then we are retrieving an SObject
        if (isMultipartReference && i < fieldNameParts.size() - 1) {
          objectToUse = objectToUse.getSObject(fieldPart);
        } else {
          //If we get here then we are retrieving a field value
          fieldValue = objectToUse.get(fieldPart);
        }
      }
    }

    return fieldValue;
  }

  /**
   * @description Class that represents the SObject and SObject field from walking an SObject returned from a query
   * with a text field name (path); for example (from case) Contact.Account.Name;
   * This should return with SObject = Account SObjectField = Name;
   * The passed in object will be Case in this instance
   */
  public class ObjectFieldInformation {
    public SObject objectReference;
    public SObjectField objectField;
  }

  /**
   * @description Retrieves and SObject and SObjectField from an SObject based on a field name
   *
   * @param anObject Root Object; for example Case
   * @param fieldName Multipart field name; for example Contact.Account.Name
   *
   * @return Object contain an SObject and SObjectField reference in example above that would be Account and Name
   */
  public static ObjectFieldInformation getObjectAndFieldInformation(
    SObject anObject,
    String fieldName
  ) {
    ObjectFieldInformation result = new ObjectFieldInformation();

    List<String> fieldNameParts = CMN_UTIL_System.convertStringToList(
      fieldName,
      CMN_UTIL_String.DOT
    );

    Boolean isMultipartReference = fieldNameParts.size() > 1;

    result.objectReference = anObject;
    String fieldPart;

    for (Integer i = 0; i < fieldNameParts.size(); i++) {
      if (
        result.objectReference != null //WHILST the field name may be field, the object references is null...
      ) {
        fieldPart = fieldNameParts[i];

        //If we are not at the end of the field parts, then we are retrieving an SObject
        if (isMultipartReference && i < fieldNameParts.size() - 1) {
          result.objectReference = result.objectReference.getSObject(fieldPart);
        }
      }
    }

    if (result.objectReference != null) {
      result.objectField = result.objectReference.getSObjectType()
        .getDescribe()
        .fields.getMap()
        .get(fieldPart);
    }

    return result;
  }

  private static final Set<String> IGNORED_SELECT_FIELDS = new Set<String>{
    'AboutMe',
    'AnnualRevenue',
    'AssetId',
    'BannerPhotoUrl',
    'BusinessHoursId',
    'BusinessProcessId',
    'CallCenterId',
    'Campaign__c',
    'CampaignId',
    'CommunityId',
    'ConvertedAccountId',
    'ConvertedContactId',
    'ConvertedDate',
    'ConvertedOpportunityId',
    'CosmosID__c',
    'CosmosID__pc',
    'CreatedDate',
    'CreatedById',
    'CreatorFullPhotoUrl',
    'CreatorSmallPhotoUrl',
    'DB_Region__c',
    'DefaultCurrencyIsoCode',
    'DefaultGroupNotificationFrequency',
    'DigestFrequency',
    'DelegatedApproverId',
    'DoNotCall',
    'dsfs__DSProSFMembershipStatus__c',
    'dsfs__DSProSFPassword__c',
    'dsfs__DSProSFUsername__c',
    'EmailBouncedDate',
    'EmailBouncedReason',
    'EmailEncodingKey',
    'EmailPreferencesAutoBcc',
    'EmailPreferencesAutoBccStayInTouch',
    'EmailPreferencesStayInTouchReminder',
    'EntitlementId',
    'Extension',
    'FederationIdentifier',
    'FeedItemId',
    'ForecastEnabled',
    'FullPhotoUrl',
    'OutOfOfficeMessage',
    'HasOptedOutOfEmail',
    'HasOptedOutOfFax',
    'IsCustomerPortal',
    'IsEmailBounced',
    'IsExtIndicatorVisible',
    'IsPartner',
    'IsPersonType',
    'IsPortalEnabled',
    'IsPrmSuperUser',
    'IsProfilePhotoActive',
    'Jigsaw',
    'JigsawCompanyId',
    'JigsawContactId',
    'LanguageLocaleKey',
    'LastActivityDate',
    'LastCURequestDate',
    'LastCUUpdateDate',
    'LastLoginDate',
    'LastPasswordChangeDate',
    'LastReferencedDate',
    'LastTransferDate',
    'LastViewedDate',
    'LastModifiedDate',
    'Linked_Financial_Asset__c',
    'LocaleSidKey',
    'LocaleSidKey',
    'MediumBannerPhotoUrl',
    'MediumPhotoUrl',
    'NamespacePrefix',
    'NumberOfEmployees',
    'OfflinePdaTrialExpirationDate',
    'OfflineTrialExpirationDate',
    'Owning_Company__c',
    'Parent_Opportunity__c',
    'PermissionsAccessCMC',
    'PermissionsActivateContract',
    'PermissionsActivateOrder',
    'PermissionsAllowUniversalSearch',
    'PermissionsAllowViewKnowledge',
    'PermissionsApiEnabled',
    'PermissionsApiUserOnly',
    'PermissionsAssignPermissionSets',
    'PermissionsAssignTopics',
    'PermissionsAssignUserToSkill',
    'PermissionsAuthorApex',
    'PermissionsBulkApiHardDelete',
    'PermissionsBulkMacrosAllowed',
    'PermissionsBypassEmailApproval',
    'PermissionsCampaignInfluence2',
    'PermissionsCanApproveFeedPost',
    'PermissionsCanInsertFeedSystemFields',
    'PermissionsCanUseNewDashboardBuilder',
    'PermissionsChatterComposeUiCodesnippet',
    'PermissionsChatterEditOwnPost',
    'PermissionsChatterEditOwnRecordPost',
    'PermissionsChatterFileLink',
    'PermissionsChatterForSharePoint',
    'PermissionsChatterInternalUser',
    'PermissionsChatterInviteExternalUsers',
    'PermissionsChatterOwnGroups',
    'PermissionsConfigCustomRecs',
    'PermissionsConnectOrgToEnvironmentHub',
    'PermissionsContentAdministrator',
    'PermissionsContentHubUser',
    'PermissionsConvertLeads',
    'PermissionsCreateAuditFields',
    'PermissionsCreateCustomizeFilters',
    'PermissionsCreateMultiforce',
    'PermissionsCreateTopics',
    'PermissionsCreateWorkBadgeDefinition',
    'PermissionsCreateWorkspaces',
    'PermissionsCustomizeApplication',
    'PermissionsCustomMobileAppsAccess',
    'PermissionsDataExport',
    'PermissionsDelegatedPortalUserAdmin',
    'PermissionsDelegatedTwoFactor',
    'PermissionsDeleteActivatedContract',
    'PermissionsDeleteTopics',
    'PermissionsDistributeFromPersWksp',
    'PermissionsEditActivatedOrders',
    'PermissionsEditBrandTemplates',
    'PermissionsEditCaseComments',
    'PermissionsEditEvent',
    'PermissionsEditHtmlTemplates',
    'PermissionsEditKnowledge',
    'PermissionsEditOppLineItemUnitPrice',
    'PermissionsEditPublicDocuments',
    'PermissionsEditPublicTemplates',
    'PermissionsEditReadonlyFields',
    'PermissionsEditReports',
    'PermissionsEditTask',
    'PermissionsEditTopics',
    'PermissionsEmailAdministration',
    'PermissionsEmailMass',
    'PermissionsEmailSingle',
    'PermissionsEmailTemplateManagement',
    'PermissionsEnableNotifications',
    'PermissionsExportReport',
    'PermissionsFlowUFLRequired',
    'PermissionsForceTwoFactor',
    'PermissionsGovernNetworks',
    'PermissionsIdentityConnect',
    'PermissionsIdentityEnabled',
    'PermissionsImportCustomObjects',
    'PermissionsImportLeads',
    'PermissionsImportPersonal',
    'PermissionsInboundMigrationToolsUser',
    'PermissionsInstallMultiforce',
    'PermissionsLightningExperienceUser',
    'PermissionsManageAnalyticSnapshots',
    'PermissionsManageAuthProviders',
    'PermissionsManageBusinessHourHolidays',
    'PermissionsManageCallCenters',
    'PermissionsManageCases',
    'PermissionsManageCategories',
    'PermissionsManageChatterMessages',
    'PermissionsManageContentPermissions',
    'PermissionsManageContentProperties',
    'PermissionsManageContentTypes',
    'PermissionsManageCssUsers',
    'PermissionsManageCustomPermissions',
    'PermissionsManageCustomReportTypes',
    'PermissionsManageDashboards',
    'PermissionsManageDataCategories',
    'PermissionsManageDataIntegrations',
    'PermissionsManageEmailClientConfig',
    'PermissionsManageEncryptionKeys',
    'PermissionsManageEntitlements',
    'PermissionsManageExchangeConfig',
    'PermissionsManageInteraction',
    'PermissionsManageInternalUsers',
    'PermissionsManageIpAddresses',
    'PermissionsManageKnowledge',
    'PermissionsManageKnowledgeImportExport',
    'PermissionsManageLeads',
    'PermissionsManageLoginAccessPolicies',
    'PermissionsManageMobile',
    'PermissionsManageNetworks',
    'PermissionsManagePartners',
    'PermissionsManagePasswordPolicies',
    'PermissionsManageProfilesPermissionsets',
    'PermissionsManagePvtRptsAndDashbds',
    'PermissionsManageRemoteAccess',
    'PermissionsManageRoles',
    'PermissionsManageSearchPromotionRules',
    'PermissionsManageSharing',
    'PermissionsManageSolutions',
    'PermissionsManageSynonyms',
    'PermissionsManageTwoFactor',
    'PermissionsManageUnlistedGroups',
    'PermissionsManageUsers',
    'PermissionsMassInlineEdit',
    'PermissionsMergeTopics',
    'PermissionsModerateChatter',
    'PermissionsModerateNetworkFeeds',
    'PermissionsModerateNetworkFiles',
    'PermissionsModerateNetworkMessages',
    'PermissionsModerateNetworkUsers',
    'PermissionsModifyAllData',
    'PermissionsNewReportBuilder',
    'PermissionsOutboundMigrationToolsUser',
    'PermissionsPasswordNeverExpires',
    'PermissionsPortalSuperUser',
    'PermissionsPublishMultiforce',
    'PermissionsResetPasswords',
    'PermissionsRunFlow',
    'PermissionsRunReports',
    'PermissionsSalesConsole',
    'PermissionsScheduleJob',
    'PermissionsScheduleReports',
    'PermissionsSelectFilesFromSalesforce',
    'PermissionsSendAnnouncementEmails',
    'PermissionsSendExternalEmailAvailable',
    'PermissionsSendSitRequests',
    'PermissionsShareInternalArticles',
    'PermissionsShowCompanyNameAsUserBadge',
    'PermissionsSolutionImport',
    'PermissionsSubmitMacrosAllowed',
    'PermissionsTransferAnyCase',
    'PermissionsTransferAnyEntity',
    'PermissionsTransferAnyLead',
    'PermissionsTwoFactorApi',
    'PermissionsUpdateWithInactiveOwner',
    'PermissionsUseTeamReassignWizards',
    'PermissionsViewAllData',
    'PermissionsViewAllUsers',
    'PermissionsViewCaseInteraction',
    'PermissionsViewContent',
    'PermissionsViewDataCategories',
    'PermissionsViewEncryptedData',
    'PermissionsViewEventLogFiles',
    'PermissionsViewGlobalHeader',
    'PermissionsViewHelpLink',
    'PermissionsViewMyTeamsDashboards',
    'PermissionsViewSetup',
    'PersonAssistantName',
    'PersonAssistantPhone',
    'PersonDoNotCall',
    'PersonEmailBouncedDate',
    'PersonEmailBouncedReason',
    'PersonHasOptedOutOfEmail',
    'PersonHasOptedOutOfFax',
    'PersonLastCURequestDate',
    'PersonLastCUUpdateDate',
    'PhotoUrl',
    'PortalRole',
    'ProductId',
    'QuestionId',
    'Rating',
    'PortalAccountOwnerId',
    'ReceivesAdminInfoEmails',
    'ReceivesInfoEmails',
    'SenderEmail',
    'SenderName',
    'Sic',
    'SicDesc',
    'Signature',
    'SmallBannerPhotoUrl',
    'SmallPhotoUrl',
    'SobjectType',
    'StayInTouchNote',
    'StayInTouchSignature',
    'StayInTouchSubject',
    'SystemModstamp',
    'TickerSymbol',
    'TimeZoneSidKey',
    'UserLicenseId',
    'UserPermissionsAvantgoUser',
    'UserPermissionsCallCenterAutoLogin',
    'UserPermissionsChatterAnswersUser',
    'UserPermissionsInteractionUser',
    'UserPermissionsKnowledgeUser',
    'UserPermissionsLiveAgentUser',
    'UserPermissionsMarketingUser',
    'UserPermissionsMobileUser',
    'UserPermissionsOfflineUser',
    'UserPermissionsSFContentUser',
    'UserPermissionsSupportUser',
    'UserPreferencesActivityRemindersPopup',
    'UserPreferencesApexPagesDeveloperMode',
    'UserPreferencesCacheDiagnostics',
    'UserPreferencesContentEmailAsAndWhen',
    'UserPreferencesContentNoEmail',
    'UserPreferencesCreateLEXAppsWTShown',
    'UserPreferencesDisableAllFeedsEmail',
    'UserPreferencesDisableBookmarkEmail',
    'UserPreferencesDisableChangeCommentEmail',
    'UserPreferencesDisableEndorsementEmail',
    'UserPreferencesDisableFileShareNotification',
    'UserPreferencesDisableFileShareNotificationsForApi',
    'UserPreferencesDisableFollowersEmail',
    'UserPreferencesDisableLaterCommentEmail',
    'UserPreferencesDisableLikeEmail',
    'UserPreferencesDisableMentionsPostEmail',
    'UserPreferencesDisableMessageEmail',
    'UserPreferencesDisableProfilePostEmail',
    'UserPreferencesDisableSharePostEmail',
    'UserPreferencesDisCommentAfterLikeEmail',
    'UserPreferencesDisMentionsCommentEmail',
    'UserPreferencesDisProfPostCommentEmail',
    'UserPreferencesEnableAutoSubForFeeds',
    'UserPreferencesEventRemindersCheckboxDefault',
    'UserPreferencesGlobalNavBarWTShown',
    'UserPreferencesGlobalNavGridMenuWTShown',
    'UserPreferencesHideBiggerPhotoCallout',
    'UserPreferencesHideChatterOnboardingSplash',
    'UserPreferencesHideCSNDesktopTask',
    'UserPreferencesHideCSNGetChatterMobileTask',
    'UserPreferencesHideEndUserOnboardingAssistantModal',
    'UserPreferencesHideLightningMigrationModal',
    'UserPreferencesHideS1BrowserUI',
    'UserPreferencesHideSecondChatterOnboarding',
    'UserPreferencesHideSecondChatterOnboardingSplash',
    'UserPreferencesHideSfxWelcomeMat',
    'UserPreferencesLightningExperiencePreferred',
    'UserPreferencesPathAssistantCollapsed',
    'UserPreferencesPreviewLightning',
    'UserPreferencesReminderSoundOff',
    'UserPreferencesShowCityToExternalUsers',
    'UserPreferencesShowCityToGuestUsers',
    'UserPreferencesShowCountryToExternalUsers',
    'UserPreferencesShowCountryToGuestUsers',
    'UserPreferencesShowEmailToExternalUsers',
    'UserPreferencesShowEmailToGuestUsers',
    'UserPreferencesShowFaxToExternalUsers',
    'UserPreferencesShowFaxToGuestUsers',
    'UserPreferencesShowManagerToExternalUsers',
    'UserPreferencesShowManagerToGuestUsers',
    'UserPreferencesShowMobilePhoneToExternalUser',
    'UserPreferencesShowMobilePhoneToExternalUsers',
    'UserPreferencesShowMobilePhoneToGuestUsers',
    'UserPreferencesShowPostalCodeToExternalUser',
    'UserPreferencesShowPostalCodeToExternalUsers',
    'UserPreferencesShowPostalCodeToGuestUsers',
    'UserPreferencesShowProfilePicToGuestUsers',
    'UserPreferencesShowStateToExternalUsers',
    'UserPreferencesShowStateToGuestUsers',
    'UserPreferencesShowStreetAddressToExternal',
    'UserPreferencesShowStreetAddressToExternalUsers',
    'UserPreferencesShowStreetAddressToGuestUsers',
    'UserPreferencesShowTitleToExternalUsers',
    'UserPreferencesShowTitleToGuestUsers',
    'UserPreferencesShowWorkPhoneToExternalUser',
    'UserPreferencesShowWorkPhoneToExternalUsers',
    'UserPreferencesShowWorkPhoneToGuestUsers',
    'UserPreferencesSortFeedByComment',
    'UserPreferencesTaskRemindersCheckboxDefault',
    'UserType',
    'WR_Approver__c',
    'ContractId',
    CMN_DAL_SObjectDomain.FIELD_ID,
    'IsDeleted',
    'MasterRecordId',
    'LastModifiedById',
    'PartnerAccountId',
    'SyncedQuoteId'
  };

  /**
   * @description converts id 15 to 1d 18
   *
   * @param the15charID as input
   *
   * @return converted to 18 id
   */
  public static String to18(String the15charID) {
    final String baseAlpha = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456';
    the15charID = CMN_UTIL_String.trim(the15charID);

    if (CMN_UTIL_String.length(the15charID) != 15) {
      return the15charID;
    }

    String result = '';
    List<String> chars = null;

    for (Integer i = 0; i < 3; i++)
    {
      chars = CMN_UTIL_String.toCharArray(CMN_UTIL_String.reverse(the15charID.substring(i * 5, i * 5 + 5)));
      String binary = '';
      for (String ch : chars)
      {
        binary += CMN_UTIL_Character.isUpperCase(ch) ? '1' : '0';
      }
      result += CMN_UTIL_String.charAt(baseAlpha, CMN_UTIL_Number.parseInt(binary, 2));
    }

		return the15charID + result;
	}

	/**
	 * @description Method to get the type of a single element
	 *
	 * @param objects The list of objects to evaluate
	 *
	 * @return returns Type of given list single element
	 */
	public static Type getListItemType(List<Object> objects)
	{
		return getType(objects, 'List<', '>');
	}

	/**
	 * @description Running type of object passed in parameter.
	 *
	 * @param o The object to evaluate
	 *
	 * @return This method returns null if type is not accessible - when class is private
	 * or when it's part of anonymous script. In that case, getRunningTypeName() should be used instead.
	 */
	public static Type getType(Object o)
	{
		return getType(o, 'Invalid conversion from runtime type ', ' to Date');
	}

	/**
	 * @description Overloaded method to get the type from the Type name
	 *
	 * @param anObject The object to evaluate
	 * @param open The opening tag as response from the getType
	 * @param close The closing tag as response from the getType
	 *
	 * @return Running type of object passed in parameter.
	 */
	public static Type getType(Object anObject, String open, String close)
	{
		return Type.forName(getTypeName(anObject, open, close));
	}

	/**
	 * @description This method serves to retrieve the type name of the running object node
	 *
	 * @param o The object to evaluate
	 *
	 * @return Name of running type of object passed in parameter.
	 */
	public static String getTypeName(Object o)
	{
		return getTypeName(o, 'Invalid conversion from runtime type ', ' to Date');
	}

	/**
	 * @description Method to determine the running type of any node, this method uses assignment to the date type
	 * to attempt to convert the input object and subsequently extracts the type from potential error responses
	 * when performing the type conversion.
	 *
	 * @param anObject The object used in the type conversion
	 * @param open the opening tag of the type conversion
	 * @param close the closing tag of the type conversion
	 *
	 * @return A string containing the name of the class
	 */
	public static String getTypeName(Object anObject, String open, String close)
	{
		if(anObject == null)
		{
			CMN_UTIL_Logger.error(ERROR_NULL_POINTER_TYPE, 'CMN_UTIL_System/getTypeName');
			throw new NullPointerException();
		}

		try
		{
			Date aDate = (Date)anObject;
			return DATE_TYPE;
		}
		catch(Exception ex)
		{
			return ex.getMessage().substringBetween(open, close);
		}
	}
}