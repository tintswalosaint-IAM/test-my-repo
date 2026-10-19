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
private class CMN_UTIL_Set_TEST {
  @IsTest
  private static void test_lowerCase_SetString() {
    CMN_UTIL_Set.assertEquals(null, CMN_UTIL_Set.lowerCase(null));
    CMN_UTIL_Set.assertEquals(
      new Set<String>(),
      CMN_UTIL_Set.lowerCase(new Set<String>())
    );
    CMN_UTIL_Set.assertEquals(
      new Set<String>{ 'a', 'b', 'abcd' },
      CMN_UTIL_Set.lowerCase(new Set<String>{ 'A', 'B', 'ABCD' })
    );
  }

  @IsTest
  private static void test_upperCase_SetString() {
    CMN_UTIL_Set.assertEquals(null, CMN_UTIL_Set.upperCase(null));
    CMN_UTIL_Set.assertEquals(
      new Set<String>(),
      CMN_UTIL_Set.upperCase(new Set<String>())
    );
    CMN_UTIL_Set.assertEquals(
      new Set<String>{ 'A', 'B', 'ABCD' },
      CMN_UTIL_Set.upperCase(new Set<String>{ 'a', 'b', 'abcd' })
    );
  }

  @IsTest
  private static void test_trim_SetString() {
    CMN_UTIL_Set.assertEquals(null, CMN_UTIL_Set.trim(null));
    CMN_UTIL_Set.assertEquals(
      new Set<String>(),
      CMN_UTIL_Set.trim(new Set<String>())
    );
    CMN_UTIL_Set.assertEquals(
      new Set<String>{ 'a', 'b', 'abcd' },
      CMN_UTIL_Set.trim(new Set<String>{ ' a\t\n ', ' \tb\n ', ' abcd ' })
    );
  }

