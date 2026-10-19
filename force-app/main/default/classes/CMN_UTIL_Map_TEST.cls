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
@IsTest(SeeAllData=false)
private class CMN_UTIL_Map_TEST {
  @IsTest
  private static void testJoinMap() {
    assertJoinMap(null, null, null, null);
    Map<String, String> theMap = new Map<String, String>();
    assertJoinMap(theMap, null, null, '');
    assertJoinMap(theMap, '=', '&', '');
    theMap.put('xyz', '123');
    theMap.put('abc', 'efc');
    assertJoinMap(theMap, '=', '&', 'xyz=123&abc=efc');
    System.assertEquals(
      'abc=efc&xyz=123',
      CMN_UTIL_Map.joinMap(theMap, '=', '&')
    );
    theMap.remove('abc');
    assertJoinMap(theMap, '=', '&', 'xyz=123');
    System.assertEquals('xyz=123', CMN_UTIL_Map.joinMap(theMap, '=', '&'));
    theMap.put('abc', 'efc');
    theMap.put('59394932', 'asdfasdfasldjlaksdjf');
    assertJoinMap(
      theMap,
      '=',
      '&',
      'xyz=123&abc=efc&59394932=asdfasdfasldjlaksdjf'
    );
    System.assertEquals(
      '59394932=asdfasdfasldjlaksdjf&abc=efc&xyz=123',
      CMN_UTIL_Map.joinMap(theMap, '=', '&')
    );
  }

  private static void assertJoinMap(
    Map<String, String> theMap,
    String keyValueSeparator,
    String recordSeparator,
    String expected
  ) {
    String actual = CMN_UTIL_Map.joinMap(
      theMap,
      keyValueSeparator,
      recordSeparator
    );
    if (theMap == null || theMap.size() <= 0) {
      System.assert(
        CMN_UTIL_String.isBlank(expected),
        'CMN_UTIL_Map.joinMap(Map<String,String>, \'' +
        (keyValueSeparator == null ? 'null' : keyValueSeparator) +
        '\', \'' +
        (recordSeparator == null ? 'null' : recordSeparator) +
        '\') returned ' +
        actual
      );
      return;
    }
    Set<String> actualAsSet = new Set<String>(
      CMN_UTIL_String.split(actual, recordSeparator)
    );
    Set<String> expectedAsSet = new Set<String>(
      CMN_UTIL_String.split(expected, recordSeparator)
    );
    System.assert(
      actualAsSet.containsAll(expectedAsSet) &&
      expectedAsSet.containsAll(actualAsSet),
      'CMN_UTIL_Map.joinMap(Map<String,String>, \'' +
      (keyValueSeparator == null ? 'null' : keyValueSeparator) +
      '\', \'' +
      (recordSeparator == null ? 'null' : recordSeparator) +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testToString() {
    Map<String, String> theMap = new Map<String, String>();
    theMap.put('xyz', '123');
    System.assertEquals('<Map#([xyz=123])>', CMN_UTIL_Map.toString(theMap));
  }

  @IsTest
  private static void testEquals() {
    Map<String, String> map1 = new Map<String, String>();
    Map<String, String> map2 = new Map<String, String>();
    assertEquals(null, null, true);
    assertEquals(null, map1, false);
    assertEquals(map1, null, false);
    map1.put('xyz', '123');
    assertEquals(map1, map2, false);
    map2.put('xyz2', '123');
    assertEquals(map1, map2, false);
    map2.remove('xyz2');
    map2.put('xyz', '123x');
    assertEquals(map1, map2, false);
    map2.put('xyz', '123');
    assertEquals(map1, map2, true);
  }

  private static void assertEquals(
    Map<String, String> map1,
    Map<String, String> map2,
    Boolean expected
  ) {
    Boolean actual = CMN_UTIL_Map.equals(map1, map2);
    System.assert(
      actual == expected,
      'CMN_UTIL_Map.equals(' +
      CMN_UTIL_Map.toString(map1) +
      ',' +
      CMN_UTIL_Map.toString(map2) +
      ') returned ' +
      actual
    );
  }

  @IsTest
  private static void testLowerCaseKeys() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.lowerCaseKeys(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.lowerCaseKeys(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'abcdefgh' => 'MnOPQrstUv',
        'xyz' => 'aTiejcFGEkdkd'
      },
      CMN_UTIL_Map.lowerCaseKeys(
        new Map<String, String>{
          'aBcDEfgH' => 'MnOPQrstUv',
          'XyZ' => 'aTiejcFGEkdkd'
        }
      )
    );
  }

  @IsTest
  private static void testUpperCaseKeys() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.upperCaseKeys(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.upperCaseKeys(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'ABCDEFGH' => 'MnOPQrstUv',
        'XYZ' => 'aTiejcFGEkdkd'
      },
      CMN_UTIL_Map.upperCaseKeys(
        new Map<String, String>{
          'aBcDEfgH' => 'MnOPQrstUv',
          'XyZ' => 'aTiejcFGEkdkd'
        }
      )
    );
  }

