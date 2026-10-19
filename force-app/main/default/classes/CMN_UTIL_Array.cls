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
 * <p>VCCC-378</p>
 * This project code has been forked and to update the latest salesforce APIs.
 */
global class CMN_UTIL_Array {
  global static String[] EMPTY_STRING_ARRAY = new List<String>{};
  global static Integer MAX_NUMBER_OF_ELEMENTS_IN_LIST {
    get {
      return 1000;
    }
  }

  /**
   * @description convert list of objects to strings
   *
   * @param objects as input
   *
   * @return list of objects in string format
   */
  global static List<String> objectToString(List<Object> objects) {
    List<String> strings = null;
    if (objects != null) {
      strings = new List<String>();
      if (objects.size() > 0) {
        for (Object obj : objects) {
          if (obj instanceof String) {
            strings.add((String) obj);
          }
        }
      }
    }
    return strings;
  }

  /**
   * @description <p>Reverses the order of the given array.
   * <p/>
   * <p>There is no special handling for multi-dimensional arrays.
   * <p/>
   * <p>This method does nothing for a {@code null} input array.
   *
   * @param anArray the array to reverse, may be {@code null}
   *
   * @return reversed array
   */
  global static Object[] reverse(Object[] anArray) {
    if (anArray == null) {
      return null;
    }
    Integer i = 0;
    Integer j = anArray.size() - 1;
    Object tmp;
    while (j > i) {
      tmp = anArray[j];
      anArray[j] = anArray[i];
      anArray[i] = tmp;
      j--;
      i++;
    }
    return anArray;
  }

  /**
   * @description reverse order of sobject array
   *
   * @param anArray as input
   *
   * @return reversed sobject array
   */
  global static SObject[] reverse(SObject[] anArray) {
    if (anArray == null) {
      return null;
    }
    Integer i = 0;
    Integer j = anArray.size() - 1;
    SObject tmp;
    while (j > i) {
      tmp = anArray[j];
      anArray[j] = anArray[i];
      anArray[i] = tmp;
      j--;
      i++;
    }
    return anArray;
  }

  /**
   * @description returns a list of lowercase strings
   *
   * @param strs as input
   *
   * @return lower case strings
   */
  global static List<String> lowerCase(List<String> strs) {
    List<String> returnValue = null;
    if (strs != null) {
      returnValue = new List<String>();
      if (strs.size() > 0) {
        for (String str : strs) {
          returnValue.add(str == null ? null : str.toLowerCase());
        }
      }
    }
    return returnValue;
  }

  /**
   * @description returns a list of uppercase strings
   *
   * @param strings as input
   *
   * @return upper case strings
   */
  global static List<String> upperCase(List<String> strings) {
    List<String> returnValue = null;
    if (strings != null) {
      returnValue = new List<String>();
      if (strings.size() > 0) {
        for (String str : strings) {
          returnValue.add(str == null ? null : str.toUpperCase());
        }
      }
    }
    return returnValue;
  }

  /**
   * @description returns a list of trimmed strings
   *
   * @param strings as input
   *
   * @return trimmed strings
   */
  global static List<String> trim(List<String> strings) {
    List<String> returnValue = null;
    if (strings != null) {
      returnValue = new List<String>();
      if (strings.size() > 0) {
        for (String str : strings) {
          returnValue.add(str == null ? null : str.trim());
        }
      }
    }
    return returnValue;
  }

  /**
   * @description merges two object arrays together and return single merged output
   *
   * @param array1 as input
   * @param array2 as input
   *
   * @return merged object array
   */
  global static Object[] mergeX(Object[] array1, Object[] array2) {
    if (array1 == null) {
      return array2;
    }
    if (array2 == null) {
      return array1;
    }
    Object[] merged = new List<Object>(array1.size() + array2.size());
    for (Integer i = 0; i < array1.size(); i++) {
      merged[i] = array1[i];
    }
    for (Integer i = 0; i < array2.size(); i++) {
      merged[i + array1.size()] = array2[i];
    }
    return merged;
  }

  /**
   * @description merges two sobject arrays together and return single merged output
   *
   * @param array1 as input
   * @param array2 as input
   *
   * @return merged sobject array
   */
  global static SObject[] mergeX(SObject[] array1, SObject[] array2) {
    if (array1 == null) {
      return array2;
    }
    if (array2 == null) {
      return array1;
    }
    if (array1.size() <= 0) {
      return array2;
    }
    List<SObject> merged = createEmptySObjectList(array1[0]);
    for (SObject sObj : array1) {
      merged.add(sObj);
    }
    for (SObject sObj : array2) {
      merged.add(sObj);
    }
    return merged;
  }

  /**
   * @description checks if object arrays is empty
   *
   * @param objectArray as input
   *
   * @return is empty or not
   */
  global static Boolean isEmpty(Object[] objectArray) {
    if (objectArray == null) {
      return true;
    }
    return objectArray.size() == 0;
  }

  /**
   * @description checks if sobject arrays is empty
   *
   * @param sobjectArray as input
   *
   * @return is empty or not
   */
  global static Boolean isEmpty(SObject[] sobjectArray) {
    if (sobjectArray == null) {
      return true;
    }
    return sobjectArray.size() == 0;
  }

  /**
   * @description checks if object array is not empty
   *
   * @param objectArray as input
   *
   * @return is not empty or is
   */
  global static Boolean isNotEmpty(Object[] objectArray) {
    return !isEmpty(objectArray);
  }

  /**
   * @description checks if sobject array is not empty
   *
   * @param sobjectArray as input
   *
   * @return is not empty or is
   */
  global static Boolean isNotEmpty(SObject[] sobjectArray) {
    return !isEmpty(sobjectArray);
  }

  /**
   * @description plucks sobject field values from array based on field name and return an array
   *
   * @param objectArray as input
   * @param fieldName as input
   *
   * @return array of plucked field values
   */
  global static Object[] pluck(SObject[] objectArray, String fieldName) {
    if (isEmpty(objectArray) || CMN_UTIL_String.isBlank(fieldName)) {
      return new List<Object>{};
    }
    Object[] plucked = new List<Object>(objectArray.size());
    for (Integer i = 0; i < objectArray.size(); i++) {
      plucked[i] = objectArray[i].get(fieldName);
    }
    return plucked;
  }

  /**
   * @description converts array to string
   *
   * @param objectArray as input
   *
   * @return string
   */
  global static String toString(Object[] objectArray) {
    if (objectArray == null) {
      return 'null';
    }
    String returnValue = '{';
    for (Integer i = 0; i < objectArray.size(); i++) {
      if (i != 0) {
        returnValue += ',';
      }
      returnValue += '\'' + objectArray[i] + '\'';
    }
    returnValue += '}';
    return returnValue;
  }

  global static String toString(SObject[] objectArray) {
    if (objectArray == null) {
      return 'null';
    }
    String returnValue = '{';
    for (Integer i = 0; i < objectArray.size(); i++) {
      if (i != 0) {
        returnValue += ',';
      }
      returnValue += '\'' + objectArray[i] + '\'';
    }
    returnValue += '}';
    return returnValue;
  }

  /**
   * @description assets if two object arrays are equal
   *
   * @param expected as input
   * @param actual as input
   */
  global static void assertArraysAreEqual(Object[] expected, Object[] actual) {
    //check to see if one param is null but the other is not
    System.assert(
      (expected == null && actual == null) ||
      (expected != null &&
      actual != null),
      'Assertion failed, the following two arrays are not equal.  Expected: ' +
      CMN_UTIL_Array.toString(expected) +
      ', Actual: ' +
      CMN_UTIL_Array.toString(actual)
    );
    if (expected != null && actual != null) {
      System.assert(
        expected.size() == actual.size(),
        'Assertion failed, the following two arrays are not equal.  Expected: ' +
        CMN_UTIL_Array.toString(expected) +
        ', Actual: ' +
        CMN_UTIL_Array.toString(actual)
      );
      for (Integer i = 0; i < expected.size(); i++) {
        System.assert(
          expected[i] == actual[i],
          'Assertion failed, the following two arrays are not equal.  Expected: ' +
          CMN_UTIL_Array.toString(expected) +
          ', Actual: ' +
          CMN_UTIL_Array.toString(actual)
        );
      }
    }
  }

  /**
   * @description assets if two sobject arrays are equal
   *
   * @param expected as input
   * @param actual as input
   */
  global static void assertArraysAreEqual(
    SObject[] expected,
    SObject[] actual
  ) {
    //check to see if one param is null but the other is not
    System.assert(
      (expected == null && actual == null) ||
      (expected != null &&
      actual != null),
      'Assertion failed, the following two arrays are not equal.  Expected: ' +
      CMN_UTIL_Array.toString(expected) +
      ', Actual: ' +
      CMN_UTIL_Array.toString(actual)
    );
    if (expected != null && actual != null) {
      System.assert(
        expected.size() == actual.size(),
        'Assertion failed, the following two arrays are not equal.  Expected: ' +
        CMN_UTIL_Array.toString(expected) +
        ', Actual: ' +
        CMN_UTIL_Array.toString(actual)
      );
      for (Integer i = 0; i < expected.size(); i++) {
        System.assert(
          expected[i] == actual[i],
          'Assertion failed, the following two arrays are not equal.  Expected: ' +
          CMN_UTIL_Array.toString(expected) +
          ', Actual: ' +
          CMN_UTIL_Array.toString(actual)
        );
      }
    }
  }

  /**
   * @description This method is no longer needed as in Spring '10, you can created
   * generic SObject lists.
   *
   * @param prototype as input
   *
   * @return @deprecated
   */
  global static List<SObject> createEmptySObjectList(SObject prototype) {
    if (prototype == null) {
      return null;
    }
    return Database.query(
      'SELECT Id FROM ' +
      CMN_UTIL_String.split('' + prototype, ':')[0] +
      ' WHERE Id = \'0015000000Mrr40\' LIMIT 0'
    ); // use dummy Id to ensure no return
  }

  /**
   * @description merges two lists and produces single merged list output
   *
   * @param list1 as input
   * @param list2 ss input
   *
   * @return list of merged objects
   */
  global static List<Object> mergeLists(
    List<Object> list1,
    List<Object> list2
  ) {
    List<Object> returnList = new List<Object>();
    if (
      list1 != null &&
      list2 != null &&
      (list1.size() + list2.size()) > MAX_NUMBER_OF_ELEMENTS_IN_LIST
    ) {
      throw new IllegalArgumentException(
        'Lists cannot be merged because new list would be greater than maximum number of elements in a list: ' +
        MAX_NUMBER_OF_ELEMENTS_IN_LIST
      );
    }
    if (isNotEmpty(list1)) {
      for (Object elmt : list1) {
        returnList.add(elmt);
      }
    }
    if (isNotEmpty(list2)) {
      for (Object elmt : list2) {
        returnList.add(elmt);
      }
    }
    return returnList;
  }

  /**
   * @description merges two sobject lists and produces single merged list output
   *
   * @param list1 as input
   * @param list2 ss input
   *
   * @return list of merged sobjects
   */
  global static List<SObject> mergeSObjectLists(
    List<SObject> list1,
    List<SObject> list2
  ) {
    if (
      list1 != null &&
      list2 != null &&
      (list1.size() + list2.size()) > MAX_NUMBER_OF_ELEMENTS_IN_LIST
    ) {
      throw new IllegalArgumentException(
        'Lists cannot be merged because new list would be greater than maximum number of elements in a list: ' +
        MAX_NUMBER_OF_ELEMENTS_IN_LIST
      );
    }
    if (isEmpty(list1) && isEmpty(list2)) {
      return null;
    }
    List<SObject> returnList = createEmptySObjectList(
      isNotEmpty(list1) ? list1.get(0) : list2.get(0)
    );
    if (list1 != null) {
      for (SObject elmt : list1) {
        returnList.add(elmt);
      }
    }
    if (list2 != null) {
      for (SObject elmt : list2) {
        returnList.add(elmt);
      }
    }
    return returnList;
  }

  /**
   * @description returns a subset of list based on counter starting from 0 till counter value
   *
   * @param aList as input
   * @param count as input
   *
   * @return list of subset objects
   */
  global static List<Object> subset(List<Object> aList, Integer count) {
    return subset(aList, 0, count);
  }

  /**
   * @description returns a subset of list based on counter starting from startIndex till counter value
   *
   * @param list1 as input
   * @param startIndex as input
   * @param count as input
   *
   * @return list of subset objects
   */
  global static List<Object> subset(
    List<Object> list1,
    Integer startIndex,
    Integer count
  ) {
    List<Object> returnList = new List<Object>();
    if (
      list1 != null &&
      list1.size() > 0 &&
      startIndex >= 0 &&
      startIndex <= list1.size() - 1 &&
      count > 0
    ) {
      for (
        Integer i = startIndex; i < list1.size() && i - startIndex < count; i++
      ) {
        returnList.add(list1.get(i));
      }
    }
    return returnList;
  }

  /**
   * @description returns a subset of sobjects list based on counter starting from 0 till counter value
   *
   * @param aList as input
   * @param count as input
   *
   * @return list of subset sobjects
   */
  global static List<SObject> subset(List<SObject> aList, Integer count) {
    return subset(aList, 0, count);
  }

  /**
   * @description returns a subset of sobjects list based on counter starting from startIndex till counter value
   *
   * @param list1 as input
   * @param startIndex as input
   * @param count as input
   *
   * @return list of subset sobjects
   */
  global static List<SObject> subset(
    List<SObject> list1,
    Integer startIndex,
    Integer count
  ) {
    List<SObject> returnList = null;
    if (
      list1 != null &&
      list1.size() > 0 &&
      startIndex <= list1.size() - 1 &&
      count > 0
    ) {
      returnList = createEmptySObjectList(list1.get(0));
      for (
        Integer i = startIndex; i < list1.size() && i - startIndex < count; i++
      ) {
        returnList.add(list1.get(i));
      }
    }
    return returnList;
  }

  /**
   * @description LIST/ARRAY SORTING FOR FORCE.COM PRIMITIVES (Double,Integer,ID,etc.):
   *
   * @param theList as input
   *
   * @return list of sorted objects
   */
  global static List<Object> sort(List<Object> theList) {
    return sort(theList, new CMN_UTIL_Comparators.PrimitiveComparator());
  }

  /**
   * @description sort list of object by ascending or not
   *
   * @param theList as input
   * @param sortAsc as input
   *
   * @return sorted list
   */
  global static List<Object> sort(List<Object> theList, Boolean sortAsc) {
    return sort(
      theList,
      new CMN_UTIL_Comparators.PrimitiveComparator(),
      sortAsc
    );
  }

  /**
   * @description sort list of object by comparator
   *
   * @param theList as input
   * @param comparator as input
   *
   * @return sorted list
   */
  global static List<Object> sort(
    List<Object> theList,
    CMN_UTIL_Comparators.Comparator comparator
  ) {
    return sort(theList, comparator, true);
  }

  /**
   * @description sort list of object by comparator and sort by ascending or not
   *
   * @param theList as input
   * @param comparator as input
   * @param sortAsc as input
   *
   * @return sorted list
   */
  global static List<Object> sort(
    List<Object> theList,
    CMN_UTIL_Comparators.Comparator comparator,
    Boolean sortAsc
  ) {
    return sort(
      theList,
      0,
      (theList == null ? 0 : theList.size() - 1),
      comparator,
      sortAsc
    );
  }

  /**
   * @description sorts list of objects including the low and high index, based on comparator and sort order
   *
   * @param theList as input
   * @param lo0 as input e.g. 0
   * @param hi0 as input e.g. lastIndex
   * @param comparator as input
   * @param sortAsc as input
   *
   * @return sorted list
   */
  private static List<Object> sort(
    List<Object> theList,
    Integer lo0,
    Integer hi0,
    CMN_UTIL_Comparators.Comparator comparator,
    Boolean sortAsc
  ) {
    Integer lo = lo0;
    Integer hi = hi0;

    if (lo >= hi) {
      return theList;
    } else if (lo == hi - 1) {
      if (
        (comparator.compare(theList[lo], theList[hi]) > 0 && sortAsc) ||
        (comparator.compare(theList[lo], theList[hi]) < 0 && !sortAsc)
      ) {
        Object prs = theList[lo];
        theList[lo] = theList[hi];
        theList[hi] = prs;
      }
      return theList;
    }

    Object pivot = theList[(lo + hi) / 2];
    theList[(lo + hi) / 2] = theList[hi];
    theList[hi] = pivot;

    while (lo < hi) {
      while (
        (comparator.compare(theList[lo], pivot) <= 0 && lo < hi && sortAsc) ||
        (comparator.compare(theList[lo], pivot) >= 0 &&
        lo < hi &&
        !sortAsc)
      ) {
        lo++;
      }
      while (
        (comparator.compare(pivot, theList[hi]) <= 0 && lo < hi && sortAsc) ||
        (comparator.compare(pivot, theList[hi]) >= 0 &&
        lo < hi &&
        !sortAsc)
      ) {
        hi--;
      }

      if (lo < hi) {
        Object prs = theList[lo];
        theList[lo] = theList[hi];
        theList[hi] = prs;
      }
    }

    theList[hi0] = theList[hi];
    theList[hi] = pivot;

    sort(theList, lo0, lo - 1, comparator, sortAsc);
    sort(theList, hi + 1, hi0, comparator, sortAsc);

    return theList;
  }

  /**
   * @description sort salesforce sobjects list using sobject comparator
   *
   * @param theList as input
   * @param comparator as input
   *
   * @return list of sorted sobjects
   */
  global static List<SObject> sortSObjects(
    List<SObject> theList,
    CMN_UTIL_Comparators.SObjectComparator comparator
  ) {
    return sortSObjects(theList, comparator, true);
  }

  /**
   * @description sorte salesforce object list using sobject comparator and sort ascending
   *
   * @param theList as input
   * @param comparator as input
   * @param sortAsc as input
   *
   * @return sorted sobject list
   */
  global static List<SObject> sortSObjects(
    List<SObject> theList,
    CMN_UTIL_Comparators.SObjectComparator comparator,
    Boolean sortAsc
  ) {
    return sortSObjects(
      theList,
      0,
      (theList == null ? 0 : theList.size() - 1),
      comparator,
      sortAsc
    );
  }

  /**
   * @description sorts sobjects including the low and high index, based on comparator and sort order
   *
   * @param theList as input
   * @param lo0 as input e.g. 0
   * @param hi0 as input e.g. lastIndex
   * @param comparator as input
   * @param sortAsc as input
   *
   * @return sorted sobject list
   */
  private static List<SObject> sortSObjects(
    List<SObject> theList,
    Integer lo0,
    Integer hi0,
    CMN_UTIL_Comparators.SObjectComparator comparator,
    Boolean sortAsc
  ) {
    Integer lo = lo0;
    Integer hi = hi0;

    if (lo >= hi) {
      return theList;
    } else if (lo == hi - 1) {
      if (
        (comparator.compare(theList[lo], theList[hi]) > 0 && sortAsc) ||
        (comparator.compare(theList[lo], theList[hi]) < 0 && !sortAsc)
      ) {
        SObject prs = theList[lo];
        theList[lo] = theList[hi];
        theList[hi] = prs;
      }
      return theList;
    }

    SObject pivot = theList[(lo + hi) / 2];
    theList[(lo + hi) / 2] = theList[hi];
    theList[hi] = pivot;

    while (lo < hi) {
      while (
        (comparator.compare(theList[lo], pivot) <= 0 && lo < hi && sortAsc) ||
        (comparator.compare(theList[lo], pivot) >= 0 &&
        lo < hi &&
        !sortAsc)
      ) {
        lo++;
      }
      while (
        (comparator.compare(pivot, theList[hi]) <= 0 && lo < hi && sortAsc) ||
        (comparator.compare(pivot, theList[hi]) >= 0 &&
        lo < hi &&
        !sortAsc)
      ) {
        hi--;
      }

      if (lo < hi) {
        SObject prs = theList[lo];
        theList[lo] = theList[hi];
        theList[hi] = prs;
      }
    }

    theList[hi0] = theList[hi];
    theList[hi] = pivot;

    sortSObjects(theList, lo0, lo - 1, comparator, sortAsc);
    sortSObjects(theList, hi + 1, hi0, comparator, sortAsc);

    return theList;
  }
}