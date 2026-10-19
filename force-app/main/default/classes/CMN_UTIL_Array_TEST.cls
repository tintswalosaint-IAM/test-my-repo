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
private class CMN_UTIL_Array_TEST {
  @IsTest
  private static void testObjectToString() {
    assertObjectToString(null, null);
    assertObjectToString(new List<Object>{}, new List<String>{});
    final String str1 = 'xyz';
    final String str2 = 'abc';
    assertObjectToString(new List<Object>{ str1 }, new List<String>{ str1 });
    assertObjectToString(
      new List<Object>{ str1, str2 },
      new List<String>{ str1, str2 }
    );
  }

  private static void assertObjectToString(
    List<Object> objectList,
    List<String> expected
  ) {
    CMN_UTIL_Array.assertArraysAreEqual(
      expected,
      CMN_UTIL_Array.objectToString(objectList)
    );
  }

  @IsTest
  private static void testLowerCase() {
    CMN_UTIL_Array.assertArraysAreEqual(null, CMN_UTIL_Array.lowerCase(null));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ null },
      CMN_UTIL_Array.lowerCase(new List<String>{ null })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ ' ' },
      CMN_UTIL_Array.lowerCase(new List<String>{ ' ' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'abc', 'xyz' },
      CMN_UTIL_Array.lowerCase(new List<String>{ 'abc', 'xyz' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'abc', 'xyz' },
      CMN_UTIL_Array.lowerCase(new List<String>{ 'Abc', 'xYz' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'abc', 'xyz' },
      CMN_UTIL_Array.lowerCase(new List<String>{ 'ABC', 'XYZ' })
    );
  }

  @IsTest
  private static void testUpperCase() {
    CMN_UTIL_Array.assertArraysAreEqual(null, CMN_UTIL_Array.lowerCase(null));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ null },
      CMN_UTIL_Array.upperCase(new List<String>{ null })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ ' ' },
      CMN_UTIL_Array.upperCase(new List<String>{ ' ' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'ABC', 'XYZ' },
      CMN_UTIL_Array.upperCase(new List<String>{ 'abc', 'xyz' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'ABC', 'XYZ' },
      CMN_UTIL_Array.upperCase(new List<String>{ 'Abc', 'xYz' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'ABC', 'XYZ' },
      CMN_UTIL_Array.upperCase(new List<String>{ 'ABC', 'XYZ' })
    );
  }

  @IsTest
  private static void testTrim() {
    CMN_UTIL_Array.assertArraysAreEqual(null, CMN_UTIL_Array.trim(null));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ null },
      CMN_UTIL_Array.trim(new List<String>{ null })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ '' },
      CMN_UTIL_Array.trim(new List<String>{ ' \n\t ' })
    );
  }

  @IsTest
  private static void testReverseObject() {
    Object[] nullArray = null;
    CMN_UTIL_Array.assertArraysAreEqual(
      null,
      CMN_UTIL_Array.reverse(nullArray)
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{},
      CMN_UTIL_Array.reverse(new List<String>{})
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'a' },
      CMN_UTIL_Array.reverse(new List<String>{ 'a' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'ab', 'c' },
      CMN_UTIL_Array.reverse(new List<String>{ 'c', 'ab' })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<String>{ 'a', 'b', 'c' },
      CMN_UTIL_Array.reverse(new List<String>{ 'c', 'b', 'a' })
    );
  }

  @IsTest
  private static void testReverseSObject() {
    SObject[] nullArray = null;
    CMN_Foobar__c x = new CMN_Foobar__c(Name = 'x');
    CMN_Foobar__c y = new CMN_Foobar__c(Name = 'y');
    CMN_Foobar__c z = new CMN_Foobar__c(Name = 'z');
    CMN_UTIL_Array.assertArraysAreEqual(
      null,
      CMN_UTIL_Array.reverse(nullArray)
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{},
      CMN_UTIL_Array.reverse(new List<CMN_Foobar__c>{})
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{ x },
      CMN_UTIL_Array.reverse(new List<CMN_Foobar__c>{ x })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{ x, y },
      CMN_UTIL_Array.reverse(new List<CMN_Foobar__c>{ y, x })
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{ x, y, z },
      CMN_UTIL_Array.reverse(new List<CMN_Foobar__c>{ z, y, x })
    );
  }

  @IsTest
  private static void testIsEmpty() {
    String[] aNull = null;
    CMN_Foobar__c[] aNull2 = null;
    CMN_UTIL_NumberRange.DecimalRange[] aNull3 = null;
    System.assertEquals(true, CMN_UTIL_Array.isEmpty(aNull));
    System.assertEquals(true, CMN_UTIL_Array.isEmpty(new List<String>{}));
    System.assertEquals(false, CMN_UTIL_Array.isEmpty(new List<String>{ 'a' }));
    System.assertEquals(
      false,
      CMN_UTIL_Array.isEmpty(new List<String>{ 'a', 'b' })
    );
    System.assertEquals(true, CMN_UTIL_Array.isEmpty(new List<Integer>{}));
    System.assertEquals(false, CMN_UTIL_Array.isEmpty(new List<Integer>{ 1 }));
    System.assertEquals(
      false,
      CMN_UTIL_Array.isEmpty(new List<Integer>{ 1, 2 })
    );
    System.assertEquals(true, CMN_UTIL_Array.isEmpty(aNull2));
    System.assertEquals(
      true,
      CMN_UTIL_Array.isEmpty(new List<CMN_Foobar__c>{})
    );
    System.assertEquals(
      false,
      CMN_UTIL_Array.isEmpty(
        new List<CMN_Foobar__c>{ new CMN_Foobar__c(Name = 'test') }
      )
    );
    System.assertEquals(true, CMN_UTIL_Array.isEmpty(aNull3));
    System.assertEquals(
      true,
      CMN_UTIL_Array.isEmpty(new List<CMN_UTIL_NumberRange.DecimalRange>{})
    );
    System.assertEquals(
      false,
      CMN_UTIL_Array.isEmpty(
        new List<CMN_UTIL_NumberRange.DecimalRange>{
          new CMN_UTIL_NumberRange.DecimalRange(1, 1)
        }
      )
    );
  }

  @IsTest
  private static void testIsNotEmpty() {
    String[] aNull = null;
    CMN_Foobar__c[] aNull2 = null;
    CMN_UTIL_NumberRange.DecimalRange[] aNull3 = null;
    System.assertEquals(false, CMN_UTIL_Array.isNotEmpty(aNull));
    System.assertEquals(false, CMN_UTIL_Array.isNotEmpty(new List<String>{}));
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(new List<String>{ 'a' })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(new List<String>{ 'a', 'b' })
    );
    System.assertEquals(false, CMN_UTIL_Array.isNotEmpty(new List<Integer>{}));
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(new List<Integer>{ 1 })
    );
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(new List<Integer>{ 1, 2 })
    );
    System.assertEquals(false, CMN_UTIL_Array.isNotEmpty(aNull2));
    System.assertEquals(
      false,
      CMN_UTIL_Array.isNotEmpty(new List<CMN_Foobar__c>{})
    );
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(
        new List<CMN_Foobar__c>{ new CMN_Foobar__c(Name = 'test') }
      )
    );
    System.assertEquals(false, CMN_UTIL_Array.isNotEmpty(aNull3));
    System.assertEquals(
      false,
      CMN_UTIL_Array.isNotEmpty(new List<CMN_UTIL_NumberRange.DecimalRange>{})
    );
    System.assertEquals(
      true,
      CMN_UTIL_Array.isNotEmpty(
        new List<CMN_UTIL_NumberRange.DecimalRange>{
          new CMN_UTIL_NumberRange.DecimalRange(1, 1)
        }
      )
    );
  }

  @IsTest
  private static void testPluck() {
    assertPluck(null, 'Name', new List<Object>{});
    assertPluck(
      new List<CMN_Foobar__c>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      null,
      new List<Object>{}
    );
    assertPluck(
      new List<CMN_Foobar__c>{
        new CMN_Foobar__c(Name = 'abc123'),
        new CMN_Foobar__c(Name = 'xyz456')
      },
      'Name',
      new List<String>{ 'abc123', 'xyz456' }
    );
  }

  private static void assertPluck(
    SObject[] objectArray,
    String fieldName,
    Object[] expected
  ) {
    Object[] actual = CMN_UTIL_Array.pluck(objectArray, fieldName);
    CMN_UTIL_Array.assertArraysAreEqual(expected, actual);
  }

  @IsTest
  private static void testMergeObjectArrays() {
    Object[] nullArray = null;
    System.assertEquals(null, CMN_UTIL_Array.mergeX(nullArray, nullArray));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<Object>{},
      CMN_UTIL_Array.mergeX(new List<Object>{}, nullArray)
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<Object>{},
      CMN_UTIL_Array.mergeX(nullArray, new List<Object>{})
    );
    Object x = 'x';
    Object y = 'y';
    Object z = 'z';
    Object ten = 10;
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<Object>{ x, y, z, ten },
      CMN_UTIL_Array.mergeX(
        new List<Object>{ x, y },
        new List<Object>{ z, ten }
      )
    );
  }

  @IsTest
  private static void testMergeSObjectArrays() {
    SObject[] nullArray = null;
    System.assertEquals(null, CMN_UTIL_Array.mergeX(nullArray, nullArray));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{},
      CMN_UTIL_Array.mergeX(new List<CMN_Foobar__c>{}, nullArray)
    );
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{},
      CMN_UTIL_Array.mergeX(
        new List<CMN_Foobar__c>{},
        new List<CMN_Foobar__c>{}
      )
    );
    CMN_Foobar__c x = new CMN_Foobar__c(Name = 'x');
    CMN_Foobar__c y = new CMN_Foobar__c(Name = 'y');
    CMN_Foobar__c z = new CMN_Foobar__c(Name = 'z');
    CMN_Foobar__c ten = new CMN_Foobar__c(Name = '10');
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{ x, y, z, ten },
      CMN_UTIL_Array.mergeX(
        new List<CMN_Foobar__c>{ x, y },
        new List<CMN_Foobar__c>{ z, ten }
      )
    );
  }

  @IsTest
  private static void testCreateEmptySObjectList() {
    System.assertEquals(null, CMN_UTIL_Array.createEmptySObjectList(null));
    CMN_UTIL_Array.assertArraysAreEqual(
      new List<CMN_Foobar__c>{},
      CMN_UTIL_Array.createEmptySObjectList(new CMN_Foobar__c())
    );
  }

  @IsTest
  private static void testQSortSObjects() {
    List<CMN_Foobar__c> listToSort = new List<CMN_Foobar__c>{
      new CMN_Foobar__c(Name = 'test9'),
      new CMN_Foobar__c(Name = 'test5'),
      new CMN_Foobar__c(Name = 'test3'),
      new CMN_Foobar__c(Name = 'test7'),
      new CMN_Foobar__c(Name = 'test8'),
      new CMN_Foobar__c(Name = 'test1'),
      new CMN_Foobar__c(Name = 'test2')
    };

    CMN_UTIL_Array.sortSObjects(
      listToSort,
      new CMN_UTIL_Comparators.SObjectNameComparator()
    );
    System.assertNotEquals(null, listToSort);
    System.assertEquals(7, listToSort.size());
    System.assertEquals('test1', listToSort[0].Name);
    System.assertEquals('test2', listToSort[1].Name);
    System.assertEquals('test3', listToSort[2].Name);
  }
  @IsTest
  private static void testQSortForceDotComPrimitives() {
    List<Double> listToSort = new List<Double>{ 4, 1.22, -5.4, 1.22, 3.2 };
    CMN_UTIL_Array.sort(listToSort);
    System.assertNotEquals(null, listToSort);
    System.assertEquals(5, listToSort.size());

    System.assertEquals(-5.4, listToSort[0]);
    System.assertEquals(1.22, listToSort[1]);
    System.assertEquals(1.22, listToSort[2]);
    System.assertEquals(3.2, listToSort[3]);
    System.assertEquals(4, listToSort[4]);

    CMN_UTIL_Array.sort(listToSort, false);
    System.assertNotEquals(null, listToSort);
    System.assertEquals(5, listToSort.size());

    System.assertEquals(4, listToSort[0]);
    System.assertEquals(3.2, listToSort[1]);
    System.assertEquals(1.22, listToSort[2]);
    System.assertEquals(1.22, listToSort[3]);
    System.assertEquals(-5.4, listToSort[4]);
  }

  @IsTest
  private static void testQSortCustomClasses() {
    CMN_UTIL_NumberRange.DecimalRange r1 = new CMN_UTIL_NumberRange.DecimalRange(
      -10,
      10
    );
    CMN_UTIL_NumberRange.DecimalRange r2 = new CMN_UTIL_NumberRange.DecimalRange(
      1,
      2
    );
    CMN_UTIL_NumberRange.DecimalRange r3 = new CMN_UTIL_NumberRange.DecimalRange(
      1.3,
      10
    );
    CMN_UTIL_NumberRange.DecimalRange r4 = new CMN_UTIL_NumberRange.DecimalRange(
      1.5,
      1.7
    );
    CMN_UTIL_NumberRange.DecimalRange r5 = new CMN_UTIL_NumberRange.DecimalRange(
      10,
      10
    );
    CMN_UTIL_NumberRange.DecimalRange r6 = new CMN_UTIL_NumberRange.DecimalRange(
      12,
      15
    );
    List<CMN_UTIL_NumberRange.DecimalRange> listToSort = new List<CMN_UTIL_NumberRange.DecimalRange>{
      r4,
      r5,
      r1,
      r2,
      r3,
      r6
    };

    CMN_UTIL_Array.sort(
      listToSort,
      new CMN_UTIL_Comparators.DecimalRangeComparator()
    );
    System.assertNotEquals(null, listToSort);
    System.assertEquals(6, listToSort.size());
    System.assertEquals(r1.min(), listToSort.get(0).min());
    System.assertEquals(r2.min(), listToSort.get(1).min());
    System.assertEquals(r3.min(), listToSort.get(2).min());
  }

  @IsTest
  private static void testToString() {
    List<Object> aList = null;
    CMN_UTIL_Array.toString(aList);
    aList = new List<CMN_UTIL_NumberRange.DecimalRange>{};
    CMN_UTIL_Array.toString(aList);
    aList = new List<CMN_UTIL_NumberRange.DecimalRange>{
      new CMN_UTIL_NumberRange.DecimalRange(12, 15),
      new CMN_UTIL_NumberRange.DecimalRange(12, 15)
    };
    CMN_UTIL_Array.toString(aList);
  }

  @IsTest
  private static void testMergeForceDotComPrimitives() {
    List<Object> l1 = new List<Object>();
    for (
      Integer i = 0; i < CMN_UTIL_Array.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++
    ) {
      l1.add(i);
    }
    Boolean exceptionThrown = false;
    try {
      CMN_UTIL_Array.mergeLists(l1, new List<Integer>{ 1 });
    } catch (IllegalArgumentException e) {
      exceptionThrown = true;
    }
    System.assert(exceptionThrown);

    Double[] d1 = new List<Double>{ 1, 2, 3 };
    Double[] d2 = new List<Double>{ 4, 5, 6 };
    List<Object> merged = CMN_UTIL_Array.mergeLists(d1, d2);
    System.assertNotEquals(null, merged);
    System.assertEquals(6, merged.size());
    System.assertEquals(1, merged.get(0));
    System.assertEquals(4, merged.get(3));
  }

  @IsTest
  private static void testSubsetCustomClasses() {
    Object[] iobjs = new List<CMN_UTIL_NumberRange.DecimalRange>{
      new CMN_UTIL_NumberRange.DecimalRange(1, 1),
      new CMN_UTIL_NumberRange.DecimalRange(2, 2),
      new CMN_UTIL_NumberRange.DecimalRange(3, 3)
    };
    List<Object> returned = CMN_UTIL_Array.subset(iobjs, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(2, returned.size());
    System.assertEquals(
      1,
      ((CMN_UTIL_NumberRange.DecimalRange) returned.get(0)).min()
    );
    System.assertEquals(
      2,
      ((CMN_UTIL_NumberRange.DecimalRange) returned.get(1)).min()
    );
  }

  @IsTest
  private static void testMergeCustomClasses() {
    List<Object> l1 = new List<Object>();
    for (
      Integer i = 0; i < CMN_UTIL_Array.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++
    ) {
      l1.add(new CMN_UTIL_NumberRange.DecimalRange(i, i));
    }
    Boolean exceptionThrown = false;
    try {
      CMN_UTIL_Array.mergeLists(
        l1,
        new List<CMN_UTIL_NumberRange.DecimalRange>{
          new CMN_UTIL_NumberRange.DecimalRange(1, 1)
        }
      );
    } catch (IllegalArgumentException e) {
      exceptionThrown = true;
    }
    System.assert(exceptionThrown);

    CMN_UTIL_NumberRange.DecimalRange[] d1 = new List<CMN_UTIL_NumberRange.DecimalRange>{
      new CMN_UTIL_NumberRange.DecimalRange(1, 1),
      new CMN_UTIL_NumberRange.DecimalRange(2, 2)
    };
    CMN_UTIL_NumberRange.DecimalRange[] d2 = new List<CMN_UTIL_NumberRange.DecimalRange>{
      new CMN_UTIL_NumberRange.DecimalRange(3, 3),
      new CMN_UTIL_NumberRange.DecimalRange(4, 4)
    };
    List<Object> merged = CMN_UTIL_Array.mergeLists(d1, d2);
    System.assertNotEquals(null, merged);
    System.assertEquals(4, merged.size());
    System.assertEquals(
      1,
      ((CMN_UTIL_NumberRange.DecimalRange) merged.get(0)).min()
    );
    System.assertEquals(
      3,
      ((CMN_UTIL_NumberRange.DecimalRange) merged.get(2)).min()
    );
  }

  @IsTest
  private static void testSubsetSObjects() {
    SObject[] sobjs = new List<CMN_Foobar__c>{
      new CMN_Foobar__c(Name = '1'),
      new CMN_Foobar__c(Name = '2'),
      new CMN_Foobar__c(Name = '3')
    };
    List<SObject> returned = CMN_UTIL_Array.subset(sobjs, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(2, returned.size());
    System.assertEquals('1', ((CMN_Foobar__c) returned.get(0)).Name);
    System.assertEquals('2', ((CMN_Foobar__c) returned.get(1)).Name);
  }

  @IsTest
  private static void testMergeSObjects() {
    List<SObject> l1 = new List<CMN_Foobar__c>();
    for (
      Integer i = 0; i < CMN_UTIL_Array.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++
    ) {
      l1.add(new CMN_Foobar__c());
    }
    Boolean exceptionThrown = false;
    try {
      CMN_UTIL_Array.mergeSObjectLists(
        l1,
        new List<CMN_Foobar__c>{ new CMN_Foobar__c() }
      );
    } catch (IllegalArgumentException e) {
      exceptionThrown = true;
    }
    System.assert(exceptionThrown);
    l1 = null;
    List<SObject> merged = CMN_UTIL_Array.mergeSObjectLists(l1, l1);
    System.assertEquals(null, merged);

    CMN_Foobar__c[] c1 = new List<CMN_Foobar__c>{
      new CMN_Foobar__c(Name = '1'),
      new CMN_Foobar__c(Name = '2')
    };
    merged = CMN_UTIL_Array.mergeSObjectLists(l1, c1);
    CMN_Foobar__c[] c2 = new List<CMN_Foobar__c>{
      new CMN_Foobar__c(Name = '3'),
      new CMN_Foobar__c(Name = '4')
    };
    merged = CMN_UTIL_Array.mergeSObjectLists(c1, c2);
    System.assertNotEquals(null, merged);
    System.assertEquals(4, merged.size());
    System.assertEquals('1', ((CMN_Foobar__c) merged.get(0)).Name);
    System.assertEquals('2', ((CMN_Foobar__c) merged.get(1)).Name);
    System.assertEquals('3', ((CMN_Foobar__c) merged.get(2)).Name);
    System.assertEquals('4', ((CMN_Foobar__c) merged.get(3)).Name);
  }

  @IsTest
  private static void testSubsetForceDotComPrimitives() {
    Double[] prim = new List<Double>{ 1, 2, 3 };
    List<Object> returned = CMN_UTIL_Array.subset(prim, 3);
    System.assertNotEquals(null, returned);
    System.assertEquals(3, returned.size());
    System.assertEquals(1, returned.get(0));
    System.assertEquals(2, returned.get(1));
    System.assertEquals(3, returned.get(2));

    returned = CMN_UTIL_Array.subset(prim, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(2, returned.size());
    System.assertEquals(1, returned.get(0));
    System.assertEquals(2, returned.get(1));

    returned = CMN_UTIL_Array.subset(prim, 1);
    System.assertNotEquals(null, returned);
    System.assertEquals(1, returned.size());
    System.assertEquals(1, returned.get(0));

    returned = CMN_UTIL_Array.subset(prim, 1, 3);
    System.assertNotEquals(null, returned);
    System.assertEquals(2, returned.size());
    System.assertEquals(2, returned.get(0));
    System.assertEquals(3, returned.get(1));

    returned = CMN_UTIL_Array.subset(prim, -1, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(0, returned.size());

    returned = CMN_UTIL_Array.subset(prim, 10, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(0, returned.size());

    returned = CMN_UTIL_Array.subset(prim, 0, 20);
    System.assertNotEquals(null, returned);
    System.assertEquals(3, returned.size());

    prim = null;
    returned = CMN_UTIL_Array.subset(prim, 0, 2);
    System.assertNotEquals(null, returned);
    System.assertEquals(0, returned.size());
  }
}