  @IsTest
  private static void testTrimKeys() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.trimKeys(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.trimKeys(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'aBcDEfgH' => 'MnOPQrstUv',
        'XyZ' => 'aTiejcFGEkdkd'
      },
      CMN_UTIL_Map.trimKeys(
        new Map<String, String>{
          '   aBcDEfgH   \t\n' => 'MnOPQrstUv',
          '  XyZ  ' => 'aTiejcFGEkdkd'
        }
      )
    );
  }

  @IsTest
  private static void testLowerCaseValues() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.lowerCaseValues(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.lowerCaseValues(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'aBcDEfgH' => 'mnopqrstuv',
        'XyZ' => 'atiejcfgekdkd'
      },
      CMN_UTIL_Map.lowerCaseValues(
        new Map<String, String>{
          'aBcDEfgH' => 'MnOPQrstUv',
          'XyZ' => 'aTiejcFGEkdkd'
        }
      )
    );
  }

  @IsTest
  private static void testUpperCaseValues() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.upperCaseValues(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.upperCaseValues(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'aBcDEfgH' => 'MNOPQRSTUV',
        'XyZ' => 'ATIEJCFGEKDKD'
      },
      CMN_UTIL_Map.upperCaseValues(
        new Map<String, String>{
          'aBcDEfgH' => 'MnOPQrstUv',
          'XyZ' => 'aTiejcFGEkdkd'
        }
      )
    );
  }

  @IsTest
  private static void testTrimValues() {
    CMN_UTIL_Map.assertEquals(null, CMN_UTIL_Map.trimValues(null));
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>(),
      CMN_UTIL_Map.trimValues(new Map<String, String>())
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'aBcDEfgH' => 'MnOPQrstUv',
        'XyZ' => 'aTiejcFGEkdkd'
      },
      CMN_UTIL_Map.trimValues(
        new Map<String, String>{
          'aBcDEfgH' => '   MnOPQrstUv   \t\n',
          'XyZ' => '  aTiejcFGEkdkd  '
        }
      )
    );
  }

  @IsTest
  private static void testIndex() {
    final List<CMN_Foobar__c> foos = new List<CMN_Foobar__c>{
      new CMN_Foobar__c(Name = 'def', CMN_Text__c = 'asdf asdfasdfasdf'),
      new CMN_Foobar__c(Name = 'abc', CMN_Text__c = 'asdfasdf aas df asdf')
    };
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'abc' => 'asdfasdf aas df asdf',
        'def' => 'asdf asdfasdfasdf'
      },
      CMN_UTIL_Map.index(foos, 'name', 'CMN_Text__c')
    );
    CMN_UTIL_Map.assertEquals(
      new Map<String, String>{
        'asdfasdf aas df asdf' => 'abc',
        'asdf asdfasdfasdf' => 'def'
      },
      CMN_UTIL_Map.index(foos, 'CMN_Text__c', 'name')
    );
  }
}