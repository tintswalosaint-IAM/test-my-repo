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
private class CMN_UTIL_NumberRange_TEST {
  @IsTest
  private static void testNullOneRange() {
    try {
      new CMN_UTIL_NumberRange.IntegerRange(null);
      System.assert(false);
    } catch (IllegalArgumentException e) {
      System.assert(true);
    }
  }

  @IsTest
  private static void testNullTwoRange() {
    try {
      new CMN_UTIL_NumberRange.IntegerRange(null, null);
      System.assert(false);
    } catch (IllegalArgumentException e) {
      System.assert(true);
    }
  }

  @IsTest
  private static void testToArrayString() {
    CMN_UTIL_NumberRange.NumberRange range = new CMN_UTIL_NumberRange.IntegerRange(
      0
    );
    System.assertEquals(range.toArrayString(), '[0,0]');

    range = new CMN_UTIL_NumberRange.IntegerRange(0, 1);
    System.assertEquals(range.toArrayString(), '[0,1]');

    range = new CMN_UTIL_NumberRange.IntegerRange(1, 0);
    System.assertEquals(range.toArrayString(), '[0,1]');
  }

  @IsTest
  private static void testCompare() {
    CMN_UTIL_NumberRange.NumberRange range = new CMN_UTIL_NumberRange.IntegerRange(
      0
    );
    System.assertEquals(range.compare(0, 0), 0);
  }

  @IsTest
  private static void testIntegerRange() {
    CMN_UTIL_NumberRange.IntegerRange range = new CMN_UTIL_NumberRange.IntegerRange(
      0
    );
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 0);

    range = new CMN_UTIL_NumberRange.IntegerRange(0, 1);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    range = new CMN_UTIL_NumberRange.IntegerRange(1, 0);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    System.assert(range.contains(1), true);
    System.assert(
      range.contains(new CMN_UTIL_NumberRange.IntegerRange(0, 1)),
      true
    );
    System.assert(
      range.overlaps(new CMN_UTIL_NumberRange.IntegerRange(1, 0)),
      true
    );
  }

  @IsTest
  private static void testLongRange() {
    CMN_UTIL_NumberRange.LongRange range = new CMN_UTIL_NumberRange.LongRange(
      0
    );
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 0);

    range = new CMN_UTIL_NumberRange.LongRange(0, 1);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    range = new CMN_UTIL_NumberRange.LongRange(1, 0);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    System.assert(range.contains(1), true);
    System.assert(
      range.contains(new CMN_UTIL_NumberRange.LongRange(0, 1)),
      true
    );
    System.assert(
      range.overlaps(new CMN_UTIL_NumberRange.LongRange(1, 0)),
      true
    );
  }

  @IsTest
  private static void testDoubleRange() {
    CMN_UTIL_NumberRange.DoubleRange range = new CMN_UTIL_NumberRange.DoubleRange(
      0
    );
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 0);

    range = new CMN_UTIL_NumberRange.DoubleRange(0, 1);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    range = new CMN_UTIL_NumberRange.DoubleRange(1, 0);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    System.assert(range.contains(1), true);
    System.assert(
      range.contains(new CMN_UTIL_NumberRange.DoubleRange(0, 1)),
      true
    );
    System.assert(
      range.overlaps(new CMN_UTIL_NumberRange.DoubleRange(1, 0)),
      true
    );
  }

  @IsTest
  private static void testDecimalRange() {
    CMN_UTIL_NumberRange.DecimalRange range = new CMN_UTIL_NumberRange.DecimalRange(
      0
    );
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 0);

    range = new CMN_UTIL_NumberRange.DecimalRange(0, 1);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    range = new CMN_UTIL_NumberRange.DecimalRange(1, 0);
    System.assertEquals(range.min(), 0);
    System.assertEquals(range.max(), 1);

    System.assert(range.contains(1), true);
    System.assert(
      range.contains(new CMN_UTIL_NumberRange.DecimalRange(0, 1)),
      true
    );
    System.assert(
      range.overlaps(new CMN_UTIL_NumberRange.DecimalRange(1, 0)),
      true
    );
  }
}