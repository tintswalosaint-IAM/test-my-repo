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
private class CMN_UTIL_Character_TEST {
  private static String CHARS_ASCII_CONTROL = '\n\t\r\f';
  private static String CHARS_ASCII_DIGITS = '0123456789';
  private static String CHARS_ASCII_UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  private static String CHARS_ASCII_LOWER = 'abcdefghijklmnopqrstuvwxyz';
  private static String CHARS_ASCII_PRINTABLE =
    ' !"#$%&\'()*+,-./' +
    CHARS_ASCII_DIGITS +
    ':;<=>?@' +
    CHARS_ASCII_UPPER +
    '[\\]^_`' +
    CHARS_ASCII_LOWER +
    '{|}~';
  private static String CHARS_ALL_ASCII =
    CHARS_ASCII_CONTROL + CHARS_ASCII_PRINTABLE;
  private static String CHARS_NON_ASCII = '€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ ¡¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþ';
  private static String CHARS_ASCII_NON_PRINTABLE =
    CHARS_ASCII_CONTROL + CHARS_NON_ASCII;

  @IsTest
  private static void testValidateChar() {
    final String[] badCharStrings = new List<String>{ '', 'AB' };
    for (String badCharString : badCharStrings) {
      try {
        CMN_UTIL_Character.validateChar(badCharString);
        System.assert(
          false,
          'Exception should have been thrown for invalid char: ' + badCharString
        );
      } catch (Exception e) {
        System.assert(true);
      }
    }
    CMN_UTIL_Character.validateChar('B');
  }

  @IsTest
  private static void testIsUpperCase() {
    final String UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (Integer i = 0; i < UPPER.length(); i++) {
      assertIsUpperCase(UPPER.substring(i, i + 1), true);
    }
    final String LOWER = 'abcdefghijklmnopqrstuvwxyz';
    for (Integer i = 0; i < LOWER.length(); i++) {
      assertIsUpperCase(LOWER.substring(i, i + 1), false);
    }
  }

