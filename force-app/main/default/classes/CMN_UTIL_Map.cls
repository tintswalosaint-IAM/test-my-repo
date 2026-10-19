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
global class CMN_UTIL_Map {
  /**
   * @description join map based on provided key value separator
   *
   * @param theMap as input
   * @param keyValueSeparator as input
   *
   * @return list of strings
   */
  global static List<String> joinMap(
    Map<String, String> theMap,
    String keyValueSeparator
  ) {
    return joinX(theMap, keyValueSeparator);
  }

  /**
   * @description join map based on provided key value separator
   *
   * @param theMap as input
   * @param keyValueSeparator as input
   *
   * @return list of strings
   */
  global static List<String> joinX(
    Map<String, String> theMap,
    String keyValueSeparator
  ) {
    List<String> returnValue = null;
    if (theMap != null) {
      returnValue = new List<String>();
      if (theMap.size() > 0) {
        final List<String> keys = new List<String>();
        keys.addAll(theMap.keySet());
        keys.sort();
        for (String key : keys) {
          returnValue.add(key + keyValueSeparator + theMap.get(key));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description join map based on provided key value separator and record separator
   *
   * @param theMap as input
   * @param keyValueSeparator as input
   * @param recordSeparator as input
   *
   * @return list of strings
   */
  global static String joinMap(
    Map<String, String> theMap,
    String keyValueSeparator,
    String recordSeparator
  ) {
    return joinX(theMap, keyValueSeparator, recordSeparator);
  }

  /**
   * @description join map based on provided key value separator and record separator
   *
   * @param theMap as input
   * @param keyValueSeparator as input
   * @param recordSeparator as input
   *
   * @return list of strings
   */
  global static String joinX(
    Map<String, String> theMap,
    String keyValueSeparator,
    String recordSeparator
  ) {
    String returnValue = null;
    if (theMap != null) {
      returnValue = '';
      if (theMap.size() > 0) {
        returnValue = CMN_UTIL_String.joinArray(
          joinMap(theMap, keyValueSeparator),
          recordSeparator
        );
      }
    }
    return returnValue;
  }

  /**
   * @description map to string
   *
   * @param theMap as input
   *
   * @return result
   */
  global static String toString(Map<String, String> theMap) {
    return '<Map#([' + joinMap(theMap, '=', ';') + '])>';
  }

  /**
   * @description checks is two maps match
   *
   * @param map1 as input
   * @param map2 as input
   *
   * @return match or not
   */
  global static Boolean equals(
    Map<String, String> map1,
    Map<String, String> map2
  ) {
    if (map1 == null && map2 == null) {
      return true;
    }
    if (
      (map1 != null &&
      map2 == null) ||
      (map1 == null &&
      map2 != null) ||
      (map1.size() != map2.size())
    ) {
      return false;
    }
    for (String key1 : map1.keySet()) {
      if (!map2.containsKey(key1)) {
        return false;
      }
      if (map1.get(key1) != map2.get(key1)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @description assets if two maps match or throw assert exception
   *
   * @param expected as input
   * @param actual as input
   */
  global static void assertEquals(
    Map<String, String> expected,
    Map<String, String> actual
  ) {
    System.assert(
      equals(expected, actual),
      'Assertion failed, the following two maps are not equal.  Expected: ' +
      expected +
      ', Actual: ' +
      actual
    );
  }

  /**
   * @description converts map keys to lowercase
   *
   * @param theMap as input
   *
   * @return lowercase keyed map
   */
  global static Map<String, String> lowerCaseKeys(Map<String, String> theMap) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(CMN_UTIL_String.lowerCase(key), theMap.get(key));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description converts map keys to uppercase
   *
   * @param theMap as input
   *
   * @return uppercase keyed map
   */
  global static Map<String, String> upperCaseKeys(Map<String, String> theMap) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(CMN_UTIL_String.upperCase(key), theMap.get(key));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description converts map keys to trimmed keys
   *
   * @param theMap as input
   *
   * @return trimmed keyed map
   */
  global static Map<String, String> trimKeys(Map<String, String> theMap) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(CMN_UTIL_String.trim(key), theMap.get(key));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description converts map values to lowercase values
   *
   * @param theMap as input
   *
   * @return lowercase values map
   */
  global static Map<String, String> lowerCaseValues(
    Map<String, String> theMap
  ) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(key, CMN_UTIL_String.lowerCase(theMap.get(key)));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description converts map values to uppercase values
   *
   * @param theMap as input
   *
   * @return uppercase values map
   */
  global static Map<String, String> upperCaseValues(
    Map<String, String> theMap
  ) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(key, CMN_UTIL_String.upperCase(theMap.get(key)));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description converts map values to trimmed values
   *
   * @param theMap as input
   *
   * @return trimmed values map
   */
  global static Map<String, String> trimValues(Map<String, String> theMap) {
    final Map<String, String> returnValue = null;
    if (theMap != null) {
      returnValue = new Map<String, String>();
      if (theMap.size() > 0) {
        for (String key : theMap.keySet()) {
          returnValue.put(key, CMN_UTIL_String.trim(theMap.get(key)));
        }
      }
    }
    return returnValue;
  }

  /**
   * @description returns an index map of sobject based on specified field (must be string-based)
   *
   * @param records as input
   * @param keyFieldName as input
   * @param valueFieldName as input
   *
   * @return index
   */
  global static Map<String, String> index(
    List<SObject> records,
    String keyFieldName, //must be a string field
    String valueFieldName //must be a string field
  ) {
    final Map<String, String> returnValue = null;
    if (records != null) {
      returnValue = new Map<String, String>();
      if (records.size() > 0) {
        Object key = null;
        for (SObject record : records) {
          if (record != null) {
            key = record.get(keyFieldName);
            if (key != null) {
              returnValue.put(
                String.valueOf(key),
                String.valueOf(record.get(valueFieldName))
              );
            }
          }
        }
      }
    }
    return returnValue;
  }
}