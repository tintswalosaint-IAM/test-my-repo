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
private class CMN_UTIL_Boolean_TEST {
  @IsTest
  private static void testIsFalse() {
    System.assertEquals(CMN_UTIL_Boolean.isFalse(true), false);
    System.assertEquals(CMN_UTIL_Boolean.isFalse(false), true);
    System.assertEquals(CMN_UTIL_Boolean.isFalse(null), false);
  }

  @IsTest
  private static void testIsNotFalse() {
    System.assertEquals(CMN_UTIL_Boolean.isNotFalse(true), true);
    System.assertEquals(CMN_UTIL_Boolean.isNotFalse(false), false);
    System.assertEquals(CMN_UTIL_Boolean.isNotFalse(null), true);
  }

  @IsTest
  private static void testIsTrue() {
    System.assertEquals(CMN_UTIL_Boolean.isTrue(true), true);
    System.assertEquals(CMN_UTIL_Boolean.isTrue(false), false);
    System.assertEquals(CMN_UTIL_Boolean.isTrue(null), false);
  }

  @IsTest
  private static void testIsNotTrue() {
    System.assertEquals(CMN_UTIL_Boolean.isNotTrue(true), false);
    System.assertEquals(CMN_UTIL_Boolean.isNotTrue(false), true);
    System.assertEquals(CMN_UTIL_Boolean.isNotTrue(null), true);
  }

  @IsTest
  private static void testNegate() {
    System.assertEquals(CMN_UTIL_Boolean.negate(true), false);
    System.assertEquals(CMN_UTIL_Boolean.negate(false), true);
    System.assertEquals(CMN_UTIL_Boolean.negate(null), null);
  }

  @IsTest
  private static void testToBooleanDefaultIfNull() {
    System.assertEquals(
      CMN_UTIL_Boolean.toBooleanDefaultIfNull(true, false),
      true
    );
    System.assertEquals(
      CMN_UTIL_Boolean.toBooleanDefaultIfNull(false, false),
      false
    );
    System.assertEquals(
      CMN_UTIL_Boolean.toBooleanDefaultIfNull(null, false),
      false
    );
  }

  @IsTest
  private static void testToBoolean() {
    System.assertEquals(CMN_UTIL_Boolean.toBoolean(1), true);
    System.assertEquals(CMN_UTIL_Boolean.toBoolean(0), false);
    System.assertEquals(CMN_UTIL_Boolean.toBoolean(null), false);

    System.assertEquals(CMN_UTIL_Boolean.toBoolean(1, 1, 0), true);
    System.assertEquals(CMN_UTIL_Boolean.toBoolean(0, 1, 0), false);
    try {
      System.assertEquals(CMN_UTIL_Boolean.toBoolean(2, 1, 0), false);
    } catch (Exception exp) {
    }
  }

  @IsTest
  private static void testToInteger() {
    System.assertEquals(CMN_UTIL_Boolean.toInteger(true), 1);
    System.assertEquals(CMN_UTIL_Boolean.toInteger(false), 0);
    try {
      System.assertEquals(CMN_UTIL_Boolean.toInteger(null), 0);
    } catch (Exception exp) {
    }
  }

  @IsTest
  private static void testToStringYesNo() {
    System.assertEquals(CMN_UTIL_Boolean.toStringYesNo(true), 'yes');
    System.assertEquals(CMN_UTIL_Boolean.toStringYesNo(false), 'no');
    System.assertEquals(CMN_UTIL_Boolean.toStringYesNo(null), null);
  }

  @IsTest
  private static void testToString() {
    System.assertEquals(
      CMN_UTIL_Boolean.toString(true, 'true', 'false'),
      'true'
    );
    System.assertEquals(
      CMN_UTIL_Boolean.toString(false, 'true', 'false'),
      'false'
    );
    System.assertEquals(CMN_UTIL_Boolean.toString(null, 'true', 'false'), null);
  }

  @IsTest
  private static void testXor() {
    System.assertEquals(
      CMN_UTIL_Boolean.xor(new List<Boolean>{ true, true, true }),
      true
    );
    System.assertEquals(
      CMN_UTIL_Boolean.xor(new List<Boolean>{ false, false, false }),
      true
    );
    try {
      System.assertEquals(CMN_UTIL_Boolean.xor(new List<Boolean>()), true);
    } catch (Exception exp) {
    }

    try {
      System.assertEquals(CMN_UTIL_Boolean.xor(null), true);
    } catch (Exception exp) {
    }

    System.assertEquals(
      CMN_UTIL_Boolean.xor(new List<Boolean>{ false, false, true }),
      false
    );
  }

  @IsTest
  private static void testStringToBoolean() {
    System.assertEquals(CMN_UTIL_Boolean.stringToBoolean('true'), true);
    System.assertEquals(CMN_UTIL_Boolean.stringToBoolean('false'), false);
    System.assertEquals(CMN_UTIL_Boolean.stringToBoolean(null), false);
  }

  @IsTest
  private static void testToStringYn() {
    System.assertEquals(CMN_UTIL_Boolean.toStringYn(true), 'Y');
    System.assertEquals(CMN_UTIL_Boolean.toStringYn(false), 'N');
    System.assertEquals(CMN_UTIL_Boolean.toStringYn(null), null);
  }
}