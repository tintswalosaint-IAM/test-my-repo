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
 * This class provides utility methods which manipulate words and word strings
 * The functions include methods to neatly wrap words, including primitive data types,
 * Normalising word strings by capitalizing word text, un-capitalizing, swapping case, delimiting
 * initialling and abbreviating words. This is useful when trying to standardise displayed
 * test in a user friendly readable manner.
 * <p/>
 * <p>Operations on Strings that contain words.</p>
 * <p/>
 * <p>This class tries to handle <code>null</code> input gracefully.
 * An exception will not be thrown for a <code>null</code> input.
 * Each method documents its behaviour in more detail.</p>
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see CMN_UTIL_Word_TEST for usage examples
 */
global class CMN_UTIL_Word {
  global static final String LINE_SEPARATOR = '\n';

  /**
   * @description <p>Wraps a single line of text, identifying words by <code>' '</code>.</p>
   * <p/>
   * <p>New lines will be separated by the system property line separator.
   * Very long words, such as URLs will <i>not</i> be wrapped.</p>
   * <p/>
   * <p>Leading spaces on a new line are stripped.
   * Trailing spaces are not stripped.</p>
   * <p/>
   * <table border="1">
   *  <caption>Examples</caption>
   *  <tr>
   *   <th>input</th>
   *   <th>wrapLength</th>
   *   <th>result</th>
   *  </tr>
   *  <tr>
   *   <td>null</td>
   *   <td>*</td>
   *   <td>null</td>
   *  </tr>
   *  <tr>
   *   <td>""</td>
   *   <td>*</td>
   *   <td>""</td>
   *  </tr>
   *  <tr>
   *   <td>"Here is one line of text that is going to be wrapped after 20 columns."</td>
   *   <td>20</td>
   *   <td>"Here is one line of\ntext that is going\nto be wrapped after\n20 columns."</td>
   *  </tr>
   *  <tr>
   *   <td>"Click here to jump to the commons website - http://commons.apache.org"</td>
   *   <td>20</td>
   *   <td>"Click here to jump\nto the commons\nwebsite -\nhttp://commons.apache.org"</td>
   *  </tr>
   *  <tr>
   *   <td>"Click here, http://commons.apache.org, to jump to the commons website"</td>
   *   <td>20</td>
   *   <td>"Click here,\nhttp://commons.apache.org,\nto jump to the\ncommons website"</td>
   *  </tr>
   * </table>
   * <p/>
   * (assuming that '\n' is the systems line separator)
   *
   * @param str the String to be word wrapped, may be null
   * @param wrapLength the column to wrap the words at, less than 1 is treated as 1
   *
   * @return a line with newlines inserted, <code>null</code> if null input
   */
  global static String wrap(String str, Integer wrapLength) {
    return wrap(str, wrapLength, null, false);
  }

  /**
   * @description <p>Wraps a single line of text, identifying words by <code>' '</code>.</p>
   * <p/>
   * <p>Leading spaces on a new line are stripped.
   * Trailing spaces are not stripped.</p>
   * <p/>
   * <table border="1">
   *  <caption>Examples</caption>
   *  <tr>
   *   <th>input</th>
   *   <th>wrapLength</th>
   *   <th>newLineString</th>
   *   <th>wrapLongWords</th>
   *   <th>result</th>
   *  </tr>
   *  <tr>
   *   <td>null</td>
   *   <td>*</td>
   *   <td>*</td>
   *   <td>true/false</td>
   *   <td>null</td>
   *  </tr>
   *  <tr>
   *   <td>""</td>
   *   <td>*</td>
   *   <td>*</td>
   *   <td>true/false</td>
   *   <td>""</td>
   *  </tr>
   *  <tr>
   *   <td>"Here is one line of text that is going to be wrapped after 20 columns."</td>
   *   <td>20</td>
   *   <td>"\n"</td>
   *   <td>true/false</td>
   *   <td>"Here is one line of\ntext that is going\nto be wrapped after\n20 columns."</td>
   *  </tr>
   *  <tr>
   *   <td>"Here is one line of text that is going to be wrapped after 20 columns."</td>
   *   <td>20</td>
   *   <td>"&lt;br /&gt;"</td>
   *   <td>true/false</td>
   *   <td>"Here is one line of&lt;br /&gt;text that is going&lt;br /&gt;to be wrapped after&lt;br /&gt;20 columns."</td>
   *  </tr>
   *  <tr>
   *   <td>"Here is one line of text that is going to be wrapped after 20 columns."</td>
   *   <td>20</td>
   *   <td>null</td>
   *   <td>true/false</td>
   *   <td>"Here is one line of" + systemNewLine + "text that is going" + systemNewLine + "to be wrapped after" + systemNewLine + "20 columns."</td>
   *  </tr>
   *  <tr>
   *   <td>"Click here to jump to the commons website - http://commons.apache.org"</td>
   *   <td>20</td>
   *   <td>"\n"</td>
   *   <td>false</td>
   *   <td>"Click here to jump\nto the commons\nwebsite -\nhttp://commons.apache.org"</td>
   *  </tr>
   *  <tr>
   *   <td>"Click here to jump to the commons website - http://commons.apache.org"</td>
   *   <td>20</td>
   *   <td>"\n"</td>
   *   <td>true</td>
   *   <td>"Click here to jump\nto the commons\nwebsite -\nhttp://commons.apach\ne.org"</td>
   *  </tr>
   * </table>
   *
   * @param str the String to be word wrapped, may be null
   * @param wrapLength the column to wrap the words at, less than 1 is treated as 1
   * @param newLineStr the string to insert for a new line,
   *  <code>null</code> uses the system property line separator
   * @param wrapLongWords true if long words (such as URLs) should be wrapped
   *
   * @return a line with newlines inserted, <code>null</code> if null input
   */
  global static String wrap(
    String str,
    Integer wrapLength,
    String newLineStr,
    Boolean wrapLongWords
  ) {
    if (str == null) {
      return null;
    }
    if (newLineStr == null) {
      newLineStr = LINE_SEPARATOR;
    }
    if (wrapLength < 1) {
      wrapLength = 1;
    }
    Integer inputLineLength = str.length();
    Integer offset = 0;
    String wrappedLine = '';

    while ((inputLineLength - offset) > wrapLength) {
      if (' '.equals(CMN_UTIL_String.charAt(str, offset))) {
        offset++;
        continue;
      }
      Integer spaceToWrapAt = CMN_UTIL_String.lastIndexOf(
        str,
        ' ',
        wrapLength + offset
      );

      if (spaceToWrapAt >= offset) {
        // normal case
        wrappedLine += str.substring(offset, spaceToWrapAt);
        wrappedLine += newLineStr;
        offset = spaceToWrapAt + 1;
      } else {
        // really long word or URL
        if (wrapLongWords) {
          // wrap really long word one line at a time
          wrappedLine += str.substring(offset, wrapLength + offset);
          wrappedLine += newLineStr;
          offset += wrapLength;
        } else {
          // do not wrap really long word, just extend beyond limit
          spaceToWrapAt = str.indexOf(' ', wrapLength + offset);
          if (spaceToWrapAt >= 0) {
            wrappedLine += str.substring(offset, spaceToWrapAt);
            wrappedLine += newLineStr;
            offset = spaceToWrapAt + 1;
          } else {
            wrappedLine += str.substring(offset);
            offset = inputLineLength;
          }
        }
      }
    }

    // Whatever is left in line is short enough to just pass through
    wrappedLine += (str != null &&
      str.length() > offset
      ? str.substring(offset)
      : '');

    return wrappedLine;
  }

  /**
   * @description <p>Capitalizes all the whitespace separated words in a String.
   * Only the first character of each word is changed. To convert the
   * rest of each word to lowercase at the same time,
   * use {@link #capitalizeFully(String)}.</p>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.
   * Capitalization uses the Unicode title case, normally equivalent to
   * upper case.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.capitalize(null)        = null
   * CMN_UTIL_Word.capitalize("")          = ""
   * CMN_UTIL_Word.capitalize("i am FINE") = "I Am FINE"
   * </pre>
   *
   * @param str the String to capitalize, may be null
   *
   * @return capitalized String, <code>null</code> if null String input
   */
  global static String capitalize(String str) {
    return capitalize(str, null);
  }

  /**
   * @description <p>Capitalizes all the delimiter separated words in a String.
   * Only the first character of each word is changed. To convert the
   * rest of each word to lowercase at the same time,
   * use {@link #capitalizeFully(String, char[])}.</p>
   * <p/>
   * <p>The delimiters represent a set of characters understood to separate words.
   * The first string character and the first non-delimiter character after a
   * delimiter will be capitalized. </p>
   * <p/>
   * <p>A <code>null</code> input String returns <code>null</code>.
   * Capitalization uses the Unicode title case, normally equivalent to
   * upper case.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.capitalize(null, *)            = null
   * CMN_UTIL_Word.capitalize("", *)              = ""
   * CMN_UTIL_Word.capitalize(*, new char[0])     = *
   * CMN_UTIL_Word.capitalize("i am fine", null)  = "I Am Fine"
   * CMN_UTIL_Word.capitalize("i aM.fine", {'.'}) = "I aM.Fine"
   * </pre>
   *
   * @param str the String to capitalize, may be null
   * @param delimiters set of characters to determine capitalization, null means whitespace
   *
   * @return capitalized String, <code>null</code> if null String input
   * @since 2.1
   */
  global static String capitalize(String str, String[] delimiters) {
    Integer delimitLen = (delimiters == null ? -1 : delimiters.size());
    if (str == null || str.length() == 0 || delimitLen == 0) {
      return str;
    }
    Integer strLen = str.length();
    String buffer = '';
    Boolean capitalizeNext = true;
    for (Integer i = 0; i < strLen; i++) {
      String ch = CMN_UTIL_String.charAt(str, i);

      if (isDelimiter(ch, delimiters)) {
        buffer += ch;
        capitalizeNext = true;
      } else if (capitalizeNext) {
        buffer += CMN_UTIL_Character.toTitleCase(ch);
        capitalizeNext = false;
      } else {
        buffer += ch;
      }
    }
    return buffer;
  }

  /**
   * @description <p>Converts all the whitespace separated words in a String into capitalized words,
   * that is each word is made up of a titlecase character and then a series of
   * lowercase characters.  </p>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.
   * Capitalization uses the Unicode title case, normally equivalent to
   * upper case.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.capitalizeFully(null)        = null
   * CMN_UTIL_Word.capitalizeFully("")          = ""
   * CMN_UTIL_Word.capitalizeFully("i am FINE") = "I Am Fine"
   * </pre>
   *
   * @param str the String to capitalize, may be null
   *
   * @return capitalized String, <code>null</code> if null String input
   */
  global static String capitalizeFully(String str) {
    return capitalizeFully(str, null);
  }

  /**
   * @description <p>Converts all the delimiter separated words in a String into capitalized words,
   * that is each word is made up of a titlecase character and then a series of
   * lowercase characters. </p>
   * <p/>
   * <p>The delimiters represent a set of characters understood to separate words.
   * The first string character and the first non-delimiter character after a
   * delimiter will be capitalized. </p>
   * <p/>
   * <p>A <code>null</code> input String returns <code>null</code>.
   * Capitalization uses the Unicode title case, normally equivalent to
   * upper case.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.capitalizeFully(null, *)            = null
   * CMN_UTIL_Word.capitalizeFully("", *)              = ""
   * CMN_UTIL_Word.capitalizeFully(*, null)            = *
   * CMN_UTIL_Word.capitalizeFully(*, new char[0])     = *
   * CMN_UTIL_Word.capitalizeFully("i aM.fine", {'.'}) = "I am.Fine"
   * </pre>
   *
   * @param str the String to capitalize, may be null
   * @param delimiters set of characters to determine capitalization, null means whitespace
   *
   * @return capitalized String, <code>null</code> if null String input
   * @since 2.1
   */
  global static String capitalizeFully(String str, String[] delimiters) {
    Integer delimLen = (delimiters == null ? -1 : delimiters.size());
    if (str == null || str.length() == 0 || delimLen == 0) {
      return str;
    }
    str = str.toLowerCase();
    return capitalize(str, delimiters);
  }

  /**
   * @description <p>Uncapitalizes all the whitespace separated words in a String.
   * Only the first character of each word is changed.</p>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.uncapitalize(null)        = null
   * CMN_UTIL_Word.uncapitalize("")          = ""
   * CMN_UTIL_Word.uncapitalize("I Am FINE") = "i am fINE"
   * </pre>
   *
   * @param str the String to uncapitalize, may be null
   *
   * @return uncapitalized String, <code>null</code> if null String input
   */
  global static String uncapitalize(String str) {
    return uncapitalize(str, null);
  }

  /**
   * @description <p>Uncapitalizes all the whitespace separated words in a String.
   * Only the first character of each word is changed.</p>
   * <p/>
   * <p>The delimiters represent a set of characters understood to separate words.
   * The first string character and the first non-delimiter character after a
   * delimiter will be uncapitalized. </p>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.uncapitalize(null, *)            = null
   * CMN_UTIL_Word.uncapitalize("", *)              = ""
   * CMN_UTIL_Word.uncapitalize(*, null)            = *
   * CMN_UTIL_Word.uncapitalize(*, new char[0])     = *
   * CMN_UTIL_Word.uncapitalize("I AM.FINE", {'.'}) = "i AM.fINE"
   * </pre>
   *
   * @param str the String to uncapitalize, may be null
   * @param delimiters set of characters to determine uncapitalization, null means whitespace
   *
   * @return uncapitalized String, <code>null</code> if null String input
   * @since 2.1
   */
  global static String uncapitalize(String str, String[] delimiters) {
    Integer delimLen = (delimiters == null ? -1 : delimiters.size());
    if (str == null || str.length() == 0 || delimLen == 0) {
      return str;
    }
    Integer strLen = str.length();
    String buffer = '';
    Boolean uncapitalizeNext = true;
    for (Integer i = 0; i < strLen; i++) {
      String ch = CMN_UTIL_String.charAt(str, i);

      if (isDelimiter(ch, delimiters)) {
        buffer += ch;
        uncapitalizeNext = true;
      } else if (uncapitalizeNext) {
        buffer += CMN_UTIL_Character.toLowerCase(ch);
        uncapitalizeNext = false;
      } else {
        buffer += ch;
      }
    }
    return buffer;
  }

  /**
   * @description <p>Swaps the case of a String using a word based algorithm.</p>
   * <p/>
   * <ul>
   *  <li>Upper case character converts to Lower case</li>
   *  <li>Title case character converts to Lower case</li>
   *  <li>Lower case character after Whitespace or at start converts to Title case</li>
   *  <li>Other Lower case character converts to Upper case</li>
   * </ul>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.</p>
   * <p/>
   * <pre>
   * StringUtils.swapCase(null)                 = null
   * StringUtils.swapCase("")                   = ""
   * StringUtils.swapCase("The dog has a BONE") = "tHE DOG HAS A bone"
   * </pre>
   *
   * @param str the String to swap case, may be null
   *
   * @return the changed String, <code>null</code> if null String input
   */
  global static String swapCase(String str) {
    Integer strLen;
    if (str == null || (strLen = str.length()) == 0) {
      return str;
    }
    String buffer = '';

    Boolean whitespace = true;
    String ch = null;
    String tmp = null;

    for (Integer i = 0; i < strLen; i++) {
      ch = CMN_UTIL_String.charAt(str, i);
      if (CMN_UTIL_Character.isUpperCase(ch)) {
        tmp = CMN_UTIL_Character.toLowerCase(ch);
      } else if (CMN_UTIL_Character.isLowerCase(ch)) {
        if (whitespace) {
          tmp = CMN_UTIL_Character.toTitleCase(ch);
        } else {
          tmp = CMN_UTIL_Character.toUpperCase(ch);
        }
      } else {
        tmp = ch;
      }
      buffer += tmp;
      whitespace = CMN_UTIL_Character.isWhitespace(ch);
    }
    return buffer;
  }

  /**
   * @description <p>Extracts the initial characters from each word in the String.</p>
   * <p/>
   * <p>All first characters after whitespace are returned as a new string.
   * Their case is not changed.</p>
   * <p/>
   * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.initials(null)             = null
   * CMN_UTIL_Word.initials("")               = ""
   * CMN_UTIL_Word.initials("Ben John Lee")   = "BJL"
   * CMN_UTIL_Word.initials("Ben J.Lee")      = "BJ"
   * </pre>
   *
   * @param str the String to get initials from, may be null
   *
   * @return String of initial letters, <code>null</code> if null String input
   * @since 2.2
   */
  global static String initials(String str) {
    return initials(str, null);
  }

  /**
   * @description <p>Extracts the initial characters from each word in the String.</p>
   * <p/>
   * <p>All first characters after the defined delimiters are returned as a new string.
   * Their case is not changed.</p>
   * <p/>
   * <p>If the delimiters array is null, then Whitespace is used.
   * Whitespace is defined by {@link Character#isWhitespace(char)}.
   * A <code>null</code> input String returns <code>null</code>.
   * An empty delimiter array returns an empty String.</p>
   * <p/>
   * <pre>
   * CMN_UTIL_Word.initials(null, *)                = null
   * CMN_UTIL_Word.initials("", *)                  = ""
   * CMN_UTIL_Word.initials("Ben John Lee", null)   = "BJL"
   * CMN_UTIL_Word.initials("Ben J.Lee", null)      = "BJ"
   * CMN_UTIL_Word.initials("Ben J.Lee", [' ','.']) = "BJL"
   * CMN_UTIL_Word.initials(*, new char[0])         = ""
   * </pre>
   *
   * @param str the String to get initials from, may be null
   * @param delimiters set of characters to determine words, null means whitespace
   *
   * @return String of initial characters, <code>null</code> if null String input
   * @since 2.2
   */
  global static String initials(String str, String[] delimiters) {
    if (str == null || str.length() == 0) {
      return str;
    }
    if (delimiters != null && delimiters.size() == 0) {
      return '';
    }
    Integer strLen = str.length();
    String buf = '';
    Boolean lastWasGap = true;
    for (Integer i = 0; i < strLen; i++) {
      String ch = CMN_UTIL_String.charAt(str, i);

      if (isDelimiter(ch, delimiters)) {
        lastWasGap = true;
      } else if (lastWasGap) {
        buf += ch;
        lastWasGap = false;
      } else {
        // ignore ch
      }
    }
    return buf;
  }

  /**
   * @description Is the character a delimiter.
   *
   * @param ch the character to check
   * @param delimiters the delimiters
   *
   * @return true if it is a delimiter
   */
  private static Boolean isDelimiter(String ch, String[] delimiters) {
    if (delimiters == null) {
      return CMN_UTIL_Character.isWhitespace(ch);
    }
    for (Integer i = 0, isize = delimiters.size(); i < isize; i++) {
      if (
        (ch == null && delimiters[i] == null) ||
        (ch != null && ch.equals(delimiters[i]))
      ) {
        return true;
      }
    }
    return false;
  }

  /**
   * @description abbreviate a word string
   *
   * @param str as input
   * @param lower as input
   * @param upper as input
   * @param appendToEnd as input
   *
   * @return abbreviated word string
   */
  global static String abbreviate(
    String str,
    Integer lower,
    Integer upper,
    String appendToEnd
  ) {
    // initial parameter checks
    if (str == null) {
      return null;
    }
    if (str.length() == 0) {
      return CMN_UTIL_String.EMPTY;
    }

    // if the upper value is -1 (i.e. no limit) or is greater
    // than the length of the string, set to the length of the string
    if (upper == -1 || upper > str.length()) {
      upper = str.length();
    }
    // if upper is less than lower, raise it to lower
    if (upper < lower) {
      upper = lower;
    }

    String result = '';
    Integer index = CMN_UTIL_String.indexOf(str, ' ', lower);
    if (index == -1) {
      result += str.substring(0, upper);
      // only if abbreviation has occurred do we append the appendToEnd value
      if (upper != str.length()) {
        result += CMN_UTIL_String.defaultString(appendToEnd);
      }
    } else if (index > upper) {
      result += str.substring(0, upper);
      result += CMN_UTIL_String.defaultString(appendToEnd);
    } else {
      result += str.substring(0, index);
      result += CMN_UTIL_String.defaultString(appendToEnd);
    }
    return result;
  }
}