  private static void assertIsUpperCase(String aCharacter, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isUpperCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isUpperCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testToTitleCase() {
    assertToTitleCase('\t', '\t');
    assertToTitleCase('\n', '\n');
    assertToTitleCase('\f', '\f');
    assertToTitleCase('\r', '\r');
    assertToTitleCase(' ', ' ');
    assertToTitleCase('!', '!');
    assertToTitleCase('"', '"');
    assertToTitleCase('#', '#');
    assertToTitleCase('$', '$');
    assertToTitleCase('%', '%');
    assertToTitleCase('&', '&');
    assertToTitleCase('\'', '\'');
    assertToTitleCase('(', '(');
    assertToTitleCase(')', ')');
    assertToTitleCase('*', '*');
    assertToTitleCase('+', '+');
    assertToTitleCase(',', ',');
    assertToTitleCase('-', '-');
    assertToTitleCase('.', '.');
    assertToTitleCase('/', '/');
    assertToTitleCase('0', '0');
    assertToTitleCase('1', '1');
    assertToTitleCase('2', '2');
    assertToTitleCase('3', '3');
    assertToTitleCase('4', '4');
    assertToTitleCase('5', '5');
    assertToTitleCase('6', '6');
    assertToTitleCase('7', '7');
    assertToTitleCase('8', '8');
    assertToTitleCase('9', '9');
    assertToTitleCase(':', ':');
    assertToTitleCase(';', ';');
    assertToTitleCase('<', '<');
    assertToTitleCase('=', '=');
    assertToTitleCase('>', '>');
    assertToTitleCase('?', '?');
    assertToTitleCase('@', '@');
    assertToTitleCase('A', 'A');
    assertToTitleCase('B', 'B');
    assertToTitleCase('C', 'C');
    assertToTitleCase('D', 'D');
    assertToTitleCase('E', 'E');
    assertToTitleCase('F', 'F');
    assertToTitleCase('G', 'G');
    assertToTitleCase('H', 'H');
    assertToTitleCase('I', 'I');
    assertToTitleCase('J', 'J');
    assertToTitleCase('K', 'K');
    assertToTitleCase('L', 'L');
    assertToTitleCase('M', 'M');
    assertToTitleCase('N', 'N');
    assertToTitleCase('O', 'O');
    assertToTitleCase('P', 'P');
    assertToTitleCase('Q', 'Q');
    assertToTitleCase('R', 'R');
    assertToTitleCase('S', 'S');
    assertToTitleCase('T', 'T');
    assertToTitleCase('U', 'U');
    assertToTitleCase('V', 'V');
    assertToTitleCase('W', 'W');
    assertToTitleCase('X', 'X');
    assertToTitleCase('Y', 'Y');
    assertToTitleCase('Z', 'Z');
    assertToTitleCase('[', '[');
    assertToTitleCase('\\', '\\');
    assertToTitleCase(']', ']');
    assertToTitleCase('^', '^');
    assertToTitleCase('_', '_');
    assertToTitleCase('`', '`');
    assertToTitleCase('a', 'A');
    assertToTitleCase('b', 'B');
    assertToTitleCase('c', 'C');
    assertToTitleCase('d', 'D');
    assertToTitleCase('e', 'E');
    assertToTitleCase('f', 'F');
    assertToTitleCase('g', 'G');
    assertToTitleCase('h', 'H');
    assertToTitleCase('i', 'I');
    assertToTitleCase('j', 'J');
    assertToTitleCase('k', 'K');
    assertToTitleCase('l', 'L');
    assertToTitleCase('m', 'M');
    assertToTitleCase('n', 'N');
    assertToTitleCase('o', 'O');
    assertToTitleCase('p', 'P');
    assertToTitleCase('q', 'Q');
    assertToTitleCase('r', 'R');
    assertToTitleCase('s', 'S');
    assertToTitleCase('t', 'T');
    assertToTitleCase('u', 'U');
    assertToTitleCase('v', 'V');
    assertToTitleCase('w', 'W');
    assertToTitleCase('x', 'X');
    assertToTitleCase('y', 'Y');
    assertToTitleCase('z', 'Z');
    assertToTitleCase('{', '{');
    assertToTitleCase('|', '|');
    assertToTitleCase('}', '}');
    assertToTitleCase('~', '~');
  }

  private static void assertToTitleCase(String aCharacter, String expected) {
    String actual = CMN_UTIL_Character.toTitleCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.toTitleCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testToLowerCase() {
    assertToLowerCase('\t', '\t');
    assertToLowerCase('\n', '\n');
    assertToLowerCase('\f', '\f');
    assertToLowerCase('\r', '\r');
    assertToLowerCase(' ', ' ');
    assertToLowerCase('!', '!');
    assertToLowerCase('"', '"');
    assertToLowerCase('#', '#');
    assertToLowerCase('$', '$');
    assertToLowerCase('%', '%');
    assertToLowerCase('&', '&');
    assertToLowerCase('\'', '\'');
    assertToLowerCase('(', '(');
    assertToLowerCase(')', ')');
    assertToLowerCase('*', '*');
    assertToLowerCase('+', '+');
    assertToLowerCase(',', ',');
    assertToLowerCase('-', '-');
    assertToLowerCase('.', '.');
    assertToLowerCase('/', '/');
    assertToLowerCase('0', '0');
    assertToLowerCase('1', '1');
    assertToLowerCase('2', '2');
    assertToLowerCase('3', '3');
    assertToLowerCase('4', '4');
    assertToLowerCase('5', '5');
    assertToLowerCase('6', '6');
    assertToLowerCase('7', '7');
    assertToLowerCase('8', '8');
    assertToLowerCase('9', '9');
    assertToLowerCase(':', ':');
    assertToLowerCase(';', ';');
    assertToLowerCase('<', '<');
    assertToLowerCase('=', '=');
    assertToLowerCase('>', '>');
    assertToLowerCase('?', '?');
    assertToLowerCase('@', '@');
    assertToLowerCase('A', 'a');
    assertToLowerCase('B', 'b');
    assertToLowerCase('C', 'c');
    assertToLowerCase('D', 'd');
    assertToLowerCase('E', 'e');
    assertToLowerCase('F', 'f');
    assertToLowerCase('G', 'g');
    assertToLowerCase('H', 'h');
    assertToLowerCase('I', 'i');
    assertToLowerCase('J', 'j');
    assertToLowerCase('K', 'k');
    assertToLowerCase('L', 'l');
    assertToLowerCase('M', 'm');
    assertToLowerCase('N', 'n');
    assertToLowerCase('O', 'o');
    assertToLowerCase('P', 'p');
    assertToLowerCase('Q', 'q');
    assertToLowerCase('R', 'r');
    assertToLowerCase('S', 's');
    assertToLowerCase('T', 't');
    assertToLowerCase('U', 'u');
    assertToLowerCase('V', 'v');
    assertToLowerCase('W', 'w');
    assertToLowerCase('X', 'x');
    assertToLowerCase('Y', 'y');
    assertToLowerCase('Z', 'z');
    assertToLowerCase('[', '[');
    assertToLowerCase('\\', '\\');
    assertToLowerCase(']', ']');
    assertToLowerCase('^', '^');
    assertToLowerCase('_', '_');
    assertToLowerCase('`', '`');
    assertToLowerCase('a', 'a');
    assertToLowerCase('b', 'b');
    assertToLowerCase('c', 'c');
    assertToLowerCase('d', 'd');
    assertToLowerCase('e', 'e');
    assertToLowerCase('f', 'f');
    assertToLowerCase('g', 'g');
    assertToLowerCase('h', 'h');
    assertToLowerCase('i', 'i');
    assertToLowerCase('j', 'j');
    assertToLowerCase('k', 'k');
    assertToLowerCase('l', 'l');
    assertToLowerCase('m', 'm');
    assertToLowerCase('n', 'n');
    assertToLowerCase('o', 'o');
    assertToLowerCase('p', 'p');
    assertToLowerCase('q', 'q');
    assertToLowerCase('r', 'r');
    assertToLowerCase('s', 's');
    assertToLowerCase('t', 't');
    assertToLowerCase('u', 'u');
    assertToLowerCase('v', 'v');
    assertToLowerCase('w', 'w');
    assertToLowerCase('x', 'x');
    assertToLowerCase('y', 'y');
    assertToLowerCase('z', 'z');
    assertToLowerCase('{', '{');
    assertToLowerCase('|', '|');
    assertToLowerCase('}', '}');
    assertToLowerCase('~', '~');
  }

  private static void assertToLowerCase(String aCharacter, String expected) {
    String actual = CMN_UTIL_Character.toLowerCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.toLowerCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsTitleCase() {
    //test: global static Boolean isTitleCase(String character){
    assertIsTitleCase('\t', false);
    assertIsTitleCase('\n', false);
    assertIsTitleCase('\f', false);
    assertIsTitleCase('\r', false);
    assertIsTitleCase(' ', false);
    assertIsTitleCase('!', false);
    assertIsTitleCase('"', false);
    assertIsTitleCase('#', false);
    assertIsTitleCase('$', false);
    assertIsTitleCase('%', false);
    assertIsTitleCase('&', false);
    assertIsTitleCase('\'', false);
    assertIsTitleCase('(', false);
    assertIsTitleCase(')', false);
    assertIsTitleCase('*', false);
    assertIsTitleCase('+', false);
    assertIsTitleCase(',', false);
    assertIsTitleCase('-', false);
    assertIsTitleCase('.', false);
    assertIsTitleCase('/', false);
    assertIsTitleCase('0', false);
    assertIsTitleCase('1', false);
    assertIsTitleCase('2', false);
    assertIsTitleCase('3', false);
    assertIsTitleCase('4', false);
    assertIsTitleCase('5', false);
    assertIsTitleCase('6', false);
    assertIsTitleCase('7', false);
    assertIsTitleCase('8', false);
    assertIsTitleCase('9', false);
    assertIsTitleCase(':', false);
    assertIsTitleCase(';', false);
    assertIsTitleCase('<', false);
    assertIsTitleCase('=', false);
    assertIsTitleCase('>', false);
    assertIsTitleCase('?', false);
    assertIsTitleCase('@', false);
    assertIsTitleCase('A', true);
    assertIsTitleCase('B', true);
    assertIsTitleCase('C', true);
    assertIsTitleCase('D', true);
    assertIsTitleCase('E', true);
    assertIsTitleCase('F', true);
    assertIsTitleCase('G', true);
    assertIsTitleCase('H', true);
    assertIsTitleCase('I', true);
    assertIsTitleCase('J', true);
    assertIsTitleCase('K', true);
    assertIsTitleCase('L', true);
    assertIsTitleCase('M', true);
    assertIsTitleCase('N', true);
    assertIsTitleCase('O', true);
    assertIsTitleCase('P', true);
    assertIsTitleCase('Q', true);
    assertIsTitleCase('R', true);
    assertIsTitleCase('S', true);
    assertIsTitleCase('T', true);
    assertIsTitleCase('U', true);
    assertIsTitleCase('V', true);
    assertIsTitleCase('W', true);
    assertIsTitleCase('X', true);
    assertIsTitleCase('Y', true);
    assertIsTitleCase('Z', true);
    assertIsTitleCase('[', false);
    assertIsTitleCase('\\', false);
    assertIsTitleCase(']', false);
    assertIsTitleCase('^', false);
    assertIsTitleCase('_', false);
    assertIsTitleCase('`', false);
    assertIsTitleCase('a', false);
    assertIsTitleCase('b', false);
    assertIsTitleCase('c', false);
    assertIsTitleCase('d', false);
    assertIsTitleCase('e', false);
    assertIsTitleCase('f', false);
    assertIsTitleCase('g', false);
    assertIsTitleCase('h', false);
    assertIsTitleCase('i', false);
    assertIsTitleCase('j', false);
    assertIsTitleCase('k', false);
    assertIsTitleCase('l', false);
    assertIsTitleCase('m', false);
    assertIsTitleCase('n', false);
    assertIsTitleCase('o', false);
    assertIsTitleCase('p', false);
    assertIsTitleCase('q', false);
    assertIsTitleCase('r', false);
    assertIsTitleCase('s', false);
    assertIsTitleCase('t', false);
    assertIsTitleCase('u', false);
    assertIsTitleCase('v', false);
    assertIsTitleCase('w', false);
    assertIsTitleCase('x', false);
    assertIsTitleCase('y', false);
    assertIsTitleCase('z', false);
    assertIsTitleCase('{', false);
    assertIsTitleCase('|', false);
    assertIsTitleCase('}', false);
    assertIsTitleCase('~', false);
  }

  private static void assertIsTitleCase(String aCharacter, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isTitleCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isTitleCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testToUpperCase() {
    //test: global static String toUpperCase(String ch){
    assertToUpperCase('\t', '\t');
    assertToUpperCase('\n', '\n');
    assertToUpperCase('\f', '\f');
    assertToUpperCase('\r', '\r');
    assertToUpperCase(' ', ' ');
    assertToUpperCase('!', '!');
    assertToUpperCase('"', '"');
    assertToUpperCase('#', '#');
    assertToUpperCase('$', '$');
    assertToUpperCase('%', '%');
    assertToUpperCase('&', '&');
    assertToUpperCase('\'', '\'');
    assertToUpperCase('(', '(');
    assertToUpperCase(')', ')');
    assertToUpperCase('*', '*');
    assertToUpperCase('+', '+');
    assertToUpperCase(',', ',');
    assertToUpperCase('-', '-');
    assertToUpperCase('.', '.');
    assertToUpperCase('/', '/');
    assertToUpperCase('0', '0');
    assertToUpperCase('1', '1');
    assertToUpperCase('2', '2');
    assertToUpperCase('3', '3');
    assertToUpperCase('4', '4');
    assertToUpperCase('5', '5');
    assertToUpperCase('6', '6');
    assertToUpperCase('7', '7');
    assertToUpperCase('8', '8');
    assertToUpperCase('9', '9');
    assertToUpperCase(':', ':');
    assertToUpperCase(';', ';');
    assertToUpperCase('<', '<');
    assertToUpperCase('=', '=');
    assertToUpperCase('>', '>');
    assertToUpperCase('?', '?');
    assertToUpperCase('@', '@');
    assertToUpperCase('A', 'A');
    assertToUpperCase('B', 'B');
    assertToUpperCase('C', 'C');
    assertToUpperCase('D', 'D');
    assertToUpperCase('E', 'E');
    assertToUpperCase('F', 'F');
    assertToUpperCase('G', 'G');
    assertToUpperCase('H', 'H');
    assertToUpperCase('I', 'I');
    assertToUpperCase('J', 'J');
    assertToUpperCase('K', 'K');
    assertToUpperCase('L', 'L');
    assertToUpperCase('M', 'M');
    assertToUpperCase('N', 'N');
    assertToUpperCase('O', 'O');
    assertToUpperCase('P', 'P');
    assertToUpperCase('Q', 'Q');
    assertToUpperCase('R', 'R');
    assertToUpperCase('S', 'S');
    assertToUpperCase('T', 'T');
    assertToUpperCase('U', 'U');
    assertToUpperCase('V', 'V');
    assertToUpperCase('W', 'W');
    assertToUpperCase('X', 'X');
    assertToUpperCase('Y', 'Y');
    assertToUpperCase('Z', 'Z');
    assertToUpperCase('[', '[');
    assertToUpperCase('\\', '\\');
    assertToUpperCase(']', ']');
    assertToUpperCase('^', '^');
    assertToUpperCase('_', '_');
    assertToUpperCase('`', '`');
    assertToUpperCase('a', 'A');
    assertToUpperCase('b', 'B');
    assertToUpperCase('c', 'C');
    assertToUpperCase('d', 'D');
    assertToUpperCase('e', 'E');
    assertToUpperCase('f', 'F');
    assertToUpperCase('g', 'G');
    assertToUpperCase('h', 'H');
    assertToUpperCase('i', 'I');
    assertToUpperCase('j', 'J');
    assertToUpperCase('k', 'K');
    assertToUpperCase('l', 'L');
    assertToUpperCase('m', 'M');
    assertToUpperCase('n', 'N');
    assertToUpperCase('o', 'O');
    assertToUpperCase('p', 'P');
    assertToUpperCase('q', 'Q');
    assertToUpperCase('r', 'R');
    assertToUpperCase('s', 'S');
    assertToUpperCase('t', 'T');
    assertToUpperCase('u', 'U');
    assertToUpperCase('v', 'V');
    assertToUpperCase('w', 'W');
    assertToUpperCase('x', 'X');
    assertToUpperCase('y', 'Y');
    assertToUpperCase('z', 'Z');
    assertToUpperCase('{', '{');
    assertToUpperCase('|', '|');
    assertToUpperCase('}', '}');
    assertToUpperCase('~', '~');
  }

  private static void assertToUpperCase(String aCharacter, String expected) {
    String actual = CMN_UTIL_Character.toUpperCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.toUpperCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsLowerCase() {
    final String UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (Integer i = 0; i < UPPER.length(); i++) {
      assertIsLowerCase(UPPER.substring(i, i + 1), false);
    }
    final String LOWER = 'abcdefghijklmnopqrstuvwxyz';
    for (Integer i = 0; i < LOWER.length(); i++) {
      assertIsLowerCase(LOWER.substring(i, i + 1), true);
    }
  }

  private static void assertIsLowerCase(String aCharacter, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isLowerCase(aCharacter);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isLowerCase(\'' +
      aCharacter +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testToAscii() {
    //test: global static Integer toAscii(String character){
    assertToAscii('\t', 9);
    assertToAscii('\n', 10);
    assertToAscii('\f', 12);
    assertToAscii('\r', 13);
    for (Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++) {
      assertToAscii(CMN_UTIL_String.charAt(CHARS_ASCII_PRINTABLE, i), i + 32);
    }
  }

  private static void assertToAscii(String charactr, Integer expected) {
    Integer actual = CMN_UTIL_Character.toAscii(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.toAscii(' +
      charactr +
      ') returned \'' +
      actual +
      '\'; expected \'' +
      expected +
      '\''
    );
  }

  @IsTest
  private static void testToChar() {
    //test: global static String toChar(Integer ascii){
    assertToChar(-1, null);
    assertToChar(0, null);
    assertToChar(128, null);
    assertToChar(9, '\t');
    assertToChar(10, '\n');
    assertToChar(12, '\f');
    assertToChar(13, '\r');
    for (Integer i = 32; i < 128; i++) {
      assertToChar(i, CMN_UTIL_String.charAt(CHARS_ASCII_PRINTABLE, i - 32));
    }
  }

  private static void assertToChar(Integer ascii, String expected) {
    String actual = CMN_UTIL_Character.toChar(ascii);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.toChar(' +
      ascii +
      ') returned \'' +
      actual +
      '\'; expected \'' +
      expected +
      '\''
    );
  }

  @IsTest
  private static void testIsAscii() {
    //test: global static boolean isAscii(String character) {
    for (Integer i = 0; i < CHARS_ALL_ASCII.length(); i++) {
      assertIsAscii(CMN_UTIL_String.charAt(CHARS_ALL_ASCII, i), true);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAscii(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsAscii(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isAscii(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAscii(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiPrintable() {
    //test: global static boolean isAsciiPrintable(String character) {
    for (Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++) {
      assertIsAsciiPrintable(
        CMN_UTIL_String.charAt(CHARS_ASCII_PRINTABLE, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_NON_PRINTABLE.length(); i++) {
      assertIsAsciiPrintable(
        CMN_UTIL_String.charAt(CHARS_ASCII_NON_PRINTABLE, i),
        false
      );
    }
  }

  private static void assertIsAsciiPrintable(
    String charactr,
    Boolean expected
  ) {
    Boolean actual = CMN_UTIL_Character.isAsciiPrintable(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiPrintable(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiControl() {
    //test: global static boolean isAsciiControl(String character) {
    for (Integer i = 0; i < CHARS_ASCII_CONTROL.length(); i++) {
      asertIsAsciiControl(CMN_UTIL_String.charAt(CHARS_ASCII_CONTROL, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++) {
      asertIsAsciiControl(
        CMN_UTIL_String.charAt(CHARS_ASCII_PRINTABLE, i),
        false
      );
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      asertIsAsciiControl(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void asertIsAsciiControl(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isAsciiControl(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiControl(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiAlpha() {
    //test: global static boolean isAsciiAlpha(String character) {
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiAlpha(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiAlpha(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiAlpha(CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i), false);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiAlpha(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsAsciiAlpha(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isAsciiAlpha(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiAlpha(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiAlphaUpper() {
    //test: global static boolean isAsciiAlphaUpper(String character) {
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiAlphaUpper(
        CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiAlphaUpper(
        CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i),
        false
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiAlphaUpper(
        CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i),
        false
      );
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiAlphaUpper(
        CMN_UTIL_String.charAt(CHARS_NON_ASCII, i),
        false
      );
    }
  }

  private static void assertIsAsciiAlphaUpper(
    String charactr,
    Boolean expected
  ) {
    Boolean actual = CMN_UTIL_Character.isAsciiAlphaUpper(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiAlphaUpper(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiAlphaLower() {
    //test: global static boolean isAsciiAlphaLower(String character) {
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiAlphaLower(
        CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i),
        false
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiAlphaLower(
        CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiAlphaLower(
        CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i),
        false
      );
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiAlphaLower(
        CMN_UTIL_String.charAt(CHARS_NON_ASCII, i),
        false
      );
    }
  }

  private static void assertIsAsciiAlphaLower(
    String charactr,
    Boolean expected
  ) {
    Boolean actual = CMN_UTIL_Character.isAsciiAlphaLower(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiAlphaLower(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiNumeric() {
    //test: global static boolean isAsciiNumeric(String character) {
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiNumeric(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiNumeric(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiNumeric(CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i), true);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiNumeric(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsAsciiNumeric(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isAsciiNumeric(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiNumeric(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsAsciiAlphanumeric() {
    //test: global static boolean isAsciiAlphanumeric(String character) {
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiAlphanumeric(
        CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiAlphanumeric(
        CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiAlphanumeric(
        CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiAlphanumeric(
        CMN_UTIL_String.charAt(CHARS_NON_ASCII, i),
        false
      );
    }
  }

  private static void assertIsAsciiAlphanumeric(
    String charactr,
    Boolean expected
  ) {
    Boolean actual = CMN_UTIL_Character.isAsciiAlphanumeric(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isAsciiAlphanumeric(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsDigit() {
    //test: global static Boolean isDigit(String character){
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsAsciiDigit(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsAsciiDigit(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsAsciiDigit(CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i), true);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsAsciiDigit(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsAsciiDigit(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isDigit(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isDigit(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsLetter() {
    //test: global static Boolean isLetter(String character){
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsLetter(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsLetter(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsLetter(CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i), false);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsLetter(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsLetter(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isLetter(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isLetter(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsLetterOrDigit() {
    //test: global static Boolean isLetterOrDigit(String character){
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsLetterOrDigit(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsLetterOrDigit(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), true);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsLetterOrDigit(
        CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i),
        true
      );
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsLetterOrDigit(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
  }

  private static void assertIsLetterOrDigit(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isLetterOrDigit(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isLetterOrDigit(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testIsWhitespace() {
    //test: global static Boolean isWhitespace(String character){
    for (Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++) {
      assertIsWhitespace(CMN_UTIL_String.charAt(CHARS_ASCII_UPPER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++) {
      assertIsWhitespace(CMN_UTIL_String.charAt(CHARS_ASCII_LOWER, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++) {
      assertIsWhitespace(CMN_UTIL_String.charAt(CHARS_ASCII_DIGITS, i), false);
    }
    for (Integer i = 0; i < CHARS_NON_ASCII.length(); i++) {
      assertIsWhitespace(CMN_UTIL_String.charAt(CHARS_NON_ASCII, i), false);
    }
    for (Integer i = 0; i < CHARS_ASCII_CONTROL.length(); i++) {
      assertIsWhitespace(CMN_UTIL_String.charAt(CHARS_ASCII_CONTROL, i), true);
    }
  }

  private static void assertIsWhitespace(String charactr, Boolean expected) {
    Boolean actual = CMN_UTIL_Character.isWhitespace(charactr);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.isWhitespace(\'' +
      charactr +
      '\') returned ' +
      actual
    );
  }

  @IsTest
  private static void testGetType() {
    //test: global static Integer getType(String character){
    assertGetType('¿', CMN_UTIL_Character.UNASSIGNED);
    assertGetType(CMN_UTIL_Character.toChar(0), CMN_UTIL_Character.CONTROL);
    assertGetType(CMN_UTIL_Character.toChar(9), CMN_UTIL_Character.CONTROL);
    assertGetType(CMN_UTIL_Character.toChar(10), CMN_UTIL_Character.CONTROL);
    assertGetType(CMN_UTIL_Character.toChar(12), CMN_UTIL_Character.CONTROL);
    assertGetType(CMN_UTIL_Character.toChar(13), CMN_UTIL_Character.CONTROL);
    assertGetType(
      CMN_UTIL_Character.toChar(32),
      CMN_UTIL_Character.SPACE_SEPARATOR
    );
    assertGetType(
      CMN_UTIL_Character.toChar(33),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(34),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(35),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(36),
      CMN_UTIL_Character.CURRENCY_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(37),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(38),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(39),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(40),
      CMN_UTIL_Character.START_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(41),
      CMN_UTIL_Character.END_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(42),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(43),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(44),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(45),
      CMN_UTIL_Character.DASH_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(46),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(47),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(48),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(49),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(50),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(51),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(52),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(53),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(54),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(55),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(56),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(57),
      CMN_UTIL_Character.DECIMAL_DIGIT_NUMBER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(58),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(59),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(60),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(61),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(62),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(63),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(64),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(65),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(66),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(67),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(68),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(69),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(70),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(71),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(72),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(73),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(74),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(75),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(76),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(77),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(78),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(79),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(80),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(81),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(82),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(83),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(84),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(85),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(86),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(87),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(88),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(89),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(90),
      CMN_UTIL_Character.UPPERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(91),
      CMN_UTIL_Character.START_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(92),
      CMN_UTIL_Character.OTHER_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(93),
      CMN_UTIL_Character.END_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(94),
      CMN_UTIL_Character.MODIFIER_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(95),
      CMN_UTIL_Character.CONNECTOR_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(96),
      CMN_UTIL_Character.MODIFIER_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(97),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(98),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(99),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(100),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(101),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(102),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(103),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(104),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(105),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(106),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(107),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(108),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(109),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(110),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(111),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(112),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(113),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(114),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(115),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(116),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(117),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(118),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(119),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(120),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(121),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(122),
      CMN_UTIL_Character.LOWERCASE_LETTER
    );
    assertGetType(
      CMN_UTIL_Character.toChar(123),
      CMN_UTIL_Character.START_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(124),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(
      CMN_UTIL_Character.toChar(125),
      CMN_UTIL_Character.END_PUNCTUATION
    );
    assertGetType(
      CMN_UTIL_Character.toChar(126),
      CMN_UTIL_Character.MATH_SYMBOL
    );
    assertGetType(CMN_UTIL_Character.toChar(127), CMN_UTIL_Character.CONTROL);
  }

  private static void assertGetType(String character, Integer expected) {
    Integer actual = CMN_UTIL_Character.getType(character);
    System.assert(
      actual == expected,
      'CMN_UTIL_Character.getType(\'' +
      character +
      '\') returned ' +
      actual +
      ', expected ' +
      expected
    );
  }
}