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
 * This utility class tests the CMN_UTIL_Word functions
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see CMN_UTIL_Word
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_Word_TEST {
  @IsTest
  private static void testWrapStringInt() {
    System.System.assertEquals(null, CMN_UTIL_Word.wrap(null, 20));
    System.System.assertEquals(null, CMN_UTIL_Word.wrap(null, -1));

    System.System.assertEquals('', CMN_UTIL_Word.wrap('', 20));
    System.System.assertEquals('', CMN_UTIL_Word.wrap('', -1));

    // normal
    final String systemNewLine = CMN_UTIL_Word.LINE_SEPARATOR;
    String input = 'Here is one line of text that is going to be wrapped after 20 columns.';

    String expected =
      'Here is one line of' +
      systemNewLine +
      'text that is going' +
      systemNewLine +
      'to be wrapped after' +
      systemNewLine +
      '20 columns.';

    System.System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20));

    // long word at end
    input = 'Click here to jump to the jakarta website - http://jakarta.apache.org';
    expected =
      'Click here to jump' +
      systemNewLine +
      'to the jakarta' +
      systemNewLine +
      'website -' +
      systemNewLine +
      'http://jakarta.apache.org';
    System.System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20));

    // long word in middle
    input = 'Click here, http://jakarta.apache.org, to jump to the jakarta website';
    expected =
      'Click here,' +
      systemNewLine +
      'http://jakarta.apache.org,' +
      systemNewLine +
      'to jump to the' +
      systemNewLine +
      'jakarta website';

    System.System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20));
  }

  @IsTest
  private static void testWrap_StringIntStringBoolean() {
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, 20, '\n', false));
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, 20, '\n', true));
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, 20, null, true));
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, 20, null, false));
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, -1, null, true));
    System.assertEquals(null, CMN_UTIL_Word.wrap(null, -1, null, false));

    System.assertEquals('', CMN_UTIL_Word.wrap('', 20, '\n', false));
    System.assertEquals('', CMN_UTIL_Word.wrap('', 20, '\n', true));
    System.assertEquals('', CMN_UTIL_Word.wrap('', 20, null, false));
    System.assertEquals('', CMN_UTIL_Word.wrap('', 20, null, true));
    System.assertEquals('', CMN_UTIL_Word.wrap('', -1, null, false));
    System.assertEquals('', CMN_UTIL_Word.wrap('', -1, null, true));

    // normal
    String input = 'Here is one line of text that is going to be wrapped after 20 columns.';
    String expected = 'Here is one line of\ntext that is going\nto be wrapped after\n20 columns.';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));

    // unusual newline String
    input = 'Here is one line of text that is going to be wrapped after 20 columns.';
    expected = 'Here is one line of<br />text that is going<br />to be wrapped after<br />20 columns.';
    System.assertEquals(
      expected,
      CMN_UTIL_Word.wrap(input, 20, '<br />', false)
    );
    System.assertEquals(
      expected,
      CMN_UTIL_Word.wrap(input, 20, '<br />', true)
    );

    // short line length
    input = 'Here is one line';
    expected = 'Here\nis one\nline';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 6, '\n', false));
    expected = 'Here\nis\none\nline';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 2, '\n', false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, -1, '\n', false));

    // system newline String
    String systemNewLine = '\n';
    input = 'Here is one line of text that is going to be wrapped after 20 columns.';
    expected =
      'Here is one line of' +
      systemNewLine +
      'text that is going' +
      systemNewLine +
      'to be wrapped after' +
      systemNewLine +
      '20 columns.';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, null, false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, null, true));

    // with extra spaces
    input = ' Here:  is  one  line  of  text  that  is  going  to  be  wrapped  after  20  columns.';
    expected = 'Here:  is  one  line\nof  text  that  is \ngoing  to  be \nwrapped  after  20 \ncolumns.';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));

    // with tab
    input = 'Here is\tone line of text that is going to be wrapped after 20 columns.';
    expected = 'Here is\tone line of\ntext that is going\nto be wrapped after\n20 columns.';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));

    // with tab at wrapColumn
    input = 'Here is one line of\ttext that is going to be wrapped after 20 columns.';
    expected = 'Here is one line\nof\ttext that is\ngoing to be wrapped\nafter 20 columns.';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));

    // difference because of long word
    input = 'Click here to jump to the jakarta website - http://jakarta.apache.org';
    expected = 'Click here to jump\nto the jakarta\nwebsite -\nhttp://jakarta.apache.org';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    expected = 'Click here to jump\nto the jakarta\nwebsite -\nhttp://jakarta.apach\ne.org';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));

    // difference because of long word in middle
    input = 'Click here, http://jakarta.apache.org, to jump to the jakarta website';
    expected = 'Click here,\nhttp://jakarta.apache.org,\nto jump to the\njakarta website';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', false));
    expected = 'Click here,\nhttp://jakarta.apach\ne.org, to jump to\nthe jakarta website';
    System.assertEquals(expected, CMN_UTIL_Word.wrap(input, 20, '\n', true));
  }

  @IsTest
  private static void testCapitalizeString() {
    System.assertEquals(null, CMN_UTIL_Word.capitalize(null));
    System.assertEquals('', CMN_UTIL_Word.capitalize(''));
    System.assertEquals('  ', CMN_UTIL_Word.capitalize('  '));

    System.assertEquals('I', CMN_UTIL_Word.capitalize('I'));
    System.assertEquals('I', CMN_UTIL_Word.capitalize('i'));
    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalize('i am here 123')
    );
    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalize('I Am Here 123')
    );
    System.assertEquals(
      'I Am HERE 123',
      CMN_UTIL_Word.capitalize('i am HERE 123')
    );
    System.assertEquals(
      'I AM HERE 123',
      CMN_UTIL_Word.capitalize('I AM HERE 123')
    );
  }

  @IsTest
  private static void testCapitalizeWithDelimitersString() {
    System.assertEquals(null, CMN_UTIL_Word.capitalize(null, null));
    System.assertEquals('', CMN_UTIL_Word.capitalize('', new List<String>(0)));
    System.assertEquals(
      '  ',
      CMN_UTIL_Word.capitalize('  ', new List<String>(0))
    );

    String[] chars = new List<String>{ '-', '+', ' ', '@' };
    System.assertEquals('I', '' + CMN_UTIL_Word.capitalize('I', chars));
    System.assertEquals('I', CMN_UTIL_Word.capitalize('i', chars));
    System.assertEquals(
      'I-Am Here+123',
      CMN_UTIL_Word.capitalize('i-am here+123', chars)
    );
    System.assertEquals(
      'I Am+Here-123',
      CMN_UTIL_Word.capitalize('I Am+Here-123', chars)
    );
    System.assertEquals(
      'I+Am-HERE 123',
      CMN_UTIL_Word.capitalize('i+am-HERE 123', chars)
    );
    System.assertEquals(
      'I-AM HERE+123',
      CMN_UTIL_Word.capitalize('I-AM HERE+123', chars)
    );

    chars = new List<String>{ '.' };
    System.assertEquals(
      'I aM.Fine',
      CMN_UTIL_Word.capitalize('i aM.fine', chars)
    );
    System.assertEquals(
      'I Am.fine',
      CMN_UTIL_Word.capitalize('i am.fine', null)
    );
  }

  @IsTest
  private static void testCapitalizeFullyString() {
    System.assertEquals(null, CMN_UTIL_Word.capitalizeFully(null));
    System.assertEquals('', CMN_UTIL_Word.capitalizeFully(''));
    System.assertEquals('  ', CMN_UTIL_Word.capitalizeFully('  '));

    System.assertEquals('I', CMN_UTIL_Word.capitalizeFully('I'));
    System.assertEquals('I', CMN_UTIL_Word.capitalizeFully('i'));

    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalizeFully('i am here 123')
    );
    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalizeFully('I Am Here 123')
    );
    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalizeFully('i am HERE 123')
    );
    System.assertEquals(
      'I Am Here 123',
      CMN_UTIL_Word.capitalizeFully('I AM HERE 123')
    );
  }

  @IsTest
  private static void testCapitalizeFullyWithDelimitersString() {
    System.assertEquals(null, CMN_UTIL_Word.capitalizeFully(null, null));
    System.assertEquals(
      '',
      CMN_UTIL_Word.capitalizeFully('', new List<String>(0))
    );
    System.assertEquals(
      '  ',
      CMN_UTIL_Word.capitalizeFully('  ', new List<String>(0))
    );

    String[] chars = new List<String>{ '-', '+', ' ', '@' };
    System.assertEquals('I', CMN_UTIL_Word.capitalizeFully('I', chars));
    System.assertEquals('I', CMN_UTIL_Word.capitalizeFully('i', chars));
    System.assertEquals(
      'I-Am Here+123',
      CMN_UTIL_Word.capitalizeFully('i-am here+123', chars)
    );
    System.assertEquals(
      'I Am+Here-123',
      CMN_UTIL_Word.capitalizeFully('I Am+Here-123', chars)
    );
    System.assertEquals(
      'I+Am-Here 123',
      CMN_UTIL_Word.capitalizeFully('i+am-HERE 123', chars)
    );
    System.assertEquals(
      'I-Am Here+123',
      CMN_UTIL_Word.capitalizeFully('I-AM HERE+123', chars)
    );

    chars = new List<String>{ '.' };
    System.assertEquals(
      'I am.Fine',
      CMN_UTIL_Word.capitalizeFully('i aM.fine', chars)
    );
    System.assertEquals(
      'I Am.fine',
      CMN_UTIL_Word.capitalizeFully('i am.fine', null)
    );
  }

  @IsTest
  private static void testUncapitalizeString() {
    System.assertEquals(null, CMN_UTIL_Word.uncapitalize(null));
    System.assertEquals('', CMN_UTIL_Word.uncapitalize(''));
    System.assertEquals('  ', CMN_UTIL_Word.uncapitalize('  '));

    System.assertEquals('i', CMN_UTIL_Word.uncapitalize('I'));
    System.assertEquals('i', CMN_UTIL_Word.uncapitalize('i'));

    System.assertEquals(
      'i am here 123',
      CMN_UTIL_Word.uncapitalize('i am here 123')
    );
    System.assertEquals(
      'i am here 123',
      CMN_UTIL_Word.uncapitalize('I Am Here 123')
    );
    System.assertEquals(
      'i am hERE 123',
      CMN_UTIL_Word.uncapitalize('i am HERE 123')
    );
    System.assertEquals(
      'i aM hERE 123',
      CMN_UTIL_Word.uncapitalize('I AM HERE 123')
    );
  }

  @IsTest
  private static void testUncapitalizeWithDelimitersString() {
    System.assertEquals(null, CMN_UTIL_Word.uncapitalize(null, null));
    System.assertEquals(
      '',
      CMN_UTIL_Word.uncapitalize('', new List<String>(0))
    );
    System.assertEquals(
      '  ',
      CMN_UTIL_Word.uncapitalize('  ', new List<String>(0))
    );

    String[] chars = new List<String>{ '-', '+', ' ', '@' };
    System.assertEquals('i', CMN_UTIL_Word.uncapitalize('I', chars));
    System.assertEquals('i', CMN_UTIL_Word.uncapitalize('i', chars));
    System.assertEquals(
      'i am-here+123',
      CMN_UTIL_Word.uncapitalize('i am-here+123', chars)
    );
    System.assertEquals(
      'i+am here-123',
      CMN_UTIL_Word.uncapitalize('I+Am Here-123', chars)
    );
    System.assertEquals(
      'i-am+hERE 123',
      CMN_UTIL_Word.uncapitalize('i-am+HERE 123', chars)
    );
    System.assertEquals(
      'i aM-hERE+123',
      CMN_UTIL_Word.uncapitalize('I AM-HERE+123', chars)
    );

    chars = new List<String>{ '.' };
    System.assertEquals(
      'i AM.fINE',
      CMN_UTIL_Word.uncapitalize('I AM.FINE', chars)
    );
    System.assertEquals(
      'i aM.FINE',
      CMN_UTIL_Word.uncapitalize('I AM.FINE', null)
    );
  }

  @IsTest
  private static void testInitialsString() {
    System.assertEquals(null, CMN_UTIL_Word.initials(null));
    System.assertEquals('', CMN_UTIL_Word.initials(''));
    System.assertEquals('', CMN_UTIL_Word.initials('  '));

    System.assertEquals('I', CMN_UTIL_Word.initials('I'));
    System.assertEquals('i', CMN_UTIL_Word.initials('i'));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben John Lee'));
    System.assertEquals('BJ', CMN_UTIL_Word.initials('Ben J.Lee'));
    System.assertEquals('BJ.L', CMN_UTIL_Word.initials(' Ben   John  . Lee'));
    System.assertEquals('iah1', CMN_UTIL_Word.initials('i am here 123'));
  }

  @IsTest
  private static void testInitialsStringCharArray() {
    String[] anArray = null;
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('I', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('i', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('S', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('BJ', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      'BJ.L',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals('KO', CMN_UTIL_Word.initials('Kay O\'Murphy', anArray));
    System.assertEquals(
      'iah1',
      CMN_UTIL_Word.initials('i am here 123', anArray)
    );

    anArray = new List<String>(0);
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      '',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals('', CMN_UTIL_Word.initials('Kay O\'Murphy', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('i am here 123', anArray));

    anArray = CMN_UTIL_String.toCharArray(' ');
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('I', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('i', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('S', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('BJ', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      'BJ.L',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals('KO', CMN_UTIL_Word.initials('Kay O\'Murphy', anArray));
    System.assertEquals(
      'iah1',
      CMN_UTIL_Word.initials('i am here 123', anArray)
    );

    anArray = CMN_UTIL_String.toCharArray(' .');
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('I', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('i', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('S', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      'BJL',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals('KO', CMN_UTIL_Word.initials('Kay O\'Murphy', anArray));
    System.assertEquals(
      'iah1',
      CMN_UTIL_Word.initials('i am here 123', anArray)
    );

    anArray = CMN_UTIL_String.toCharArray(' .\'');
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('I', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('i', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('S', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('BJL', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      'BJL',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals(
      'KOM',
      CMN_UTIL_Word.initials('Kay O\'Murphy', anArray)
    );
    System.assertEquals(
      'iah1',
      CMN_UTIL_Word.initials('i am here 123', anArray)
    );

    anArray = CMN_UTIL_String.toCharArray('SIJo1');
    System.assertEquals(null, CMN_UTIL_Word.initials(null, anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('', anArray));
    System.assertEquals(' ', CMN_UTIL_Word.initials('  ', anArray));
    System.assertEquals('', CMN_UTIL_Word.initials('I', anArray));
    System.assertEquals('i', CMN_UTIL_Word.initials('i', anArray));
    System.assertEquals('C', CMN_UTIL_Word.initials('SJC', anArray));
    System.assertEquals('Bh', CMN_UTIL_Word.initials('Ben John Lee', anArray));
    System.assertEquals('B.', CMN_UTIL_Word.initials('Ben J.Lee', anArray));
    System.assertEquals(
      ' h',
      CMN_UTIL_Word.initials(' Ben   John  . Lee', anArray)
    );
    System.assertEquals('K', CMN_UTIL_Word.initials('Kay O\'Murphy', anArray));
    System.assertEquals('i2', CMN_UTIL_Word.initials('i am here 123', anArray));
  }

  @IsTest
  private static void testSwapCaseString() {
    System.assertEquals(null, CMN_UTIL_Word.swapCase(null));
    System.assertEquals('', CMN_UTIL_Word.swapCase(''));
    System.assertEquals('  ', CMN_UTIL_Word.swapCase('  '));

    System.assertEquals('i', CMN_UTIL_Word.swapCase('I'));
    System.assertEquals('I', CMN_UTIL_Word.swapCase('i'));
    System.assertEquals(
      'I AM HERE 123',
      CMN_UTIL_Word.swapCase('i am here 123')
    );
    System.assertEquals(
      'i aM hERE 123',
      CMN_UTIL_Word.swapCase('I Am Here 123')
    );
    System.assertEquals(
      'I AM here 123',
      CMN_UTIL_Word.swapCase('i am HERE 123')
    );
    System.assertEquals(
      'i am here 123',
      CMN_UTIL_Word.swapCase('I AM HERE 123')
    );

    String test = 'This String contains a TitleCase character: ';
    String expect = 'tHIS sTRING CONTAINS A tITLEcASE CHARACTER: ';
    System.assertEquals(expect, CMN_UTIL_Word.swapCase(test));
  }

  @IsTest
  private static void testAbbreviate() {
    // check null and empty are returned respectively
    System.assertEquals(null, CMN_UTIL_Word.abbreviate(null, 1, -1, ''));
    System.assertEquals(
      CMN_UTIL_String.EMPTY,
      CMN_UTIL_Word.abbreviate('', 1, -1, '')
    );

    // test upper limit
    System.assertEquals(
      '01234',
      CMN_UTIL_Word.abbreviate('0123456789', 0, 5, '')
    );
    System.assertEquals(
      '01234',
      CMN_UTIL_Word.abbreviate('0123456789', 5, 2, '')
    );
    System.assertEquals(
      '012',
      CMN_UTIL_Word.abbreviate('012 3456789', 2, 5, '')
    );
    System.assertEquals(
      '012 3',
      CMN_UTIL_Word.abbreviate('012 3456789', 5, 2, '')
    );
    System.assertEquals(
      '0123456789',
      CMN_UTIL_Word.abbreviate('0123456789', 0, -1, '')
    );

    // test upper limit + append string
    System.assertEquals(
      '01234-',
      CMN_UTIL_Word.abbreviate('0123456789', 0, 5, '-')
    );
    System.assertEquals(
      '01234-',
      CMN_UTIL_Word.abbreviate('0123456789', 5, 2, '-')
    );
    System.assertEquals(
      '012',
      CMN_UTIL_Word.abbreviate('012 3456789', 2, 5, null)
    );
    System.assertEquals(
      '012 3',
      CMN_UTIL_Word.abbreviate('012 3456789', 5, 2, '')
    );
    System.assertEquals(
      '0123456789',
      CMN_UTIL_Word.abbreviate('0123456789', 0, -1, '')
    );

    // test lower value
    System.assertEquals(
      '012',
      CMN_UTIL_Word.abbreviate('012 3456789', 0, 5, null)
    );
    System.assertEquals(
      '01234',
      CMN_UTIL_Word.abbreviate('01234 56789', 5, 10, null)
    );
    System.assertEquals(
      '01 23 45 67',
      CMN_UTIL_Word.abbreviate('01 23 45 67 89', 9, -1, null)
    );
    System.assertEquals(
      '01 23 45 6',
      CMN_UTIL_Word.abbreviate('01 23 45 67 89', 9, 10, null)
    );

    // test lower value + append
    System.assertEquals(
      '012',
      CMN_UTIL_Word.abbreviate('012 3456789', 0, 5, null)
    );
    System.assertEquals(
      '01234-',
      CMN_UTIL_Word.abbreviate('01234 56789', 5, 10, '-')
    );
    System.assertEquals(
      '01 23 45 67abc',
      CMN_UTIL_Word.abbreviate('01 23 45 67 89', 9, -1, 'abc')
    );
    System.assertEquals(
      '01 23 45 6',
      CMN_UTIL_Word.abbreviate('01 23 45 67 89', 9, 10, '')
    );

    // others
    System.assertEquals('', CMN_UTIL_Word.abbreviate('0123456790', 0, 0, ''));
    System.assertEquals('', CMN_UTIL_Word.abbreviate(' 0123456790', 0, -1, ''));
  }
}