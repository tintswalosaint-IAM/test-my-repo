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
 * <p>VCCC-378</p>
 */
global class CMN_UTIL_Set {
  /**
   * @description object set to Blob set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Blob> objectToBlob(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Blob> blobSet = new Set<Blob>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Blob) {
        blobSet.add((Blob) anObject);
      }
    }
    return blobSet;
  }

  /**
   * @description object set to boolean set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Boolean> objectToBoolean(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Boolean> booleanSet = new Set<Boolean>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Boolean) {
        booleanSet.add((Boolean) anObject);
      }
    }
    return booleanSet;
  }

  /**
   * @description object set to Date set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Date> objectToDate(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Date> dateSet = new Set<Date>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Date) {
        dateSet.add((Date) anObject);
      }
    }
    return dateSet;
  }

  /**
   * @description object set to Datetime set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Datetime> objectToDatetime(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Datetime> datetimeSet = new Set<Datetime>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Datetime) {
        datetimeSet.add((Datetime) anObject);
      }
    }
    return datetimeSet;
  }

  /**
   * @description object set to Decimal set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Decimal> objectToDecimal(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Decimal> decimalSet = new Set<Decimal>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Decimal) {
        decimalSet.add((Decimal) anObject);
      }
    }
    return decimalSet;
  }

  /**
   * @description object set to Double set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Double> objectToDouble(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Double> doubleSet = new Set<Double>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Double) {
        doubleSet.add((Double) anObject);
      }
    }
    return doubleSet;
  }

  /**
   * @description object set to id set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Id> objectToId(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Id> idSet = new Set<Id>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Id) {
        idSet.add((Id) anObject);
      }
    }
    return idSet;
  }

  /**
   * @description object set to integer set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Integer> objectToInteger(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Integer> integerSet = new Set<Integer>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Integer) {
        integerSet.add((Integer) anObject);
      }
    }
    return integerSet;
  }

  /**
   * @description object set to long set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Long> objectToLong(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Long> longSet = new Set<Long>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Long) {
        longSet.add((Long) anObject);
      }
    }
    return longSet;
  }

  /**
   * @description object set to time set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<Time> objectToTime(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<Time> timeSet = new Set<Time>();
    for (Object anObject : objectSet) {
      if (anObject instanceof Time) {
        timeSet.add((Time) anObject);
      }
    }
    return timeSet;
  }

  /**
   * @description object set to Blob set
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static Set<String> objectToString(Set<Object> objectSet) {
    if (objectSet == null) {
      return null;
    }
    Set<String> stringSet = new Set<String>();
    for (Object anObject : objectSet) {
      if (anObject instanceof String) {
        stringSet.add((String) anObject);
      }
    }
    return stringSet;
  }

  /**
   * @description blob set to object set
   *
   * @param blobSet as input
   *
   * @return result
   */
  global static Set<Object> blobToObject(Set<Blob> blobSet) {
    if (blobSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Blob aBlob : blobSet) {
      objectSet.add(aBlob);
    }
    return objectSet;
  }

  /**
   * @description boolean set to object set
   *
   * @param booleanSet as input
   *
   * @return result
   */
  global static Set<Object> booleanToObject(Set<Boolean> booleanSet) {
    if (booleanSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Boolean aBoolean : booleanSet) {
      objectSet.add(aBoolean);
    }
    return objectSet;
  }

  /**
   * @description date set to object set
   *
   * @param dateSet as input
   *
   * @return result
   */
  global static Set<Object> dateToObject(Set<Date> dateSet) {
    if (dateSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Date aDate : dateSet) {
      objectSet.add(aDate);
    }
    return objectSet;
  }

  /**
   * @description datetime set to object set
   *
   * @param datetimeSet as input
   *
   * @return result
   */
  global static Set<Object> datetimeToObject(Set<Datetime> datetimeSet) {
    if (datetimeSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Datetime aDatetime : datetimeSet) {
      objectSet.add(aDatetime);
    }
    return objectSet;
  }

  /**
   * @description decimal set to object set
   *
   * @param decimalSet as input
   *
   * @return result
   */
  global static Set<Object> decimalToObject(Set<Decimal> decimalSet) {
    if (decimalSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Decimal aDecimal : decimalSet) {
      objectSet.add(aDecimal);
    }
    return objectSet;
  }

  /**
   * @description double set to object set
   *
   * @param doubleSet as input
   *
   * @return result
   */
  global static Set<Object> doubleToObject(Set<Double> doubleSet) {
    if (doubleSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Double aDouble : doubleSet) {
      objectSet.add(aDouble);
    }
    return objectSet;
  }

  /**
   * @description Id set to object set
   *
   * @param idSet as input
   *
   * @return result
   */
  global static Set<Object> idToObject(Set<Id> idSet) {
    if (idSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Id aId : idSet) {
      objectSet.add(aId);
    }
    return objectSet;
  }

  /**
   * @description integer set to object set
   *
   * @param integerSet as input
   *
   * @return result
   */
  global static Set<Object> integerToObject(Set<Integer> integerSet) {
    if (integerSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Integer aInteger : integerSet) {
      objectSet.add(aInteger);
    }
    return objectSet;
  }

  /**
   * @description long set to object set
   *
   * @param longSet as input
   *
   * @return result
   */
  global static Set<Object> longToObject(Set<Long> longSet) {
    if (longSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Long aLong : longSet) {
      objectSet.add(aLong);
    }
    return objectSet;
  }

  /**
   * @description time set to object set
   *
   * @param timeSet as input
   *
   * @return result
   */
  global static Set<Object> timeToObject(Set<Time> timeSet) {
    if (timeSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (Time aTime : timeSet) {
      objectSet.add(aTime);
    }
    return objectSet;
  }

  /**
   * @description string set to object set
   *
   * @param stringSet as input
   *
   * @return result
   */
  global static Set<Object> stringToObject(Set<String> stringSet) {
    if (stringSet == null) {
      return null;
    }
    Set<Object> objectSet = new Set<Object>();
    for (String aString : stringSet) {
      objectSet.add(aString);
    }
    return objectSet;
  }

  /**
   * @description blob set to string
   *
   * @param blobSet as input
   *
   * @return result
   */
  global static String toString(Set<Blob> blobSet) {
    return toString(blobToObject(blobSet));
  }
  /**
   * @description boolean set to string
   *
   * @param booleanSet as input
   *
   * @return result
   */
  global static String toString(Set<Boolean> booleanSet) {
    return toString(booleanToObject(booleanSet));
  }
  /**
   * @description date set to string
   *
   * @param dateSet as input
   *
   * @return result
   */
  global static String toString(Set<Date> dateSet) {
    return toString(dateToObject(dateSet));
  }

  /**
   * @description datetime set to string
   *
   * @param datetimeSet as input
   *
   * @return result
   */
  global static String toString(Set<Datetime> datetimeSet) {
    return toString(datetimeToObject(datetimeSet));
  }

  /**
   * @description decimal set to string
   *
   * @param decimalSet as input
   *
   * @return result
   */
  global static String toString(Set<Decimal> decimalSet) {
    return toString(decimalToObject(decimalSet));
  }

  /**
   * @description double set to string
   *
   * @param doubleSet as string
   *
   * @return result
   */
  global static String toString(Set<Double> doubleSet) {
    return toString(doubleToObject(doubleSet));
  }

  /**
   * @description id set to string
   *
   * @param idSet as input
   *
   * @return result
   */
  global static String toString(Set<Id> idSet) {
    return toString(idToObject(idSet));
  }

  /**
   * @description integer set to string
   *
   * @param integerSet as input
   *
   * @return result
   */
  global static String toString(Set<Integer> integerSet) {
    return toString(integerToObject(integerSet));
  }

  /**
   * @description long set to string
   *
   * @param longSet as input
   *
   * @return result
   */
  global static String toString(Set<Long> longSet) {
    return toString(longToObject(longSet));
  }

  /**
   * @description time set to string
   *
   * @param timeSet as input
   *
   * @return result
   */
  global static String toString(Set<Time> timeSet) {
    return toString(timeToObject(timeSet));
  }

  /**
   * @description string set to string
   *
   * @param stringSet as input
   *
   * @return result
   */
  global static String toString(Set<String> stringSet) {
    return toString(stringToObject(stringSet));
  }

  /**
   * @description converts set of objects to string
   *
   * @param objectSet as input
   *
   * @return result
   */
  global static String toString(Set<Object> objectSet) {
    if (objectSet == null) {
      return 'null';
    }
    if (objectSet.size() <= 0) {
      return '{}';
    }
    String returnValue = '';
    Boolean isFirst = true;
    for (Object anObject : objectSet) {
      if (isFirst) {
        isFirst = false;
      } else {
        returnValue += ',';
      }
      if (anObject instanceof Blob) {
        returnValue += '\'' + ((Blob) anObject).toString() + '\'';
      } else if (anObject instanceof Boolean) {
        returnValue += ((Boolean) anObject);
      } else if (anObject instanceof Date) {
        returnValue += '\'' + ((Date) anObject) + '\'';
      } else if (anObject instanceof Datetime) {
        returnValue += '\'' + ((Datetime) anObject) + '\'';
      } else if (anObject instanceof Integer) {
        returnValue += ((Integer) anObject);
      } else if (anObject instanceof Long) {
        returnValue += ((Long) anObject);
      } else if (anObject instanceof Decimal) {
        returnValue += ((Decimal) anObject);
      } else if (anObject instanceof String) {
        returnValue += '\'' + ((String) anObject) + '\'';
      } else if (anObject instanceof Time) {
        returnValue += '\'' + ((Time) anObject) + '\'';
      }
    }
    return '{' + returnValue + '}';
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param b1 as input
   * @param b2 as input
   */
  global static void assertEquals(Set<Blob> b1, Set<Blob> b2) {
    assertEquals(blobToObject(b1), blobToObject(b2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param b1 as input
   * @param b2 as input
   */
  global static void assertEquals(Set<Boolean> b1, Set<Boolean> b2) {
    assertEquals(booleanToObject(b1), booleanToObject(b2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   */
  global static void assertEquals(Set<Date> d1, Set<Date> d2) {
    assertEquals(dateToObject(d1), dateToObject(d2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   */
  global static void assertEquals(Set<Datetime> d1, Set<Datetime> d2) {
    assertEquals(datetimeToObject(d1), datetimeToObject(d2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   */
  global static void assertEquals(Set<Decimal> d1, Set<Decimal> d2) {
    assertEquals(decimalToObject(d1), decimalToObject(d2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   */
  global static void assertEquals(Set<Double> d1, Set<Double> d2) {
    assertEquals(doubleToObject(d1), doubleToObject(d2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param i1 as input
   * @param i2 as input
   */
  global static void assertEquals(Set<Integer> i1, Set<Integer> i2) {
    assertEquals(integerToObject(i1), integerToObject(i2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param l1 as input
   * @param l2 as input
   */
  global static void assertEquals(Set<Long> l1, Set<Long> l2) {
    assertEquals(longToObject(l1), longToObject(l2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param s1 as input
   * @param s2 as input
   */
  global static void assertEquals(Set<String> s1, Set<String> s2) {
    assertEquals(stringToObject(s1), stringToObject(s2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param t1 as input
   * @param t2 as input
   */
  global static void assertEquals(Set<Time> t1, Set<Time> t2) {
    assertEquals(timeToObject(t1), timeToObject(t2));
  }

  /**
   * @description asserts if two sets are equal
   *
   * @param expected as input
   * @param actual as input
   */
  global static void assertEquals(Set<Object> expected, Set<Object> actual) {
    System.assert(
      equals(expected, actual),
      'Assertion failed, the following two arrays are not equal.  Expected: ' +
      toString(expected) +
      ', Actual: ' +
      toString(actual)
    );
  }

  /**
   * @description checks if two sets are equal
   *
   * @param b1 as input
   * @param b2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Blob> b1, Set<Blob> b2) {
    return equals(blobToObject(b1), blobToObject(b2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param b1 as input
   * @param b2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Boolean> b1, Set<Boolean> b2) {
    return equals(booleanToObject(b1), booleanToObject(b2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Date> d1, Set<Date> d2) {
    return equals(dateToObject(d1), dateToObject(d2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Datetime> d1, Set<Datetime> d2) {
    return equals(datetimeToObject(d1), datetimeToObject(d2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Decimal> d1, Set<Decimal> d2) {
    return equals(decimalToObject(d1), decimalToObject(d2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param d1 as input
   * @param d2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Double> d1, Set<Double> d2) {
    return equals(doubleToObject(d1), doubleToObject(d2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param i1 as input
   * @param i2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Integer> i1, Set<Integer> i2) {
    return equals(integerToObject(i1), integerToObject(i2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param l1 as input
   * @param l2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Long> l1, Set<Long> l2) {
    return equals(longToObject(l1), longToObject(l2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param s1 as input
   * @param s2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<String> s1, Set<String> s2) {
    return equals(stringToObject(s1), stringToObject(s2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param t1 as input
   * @param t2 as input
   *
   * @return result
   */
  global static Boolean equals(Set<Time> t1, Set<Time> t2) {
    return equals(timeToObject(t1), timeToObject(t2));
  }

  /**
   * @description checks if two sets are equal
   *
   * @param expected as input
   * @param actual as input
   *
   * @return result
   */
  global static Boolean equals(Set<Object> expected, Set<Object> actual) {
    if (expected == null && actual == null) {
      return true;
    }
    if (
      (expected == null && actual != null) ||
      (expected != null &&
      actual == null)
    ) {
      return false;
    }
    if (expected.size() != actual.size()) {
      return false;
    }
    for (Object obj : expected) {
      if (!actual.contains(obj)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description pluck field values from list and return as set
   *
   * @param records as input
   * @param fieldName as input
   *
   * @return result
   */
  global static Set<Object> pluck(List<SObject> records, String fieldName) {
    return pluck(listToSet(records), fieldName);
  }

  /**
   * @description pluck field values from list and return as set
   *
   * @param records as input
   * @param fieldName as input
   *
   * @return result
   */
  global static Set<Object> pluck(Set<SObject> records, String fieldName) {
    Set<Object> returnValue = null;
    if (records != null) {
      returnValue = new Set<Object>();
      if (records.size() > 0 && CMN_UTIL_String.isNotBlank(fieldName)) {
        for (SObject record : records) {
          returnValue.add(record.get(fieldName));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description pluck field values from list and return as string set
   *
   * @param sObjects as input
   * @param fieldName as input
   *
   * @return result
   */
  global static Set<String> pluckString(
    List<SObject> sObjects,
    String fieldName
  ) {
    return pluckString(listToSet(sObjects), fieldName);
  }

  /**
   * @description pluck field values from list and return as string set
   *
   * @param sObjects as input
   * @param fieldName as input
   *
   * @return result
   */
  global static Set<String> pluckString(
    Set<SObject> sObjects,
    String fieldName
  ) {
    return objectToString(pluck(sObjects, fieldName));
  }

  /**
   * @description convert set to list
   *
   * @param strings as input
   *
   * @return result
   */
  global static List<String> setToList(Set<String> strings) {
    List<String> returnValue = null;
    if (strings != null) {
      returnValue = new List<String>();
      if (strings.size() > 0) {
        for (String value : strings) {
          returnValue.add(value);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description convert set to list
   *
   * @param objects input
   *
   * @return result
   */
  global static List<Object> setToList(Set<Object> objects) {
    List<Object> returnValue = null;
    if (objects != null) {
      returnValue = new List<Object>();
      if (objects.size() > 0) {
        for (Object record : objects) {
          returnValue.add(record);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description convert set of sobject to list of sobjects
   *
   * @param sObjects as input
   *
   * @return result
   */
  global static List<SObject> setToList(Set<SObject> sObjects) {
    List<SObject> returnValue = null;
    if (sObjects != null) {
      returnValue = new List<SObject>();
      if (sObjects.size() > 0) {
        for (SObject record : sObjects) {
          returnValue.add(record);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description convert set to list
   *
   * @param strings as input
   *
   * @return result
   */
  global static Set<String> listToSet(List<String> strings) {
    Set<String> returnValue = null;
    if (strings != null) {
      returnValue = new Set<String>();
      if (strings.size() > 0) {
        for (String value : strings) {
          returnValue.add(value);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description convert list to set
   *
   * @param objects as input
   *
   * @return result
   */
  global static Set<Object> listToSet(List<Object> objects) {
    Set<Object> returnValue = null;
    if (objects != null) {
      returnValue = new Set<Object>();
      if (objects.size() > 0) {
        for (Object value : objects) {
          returnValue.add(value);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description convert list to set
   *
   * @param records as input
   *
   * @return result
   */
  global static Set<SObject> listToSet(List<SObject> records) {
    Set<SObject> returnValue = null;
    if (records != null) {
      returnValue = new Set<SObject>();
      if (records.size() > 0) {
        for (SObject record : records) {
          returnValue.add(record);
        }
      }
    }
    return returnValue;
  }

  /**
   * @description lowercase a set of strings
   *
   * @param strings as input
   *
   * @return result
   */
  global static Set<String> lowerCase(Set<String> strings) {
    Set<String> returnValue = null;
    if (strings != null) {
      returnValue = new Set<String>();
      if (strings.size() > 0) {
        for (String str : strings) {
          returnValue.add(str == null ? null : str.toLowerCase());
        }
      }
    }
    return returnValue;
  }

  /**
   * @description upperCase as set of strings
   *
   * @param strings as output
   *
   * @return result
   */
  global static Set<String> upperCase(Set<String> strings) {
    Set<String> returnValue = null;
    if (strings != null) {
      returnValue = new Set<String>();
      if (strings.size() > 0) {
        for (String str : strings) {
          returnValue.add(str == null ? null : str.toUpperCase());
        }
      }
    }
    return returnValue;
  }

  /**
   * @description trim as set of strings
   *
   * @param strings as input
   *
   * @return result
   */
  global static Set<String> trim(Set<String> strings) {
    Set<String> returnValue = null;
    if (strings != null) {
      returnValue = new Set<String>();
      if (strings.size() > 0) {
        for (String str : strings) {
          returnValue.add(str == null ? null : str.trim());
        }
      }
    }
    return returnValue;
  }
}