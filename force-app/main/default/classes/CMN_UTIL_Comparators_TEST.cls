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
@IsTest(SeeAllData=false)
private class CMN_UTIL_Comparators_TEST {
  @IsTest
  private static void testPrimitiveComparatorNulls() {
    String aNull = null;
    Object aNullO = aNull;
    Object xyz = 'xyz';
    System.assertEquals(
      -1,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(aNullO, xyz)
    );
    System.assertEquals(
      0,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(aNullO, aNullO)
    );
    System.assertEquals(
      1,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(xyz, aNullO)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorBlob() {
    Object b1 = Blob.valueOf('123');
    Object b2 = Blob.valueOf('abc');
    Boolean exceptionThrown = false;
    try {
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(b1, b2);
    } catch (IllegalArgumentException e) {
      exceptionThrown = true;
    }
    System.assert(exceptionThrown);
  }

  @IsTest
  private static void testPrimitiveComparatorBoolean() {
    assertCompareBoolean(false, true, -1);
    assertCompareBoolean(true, true, 0);
    assertCompareBoolean(false, false, 0);
    assertCompareBoolean(true, false, 1);
  }
  private static void assertCompareBoolean(
    Object b1,
    Object b2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(b1, b2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorDate() {
    assertCompareDate(
      Date.newInstance(1980, 2, 17),
      Date.newInstance(1981, 2, 17),
      -1
    );
    assertCompareDate(
      Date.newInstance(1981, 2, 17),
      Date.newInstance(1981, 2, 17),
      0
    );
    assertCompareDate(
      Date.newInstance(1981, 2, 17),
      Date.newInstance(1980, 2, 17),
      1
    );
  }
  private static void assertCompareDate(
    Object d1,
    Object d2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(d1, d2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorDatetime() {
    Object d1 = Datetime.newInstance(2008, 12, 1, 12, 30, 1);
    Object d2 = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
    assertCompareDatetime(d1, d2, -1);
    assertCompareDatetime(d1, d1, 0);
    assertCompareDatetime(d2, d1, 1);
  }
  private static void assertCompareDatetime(
    Object d1,
    Object d2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(d1, d2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorDecimal() {
    Decimal d1 = 123.123;
    Decimal d2 = 125.125;
    assertCompareDecimal(d1, d2, -1);
    assertCompareDecimal(d1, d1, 0);
    assertCompareDecimal(d2, d1, 1);
  }
  private static void assertCompareDecimal(
    Object d1,
    Object d2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(d1, d2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorDouble() {
    Double d1 = 123.123;
    Double d2 = 125.125;
    assertCompareDouble(d1, d2, -1);
    assertCompareDouble(d1, d1, 0);
    assertCompareDouble(d2, d1, 1);
  }
  private static void assertCompareDouble(
    Object d1,
    Object d2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(d1, d2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorInteger() {
    Integer i1 = -10;
    Integer i2 = 15;
    assertCompare(i1, i2, -1);
    assertCompare(i1, i1, 0);
    assertCompare(i2, i1, 1);
  }
  private static void assertCompare(Object i1, Object i2, Integer expected) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(i1, i2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorLong() {
    Long i1 = -10;
    Long i2 = 15;
    assertCompareLong(i1, i2, -1);
    assertCompareLong(i1, i1, 0);
    assertCompareLong(i2, i1, 1);
  }
  private static void assertCompareLong(
    Object l1,
    Object l2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(l1, l2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorTime() {
    Time t1 = Time.newInstance(18, 30, 2, 20);
    Time t2 = Time.newInstance(18, 30, 2, 21);
    assertCompareTime(t1, t2, -1);
    assertCompareTime(t2, t2, 0);
    assertCompareTime(t2, t1, 1);
  }
  private static void assertCompareTime(
    Object t1,
    Object t2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(t1, t2)
    );
  }

  @IsTest
  private static void testPrimitiveComparatorString() {
    String s1 = 'abc';
    String s2 = 'def';
    assertCompareString(s1, s2, -1);
    assertCompareString(s1, s1, 0);
    assertCompareString(s2, s1, 1);
  }
  private static void assertCompareString(
    Object s1,
    Object s2,
    Integer expected
  ) {
    System.assertEquals(
      expected,
      (new CMN_UTIL_Comparators.PrimitiveComparator()).compare(s1, s2)
    );
  }

  @IsTest
  private static void testDecimalRangeComparatorIllegalArgumentExceptionThrown() {
    CMN_UTIL_Comparators.Comparator drc = new CMN_UTIL_Comparators.DecimalRangeComparator();
    Boolean exceptionThrown = false;
    try {
      drc.compare(null, null);
    } catch (IllegalArgumentException e) {
      exceptionThrown = true;
    }
    System.assert(exceptionThrown);
  }

  @IsTest
  private static void testDecimalRangeComparatorCompare() {
    Object r1 = new CMN_UTIL_NumberRange.DecimalRange(1, 2);
    Object r2 = new CMN_UTIL_NumberRange.DecimalRange(1.5, 1.7);
    CMN_UTIL_Comparators.Comparator drc = new CMN_UTIL_Comparators.DecimalRangeComparator();
    System.assertEquals(-1, drc.compare(r1, r2));
    System.assertEquals(0, drc.compare(r1, r1));
    System.assertEquals(1, drc.compare(r2, r1));
  }

  @IsTest
  private static void testCompareBadInput() {
    CMN_UTIL_Comparators.SObjectComparator comparator = new CMN_UTIL_Comparators.SObjectNameComparator();
    System.assertEquals(
      -1,
      comparator.compare(null, new CMN_Foobar__c(Name = 'test123'))
    );
    System.assertEquals(0, comparator.compare(null, null));
    System.assertEquals(
      1,
      comparator.compare(new CMN_Foobar__c(Name = 'test123'), null)
    );
  }

  @IsTest
  private static void testCompareWithRecords() {
    CMN_Foobar__c a1 = new CMN_Foobar__c(Name = 'abc');
    CMN_Foobar__c a2 = new CMN_Foobar__c(Name = 'efg');
    CMN_UTIL_Comparators.SObjectComparator comparator = new CMN_UTIL_Comparators.SObjectNameComparator();
    System.assert(0 > comparator.compare(a1, a2));
    System.assert(0 == comparator.compare(a1, a1));
    System.assert(0 < comparator.compare(a2, a1));
  }

  @IsTest
  private static void testCompareThrowsIllegalStateException() {
    Boolean exceptionCaught = false;
    try {
      new CMN_UTIL_Comparators.SObjectSortByFieldComparator(null)
        .compare(
          new CMN_Foobar__c(Name = 'test123'),
          new CMN_Foobar__c(Name = 'test123')
        );
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'CMN_UTIL_Exceptions.IllegalStateException not thrown'
    );
  }

  @IsTest
  private static void testCompareNulls() {
    final CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator(
      'Name'
    );

    System.assertEquals(
      -1,
      comparator.compare(null, new CMN_Foobar__c(Name = 'test123'))
    );
    System.assertEquals(0, comparator.compare(null, null));
    System.assertEquals(
      1,
      comparator.compare(new CMN_Foobar__c(Name = 'test123'), null)
    );
  }

  @IsTest
  private static void testCompareIntegerRecords() {
    CMN_Foobar__c a1 = new CMN_Foobar__c(
      Name = 'abc',
      CMN_NumberDecimal__c = 2
    );
    CMN_Foobar__c a2 = new CMN_Foobar__c(
      Name = 'efg',
      CMN_NumberDecimal__c = 1
    );

    final CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator(
      'CMN_NumberDecimal__c'
    );

    System.assertEquals(1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(-1, comparator.compare(a2, a1));

    comparator.sortAscending = false;
    System.assertEquals(-1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(1, comparator.compare(a2, a1));

    comparator.sortAscending = true;
    System.assertEquals(1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(-1, comparator.compare(a2, a1));

    comparator.sortAscending = null;
    System.assertEquals(1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(-1, comparator.compare(a2, a1));
  }

  @IsTest
  private static void testCompareStringRecords() {
    CMN_Foobar__c a1 = new CMN_Foobar__c(
      Name = 'abc',
      CMN_NumberDecimal__c = 2
    );
    CMN_Foobar__c a2 = new CMN_Foobar__c(
      Name = 'efg',
      CMN_NumberDecimal__c = 1
    );

    CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator(
      'Name'
    );

    System.assertEquals(-1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(1, comparator.compare(a2, a1));

    comparator.sortAscending = false;
    System.assertEquals(1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(-1, comparator.compare(a2, a1));

    comparator.sortAscending = true;
    System.assertEquals(-1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(1, comparator.compare(a2, a1));

    comparator.sortAscending = null;
    System.assertEquals(-1, comparator.compare(a1, a2));
    System.assertEquals(0, comparator.compare(a1, a1));
    System.assertEquals(1, comparator.compare(a2, a1));
  }

  @IsTest
  private static void testSortListSObject() {
    final List<SObject> unsorted = new List<SObject>{
      new CMN_Foobar__c(Name = 'A', CMN_NumberDecimal__c = 2),
      new CMN_Foobar__c(Name = 'D', CMN_NumberDecimal__c = 3),
      new CMN_Foobar__c(Name = 'C', CMN_NumberDecimal__c = 0),
      new CMN_Foobar__c(Name = 'B', CMN_NumberDecimal__c = 1)
    };

    CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator();
    List<SObject> sorted = comparator.sortSObjects(unsorted);

    System.assertNotEquals(null, sorted);
    System.assertEquals(4, sorted.size());
    System.assertEquals('A', sorted.get(0).get('Name'));
    System.assertEquals('B', sorted.get(1).get('Name'));
    System.assertEquals('C', sorted.get(2).get('Name'));
    System.assertEquals('D', sorted.get(3).get('Name'));
  }

  @IsTest
  private static void testSortListSObjectBoolean() {
    final List<SObject> unsorted = new List<SObject>{
      new CMN_Foobar__c(Name = 'A', CMN_NumberDecimal__c = 2),
      new CMN_Foobar__c(Name = 'D', CMN_NumberDecimal__c = 3),
      new CMN_Foobar__c(Name = 'C', CMN_NumberDecimal__c = 0),
      new CMN_Foobar__c(Name = 'B', CMN_NumberDecimal__c = 1)
    };

    CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator();
    List<SObject> sorted = comparator.sortSObjects(unsorted, false);

    System.assertNotEquals(null, sorted);
    System.assertEquals(4, sorted.size());
    System.assertEquals('D', sorted.get(0).get('Name'));
    System.assertEquals('C', sorted.get(1).get('Name'));
    System.assertEquals('B', sorted.get(2).get('Name'));
    System.assertEquals('A', sorted.get(3).get('Name'));
  }

  @IsTest
  private static void testSortListSObjectString() {
    final List<SObject> unsorted = new List<SObject>{
      new CMN_Foobar__c(Name = 'A', CMN_NumberDecimal__c = 2),
      new CMN_Foobar__c(Name = 'D', CMN_NumberDecimal__c = 3),
      new CMN_Foobar__c(Name = 'C', CMN_NumberDecimal__c = 0),
      new CMN_Foobar__c(Name = 'B', CMN_NumberDecimal__c = 1)
    };

    CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator();
    List<SObject> sorted = comparator.sortSObjects(
      unsorted,
      'CMN_NumberDecimal__c'
    );

    System.assertNotEquals(null, sorted);
    System.assertEquals(4, sorted.size());
    System.assertEquals(0, sorted.get(0).get('CMN_NumberDecimal__c'));
    System.assertEquals(1, sorted.get(1).get('CMN_NumberDecimal__c'));
    System.assertEquals(2, sorted.get(2).get('CMN_NumberDecimal__c'));
    System.assertEquals(3, sorted.get(3).get('CMN_NumberDecimal__c'));
  }

  @IsTest
  private static void testSortListSObjectStringBoolean() {
    final List<SObject> unsorted = new List<SObject>{
      new CMN_Foobar__c(Name = 'A', CMN_NumberDecimal__c = 2),
      new CMN_Foobar__c(Name = 'D', CMN_NumberDecimal__c = 3),
      new CMN_Foobar__c(Name = 'C', CMN_NumberDecimal__c = 0),
      new CMN_Foobar__c(Name = 'B', CMN_NumberDecimal__c = 1)
    };

    CMN_UTIL_Comparators.SObjectSortByFieldComparator comparator = new CMN_UTIL_Comparators.SObjectSortByFieldComparator();
    List<SObject> sorted = comparator.sortSObjects(
      unsorted,
      'CMN_NumberDecimal__c',
      false
    );

    System.assertNotEquals(null, sorted);
    System.assertEquals(4, sorted.size());
    System.assertEquals(3, sorted.get(0).get('CMN_NumberDecimal__c'));
    System.assertEquals(2, sorted.get(1).get('CMN_NumberDecimal__c'));
    System.assertEquals(1, sorted.get(2).get('CMN_NumberDecimal__c'));
    System.assertEquals(0, sorted.get(3).get('CMN_NumberDecimal__c'));
  }
}