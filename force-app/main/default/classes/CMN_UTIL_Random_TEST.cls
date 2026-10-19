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
private class CMN_UTIL_Random_TEST {
  @IsTest
  private static void testNextBoolean() {
    System.assertNotEquals(null, CMN_UTIL_Random.nextBoolean());
  }

  @IsTest
  private static void testNextInteger() {
    assertNextInteger(
      CMN_UTIL_Number.MAX_INTEGER_RANGE,
      true,
      CMN_UTIL_Random.nextInteger()
    );
  }

  @IsTest
  private static void testNextTwoInteger() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      inputRange = new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(i));
      assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i));
    }
  }

  @IsTest
  private static void testNextTwoIntegerBoolean() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      inputRange = new CMN_UTIL_NumberRange.IntegerRange(0, Math.abs(i));
      assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i, true));
      assertNextInteger(
        inputRange,
        false,
        CMN_UTIL_Random.nextInteger(i, false)
      );
    }
  }

  @IsTest
  private static void testNextThreeInteger() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      for (Integer j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
        assertNextInteger(inputRange, true, CMN_UTIL_Random.nextInteger(i, j));
      }
    }
  }

  @IsTest
  private static void testNextThreeIntegerBoolean() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      for (Integer j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
        assertNextInteger(
          inputRange,
          true,
          CMN_UTIL_Random.nextInteger(i, j, true)
        );
        assertNextInteger(
          inputRange,
          false,
          CMN_UTIL_Random.nextInteger(i, j, false)
        );
      }
    }
  }

  @IsTest
  private static void testNextIntegerRange() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      for (Integer j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
        assertNextInteger(
          inputRange,
          true,
          CMN_UTIL_Random.nextInteger(inputRange)
        );
      }
    }
  }

  @IsTest
  private static void testNextIntegerRangeBoolean() {
    CMN_UTIL_NumberRange.IntegerRange inputRange = null;
    for (Integer i = -2; i <= 2; i++) {
      for (Integer j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.IntegerRange(i, j);
        assertNextInteger(
          inputRange,
          true,
          CMN_UTIL_Random.nextInteger(inputRange, true)
        );
        assertNextInteger(
          inputRange,
          false,
          CMN_UTIL_Random.nextInteger(inputRange, false)
        );
      }
    }
  }

  @IsTest
  private static void testNextIntegerRangeBooleanNull() {
    final CMN_UTIL_NumberRange.IntegerRange nullRange = null;
    System.assertEquals(null, CMN_UTIL_Random.nextInteger(nullRange, true));
  }

  private static void assertNextInteger(
    CMN_UTIL_NumberRange.IntegerRange inputRange,
    Boolean inclusive,
    Integer actual
  ) {
    CMN_UTIL_NumberRange.IntegerRange acceptableRange = null;
    if (!inclusive && (inputRange.max() - inputRange.min()) <= 2) {
      acceptableRange = new CMN_UTIL_NumberRange.IntegerRange(
        inputRange.min(),
        inputRange.min()
      );
    } else {
      Integer inclusiveChange = 1;
      if (inclusive)
        inclusiveChange = 0;
      acceptableRange = new CMN_UTIL_NumberRange.IntegerRange(
        (Integer) inputRange.min() - inclusiveChange,
        (Integer) inputRange.max() - inclusiveChange
      );
    }
    System.assert(
      acceptableRange.contains(actual),
      'CMN_UTIL_Random.nextInteger(' +
      inputRange.toArrayString() +
      ',' +
      inclusive +
      ') returned ' +
      actual
    );
  }

  @IsTest
  private static void testNextLong() {
    assertNextLong(
      CMN_UTIL_Number.MAX_LONG_RANGE,
      true,
      CMN_UTIL_Random.nextLong()
    );
  }

  @IsTest
  private static void testNextTwoLong() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      inputRange = new CMN_UTIL_NumberRange.LongRange(0, Math.abs(i));
      assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i));
    }
  }

  @IsTest
  private static void testNextTwoLongBoolean() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      inputRange = new CMN_UTIL_NumberRange.LongRange(0, Math.abs(i));
      assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, true));
      assertNextLong(inputRange, false, CMN_UTIL_Random.nextLong(i, false));
    }
  }

  @IsTest
  private static void testNextThreeLong() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      for (Long j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
        assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, j));
      }
    }
  }

  @IsTest
  private static void testNextThreeLongBoolean() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      for (Long j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
        assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(i, j, true));
        assertNextLong(
          inputRange,
          false,
          CMN_UTIL_Random.nextLong(i, j, false)
        );
      }
    }
  }

  @IsTest
  private static void testNextLongRange() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      for (Long j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
        assertNextLong(inputRange, true, CMN_UTIL_Random.nextLong(inputRange));
      }
    }
  }

  @IsTest
  private static void testNextLongRangeBoolean() {
    CMN_UTIL_NumberRange.LongRange inputRange = null;
    for (Long i = -2; i <= 2; i++) {
      for (Long j = -2; j <= 2; j++) {
        inputRange = new CMN_UTIL_NumberRange.LongRange(i, j);
        assertNextLong(
          inputRange,
          true,
          CMN_UTIL_Random.nextLong(inputRange, true)
        );
        assertNextLong(
          inputRange,
          false,
          CMN_UTIL_Random.nextLong(inputRange, false)
        );
      }
    }
  }

  @IsTest
  private static void testNextLongRangeBooleanNull() {
    final CMN_UTIL_NumberRange.LongRange nullRange = null;
    System.assertEquals(null, CMN_UTIL_Random.nextLong(nullRange, true));
  }

  private static void assertNextLong(
    CMN_UTIL_NumberRange.LongRange inputRange,
    Boolean inclusive,
    Long actual
  ) {
    CMN_UTIL_NumberRange.LongRange acceptableRange = null;
    if (!inclusive && (inputRange.max() - inputRange.min()) <= 2) {
      acceptableRange = new CMN_UTIL_NumberRange.LongRange(
        inputRange.min(),
        inputRange.min()
      );
    } else {
      Integer inclusiveChange = 1;
      if (inclusive)
        inclusiveChange = 0;

      acceptableRange = new CMN_UTIL_NumberRange.LongRange(
        inputRange.min() - inclusiveChange,
        inputRange.max() - inclusiveChange
      );
    }
    System.assert(
      acceptableRange.contains(actual),
      'CMN_UTIL_Random.nextLong(' +
      inputRange.toArrayString() +
      ',' +
      inclusive +
      ') returned ' +
      actual
    );
  }

  @IsTest
  private static void testRandom() {
    for (Integer i = -5; i < 5; i++) {
      assertRandom(i);
    }
  }

  private static void assertRandom(Integer count) {
    String actual = CMN_UTIL_Random.random(count);

    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.random(' +
        count +
        ') returned \'' +
        actual +
        '\'; expected \'\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.random(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.isAsciiPrintable(actual),
        'CMN_UTIL_Random.random(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected non-ascii characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomAscii() {
    for (Integer i = -5; i < 5; i++) {
      assertRandomAscii(i);
    }
  }

  private static void assertRandomAscii(Integer count) {
    String actual = CMN_UTIL_Random.randomAscii(count);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.randomAscii(' +
        count +
        ') returned \'' +
        actual +
        '\'; expected \'\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.randomAscii(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.isAsciiPrintable(actual),
        'CMN_UTIL_Random.randomAscii(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected non-ascii characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomAlphabetic() {
    for (Integer i = -5; i < 5; i++) {
      assertRandomAlphabetic(i);
    }
  }

  private static void assertRandomAlphabetic(Integer count) {
    String actual = CMN_UTIL_Random.randomAlphabetic(count);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.randomAlphabetic(' +
        count +
        ') returned \'' +
        actual +
        '\'; expected \'\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.randomAlphabetic(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.isAlpha(actual),
        'CMN_UTIL_Random.randomAlphabetic(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected non-alphabetic characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomAlphanumeric() {
    for (Integer i = -5; i < 5; i++) {
      assertRandomAlphanumeric(i);
    }
  }

  private static void assertRandomAlphanumeric(Integer count) {
    String actual = CMN_UTIL_Random.randomAlphanumeric(count);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.randomAlphanumeric(' +
        count +
        ') returned \'' +
        actual +
        '\'; expected \'\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.randomAlphanumeric(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.isAlphanumeric(actual),
        'CMN_UTIL_Random.randomAlphanumeric(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected non-alphanumeric characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomNumeric() {
    for (Integer i = -5; i < 5; i++) {
      assertRandomNumeric(i);
    }
  }

  private static void assertRandomNumeric(Integer count) {
    String actual = CMN_UTIL_Random.randomNumeric(count);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.randomNumeric(' +
        count +
        ') returned \'' +
        actual +
        '\'; expected \'\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.randomNumeric(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.isNumeric(actual),
        'CMN_UTIL_Random.randomNumeric(' +
        count +
        ') returned \'' +
        actual +
        '\' (unexpected non-numeric characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomTwoArgs() {
    for (Integer i = -5; i < 5; i++) {
      assertRandomTwoArgs(i, 'abc');
    }
    for (Integer i = -5; i < 5; i++) {
      assertRandomTwoArgs(i, '4938%(#*@x)');
    }
  }

  private static void assertRandomTwoArgs(Integer count, String chars) {
    String actual = CMN_UTIL_Random.random(count, chars);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.random(' +
        count +
        ',\'' +
        chars +
        '\') returned \'' +
        actual +
        '\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.random(' +
        count +
        ',\'' +
        chars +
        '\') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      System.assert(
        CMN_UTIL_String.containsOnly(actual, chars),
        'CMN_UTIL_Random.random(' +
        count +
        ',\'' +
        chars +
        '\') returned \'' +
        actual +
        '\' (unexpected characters present)'
      );
    }
  }

  @IsTest
  private static void testRandomThreeArgs() {
    for (Integer i = -5; i < 5; i++) {
      for (Integer j = 0; j < 4; j++) {
        assertRandomThreeArgs(
          i,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1
        );
      }
    }
  }

  private static void assertRandomThreeArgs(
    Integer count,
    Boolean letters,
    Boolean numbers
  ) {
    String actual = CMN_UTIL_Random.random(count, letters, numbers);
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.random(' +
        count +
        ',' +
        letters +
        ',' +
        numbers +
        ') returned \'' +
        actual +
        '\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.random(' +
        count +
        ',' +
        letters +
        ',' +
        numbers +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      if (!letters && !numbers) {
        System.assert(
          CMN_UTIL_String.isAsciiPrintable(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-ascii printable characters present)'
        );
      } else if (!letters && numbers) {
        System.assert(
          CMN_UTIL_String.isNumeric(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-numeric characters present)'
        );
      } else if (letters && !numbers) {
        System.assert(
          CMN_UTIL_String.isAlpha(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-alpha characters present)'
        );
      } else if (letters && numbers) {
        System.assert(
          CMN_UTIL_String.isAlphanumeric(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-alphanumeric characters present)'
        );
      }
    }
  }

  @IsTest
  private static void testRandomFiveArgs() {
    for (Integer i = -5; i < 5; i++) {
      for (Integer j = 0; j < 4; j++) {
        assertRandomFiveArgs(
          i,
          -1,
          0,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1
        );
        assertRandomFiveArgs(
          i,
          0,
          4,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1
        );
        assertRandomFiveArgs(
          i,
          2,
          10,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1
        );
        assertRandomFiveArgs(
          i,
          2,
          1000,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1
        );
      }
    }
  }

  private static void assertRandomFiveArgs(
    Integer count,
    Integer startIndex,
    Integer endIndex,
    Boolean letters,
    Boolean numbers
  ) {
    String actual = CMN_UTIL_Random.random(
      count,
      startIndex,
      endIndex,
      letters,
      numbers
    );
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.random(CMN_UTIL_Random.random(' +
        count +
        ',' +
        startIndex +
        ',' +
        endIndex +
        ',' +
        letters +
        ',' +
        numbers +
        ') returned \'' +
        actual +
        '\''
      );
    } else {
      System.assert(
        CMN_UTIL_String.length(actual) == count,
        'CMN_UTIL_Random.random(' +
        count +
        ',' +
        startIndex +
        ',' +
        endIndex +
        ',' +
        letters +
        ',' +
        numbers +
        ') returned \'' +
        actual +
        '\' (unexpected length)'
      );
      if (!letters && !numbers) {
        System.assert(
          CMN_UTIL_String.isAsciiPrintable(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-ascii printable characters present)'
        );
      } else if (!letters && numbers) {
        System.assert(
          CMN_UTIL_String.isNumeric(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-numeric characters present)'
        );
      } else if (letters && !numbers) {
        System.assert(
          CMN_UTIL_String.isAlpha(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-alpha characters present)'
        );
      } else if (letters && numbers) {
        System.assert(
          CMN_UTIL_String.isAlphanumeric(actual),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ') returned \'' +
          actual +
          '\' (unexpected non-alphanumeric characters present)'
        );
      }
    }
  }

  @IsTest
  private static void testRandomSixArgs() {
    for (Integer i = -5; i < 5; i++) {
      for (Integer j = 0; j < 4; j++) {
        assertRandomSixArgs(
          i,
          -1,
          0,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          null
        );
        assertRandomSixArgs(
          i,
          0,
          4,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          null
        );
        assertRandomSixArgs(
          i,
          2,
          10,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          null
        );
        assertRandomSixArgs(
          i,
          2,
          1000,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          null
        );
        assertRandomSixArgs(
          i,
          -1,
          0,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          'abc$8532(*)'
        );
        assertRandomSixArgs(
          i,
          0,
          4,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          'abc$8532(*)'
        );
        assertRandomSixArgs(
          i,
          2,
          10,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          'abc$8532(*)'
        );
        assertRandomSixArgs(
          i,
          2,
          1000,
          Math.mod(Math.round(j / 2), 2) == 1,
          Math.mod(j, 2) == 1,
          'abc$8532(*)'
        );
      }
    }
  }

  private static void assertRandomSixArgs(
    Integer count,
    Integer startIndex,
    Integer endIndex,
    Boolean letters,
    Boolean numbers,
    String chars
  ) {
    String actual = CMN_UTIL_Random.random(
      count,
      startIndex,
      endIndex,
      letters,
      numbers,
      chars
    );
    if (count < 0) {
      System.assert(
        '' == actual,
        'CMN_UTIL_Random.random(CMN_UTIL_Random.random(' +
        count +
        ',' +
        startIndex +
        ',' +
        endIndex +
        ',' +
        letters +
        ',' +
        numbers +
        ',\'' +
        chars +
        '\') returned \'' +
        actual +
        '\''
      );
    } else {
      if (chars == null) {
        System.assert(
          CMN_UTIL_String.length(actual) == count,
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ',\'' +
          chars +
          '\') returned \'' +
          actual +
          '\' (unexpected length)'
        );
        if (!letters && !numbers) {
          System.assert(
            CMN_UTIL_String.isAsciiPrintable(actual),
            'CMN_UTIL_Random.random(' +
            count +
            ',' +
            startIndex +
            ',' +
            endIndex +
            ',' +
            letters +
            ',' +
            numbers +
            ',\'' +
            chars +
            '\') returned \'' +
            actual +
            '\' (unexpected non-ascii printable characters present)'
          );
        } else if (!letters && numbers) {
          System.assert(
            CMN_UTIL_String.isNumeric(actual),
            'CMN_UTIL_Random.random(' +
            count +
            ',' +
            startIndex +
            ',' +
            endIndex +
            ',' +
            letters +
            ',' +
            numbers +
            ',\'' +
            chars +
            '\') returned \'' +
            actual +
            '\' (unexpected non-numeric characters present)'
          );
        } else if (letters && !numbers) {
          System.assert(
            CMN_UTIL_String.isAlpha(actual),
            'CMN_UTIL_Random.random(' +
            count +
            ',' +
            startIndex +
            ',' +
            endIndex +
            ',' +
            letters +
            ',' +
            numbers +
            ',\'' +
            chars +
            '\') returned \'' +
            actual +
            '\' (unexpected non-alpha characters present)'
          );
        } else if (letters && numbers) {
          System.assert(
            CMN_UTIL_String.isAlphanumeric(actual),
            'CMN_UTIL_Random.random(' +
            count +
            ',' +
            startIndex +
            ',' +
            endIndex +
            ',' +
            letters +
            ',' +
            numbers +
            ',\'' +
            chars +
            '\') returned \'' +
            actual +
            '\' (unexpected non-alphanumeric characters present)'
          );
        }
      } else {
        System.assert(
          CMN_UTIL_String.containsOnly(actual, chars),
          'CMN_UTIL_Random.random(' +
          count +
          ',' +
          startIndex +
          ',' +
          endIndex +
          ',' +
          letters +
          ',' +
          numbers +
          ',\'' +
          chars +
          '\') returned \'' +
          actual +
          '\' (unexpected characters present)'
        );
      }
    }
  }

  @IsTest
  private static void testRandomUUID() {
    String actual = CMN_UTIL_Random.randomUUID();
    System.assertNotEquals(null, actual);
    System.assertEquals(36, actual.length());
    System.assert(
      CMN_UTIL_String.containsOnly(actual, '01234567890abcdef-'),
      'The following UUID contains invalid characters: ' + actual
    );
  }

  @IsTest
  private static void testRandomSobjectId() {
    String actual = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType);
    System.assertNotEquals(null, actual);
    System.assertEquals(18, actual.length());
    String comparison = CMN_UTIL_Random.randomSObjectId(
      CMN_Foobar__c.SObjectType
    );
    System.assertNotEquals(actual, comparison);
  }
}