  @IsTest
  private static void test_listToSet_ListString() {
    final List<String> aList = null;
    System.assertEquals(null, CMN_UTIL_Set.listToSet(aList));
    System.assertEquals(0, CMN_UTIL_Set.listToSet(new List<String>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<String>{ '' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<String>{ 'a' }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.listToSet(new List<String>{ 'a', 'b' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<String>{ 'a', 'a' }).size()
    );
  }

  @IsTest
  private static void test_listToSet_ListObject() {
    final List<Object> aList = null;
    System.assertEquals(null, CMN_UTIL_Set.listToSet(aList));
    System.assertEquals(0, CMN_UTIL_Set.listToSet(new List<Object>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<Object>{ '' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<Object>{ 'a' }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.listToSet(new List<Object>{ 'a', 'b' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<Object>{ 'a', 'a' }).size()
    );
  }

  @IsTest
  private static void test_listToSet_ListSObject() {
    final List<SObject> aList = null;
    System.assertEquals(null, CMN_UTIL_Set.listToSet(aList));
    System.assertEquals(0, CMN_UTIL_Set.listToSet(new List<SObject>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<SObject>{ new CMN_Foobar__c() }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.listToSet(new List<SObject>{ new CMN_Foobar__c() }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.listToSet(
          new List<SObject>{
            new CMN_Foobar__c(Name = '1'),
            new CMN_Foobar__c(Name = '2')
          }
        )
        .size()
    );
  }

  @IsTest
  private static void test_setToList_String() {
    final Set<String> records = null;
    System.assertEquals(null, CMN_UTIL_Set.setToList(records));
    System.assertEquals(0, CMN_UTIL_Set.setToList(new Set<String>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<String>{ '' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<String>{ 'a' }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.setToList(new Set<String>{ 'a', 'b' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<String>{ 'a', 'a' }).size()
    );
  }

  @IsTest
  private static void test_setToList_Object() {
    final Set<Object> records = null;
    System.assertEquals(null, CMN_UTIL_Set.setToList(records));
    System.assertEquals(0, CMN_UTIL_Set.setToList(new Set<Object>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<Object>{ '' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<Object>{ 'a' }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.setToList(new Set<Object>{ 'a', 'b' }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<Object>{ 'a', 'a' }).size()
    );
  }

  @IsTest
  private static void test_setToList_SetSObject() {
    final Set<String> records = null;
    System.assertEquals(null, CMN_UTIL_Set.setToList(records));
    System.assertEquals(0, CMN_UTIL_Set.setToList(new Set<SObject>()).size());
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<SObject>{ new CMN_Foobar__c() }).size()
    );
    System.assertEquals(
      1,
      CMN_UTIL_Set.setToList(new Set<SObject>{ new CMN_Foobar__c() }).size()
    );
    System.assertEquals(
      2,
      CMN_UTIL_Set.setToList(
          new Set<SObject>{
            new CMN_Foobar__c(Name = '1'),
            new CMN_Foobar__c(Name = '2')
          }
        )
        .size()
    );
  }

  @IsTest
  private static void test_pluck_ListSObject_String() {
    assert_pluck_ListSObject_String(null, null, null);
    assert_pluck_ListSObject_String(null, 'Name', null);
    assert_pluck_ListSObject_String(
      new List<SObject>(),
      null,
      new Set<Object>()
    );
    assert_pluck_ListSObject_String(
      new List<SObject>(),
      'Name',
      new Set<Object>()
    );
    assert_pluck_ListSObject_String(
      new List<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      null,
      new Set<Object>()
    );
    assert_pluck_ListSObject_String(
      new List<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      'Name',
      new Set<Object>{ 'abc123', 'xyz456' }
    );
  }

  private static void assert_pluck_ListSObject_String(
    List<SObject> records,
    String fieldName,
    Set<Object> expected
  ) {
    Set<Object> actual = CMN_UTIL_Set.pluck(records, fieldName);
    CMN_UTIL_Set.assertEquals(expected, actual);
  }

  @IsTest
  private static void test_pluck_SetSObject_String() {
    assert_pluck_SetSObject_String(null, null, null);
    assert_pluck_SetSObject_String(null, 'Name', null);
    assert_pluck_SetSObject_String(new Set<SObject>(), null, new Set<Object>());
    assert_pluck_SetSObject_String(
      new Set<SObject>(),
      'Name',
      new Set<Object>()
    );
    assert_pluck_SetSObject_String(
      new Set<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      null,
      new Set<Object>()
    );
    assert_pluck_SetSObject_String(
      new Set<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      'Name',
      new Set<Object>{ 'abc123', 'xyz456' }
    );
  }

  private static void assert_pluck_SetSObject_String(
    Set<SObject> records,
    String fieldName,
    Set<Object> expected
  ) {
    Set<Object> actual = CMN_UTIL_Set.pluck(records, fieldName);
    CMN_UTIL_Set.assertEquals(expected, actual);
  }

  @IsTest
  private static void test_pluckString_SetSObject_String() {
    //test: global static Set<String> pluckString(Set<SObject> records, String fieldName){
    assert_pluckString_SetSObject_String(null, null, null);
    assert_pluckString_SetSObject_String(null, 'Name', null);
    assert_pluckString_SetSObject_String(
      new Set<SObject>(),
      null,
      new Set<String>()
    );
    assert_pluckString_SetSObject_String(
      new Set<SObject>(),
      'Name',
      new Set<String>()
    );
    assert_pluckString_SetSObject_String(
      new Set<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      null,
      new Set<String>()
    );
    assert_pluckString_SetSObject_String(
      new Set<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      'Name',
      new Set<String>{ 'abc123', 'xyz456' }
    );
  }

  private static void assert_pluckString_SetSObject_String(
    Set<SObject> records,
    String fieldName,
    Set<String> expected
  ) {
    Set<String> actual = CMN_UTIL_Set.pluckString(records, fieldName);
    CMN_UTIL_Set.assertEquals(expected, actual);
  }

  @IsTest
  private static void test_pluckString_ListSObject_String() {
    assert_pluckString_ListSObject_String(null, null, null);
    assert_pluckString_ListSObject_String(null, 'Name', null);
    assert_pluckString_ListSObject_String(
      new List<SObject>(),
      null,
      new Set<String>()
    );
    assert_pluckString_ListSObject_String(
      new List<SObject>(),
      'Name',
      new Set<String>()
    );
    assert_pluckString_ListSObject_String(
      new List<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      null,
      new Set<String>()
    );
    assert_pluckString_ListSObject_String(
      new List<SObject>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      'Name',
      new Set<String>{ 'abc123', 'xyz456' }
    );
  }

  private static void assert_pluckString_ListSObject_String(
    List<SObject> records,
    String fieldName,
    Set<String> expected
  ) {
    Set<String> actual = CMN_UTIL_Set.pluckString(records, fieldName);
    CMN_UTIL_Set.assertEquals(expected, actual);
  }

  @IsTest
  private static void testObjectToBlob() {
    assertObjectToBlob(null, null);
    assertObjectToBlob(new Set<Object>{}, new Set<Blob>{});
    Blob blob1 = generateRandomBlob();
    Blob blob2 = generateRandomBlob();
    assertObjectToBlob(new Set<Object>{ blob1 }, new Set<Blob>{ blob1 });
    assertObjectToBlob(
      new Set<Object>{ blob1, blob2 },
      new Set<Blob>{ blob1, blob2 }
    );
  }

  @IsTest
  private static void testObjectToBoolean() {
    assertObjectToBoolean(null, null);
    assertObjectToBoolean(new Set<Object>{}, new Set<Boolean>{});
    assertObjectToBoolean(new Set<Object>{ true }, new Set<Boolean>{ true });
    assertObjectToBoolean(
      new Set<Object>{ true, false },
      new Set<Boolean>{ false, true }
    );
  }

  @IsTest
  private static void testObjectToDate() {
    assertObjectToDate(null, null);
    assertObjectToDate(new Set<Object>{}, new Set<Date>{});
    Date date1 = Date.newInstance(2009, 1, 1);
    Date date2 = Date.newInstance(2009, 1, 2);
    assertObjectToDate(new Set<Object>{ date1 }, new Set<Date>{ date1 });
    assertObjectToDate(
      new Set<Object>{ date1, date2 },
      new Set<Date>{ date1, date2 }
    );
  }

  @IsTest
  private static void testObjectToDatetime() {
    assertObjectToDatetime(null, null);
    assertObjectToDatetime(new Set<Object>{}, new Set<Datetime>{});
    Datetime date1 = Datetime.newInstance(2009, 1, 1);
    Datetime date2 = Datetime.newInstance(2009, 1, 2);
    assertObjectToDatetime(
      new Set<Object>{ date1 },
      new Set<Datetime>{ date1 }
    );
    assertObjectToDatetime(
      new Set<Object>{ date1, date2 },
      new Set<Datetime>{ date1, date2 }
    );
  }

  @IsTest
  private static void testObjectToDecimal() {
    assertObjectToDecimal(null, null);
    assertObjectToDecimal(new Set<Object>{}, new Set<Decimal>{});
    Decimal dec1 = 4.0;
    Decimal dec2 = 5.0;
    assertObjectToDecimal(new Set<Object>{ dec1 }, new Set<Decimal>{ dec1 });
    assertObjectToDecimal(
      new Set<Object>{ dec1, dec2 },
      new Set<Decimal>{ dec1, dec2 }
    );
  }

  @IsTest
  private static void testObjectToDouble() {
    assertObjectToDouble(null, null);
    assertObjectToDouble(new Set<Object>{}, new Set<Double>{});
    Double doub1 = 4.0;
    Double doub2 = 5.0;
    assertObjectToDouble(new Set<Object>{ doub1 }, new Set<Double>{ doub1 });
    assertObjectToDouble(
      new Set<Object>{ doub1, doub2 },
      new Set<Double>{ doub1, doub2 }
    );
  }

  @IsTest
  private static void testObjectToId() {
    //removed I/O
    assertObjectToId(null, null);
    assertObjectToId(new Set<Object>{}, new Set<Id>{});
    CMN_Foobar__c foo1 = new CMN_Foobar__c(
      Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
      Name = 'foo1'
    );
    //insert foo1;
    CMN_Foobar__c foo2 = new CMN_Foobar__c(
      Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
      Name = 'foo2'
    );
    //insert foo2;
    assertObjectToId(new Set<Object>{ foo1.Id }, new Set<Id>{ foo1.Id });
    assertObjectToId(
      new Set<Object>{ foo1.Id, foo2.Id },
      new Set<Id>{ foo1.Id, foo2.Id }
    );
  }

  @IsTest
  private static void testObjectToInteger() {
    assertObjectToInteger(null, null);
    assertObjectToInteger(new Set<Object>{}, new Set<Integer>{});
    Integer int1 = 4;
    Integer int2 = 5;
    assertObjectToInteger(new Set<Object>{ int1 }, new Set<Integer>{ int1 });
    assertObjectToInteger(
      new Set<Object>{ int1, int2 },
      new Set<Integer>{ int1, int2 }
    );
  }

  @IsTest
  private static void testObjectToLong() {
    assertObjectToLong(null, null);
    assertObjectToLong(new Set<Object>{}, new Set<Long>{});
    Long long1 = 4;
    Long long2 = 5;
    assertObjectToLong(new Set<Object>{ long1 }, new Set<Long>{ long1 });
    assertObjectToLong(
      new Set<Object>{ long1, long2 },
      new Set<Long>{ long1, long2 }
    );
  }

  @IsTest
  private static void testObjectToTime() {
    assertObjectToTime(null, null);
    assertObjectToTime(new Set<Object>{}, new Set<Time>{});
    Time time1 = Time.newInstance(18, 30, 2, 20);
    Time time2 = Time.newInstance(18, 30, 2, 21);
    assertObjectToTime(new Set<Object>{ time1 }, new Set<Time>{ time1 });
    assertObjectToTime(
      new Set<Object>{ time1, time2 },
      new Set<Time>{ time1, time2 }
    );
  }

  @IsTest
  private static void testObjectToString() {
    assertObjectToString(null, null);
    assertObjectToString(new Set<Object>{}, new Set<String>{});
    String str1 = 'xyz';
    String str2 = 'abc';
    assertObjectToString(new Set<Object>{ str1 }, new Set<String>{ str1 });
    assertObjectToString(
      new Set<Object>{ str1, str2 },
      new Set<String>{ str1, str2 }
    );
  }

  @IsTest
  private static void testToStringBlobSet() {
    assertToStringBlobSet(null, null);
    assertToStringBlobSet(new Set<Blob>{}, '');
    Blob blob1 = generateRandomBlob();
    Blob blob2 = generateRandomBlob();
    assertToStringBlobSet(
      new Set<Blob>{ blob1 },
      '{\'' +
      blob1.toString() +
      '\'}'
    );
    assertToStringBlobSet(
      new Set<Blob>{ blob1, blob2 },
      '{\'' +
      blob1.toString() +
      '\',\'' +
      blob2.toString() +
      '\'}'
    );
  }

  @IsTest
  private static void testToStringBooleanSet() {
    assertToStringBooleanSet(null, null);
    assertToStringBooleanSet(new Set<Boolean>{}, '');
    assertToStringBooleanSet(new Set<Boolean>{ true }, '{true}');
    assertToStringBooleanSet(new Set<Boolean>{ true, false }, '{false,true}');
  }

  @IsTest
  private static void testToStringDateSet() {
    assertToStringDateSet(null, null);
    assertToStringDateSet(new Set<Date>{}, '');
    Date date1 = Date.newInstance(2009, 1, 1);
    Date date2 = Date.newInstance(2009, 1, 2);
    assertToStringDateSet(new Set<Date>{ date1 }, '{' + date1 + '}');
    assertToStringDateSet(
      new Set<Date>{ date1, date2 },
      '{' +
      date1 +
      ',' +
      date2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringDatetimeSet() {
    assertToStringDatetimeSet(null, null);
    assertToStringDatetimeSet(new Set<Datetime>{}, '');
    Datetime date1 = Datetime.newInstance(2009, 1, 1);
    Datetime date2 = Datetime.newInstance(2009, 1, 2);
    assertToStringDatetimeSet(new Set<Datetime>{ date1 }, '{' + date1 + '}');
    assertToStringDatetimeSet(
      new Set<Datetime>{ date1, date2 },
      '{' +
      date1 +
      ',' +
      date2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringDecimalSet() {
    assertToStringDecimalSet(null, null);
    assertToStringDecimalSet(new Set<Decimal>{}, '');
    Decimal dec1 = 4.0;
    Decimal dec2 = 5.0;
    assertToStringDecimalSet(new Set<Decimal>{ dec1 }, '{' + dec1 + '}');
    assertToStringDecimalSet(
      new Set<Decimal>{ dec1, dec2 },
      '{' +
      dec1 +
      ',' +
      dec2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringDoubleSet() {
    assertToStringDoubleSet(null, null);
    assertToStringDoubleSet(new Set<Double>{}, '');
    Double doub1 = 4.0;
    Double doub2 = 5.0;
    assertToStringDoubleSet(new Set<Double>{ doub1 }, '{' + doub1 + '}');
    assertToStringDoubleSet(
      new Set<Double>{ doub1, doub2 },
      '{' +
      doub1 +
      ',' +
      doub2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringIdSet() {
    assertToStringIdSet(null, null);
    assertToStringIdSet(new Set<Id>{}, '');
    CMN_Foobar__c foo1 = new CMN_Foobar__c(
      Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
      Name = 'foo1'
    );
    //insert foo1;
    CMN_Foobar__c foo2 = new CMN_Foobar__c(
      Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
      Name = 'foo2'
    );
    //insert foo2;
    assertToStringIdSet(new Set<Id>{ foo1.Id }, '{' + foo1.Id + '}');
    assertToStringIdSet(
      new Set<Id>{ foo1.Id, foo2.Id },
      '{' +
      foo1.Id +
      ',' +
      foo2.Id +
      '}'
    );
  }

  @IsTest
  private static void testToStringIntegerSet() {
    assertToStringIntegerSet(null, null);
    assertToStringIntegerSet(new Set<Integer>{}, '');
    Integer int1 = 4;
    Integer int2 = 5;
    assertToStringIntegerSet(new Set<Integer>{ int1 }, '{' + int1 + '}');
    assertToStringIntegerSet(
      new Set<Integer>{ int1, int2 },
      '{' +
      int1 +
      ',' +
      int2 +
      '}'
    );
  }
  @IsTest
  private static void testToStringLongSet() {
    assertToStringLongSet(null, null);
    assertToStringLongSet(new Set<Long>{}, '');
    Long long1 = 4;
    Long long2 = 5;
    assertToStringLongSet(new Set<Long>{ long1 }, '{' + long1 + '}');
    assertToStringLongSet(
      new Set<Long>{ long1, long2 },
      '{' +
      long1 +
      ',' +
      long2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringTimeSet() {
    assertToStringTimeSet(null, null);
    assertToStringTimeSet(new Set<Time>{}, '');
    Time time1 = Time.newInstance(18, 30, 2, 20);
    Time time2 = Time.newInstance(18, 30, 2, 21);
    assertToStringTimeSet(new Set<Time>{ time1 }, '{' + time1 + '}');
    assertToStringTimeSet(
      new Set<Time>{ time1, time2 },
      '{' +
      time1 +
      ',' +
      time2 +
      '}'
    );
  }

  @IsTest
  private static void testToStringStringSet() {
    assertToStringStringSet(null, null);
    assertToStringStringSet(new Set<String>{}, '');
    String str1 = 'xyz';
    String str2 = 'abc';
    assertToStringStringSet(new Set<String>{ str1 }, '{' + str1 + '}');
    assertToStringStringSet(
      new Set<String>{ str1, str2 },
      '{' +
      str1 +
      ',' +
      str2 +
      '}'
    );
  }

  private static void assertObjectToBlob(
    Set<Object> objectSet,
    Set<Blob> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Blob> actual = CMN_UTIL_Set.objectToBlob(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToBlob(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToBlob(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }

  private static void assertObjectToBoolean(
    Set<Object> objectSet,
    Set<Boolean> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Boolean> actual = CMN_UTIL_Set.objectToBoolean(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToBoolean(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToBoolean(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToDate(
    Set<Object> objectSet,
    Set<Date> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Date> actual = CMN_UTIL_Set.objectToDate(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToDate(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToDate(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToDatetime(
    Set<Object> objectSet,
    Set<Datetime> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Datetime> actual = CMN_UTIL_Set.objectToDatetime(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToDatetime(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToDatetime(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToDecimal(
    Set<Object> objectSet,
    Set<Decimal> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Decimal> actual = CMN_UTIL_Set.objectToDecimal(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToDecimal(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToDecimal(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToDouble(
    Set<Object> objectSet,
    Set<Double> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Double> actual = CMN_UTIL_Set.objectToDouble(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToDouble(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToDouble(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToId(
    Set<Object> objectSet,
    Set<Id> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Id> actual = CMN_UTIL_Set.objectToId(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToId(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToId(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToInteger(
    Set<Object> objectSet,
    Set<Integer> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Integer> actual = CMN_UTIL_Set.objectToInteger(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToInteger(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToInteger(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToLong(
    Set<Object> objectSet,
    Set<Long> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Long> actual = CMN_UTIL_Set.objectToLong(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToLong(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToLong(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToTime(
    Set<Object> objectSet,
    Set<Time> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<Time> actual = CMN_UTIL_Set.objectToTime(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToTime(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToTime(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }
  private static void assertObjectToString(
    Set<Object> objectSet,
    Set<String> expected
  ) {
    System.assert(
      !((objectSet == null && expected != null) ||
      (objectSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    Set<String> actual = CMN_UTIL_Set.objectToString(objectSet);
    System.assert(
      !(objectSet == null &&
      expected == null &&
      actual != null),
      'CMN_UTIL_Set.objectToString(null) returned ' +
      CMN_UTIL_Set.toString(actual) +
      '; expected null'
    );
    if (expected != null && actual != null) {
      System.assert(
        actual.containsAll(expected) && expected.containsAll(actual),
        'CMN_UTIL_Set.objectToString(' +
        CMN_UTIL_Set.toString(objectSet) +
        ') returned ' +
        CMN_UTIL_Set.toString(actual) +
        '; expected ' +
        CMN_UTIL_Set.toString(expected)
      );
    }
  }

  private static void assertToStringBlobSet(
    Set<Blob> blobSet,
    String expected
  ) {
    System.assert(
      !((blobSet == null && expected != null) ||
      (blobSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(blobSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(blobSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringBooleanSet(
    Set<Boolean> booleanSet,
    String expected
  ) {
    System.assert(
      !((booleanSet == null && expected != null) ||
      (booleanSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(booleanSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(booleanSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringDateSet(
    Set<Date> dateSet,
    String expected
  ) {
    System.assert(
      !((dateSet == null && expected != null) ||
      (dateSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(dateSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(dateSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringDatetimeSet(
    Set<Datetime> datetimeSet,
    String expected
  ) {
    System.assert(
      !((datetimeSet == null && expected != null) ||
      (datetimeSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(datetimeSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(datetimeSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringDecimalSet(
    Set<Decimal> decimalSet,
    String expected
  ) {
    System.assert(
      !((decimalSet == null && expected != null) ||
      (decimalSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(decimalSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(decimalSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringDoubleSet(
    Set<Double> doubleSet,
    String expected
  ) {
    System.assert(
      !((doubleSet == null && expected != null) ||
      (doubleSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(doubleSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(doubleSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringIdSet(Set<Id> idSet, String expected) {
    System.assert(
      !((idSet == null && expected != null) ||
      (idSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(idSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(idSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringIntegerSet(
    Set<Integer> integerSet,
    String expected
  ) {
    System.assert(
      !((integerSet == null && expected != null) ||
      (integerSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(integerSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(integerSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringLongSet(
    Set<Long> longSet,
    String expected
  ) {
    System.assert(
      !((longSet == null && expected != null) ||
      (longSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(longSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(longSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringTimeSet(
    Set<Time> timeSet,
    String expected
  ) {
    System.assert(
      !((timeSet == null && expected != null) ||
      (timeSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(timeSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(timeSet) +
        ') returned \'' +
        actual +
        '\'; expected \'' +
        expected +
        '\''
      );
    }
  }
  private static void assertToStringStringSet(
    Set<String> stringSet,
    String expected
  ) {
    System.assert(
      !((stringSet == null && expected != null) ||
      (stringSet != null &&
      expected == null)),
      'Invalid test input: both parameters should be null.'
    );
    String actual = CMN_UTIL_Set.toString(stringSet);
    Set<String> actualAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (actual == null ? '' : actual),
          '{}\'',
          ''
        ),
        ','
      )
    );
    Set<String> expectedAsStringSet = new Set<String>(
      CMN_UTIL_String.split(
        CMN_UTIL_String.replaceChars(
          (expected == null ? '' : expected),
          '{}\'',
          ''
        ),
        ','
      )
    );
    if (expected != null && actual != null) {
      System.assert(
        actualAsStringSet.containsAll(expectedAsStringSet) &&
        expectedAsStringSet.containsAll(actualAsStringSet),
        'CMN_UTIL_Set.toString(' +
        CMN_UTIL_Set.toString(stringSet) +
        ') returned \'' +
        actual +
        '\';expected \'' +
        expected +
        '\''
      );
    }
  }

  private static Blob generateRandomBlob() {
    // return EncodingUtil.base64Decode(String.valueOf(System.currentTimeMillis() + Math.roundToLong(Math.random()* 10000)));
    // return EncodingUtil.base64Decode(CMN_UTIL_String.generateRandomString(80));
    return EncodingUtil.base64Decode('ABC');
  }

  @IsTest
  private static void testAssertEquals() {
    final Blob blob1 = generateRandomBlob();
    final Date date1 = Date.newInstance(2009, 1, 1);
    final Datetime datetime1 = Datetime.newInstance(2009, 1, 1);
    final Time time1 = Time.newInstance(18, 30, 2, 20);
    CMN_UTIL_Set.assertEquals(new Set<Blob>{ blob1 }, new Set<Blob>{ blob1 });
    CMN_UTIL_Set.assertEquals(
      new Set<Boolean>{ true },
      new Set<Boolean>{ true }
    );
    CMN_UTIL_Set.assertEquals(new Set<Date>{ date1 }, new Set<Date>{ date1 });
    CMN_UTIL_Set.assertEquals(
      new Set<Datetime>{ datetime1 },
      new Set<Datetime>{ datetime1 }
    );
    CMN_UTIL_Set.assertEquals(new Set<Decimal>{ 1.1 }, new Set<Decimal>{ 1.1 });
    CMN_UTIL_Set.assertEquals(new Set<Double>{ 1.1 }, new Set<Double>{ 1.1 });
    CMN_UTIL_Set.assertEquals(new Set<Integer>{ 1 }, new Set<Integer>{ 1 });
    CMN_UTIL_Set.assertEquals(new Set<Long>{ 1L }, new Set<Long>{ 1L });
    CMN_UTIL_Set.assertEquals(new Set<String>{ 'a' }, new Set<String>{ 'a' });
    CMN_UTIL_Set.assertEquals(new Set<Time>{ time1 }, new Set<Time>{ time1 });
  }

  @IsTest
  private static void testEquals() {
    final Set<Object> NULL_SET = null;
    System.assertEquals(true, CMN_UTIL_Set.equals(NULL_SET, NULL_SET));
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(null, new Set<Integer>{ 1 })
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<Integer>{ 1 }, null)
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Integer>(), new Set<Integer>())
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<Integer>{ 1 }, new Set<Integer>())
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<Integer>{ 1 }, new Set<Integer>{ 2 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Integer>{ 1 }, new Set<Integer>{ 1 })
    );

    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(null, new Set<String>{ 'abc' })
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<String>{ 'abc' }, null)
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<String>(), new Set<String>())
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<String>{ 'abc' }, new Set<String>())
    );
    System.assertEquals(
      false,
      CMN_UTIL_Set.equals(new Set<String>{ 'abc' }, new Set<String>{ 'def' })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<String>{ 'abc' }, new Set<String>{ 'abc' })
    );

    final Blob blob1 = generateRandomBlob();
    final Date date1 = Date.newInstance(2009, 1, 1);
    final Datetime datetime1 = Datetime.newInstance(2009, 1, 1);
    final Time time1 = Time.newInstance(18, 30, 2, 20);

    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Blob>{ blob1 }, new Set<Blob>{ blob1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Boolean>{ true }, new Set<Boolean>{ true })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Date>{ date1 }, new Set<Date>{ date1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(
        new Set<Datetime>{ datetime1 },
        new Set<Datetime>{ datetime1 }
      )
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Decimal>{ 1.1 }, new Set<Decimal>{ 1.1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Double>{ 1.1 }, new Set<Double>{ 1.1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Integer>{ 1 }, new Set<Integer>{ 1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Long>{ 1L }, new Set<Long>{ 1L })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<String>{ 'a' }, new Set<String>{ 'a' })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Set.equals(new Set<Time>{ time1 }, new Set<Time>{ time1 })
    );
  }
}