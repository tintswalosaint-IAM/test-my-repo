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
 * Port of the CMN_UTIL_String class from Java to Apex.  This
 * class is part of the Apache Commons Lang project available
 * at http://commons.apache.org/lang/.
 * <p/>
 * <p>Operations on {@link String} that are
 * {@code null} safe.</p>
 * <p/>
 * <p>The {@code CMN_UTIL_String} class defines certain words related to
 * String handling.</p>
 * <p/>
 * <ul>
 *  <li>null - {@code null}</li>
 *  <li>empty - a zero-length string ({@code ""})</li>
 *  <li>space - the space character ({@code ' '}, char 32)</li>
 *  <li>whitespace - the characters defined by {@link Character#isWhitespace(char)}</li>
 *  <li>trim - the characters &lt;= 32 as in {@link String#trim()}</li>
 * </ul>
 * <p/>
 * <p>{@code CMN_UTIL_String} handles {@code null} input Strings quietly.
 * That is to say that a {@code null} input will return {@code null}.
 * Where a {@code boolean} or {@code int} is being returned
 * details vary by method.</p>
 * <p/>
 * <p>A side effect of the {@code null} handling is that a
 * {@code NullPointerException} should be considered a bug in
 * {@code CMN_UTIL_String}.</p>
 * <p/>
 * <p>Methods in this class give sample code to explain their operation.
 * The symbol {@code *} is used to indicate any input including {@code null}.</p>
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see String @since 1.0
 */
global class CMN_UTIL_String
{
	global static final String DOT = '.';
	global static final String EMPTY = '';
	global static final String LF = '\n';
	global static final String CR = '\r';
	global static final Integer INDEX_NOT_FOUND = -1;

	private static final Integer PAD_LIMIT = 8192;

  /**
	 * @description <p>Abbreviates a String using ellipses. This will turn
	 * "Now is the time for all good men" into "Now is the time for..."</p>
	 * <p/>
	 * <p>Specifically:</p>
	 * <ul>
	 *   <li>If the number of characters in {@code str} is less than or equal to
	 *       {@code maxWidth}, return {@code str}.</li>
	 *   <li>Else abbreviate it to {@code (substring(str, 0, max-3) + "...")}.</li>
	 *   <li>If {@code maxWidth} is less than {@code 4}, throw an
	 *       {@code IllegalArgumentException}.</li>
	 *   <li>In no case will it return a String of length greater than
	 *       {@code maxWidth}.</li>
	 * </ul>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.abbreviate(null, *)      = null
	 * CMN_UTIL_String.abbreviate("", 4)        = ""
	 * CMN_UTIL_String.abbreviate("abcdefg", 6) = "abc..."
	 * CMN_UTIL_String.abbreviate("abcdefg", 7) = "abcdefg"
	 * CMN_UTIL_String.abbreviate("abcdefg", 8) = "abcdefg"
	 * CMN_UTIL_String.abbreviate("abcdefg", 4) = "a..."
	 * CMN_UTIL_String.abbreviate("abcdefg", 3) = IllegalArgumentException
	 * </pre>
	 *
	 * @param str the String to check, may be null
	 * @param maxWidth maximum length of result String, must be at least 4
	 *
	 * @return abbreviated String, {@code null} if null String input
	 * @throws IllegalArgumentException if the width is too small
	 * @since 2.0
	 */
	global static String abbreviate(String str, Integer maxWidth)
	{
		return abbreviate(str, 0, maxWidth);
	}

  /**
	 * @description <p>Abbreviates a String using ellipses. This will turn
	 * "Now is the time for all good men" into "...is the time for..."</p>
	 * <p/>
	 * <p>Works like {@code abbreviate(String, int)}, but allows you to specify
	 * a "left edge" offset.  Note that this left edge is not necessarily going to
	 * be the leftmost character in the result, or the first character following the
	 * ellipses, but it will appear somewhere in the result.
	 * <p/>
	 * <p>In no case will it return a String of length greater than
	 * {@code maxWidth}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.abbreviate(null, *, *)                = null
	 * CMN_UTIL_String.abbreviate("", 0, 4)                  = ""
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", -1, 10) = "abcdefg..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 0, 10)  = "abcdefg..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 1, 10)  = "abcdefg..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 4, 10)  = "abcdefg..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 5, 10)  = "...fghi..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 6, 10)  = "...ghij..."
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 8, 10)  = "...ijklmno"
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 10, 10) = "...ijklmno"
	 * CMN_UTIL_String.abbreviate("abcdefghijklmno", 12, 10) = "...ijklmno"
	 * CMN_UTIL_String.abbreviate("abcdefghij", 0, 3)        = IllegalArgumentException
	 * CMN_UTIL_String.abbreviate("abcdefghij", 5, 6)        = IllegalArgumentException
	 * </pre>
	 *
	 * @param str the String to check, may be null
	 * @param offset left edge of source String
	 * @param maxWidth maximum length of result String, must be at least 4
	 *
	 * @return abbreviated String, {@code null} if null String input
	 * @throws IllegalArgumentException if the width is too small
	 * @since 2.0
	 */
	global static String abbreviate(
			String str,
			Integer offset,
			Integer maxWidth
	)
	{
		if(str == null)
		{
			return null;
		}
		if(maxWidth < 4)
		{
			throw new IllegalArgumentException('Minimum abbreviation width is 4');
		}
		if(str.length() <= maxWidth)
		{
			return str;
		}
		if(offset > str.length())
		{
			offset = str.length();
		}
		if((str.length() - offset) < (maxWidth - 3))
		{
			offset = str.length() - (maxWidth - 3);
		}
		if(offset <= 4)
		{
			return str.substring(0, maxWidth - 3) + '...';
		}
		if(maxWidth < 7)
		{
			throw new IllegalArgumentException(
					'Minimum abbreviation width with offset is 7'
			);
		}
		if((offset + (maxWidth - 3)) < str.length())
		{
			return '...' + abbreviate(str.substring(offset), maxWidth - 3);
		}
		return '...' + str.substring(str.length() - (maxWidth - 3));
	}

  /**
	 * @description <p>Capitalizes a String changing the first character to title case as
	 * per {@link Character#toTitleCase(int)}. No other characters are changed.</p>
	 * <p/>
	 * <p>For a word based algorithm, see {@link org.apache.commons.lang3.text.WordUtils#capitalize(String)}.
	 * A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.capitalize(null)  = null
	 * CMN_UTIL_String.capitalize("")    = ""
	 * CMN_UTIL_String.capitalize("cat") = "Cat"
	 * CMN_UTIL_String.capitalize("cAt") = "CAt"
	 * CMN_UTIL_String.capitalize("'cat'") = "'cat'"
	 * </pre>
	 *
	 * @param str the String to capitalize, may be null
	 *
	 * @return the capitalized String, {@code null} if null String input
	 * @since 2.0
	 */
	global static String capitalize(String str)
	{
		if(isBlank(str))
		{
			return str;
		}
		return upperCase(str.substring(0, 1)) + str.substring(1);
	}

  /**
	 * @description <p>Centers a String in a larger String of size {@code size}
	 * using the space character (' ').</p>
	 * <p/>
	 * <p>If the size is less than the String length, the String is returned.
	 * A {@code null} String returns {@code null}.
	 * A negative size is treated as zero.</p>
	 * <p/>
	 * <p>Equivalent to {@code center(str, size, " ")}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.center(null, *)   = null
	 * CMN_UTIL_String.center("", 4)     = "    "
	 * CMN_UTIL_String.center("ab", -1)  = "ab"
	 * CMN_UTIL_String.center("ab", 4)   = " ab "
	 * CMN_UTIL_String.center("abcd", 2) = "abcd"
	 * CMN_UTIL_String.center("a", 4)    = " a  "
	 * </pre>
	 *
	 * @param str the String to center, may be null
	 * @param size the int size of new String, negative treated as zero
	 *
	 * @return centered String, {@code null} if null String input
	 */
	global static String center(String str, Integer size)
	{
		return center(str, size, ' ');
	}

  /**
	 * @description <p>Centers a String in a larger String of size {@code size}.
	 * Uses a supplied String as the value to pad the String with.</p>
	 * <p/>
	 * <p>If the size is less than the String length, the String is returned.
	 * A {@code null} String returns {@code null}.
	 * A negative size is treated as zero.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.center(null, *, *)     = null
	 * CMN_UTIL_String.center("", 4, " ")     = "    "
	 * CMN_UTIL_String.center("ab", -1, " ")  = "ab"
	 * CMN_UTIL_String.center("ab", 4, " ")   = " ab "
	 * CMN_UTIL_String.center("abcd", 2, " ") = "abcd"
	 * CMN_UTIL_String.center("a", 4, " ")    = " a  "
	 * CMN_UTIL_String.center("a", 4, "yz")   = "yayz"
	 * CMN_UTIL_String.center("abc", 7, null) = "  abc  "
	 * CMN_UTIL_String.center("abc", 7, "")   = "  abc  "
	 * </pre>
	 *
	 * @param str the String to center, may be null
	 * @param size the int size of new String, negative treated as zero
	 * @param padStr the String to pad the new String with, must not be null or empty
	 *
	 * @return centered String, {@code null} if null String input
	 * @throws IllegalArgumentException if padStr is {@code null} or empty
	 */
	global static String center(String str, Integer size, String padStr)
	{
		if(str == null || size <= 0)
		{
			return str;
		}
		if(isEmpty(padStr))
		{
			padStr = ' ';
		}
		Integer strLen = str.length();
		Integer padCharCount = size - strLen;
		if(padCharCount <= 0)
		{
			return str;
		}
		str = leftPad(str, strLen + padCharCount / 2, padStr);
		str = rightPad(str, size, padStr);
		return str;
	}

  /**
	 * @description retrieve character at index of string starts at 0
	 *
	 * @param str as input
	 * @param index as intpu
	 *
	 * @return string character
	 */
	global static String charAt(String str, Integer index)
	{
		if(str == null)
		{
			return null;
		}
		if(str.length() <= 0)
		{
			return str;
		}
		if(index < 0 || index >= str.length())
		{
			return null;
		}
		return str.substring(index, index + 1);
	}

  /**
	 * @description <p>Removes one newline from end of a String if it's there,
	 * otherwise leave it alone.  A newline is &quot;{@code \n}&quot;,
	 * &quot;{@code \r}&quot;, or &quot;{@code \r\n}&quot;.</p>
	 * <p/>
	 * <p>NOTE: This method changed in 2.0.
	 * It now more closely matches Perl chomp.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.chomp(null)          = null
	 * CMN_UTIL_String.chomp("")            = ""
	 * CMN_UTIL_String.chomp("abc \r")      = "abc "
	 * CMN_UTIL_String.chomp("abc\n")       = "abc"
	 * CMN_UTIL_String.chomp("abc\r\n")     = "abc"
	 * CMN_UTIL_String.chomp("abc\r\n\r\n") = "abc\r\n"
	 * CMN_UTIL_String.chomp("abc\n\r")     = "abc\n"
	 * CMN_UTIL_String.chomp("abc\n\rabc")  = "abc\n\rabc"
	 * CMN_UTIL_String.chomp("\r")          = ""
	 * CMN_UTIL_String.chomp("\n")          = ""
	 * CMN_UTIL_String.chomp("\r\n")        = ""
	 * </pre>
	 *
	 * @param str the String to chomp a newline from, may be null
	 *
	 * @return String without newline, {@code null} if null String input
	 */
	global static String chomp(String str)
	{
		if(isEmpty(str))
		{
			return str;
		}

		if(str.length() == 1)
		{
			String ch = charAt(str, 0);
			if(ch == CR || ch == LF)
			{
				return EMPTY;
			}
			return str;
		}

		Integer lastIdx = str.length() - 1;
		String last = charAt(str, lastIdx);

		if(LF.equals(last))
		{
			if(CR.equals(charAt(str, lastIdx - 1)))
			{
				lastIdx--;
			}
		}
		else if(!CR.equals(last))
		{
			lastIdx++;
		}
		return str.substring(0, lastIdx);
	}

  /**
	 * @description <p>Removes {@code separator} from the end of
	 * {@code str} if it's there, otherwise leave it alone.</p>
	 * <p/>
	 * <p>NOTE: This method changed in version 2.0.
	 * It now more closely matches Perl chomp.
	 * For the previous behavior, use {@link #substringBeforeLast(String, String)}.
	 * This method uses {@link String#endsWith(String)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.chomp(null, *)         = null
	 * CMN_UTIL_String.chomp("", *)           = ""
	 * CMN_UTIL_String.chomp("foobar", "bar") = "foo"
	 * CMN_UTIL_String.chomp("foobar", "baz") = "foobar"
	 * CMN_UTIL_String.chomp("foo", "foo")    = ""
	 * CMN_UTIL_String.chomp("foo ", "foo")   = "foo "
	 * CMN_UTIL_String.chomp(" foo", "foo")   = " "
	 * CMN_UTIL_String.chomp("foo", "foooo")  = "foo"
	 * CMN_UTIL_String.chomp("foo", "")       = "foo"
	 * CMN_UTIL_String.chomp("foo", null)     = "foo"
	 * </pre>
	 *
	 * @param str the String to chomp from, may be null
	 * @param separator separator String, may be null
	 *
	 * @return String without trailing separator, {@code null} if null String input
	 * @deprecated This feature will be removed in Lang 4.0, use {@link CMN_UTIL_String#removeEnd(String, String)} instead
	 */
	global static String chomp(String str, String separator)
	{
		if(isEmpty(str) || separator == null)
		{
			return str;
		}
		if(str.endsWith(separator))
		{
			return str.substring(0, str.length() - separator.length());
		}
		return str;
	}

  /**
	 * @description <p>Remove the last character from a String.</p>
	 * <p/>
	 * <p>If the String ends in {@code \r\n}, then remove both
	 * of them.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.chop(null)          = null
	 * CMN_UTIL_String.chop("")            = ""
	 * CMN_UTIL_String.chop("abc \r")      = "abc "
	 * CMN_UTIL_String.chop("abc\n")       = "abc"
	 * CMN_UTIL_String.chop("abc\r\n")     = "abc"
	 * CMN_UTIL_String.chop("abc")         = "ab"
	 * CMN_UTIL_String.chop("abc\nabc")    = "abc\nab"
	 * CMN_UTIL_String.chop("a")           = ""
	 * CMN_UTIL_String.chop("\r")          = ""
	 * CMN_UTIL_String.chop("\n")          = ""
	 * CMN_UTIL_String.chop("\r\n")        = ""
	 * </pre>
	 *
	 * @param str the String to chop last character from, may be null
	 *
	 * @return String without last character, {@code null} if null String input
	 */
	global static String chop(String str)
	{
		if(str == null)
		{
			return null;
		}
		Integer strLen = str.length();
		if(strLen < 2)
		{
			return EMPTY;
		}
		Integer lastIdx = strLen - 1;
		String ret = str.substring(0, lastIdx);
		String last = charAt(str, lastIdx);
		if(LF.equals(last))
		{
			if(CR.equals(charAt(ret, lastIdx - 1)))
			{
				return ret.substring(0, lastIdx - 1);
			}
		}
		return ret;
	}

  /**
	 * @description <p>Checks if CharSequence contains a search CharSequence, handling {@code null}.
	 * This method uses {@link String#indexOf(String)} if possible.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code false}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.contains(null, *)     = false
	 * CMN_UTIL_String.contains(*, null)     = false
	 * CMN_UTIL_String.contains("", "")      = true
	 * CMN_UTIL_String.contains("abc", "")   = true
	 * CMN_UTIL_String.contains("abc", "a")  = true
	 * CMN_UTIL_String.contains("abc", "z")  = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 *
	 * @return true if the CharSequence contains the search CharSequence,
	 *  false if not or {@code null} string input
	 * @since 2.0
	 * @since 3.0 Changed signature from contains(String, String) to contains(CharSequence, CharSequence)
	 */
	global static Boolean contains(String str, String searchStr)
	{
		if(str == null || searchStr == null)
		{
			return false;
		}
		return str.indexOf(searchStr, 0) >= 0;
	}

  /**
	 * @description <p>
	 * Checks if the CharSequence contains any character in the given set of characters.
	 * </p>
	 * <p/>
	 * <p>
	 * A {@code null} CharSequence will return {@code false}. A {@code null} search CharSequence will return
	 * {@code false}.
	 * </p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.containsAny(null, *)               = false
	 * CMN_UTIL_String.containsAny("", *)                 = false
	 * CMN_UTIL_String.containsAny(*, null)               = false
	 * CMN_UTIL_String.containsAny(*, "")                 = false
	 * CMN_UTIL_String.containsAny("zzabyycdxx", "za")    = true
	 * CMN_UTIL_String.containsAny("zzabyycdxx", "by")    = true
	 * CMN_UTIL_String.containsAny("zzabyycdxx", "zy")    = true
	 * CMN_UTIL_String.containsAny("zzabyycdxx", "\tx")   = true
	 * CMN_UTIL_String.containsAny("zzabyycdxx", "$.#yF") = true
	 * CMN_UTIL_String.containsAny("aba", "z")            = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchChars the chars to search for, may be null
	 *
	 * @return the {@code true} if any of the chars are found, {@code false} if no match or null input
	 * @since 2.4
	 * @since 3.0 Changed signature from containsAny(String, String) to containsAny(CharSequence, CharSequence)
	 */
	global static Boolean containsAny(String str, String searchChars)
	{
		if(
				str == null ||
						str.length() == 0 ||
						searchChars == null ||
						searchChars.length() == 0
				)
		{
			return false;
		}
		for(Integer i = 0; i < str.length(); i++)
		{
			if(searchChars.contains(charAt(str, i)))
			{
				return true;
			}
		}
		return false;
	}

  /**
	 * @description <p>Checks if CharSequence contains a search CharSequence irrespective of case,
	 * handling {@code null}. Case-insensitivity is defined as by
	 * {@link String#equalsIgnoreCase(String)}.
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code false}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.containsIgnoreCase(null, *) = false
	 * CMN_UTIL_String.containsIgnoreCase(*, null) = false
	 * CMN_UTIL_String.containsIgnoreCase("", "") = true
	 * CMN_UTIL_String.containsIgnoreCase("abc", "") = true
	 * CMN_UTIL_String.containsIgnoreCase("abc", "a") = true
	 * CMN_UTIL_String.containsIgnoreCase("abc", "z") = false
	 * CMN_UTIL_String.containsIgnoreCase("abc", "A") = true
	 * CMN_UTIL_String.containsIgnoreCase("abc", "Z") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 *
	 * @return true if the CharSequence contains the search CharSequence irrespective of
	 * case or false if not or {@code null} string input
	 * @since 3.0 Changed signature from containsIgnoreCase(String, String) to containsIgnoreCase(CharSequence, CharSequence)
	 */
	global static Boolean containsIgnoreCase(String str, String searchStr)
	{
		if(str == null || searchStr == null)
		{
			return false;
		}
		return contains(str.toUpperCase(), searchStr.toUpperCase());
	}

  /**
	 * @description <p>Checks that the CharSequence does not contain certain characters.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code true}.
	 * A {@code null} invalid character array will return {@code true}.
	 * An empty String ("") always returns true.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.containsNone(null, *)       = true
	 * CMN_UTIL_String.containsNone(*, null)       = true
	 * CMN_UTIL_String.containsNone("", *)         = true
	 * CMN_UTIL_String.containsNone("ab", "")      = true
	 * CMN_UTIL_String.containsNone("abab", "xyz") = true
	 * CMN_UTIL_String.containsNone("ab1", "xyz")  = true
	 * CMN_UTIL_String.containsNone("abz", "xyz")  = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param invalidChars a String of invalid chars, may be null
	 *
	 * @return true if it contains none of the invalid chars, or is null
	 * @since 2.0
	 * @since 3.0 Changed signature from containsNone(String, String) to containsNone(CharSequence, String)
	 */
	global static Boolean containsNone(String str, String invalidChars)
	{
		if(str == null || invalidChars == null)
		{
			return true;
		}
		Integer strSize = str.length();
		for(Integer i = 0; i < strSize; i++)
		{
			String ch = charAt(str, i);
			if(invalidChars.contains(ch))
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only certain characters.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code false}.
	 * A {@code null} valid character String will return {@code false}.
	 * An empty String (length()=0) always returns {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.containsOnly(null, *)       = false
	 * CMN_UTIL_String.containsOnly(*, null)       = false
	 * CMN_UTIL_String.containsOnly("", *)         = true
	 * CMN_UTIL_String.containsOnly("ab", "")      = false
	 * CMN_UTIL_String.containsOnly("abab", "abc") = true
	 * CMN_UTIL_String.containsOnly("ab1", "abc")  = false
	 * CMN_UTIL_String.containsOnly("abz", "abc")  = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param validChars a String of valid chars, may be null
	 *
	 * @return true if it only contains valid chars and is non-null
	 * @since 2.0
	 * @since 3.0 Changed signature from containsOnly(String, String) to containsOnly(CharSequence, String)
	 */
	global static Boolean containsOnly(String str, String validChars)
	{
		if((validChars == null) || (str == null))
		{
			return false;
		}
		if(str.length() == 0)
		{
			return true;
		}
		if(validChars.length() == 0)
		{
			return false;
		}
		return indexOfAnyBut(str, validChars) == -1;
	}

  /**
	 * @description <p>Counts how many times the substring appears in the larger string.</p>
	 * <p/>
	 * <p>A {@code null} or empty ("") String input returns {@code 0}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.countMatches(null, *)       = 0
	 * CMN_UTIL_String.countMatches("", *)         = 0
	 * CMN_UTIL_String.countMatches("abba", null)  = 0
	 * CMN_UTIL_String.countMatches("abba", "")    = 0
	 * CMN_UTIL_String.countMatches("abba", "a")   = 2
	 * CMN_UTIL_String.countMatches("abba", "ab")  = 1
	 * CMN_UTIL_String.countMatches("abba", "xxx") = 0
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param sub the substring to count, may be null
	 *
	 * @return the number of occurrences, 0 if either CharSequence is {@code null}
	 * @since 3.0 Changed signature from countMatches(String, String) to countMatches(CharSequence, CharSequence)
	 */
	global static Integer countMatches(String str, String sub)
	{
		if(isEmpty(str) || isEmpty(sub))
		{
			return 0;
		}
		Integer count = 0;
		Integer idx = 0;
		while((idx = str.indexOf(sub, idx)) != -1)
		{
			count++;
			idx += sub.length();
		}
		return count;
	}

  /**
	 * @description <p>Returns either the passed in CharSequence, or if the CharSequence is
	 * whitespace, empty ("") or {@code null}, the value of {@code defaultStr}.</p>
	 * <p/>
	 * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.defaultIfBlank(null, "NULL")  = "NULL"
	 * CMN_UTIL_String.defaultIfBlank("", "NULL")    = "NULL"
	 * CMN_UTIL_String.defaultIfBlank(" ", "NULL")   = "NULL"
	 * CMN_UTIL_String.defaultIfBlank("bat", "NULL") = "bat"
	 * CMN_UTIL_String.defaultIfBlank("", null)      = null
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param defaultStr the default CharSequence to return
	 *  if the input is whitespace, empty ("") or {@code null}, may be null
	 *
	 * @return the passed in CharSequence, or the default
	 */
	global static String defaultIfEmpty(String str, String defaultStr)
	{
		return CMN_UTIL_String.isEmpty(str) ? defaultStr : str;
	}

  /**
	 * @description <p>Returns either the passed in String,
	 * or if the String is {@code null}, an empty String ("").</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.defaultString(null)  = ""
	 * CMN_UTIL_String.defaultString("")    = ""
	 * CMN_UTIL_String.defaultString("bat") = "bat"
	 * </pre>
	 *
	 * @param str the String to check, may be null
	 *
	 * @return the passed in String, or the empty String if it
	 *  was {@code null}
	 */
	global static String defaultString(String str)
	{
		return str == null ? EMPTY : str;
	}

  /**
	 * @description <p>Returns either the passed in String, or if the String is
	 * {@code null}, the value of {@code defaultStr}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.defaultString(null, "NULL")  = "NULL"
	 * CMN_UTIL_String.defaultString("", "NULL")    = ""
	 * CMN_UTIL_String.defaultString("bat", "NULL") = "bat"
	 * </pre>
	 *
	 * @param str the String to check, may be null
	 * @param defaultStr the default String to return
	 *  if the input is {@code null}, may be null
	 *
	 * @return the passed in String, or the default if it was {@code null}
	 */
	global static String defaultString(String str, String defaultStr)
	{
		return str == null ? defaultStr : str;
	}

  /**
	 * @description <p>Deletes all whitespaces from a String as defined by
	 * {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.deleteWhitespace(null)         = null
	 * CMN_UTIL_String.deleteWhitespace("")           = ""
	 * CMN_UTIL_String.deleteWhitespace("abc")        = "abc"
	 * CMN_UTIL_String.deleteWhitespace("   ab  c  ") = "abc"
	 * </pre>
	 *
	 * @param str the String to delete whitespace from, may be null
	 *
	 * @return the String without whitespaces, {@code null} if null String input
	 */
	global static String deleteWhitespace(String str)
	{
		if(isEmpty(str))
		{
			return str;
		}
		String returnString = '';
		String currentChar = null;
		for(Integer i = 0; i < str.length(); i++)
		{
			currentChar = charAt(str, i);
			if(!CMN_UTIL_Character.isWhitespace(currentChar))
			{
				returnString += currentChar;
			}
		}
		return returnString;
	}

  /**
	 * @description <p>Compares two Strings, and returns the portion where they differ.
	 * More precisely, return the remainder of the second String,
	 * starting from where it's different from the first. This means that
	 * the difference between "abc" and "ab" is the empty String and not "c". </p>
	 * <p/>
	 * <p>For example,
	 * {@code difference("i am a machine", "i am a robot") -> "robot"}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.difference(null, null) = null
	 * CMN_UTIL_String.difference("", "") = ""
	 * CMN_UTIL_String.difference("", "abc") = "abc"
	 * CMN_UTIL_String.difference("abc", "") = ""
	 * CMN_UTIL_String.difference("abc", "abc") = ""
	 * CMN_UTIL_String.difference("abc", "ab") = ""
	 * CMN_UTIL_String.difference("ab", "abxyz") = "xyz"
	 * CMN_UTIL_String.difference("abcde", "abxyz") = "xyz"
	 * CMN_UTIL_String.difference("abcde", "xyz") = "xyz"
	 * </pre>
	 *
	 * @param str1 the first String, may be null
	 * @param str2 the second String, may be null
	 *
	 * @return the portion of str2 where it differs from str1; returns the
	 * empty String if they are equal
	 * @since 2.0
	 */
	global static String difference(String str1, String str2)
	{
		if(str1 == null)
		{
			return str2;
		}
		if(str2 == null)
		{
			return str1;
		}
		Integer at = indexOfDifference(str1, str2);
		if(at == -1)
		{
			return EMPTY;
		}
		if(at == 0)
		{
			return str2;
		}
		return str2.substring(at);
	}

  /**
	 * @description <p>Compares two CharSequences, and returns the index at which the
	 * CharSequences begin to differ.</p>
	 * <p/>
	 * <p>For example,
	 * {@code indexOfDifference("i am a machine", "i am a robot") -> 7}</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOfDifference(null, null) = -1
	 * CMN_UTIL_String.indexOfDifference("", "") = -1
	 * CMN_UTIL_String.indexOfDifference("", "abc") = 0
	 * CMN_UTIL_String.indexOfDifference("abc", "") = 0
	 * CMN_UTIL_String.indexOfDifference("abc", "abc") = -1
	 * CMN_UTIL_String.indexOfDifference("ab", "abxyz") = 2
	 * CMN_UTIL_String.indexOfDifference("abcde", "abxyz") = 2
	 * CMN_UTIL_String.indexOfDifference("abcde", "xyz") = 0
	 * </pre>
	 *
	 * @param str1 the first CharSequence, may be null
	 * @param str2 the second CharSequence, may be null
	 *
	 * @return the index where cs1 and cs2 begin to differ; -1 if they are equal
	 * @since 2.0
	 * @since 3.0 Changed signature from indexOfDifference(String, String) to
	 * indexOfDifference(CharSequence, CharSequence)
	 */
	global static Integer indexOfDifference(String str1, String str2)
	{
		if(str1 == str2)
		{
			return -1;
		}
		if(str1 == null || str2 == null)
		{
			return 0;
		}
		Integer i;
		for(i = 0; i < str1.length() && i < str2.length(); ++i)
		{
			if(charAt(str1, i) != charAt(str2, i))
			{
				break;
			}
		}
		return i;
	}

  /**
	 * @description <p>Compares all CharSequences in an array and returns the index at which the
	 * CharSequences begin to differ.</p>
	 * <p/>
	 * <p>For example,
	 * {@code indexOfDifference(new String[] {"i am a machine", "i am a robot"}) -> 7}</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOfDifference(null) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {}) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abc"}) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {null, null}) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {"", ""}) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {"", null}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abc", null, null}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {null, null, "abc"}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"", "abc"}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abc", ""}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abc", "abc"}) = -1
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abc", "a"}) = 1
	 * CMN_UTIL_String.indexOfDifference(new String[] {"ab", "abxyz"}) = 2
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abcde", "abxyz"}) = 2
	 * CMN_UTIL_String.indexOfDifference(new String[] {"abcde", "xyz"}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"xyz", "abcde"}) = 0
	 * CMN_UTIL_String.indexOfDifference(new String[] {"i am a machine", "i am a robot"}) = 7
	 * </pre>
	 *
	 * @param strings array of CharSequences, entries may be null
	 *
	 * @return the index where the strings begin to differ; -1 if they are all equal
	 * @since 2.4
	 * @since 3.0 Changed signature from indexOfDifference(String...) to indexOfDifference(CharSequence...)
	 */
	global static Integer indexOfDifference(String[] strings)
	{
		if(strings == null || strings.size() <= 1)
		{
			return -1;
		}
		Boolean anyStringNull = false;
		Boolean allStringsNull = true;
		Integer listSize = strings.size();
		Integer shortestStrLen = CMN_UTIL_Number.MAX_INTEGER;
		Integer longestStrLen = 0;

		// find the min and max string lengths; this avoids checking to make
		// sure we are not exceeding the length of the string each time through
		// the bottom loop.
		for(Integer i = 0; i < listSize; i++)
		{
			if(strings.get(i) == null)
			{
				anyStringNull = true;
				shortestStrLen = 0;
			}
			else
			{
				allStringsNull = false;
				shortestStrLen = Math.min(strings.get(i).length(), shortestStrLen);
				longestStrLen = Math.max(strings.get(i).length(), longestStrLen);
			}
		}

		// handle lists containing all nulls or all empty strings
		if(allStringsNull || (longestStrLen == 0 && !anyStringNull))
		{
			return -1;
		}

		// handle lists containing some nulls or some empty strings
		if(shortestStrLen == 0)
		{
			return 0;
		}

		// find the position with the first difference across all strings
		Integer firstDiff = -1;
		for(Integer stringPos = 0; stringPos < shortestStrLen; stringPos++)
		{
			String comparisonChar = charAt(strings.get(0), stringPos);
			for(Integer arrayPos = 1; arrayPos < listSize; arrayPos++)
			{
				if(charAt(strings.get(arrayPos), stringPos) != comparisonChar)
				{
					firstDiff = stringPos;
					break;
				}
			}
			if(firstDiff != -1)
			{
				break;
			}
		}

		if(firstDiff == -1 && shortestStrLen != longestStrLen)
		{
			// we compared all of the characters up to the length of the
			// shortest string and didn't find a match, but the string lengths
			// vary, so return the length of the shortest string.
			return shortestStrLen;
		}
		return firstDiff;
	}

  /**
	 * @description compares two string and if they are exactly equal
	 *
	 * @param str1 the first string to compare
	 * @param str2 the seconds tring to compare
	 *
	 * @return if string are exactly exaule or not
	 */
	global static Boolean equals(String str1, String str2)
	{
		return str1 == null ? str2 == null : str1.equals(str2);
	}

  /**
	 * @description <p>Compares two CharSequences, returning {@code true} if they represent
	 * equal sequences of characters, ignoring case.</p>
	 * <p/>
	 * <p>{@code null}s are handled without exceptions. Two {@code null}
	 * references are considered equal. The comparison is <strong>case insensitive</strong>.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.equalsIgnoreCase(null, null)   = true
	 * CMN_UTIL_String.equalsIgnoreCase(null, "abc")  = false
	 * CMN_UTIL_String.equalsIgnoreCase("abc", null)  = false
	 * CMN_UTIL_String.equalsIgnoreCase("abc", "abc") = true
	 * CMN_UTIL_String.equalsIgnoreCase("abc", "ABC") = true
	 * </pre>
	 *
	 * @param str1 the first CharSequence, may be {@code null}
	 * @param str2 the second CharSequence, may be {@code null}
	 *
	 * @return {@code true} if the CharSequences are equal (case-insensitive), or both {@code null}
	 * @since 3.0 Changed signature from equalsIgnoreCase(String, String) to equalsIgnoreCase(CharSequence, CharSequence)
	 */
	global static Boolean equalsIgnoreCase(String str1, String str2)
	{
		return str1 == null ? str2 == null : str1.equalsIgnoreCase(str2);
	}

  /**
	 * @description <p>Finds the first index within a CharSequence, handling {@code null}.
	 * This method uses {@link String#indexOf(String, int)} if possible.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOf(null, *)          = -1
	 * CMN_UTIL_String.indexOf(*, null)          = -1
	 * CMN_UTIL_String.indexOf("", "")           = 0
	 * CMN_UTIL_String.indexOf("", *)            = -1 (except when * = "")
	 * CMN_UTIL_String.indexOf("aabaabaa", "a")  = 0
	 * CMN_UTIL_String.indexOf("aabaabaa", "b")  = 2
	 * CMN_UTIL_String.indexOf("aabaabaa", "ab") = 1
	 * CMN_UTIL_String.indexOf("aabaabaa", "")   = 0
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 *
	 * @return the first index of the search CharSequence,
	 *  -1 if no match or {@code null} string input
	 * @since 2.0
	 * @since 3.0 Changed signature from indexOf(String, String) to indexOf(CharSequence, CharSequence)
	 */
	global static Integer indexOf(String str, String searchStr)
	{
		if(str == null || searchStr == null)
		{
			return -1;
		}
		return str.indexOf(searchStr);
	}

  /**
	 * @description <p>Finds the first index within a CharSequence, handling {@code null}.
	 * This method uses {@link String#indexOf(String, int)} if possible.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.
	 * A negative start position is treated as zero.
	 * An empty ("") search CharSequence always matches.
	 * A start position greater than the string length only matches
	 * an empty search CharSequence.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOf(null, *, *)          = -1
	 * CMN_UTIL_String.indexOf(*, null, *)          = -1
	 * CMN_UTIL_String.indexOf("", "", 0)           = 0
	 * CMN_UTIL_String.indexOf("", *, 0)            = -1 (except when * = "")
	 * CMN_UTIL_String.indexOf("aabaabaa", "a", 0)  = 0
	 * CMN_UTIL_String.indexOf("aabaabaa", "b", 0)  = 2
	 * CMN_UTIL_String.indexOf("aabaabaa", "ab", 0) = 1
	 * CMN_UTIL_String.indexOf("aabaabaa", "b", 3)  = 5
	 * CMN_UTIL_String.indexOf("aabaabaa", "b", 9)  = -1
	 * CMN_UTIL_String.indexOf("aabaabaa", "b", -1) = 2
	 * CMN_UTIL_String.indexOf("aabaabaa", "", 2)   = 2
	 * CMN_UTIL_String.indexOf("abc", "", 9)        = 3
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 * @param startPos the start position, negative treated as zero
	 *
	 * @return the first index of the search CharSequence (always &ge; startPos),
	 *  -1 if no match or {@code null} string input
	 * @since 2.0
	 * @since 3.0 Changed signature from indexOf(String, String, int) to indexOf(CharSequence, CharSequence, int)
	 */
	global static Integer indexOf(
			String str,
			String searchStr,
			Integer startPos
	)
	{
		if(str == null || searchStr == null)
		{
			return -1;
		}
		if(searchStr.length() == 0 && startPos >= str.length())
		{
			return str.length();
		}
		return str.indexOf(searchStr, startPos);
	}

  /**
	 * @description <p>Finds the n-th index within a CharSequence, handling {@code null}.
	 * This method uses {@link String#indexOf(String)} if possible.</p>
	 * <p><b>Note:</b> The code starts looking for a match at the start of the target,
	 * incrementing the starting index by one after each successful match
	 * (unless {@code searchStr} is an empty string in which case the position
	 * is never incremented and {@code 0} is returned immediately).
	 * This means that matches may overlap.</p>
	 * <p>A {@code null} CharSequence will return {@code -1}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.ordinalIndexOf(null, *, *)          = -1
	 * CMN_UTIL_String.ordinalIndexOf(*, null, *)          = -1
	 * CMN_UTIL_String.ordinalIndexOf("", "", *)           = 0
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "a", 1)  = 0
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "a", 2)  = 1
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "b", 1)  = 2
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "b", 2)  = 5
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "ab", 1) = 1
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "ab", 2) = 4
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "", 1)   = 0
	 * CMN_UTIL_String.ordinalIndexOf("aabaabaa", "", 2)   = 0
	 * </pre>
	 * <p/>
	 * <p>Matches may overlap:</p>
	 * <pre>
	 * CMN_UTIL_String.ordinalIndexOf("ababab", "aba", 1)   = 0
	 * CMN_UTIL_String.ordinalIndexOf("ababab", "aba", 2)   = 2
	 * CMN_UTIL_String.ordinalIndexOf("ababab", "aba", 3)   = -1
	 *
	 * CMN_UTIL_String.ordinalIndexOf("abababab", "abab", 1) = 0
	 * CMN_UTIL_String.ordinalIndexOf("abababab", "abab", 2) = 2
	 * CMN_UTIL_String.ordinalIndexOf("abababab", "abab", 3) = 4
	 * CMN_UTIL_String.ordinalIndexOf("abababab", "abab", 4) = -1
	 * </pre>
	 * <p/>
	 * <p>Note that 'head(CharSequence str, int n)' may be implemented as: </p>
	 * <p/>
	 * <pre>
	 *   str.substring(0, lastOrdinalIndexOf(str, "\n", n))
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 * @param ordinal the n-th {@code searchStr} to find
	 *
	 * @return the n-th index of the search CharSequence,
	 *  {@code -1} ({@code INDEX_NOT_FOUND}) if no match or {@code null} string input
	 * @since 2.1
	 * @since 3.0 Changed signature from ordinalIndexOf(String, String, int) to ordinalIndexOf(CharSequence, CharSequence, int)
	 */
	global static Integer ordinalIndexOf(
			String str,
			String searchStr,
			Integer ordinal
	)
	{
		//'','',-1
		if(str == null || searchStr == null || ordinal <= 0)
		{
			return INDEX_NOT_FOUND;
		}
		if(searchStr.length() == 0)
		{
			return 0;
		}
		Integer found = 0;
		Integer index = INDEX_NOT_FOUND;
		do
		{
			index = str.indexOf(searchStr, index + 1);
			if(index < 0)
			{
				return index;
			}
			found++;
		}
		while(found < ordinal);
		return index;
	}

  /**
	 * @description attepts to resolve the common prefix from an array of strings
	 *
	 * @param strings as input
	 *
	 * @return resolved common prefix of strings
	 */
	global static String getCommonPrefix(String[] strings)
	{
		if(strings == null || strings.size() == 0)
		{
			return EMPTY;
		}
		Integer smallestIndexOfDiff = indexOfDifference(strings);
		if(smallestIndexOfDiff == -1)
		{
			// all strings were identical
			if(strings.get(0) == null)
			{
				return EMPTY;
			}
			return strings.get(0);
		}
		else if(smallestIndexOfDiff == 0)
		{
			// there were no common initial characters
			return EMPTY;
		}
		else
		{
			// we found a common initial character sequence
			return strings.get(0).substring(0, smallestIndexOfDiff);
		}
	}

  /**
	 * @description <p>Find the Levenshtein distance between two Strings.</p>
	 * <p/>
	 * <p>This is the number of changes needed to change one String into
	 * another, where each change is a single character modification (deletion,
	 * insertion or substitution).</p>
	 * <p/>
	 * <p>The implementation uses a single-dimensional array of length s.length() + 1. See
	 * <a href="http://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-c.html">
	 * http://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-c.html</a> for details.</p>
	 * <p/>
	 * <pre>
	 * StringUtils.getLevenshteinDistance(null, *)             = IllegalArgumentException
	 * StringUtils.getLevenshteinDistance(*, null)             = IllegalArgumentException
	 * StringUtils.getLevenshteinDistance("", "")              = 0
	 * StringUtils.getLevenshteinDistance("", "a")             = 1
	 * StringUtils.getLevenshteinDistance("aaapppp", "")       = 7
	 * StringUtils.getLevenshteinDistance("frog", "fog")       = 1
	 * StringUtils.getLevenshteinDistance("fly", "ant")        = 3
	 * StringUtils.getLevenshteinDistance("elephant", "hippo") = 7
	 * StringUtils.getLevenshteinDistance("hippo", "elephant") = 7
	 * StringUtils.getLevenshteinDistance("hippo", "zzzzzzzz") = 8
	 * StringUtils.getLevenshteinDistance("hello", "hallo")    = 1
	 * </pre>
	 *
	 * @param s the first String, must not be null
	 * @param t the second String, must not be null
	 *
	 * @return result distance
	 * @throws IllegalArgumentException if either String input {@code null}
	 * @since 3.0 Changed signature from getLevenshteinDistance(String, String) to
	 * getLevenshteinDistance(CharSequence, CharSequence)
	 * @deprecated as of 3.6, use commons-text
	 * <a href="https://commons.apache.org/proper/commons-text/javadocs/api-release/org/apache/commons/text/similarity/LevenshteinDistance.html">
	 * LevenshteinDistance</a> instead
	 */
	global static Integer getLevenshteinDistance(String s, String t)
	{
		if(s == null || t == null)
		{
			throw new IllegalArgumentException('Strings must not be null');
		}

		Integer n = s.length(); // length of s
		Integer m = t.length(); // length of t

		if(n == 0)
		{
			return m;
		}
		else if(m == 0)
		{
			return n;
		}

		if(n > m)
		{
			// swap the input strings to consume less memory
			String tmp = s;
			s = t;
			t = tmp;
			n = m;
			m = t.length();
		}

		Integer[] p = new List<Integer>(n + 1); //'previous' cost array, horizontally
		Integer[] d = new List<Integer>(n + 1); // cost array, horizontally
		Integer[] dSwap; //placeholder to assist in swapping p and d

		// indexes into strings s and t
		Integer i; // iterates through s
		Integer j; // iterates through t

		String jthCharacter; // jth character of t

		Integer cost; // cost

		for(i = 0; i <= n; i++)
		{
			p[i] = i;
		}

		for(j = 1; j <= m; j++)
		{
			jthCharacter = charAt(t, j - 1);
			d[0] = j;

			for(i = 1; i <= n; i++)
			{
				cost = charAt(s, i - 1) == jthCharacter ? 0 : 1;
				// minimum of cell to the left+1, to the top+1, diagonally left and up +cost
				d[i] = Math.min(Math.min(d[i - 1] + 1, p[i] + 1), p[i - 1] + cost);
			}

			// copy current distance counts to 'previous row' distance counts
			dSwap = p;
			p = d;
			d = dSwap;
		}

		// our last action in the above loop was to switch d and p, so p now
		// actually has the most recent cost counts
		return p[n];
	}

  /**
	 * @description <p>Search a CharSequence to find the first index of any
	 * character not in the given set of characters.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.
	 * A {@code null} or empty search string will return {@code -1}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOfAnyBut(null, *)            = -1
	 * CMN_UTIL_String.indexOfAnyBut("", *)              = -1
	 * CMN_UTIL_String.indexOfAnyBut(*, null)            = -1
	 * CMN_UTIL_String.indexOfAnyBut(*, "")              = -1
	 * CMN_UTIL_String.indexOfAnyBut("zzabyycdxx", "za") = 3
	 * CMN_UTIL_String.indexOfAnyBut("zzabyycdxx", "")   = -1
	 * CMN_UTIL_String.indexOfAnyBut("aba", "ab")        = -1
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchChars the chars to search for, may be null
	 *
	 * @return the index of any of the chars, -1 if no match or null input
	 * @since 2.0
	 * @since 3.0 Changed signature from indexOfAnyBut(String, String) to indexOfAnyBut(CharSequence, CharSequence)
	 */
	global static Integer indexOfAnyBut(String str, String searchChars)
	{
		if(isEmpty(str) || searchChars == null)
		{
			return -1;
		}
		for(Integer i = 0; i < str.length(); i++)
		{
			if(searchChars.contains(charAt(str, i)))
			{
				continue;
			}
			return i;
		}
		return -1;
	}

  /**
	 * @description <p>Check if a CharSequence ends with a specified suffix.</p>
	 * <p/>
	 * <p>{@code null}s are handled without exceptions. Two {@code null}
	 * references are considered to be equal. The comparison is case sensitive.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.endsWith(null, null)      = true
	 * CMN_UTIL_String.endsWith(null, "def")     = false
	 * CMN_UTIL_String.endsWith("abcdef", null)  = false
	 * CMN_UTIL_String.endsWith("abcdef", "def") = true
	 * CMN_UTIL_String.endsWith("ABCDEF", "def") = false
	 * CMN_UTIL_String.endsWith("ABCDEF", "cde") = false
	 * CMN_UTIL_String.endsWith("ABCDEF", "")    = true
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param suffix the suffix to find, may be null
	 *
	 * @return {@code true} if the CharSequence ends with the suffix, case sensitive, or
	 *  both {@code null}
	 * @since 2.4
	 * @since 3.0 Changed signature from endsWith(String, String) to endsWith(CharSequence, CharSequence)
	 */
	global static Boolean endsWith(String str, String suffix)
	{
		return endsWith(str, suffix, false);
	}

  /**
	 * @description <p>Check if a CharSequence ends with a specified suffix (optionally case insensitive).</p>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param suffix the suffix to find, may be null
	 * @param ignoreCase indicates whether the compare should ignore case
	 *  (case insensitive) or not.
	 *
	 * @return {@code true} if the CharSequence starts with the prefix or
	 *  both {@code null}
	 */
	private static Boolean endsWith(
			String str,
			String suffix,
			Boolean ignoreCase
	)
	{
		if(str == null || suffix == null)
		{
			return (str == null && suffix == null);
		}
		if(suffix.length() > str.length())
		{
			return false;
		}
		Integer strOffset = str.length() - suffix.length();
		String ending = str.substring(strOffset, str.length());
		if(ignoreCase)
		{
			return suffix.equalsIgnoreCase(ending);
		}
		return suffix.equals(ending);
	}

  /**
	 * @description <p>Case insensitive check if a CharSequence ends with a specified suffix.</p>
	 * <p/>
	 * <p>{@code null}s are handled without exceptions. Two {@code null}
	 * references are considered to be equal. The comparison is case insensitive.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.endsWithIgnoreCase(null, null)      = true
	 * CMN_UTIL_String.endsWithIgnoreCase(null, "def")     = false
	 * CMN_UTIL_String.endsWithIgnoreCase("abcdef", null)  = false
	 * CMN_UTIL_String.endsWithIgnoreCase("abcdef", "def") = true
	 * CMN_UTIL_String.endsWithIgnoreCase("ABCDEF", "def") = true
	 * CMN_UTIL_String.endsWithIgnoreCase("ABCDEF", "cde") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param suffix the suffix to find, may be null
	 *
	 * @return {@code true} if the CharSequence ends with the suffix, case insensitive, or
	 *  both {@code null}
	 * @since 2.4
	 * @since 3.0 Changed signature from endsWithIgnoreCase(String, String) to endsWithIgnoreCase(CharSequence, CharSequence)
	 */
	global static Boolean endsWithIgnoreCase(String str, String suffix)
	{
		return endsWith(str, suffix, true);
	}

  /**
	 * @description <p>Search a CharSequence to find the first index of any
	 * character in the given set of characters.</p>
	 * <p/>
	 * <p>A {@code null} String will return {@code -1}.
	 * A {@code null} search string will return {@code -1}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOfAny(null, *)            = -1
	 * CMN_UTIL_String.indexOfAny("", *)              = -1
	 * CMN_UTIL_String.indexOfAny(*, null)            = -1
	 * CMN_UTIL_String.indexOfAny(*, "")              = -1
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", "za") = 0
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", "by") = 3
	 * CMN_UTIL_String.indexOfAny("aba", "z")         = -1
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchChars the chars to search for, may be null
	 *
	 * @return the index of any of the chars, -1 if no match or null input
	 * @since 2.0
	 * @since 3.0 Changed signature from indexOfAny(String, String) to indexOfAny(CharSequence, String)
	 */
	global static Integer indexOfAny(String str, String searchChars)
	{
		if(isEmpty(str) || searchChars == null)
		{
			return -1;
		}
		for(Integer i = 0; i < str.length(); i++)
		{
			String ch = charAt(str, i);
			for(Integer j = 0; j < searchChars.length(); j++)
			{
				if(charAt(searchChars, j) == ch)
				{
					return i;
				}
			}
		}
		return -1;
	}

  /**
	 * @description <p>Find the first index of any of a set of potential substrings.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.
	 * A {@code null} or zero length search array will return {@code -1}.
	 * A {@code null} search array entry will be ignored, but a search
	 * array containing "" will return {@code 0} if {@code str} is not
	 * null. This method uses {@link String#indexOf(String)} if possible.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.indexOfAny(null, *)                      = -1
	 * CMN_UTIL_String.indexOfAny(*, null)                      = -1
	 * CMN_UTIL_String.indexOfAny(*, [])                        = -1
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", ["ab", "cd"])   = 2
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", ["cd", "ab"])   = 2
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", ["mn", "op"])   = -1
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", ["zab", "aby"]) = 1
	 * CMN_UTIL_String.indexOfAny("zzabyycdxx", [""])           = 0
	 * CMN_UTIL_String.indexOfAny("", [""])                     = 0
	 * CMN_UTIL_String.indexOfAny("", ["a"])                    = -1
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStrs the CharSequences to search for, may be null
	 *
	 * @return the first index of any of the searchStrs in str, -1 if no match
	 * @since 3.0 Changed signature from indexOfAny(String, String[]) to indexOfAny(CharSequence, CharSequence...)
	 */
	global static Integer indexOfAny(String str, String[] searchStrs)
	{
		if(str == null || searchStrs == null || searchStrs.size() == 0)
		{
			return -1;
		}
		Integer returnIndexOf = CMN_UTIL_Number.MAX_INTEGER;

		Integer currentIndexOf = 0;
		for(String searchStr : searchStrs)
		{
			if(searchStr == null)
			{
				continue;
			}
			currentIndexOf = str.indexOf(searchStr);
			if(currentIndexOf == -1)
			{
				continue;
			}

			if(currentIndexOf < returnIndexOf)
			{
				returnIndexOf = currentIndexOf;
			}
		}

		return (returnIndexOf == CMN_UTIL_Number.MAX_INTEGER) ? -1 : returnIndexOf;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode letters.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code false}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isAlpha(null)   = false
	 * CMN_UTIL_String.isAlpha("")     = false
	 * CMN_UTIL_String.isAlpha("  ")   = false
	 * CMN_UTIL_String.isAlpha("abc")  = true
	 * CMN_UTIL_String.isAlpha("ab2c") = false
	 * CMN_UTIL_String.isAlpha("ab-c") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains letters, and is non-null
	 * @since 3.0 Changed signature from isAlpha(String) to isAlpha(CharSequence)
	 * @since 3.0 Changed "" to return false and not true
	 */
	global static Boolean isAlpha(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer size = str.length();
		for(Integer i = 0; i < size; i++)
		{
			if(CMN_UTIL_Character.isLetter(charAt(str, i)) == false)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode letters and
	 * space (' ').</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}
	 * An empty CharSequence (length()=0) will return {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isAlphaSpace(null)   = false
	 * CMN_UTIL_String.isAlphaSpace("")     = true
	 * CMN_UTIL_String.isAlphaSpace("  ")   = true
	 * CMN_UTIL_String.isAlphaSpace("abc")  = true
	 * CMN_UTIL_String.isAlphaSpace("ab c") = true
	 * CMN_UTIL_String.isAlphaSpace("ab2c") = false
	 * CMN_UTIL_String.isAlphaSpace("ab-c") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains letters and space,
	 *  and is non-null
	 * @since 3.0 Changed signature from isAlphaSpace(String) to isAlphaSpace(CharSequence)
	 */
	global static Boolean isAlphaSpace(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(
					(CMN_UTIL_Character.isLetter(charAt(str, i)) == false) &&
							(charAt(str, i) != ' ')
					)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode letters or digits.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code false}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isAlphanumeric(null)   = false
	 * CMN_UTIL_String.isAlphanumeric("")     = false
	 * CMN_UTIL_String.isAlphanumeric("  ")   = false
	 * CMN_UTIL_String.isAlphanumeric("abc")  = true
	 * CMN_UTIL_String.isAlphanumeric("ab c") = false
	 * CMN_UTIL_String.isAlphanumeric("ab2c") = true
	 * CMN_UTIL_String.isAlphanumeric("ab-c") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains letters or digits,
	 *  and is non-null
	 * @since 3.0 Changed signature from isAlphanumeric(String) to isAlphanumeric(CharSequence)
	 * @since 3.0 Changed "" to return false and not true
	 */
	global static Boolean isAlphanumeric(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(CMN_UTIL_Character.isLetterOrDigit(charAt(str, i)) == false)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode letters, digits
	 * or space ({@code ' '}).</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isAlphanumericSpace(null)   = false
	 * CMN_UTIL_String.isAlphanumericSpace("")     = true
	 * CMN_UTIL_String.isAlphanumericSpace("  ")   = true
	 * CMN_UTIL_String.isAlphanumericSpace("abc")  = true
	 * CMN_UTIL_String.isAlphanumericSpace("ab c") = true
	 * CMN_UTIL_String.isAlphanumericSpace("ab2c") = true
	 * CMN_UTIL_String.isAlphanumericSpace("ab-c") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains letters, digits or space,
	 *  and is non-null
	 * @since 3.0 Changed signature from isAlphanumericSpace(String) to isAlphanumericSpace(CharSequence)
	 */
	global static Boolean isAlphanumericSpace(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(
					(CMN_UTIL_Character.isLetterOrDigit(charAt(str, i)) == false) &&
							(charAt(str, i) != ' ')
					)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only ASCII printable characters.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isAsciiPrintable(null)     = false
	 * CMN_UTIL_String.isAsciiPrintable("")       = true
	 * CMN_UTIL_String.isAsciiPrintable(" ")      = true
	 * CMN_UTIL_String.isAsciiPrintable("Ceki")   = true
	 * CMN_UTIL_String.isAsciiPrintable("ab2c")   = true
	 * CMN_UTIL_String.isAsciiPrintable("!ab-c~") = true
	 * CMN_UTIL_String.isAsciiPrintable("\u0020") = true
	 * CMN_UTIL_String.isAsciiPrintable("\u0021") = true
	 * CMN_UTIL_String.isAsciiPrintable("\u007e") = true
	 * CMN_UTIL_String.isAsciiPrintable("\u007f") = false
	 * CMN_UTIL_String.isAsciiPrintable("Ceki G\u00fclc\u00fc") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if every character is in the range
	 *  32 thru 126
	 * @since 2.1
	 * @since 3.0 Changed signature from isAsciiPrintable(String) to isAsciiPrintable(CharSequence)
	 */
	global static Boolean isAsciiPrintable(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(CMN_UTIL_Character.isAsciiPrintable(charAt(str, i)) == false)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode digits.
	 * A decimal point is not a Unicode digit and returns false.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code false}.</p>
	 * <p/>
	 * <p>Note that the method does not allow for a leading sign, either positive or negative.
	 * Also, if a String passes the numeric test, it may still generate a NumberFormatException
	 * when parsed by Integer.parseInt or Long.parseLong, e.g. if the value is outside the range
	 * for int or long respectively.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isNumeric(null)   = false
	 * CMN_UTIL_String.isNumeric("")     = false
	 * CMN_UTIL_String.isNumeric("  ")   = false
	 * CMN_UTIL_String.isNumeric("123")  = true
	 * CMN_UTIL_String.isNumeric("\u0967\u0968\u0969")  = true
	 * CMN_UTIL_String.isNumeric("12 3") = false
	 * CMN_UTIL_String.isNumeric("ab2c") = false
	 * CMN_UTIL_String.isNumeric("12-3") = false
	 * CMN_UTIL_String.isNumeric("12.3") = false
	 * CMN_UTIL_String.isNumeric("-123") = false
	 * CMN_UTIL_String.isNumeric("+123") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains digits, and is non-null
	 * @since 3.0 Changed signature from isNumeric(String) to isNumeric(CharSequence)
	 * @since 3.0 Changed "" to return false and not true
	 */
	global static Boolean isNumeric(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(CMN_UTIL_Character.isDigit(charAt(str, i)) == false)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only Unicode digits or space
	 * ({@code ' '}).
	 * A decimal point is not a Unicode digit and returns false.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isNumericSpace(null)   = false
	 * CMN_UTIL_String.isNumericSpace("")     = true
	 * CMN_UTIL_String.isNumericSpace("  ")   = true
	 * CMN_UTIL_String.isNumericSpace("123")  = true
	 * CMN_UTIL_String.isNumericSpace("12 3") = true
	 * CMN_UTIL_String.isNumeric("\u0967\u0968\u0969")  = true
	 * CMN_UTIL_String.isNumeric("\u0967\u0968 \u0969")  = true
	 * CMN_UTIL_String.isNumericSpace("ab2c") = false
	 * CMN_UTIL_String.isNumericSpace("12-3") = false
	 * CMN_UTIL_String.isNumericSpace("12.3") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains digits or space,
	 *  and is non-null
	 * @since 3.0 Changed signature from isNumericSpace(String) to isNumericSpace(CharSequence)
	 */
	global static Boolean isNumericSpace(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if(
					(CMN_UTIL_Character.isDigit(charAt(str, i)) == false) &&
							(charAt(str, i) != ' ')
					)
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if the CharSequence contains only whitespace.</p>
	 * <p/>
	 * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <p>{@code null} will return {@code false}.
	 * An empty CharSequence (length()=0) will return {@code true}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isWhitespace(null)   = false
	 * CMN_UTIL_String.isWhitespace("")     = true
	 * CMN_UTIL_String.isWhitespace("  ")   = true
	 * CMN_UTIL_String.isWhitespace("abc")  = false
	 * CMN_UTIL_String.isWhitespace("ab2c") = false
	 * CMN_UTIL_String.isWhitespace("ab-c") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if only contains whitespace, and is non-null
	 * @since 2.0
	 * @since 3.0 Changed signature from isWhitespace(String) to isWhitespace(CharSequence)
	 */
	global static Boolean isWhitespace(String str)
	{
		if(str == null)
		{
			return false;
		}
		Integer sz = str.length();
		for(Integer i = 0; i < sz; i++)
		{
			if((CMN_UTIL_Character.isWhitespace(charAt(str, i)) == false))
			{
				return false;
			}
		}
		return true;
	}

  /**
	 * @description <p>Checks if a CharSequence is empty (""), null or whitespace only.</p>
	 * <p/>
	 * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isBlank(null)      = true
	 * CMN_UTIL_String.isBlank("")        = true
	 * CMN_UTIL_String.isBlank(" ")       = true
	 * CMN_UTIL_String.isBlank("bob")     = false
	 * CMN_UTIL_String.isBlank("  bob  ") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if the CharSequence is null, empty or whitespace only
	 * @since 2.0
	 * @since 3.0 Changed signature from isBlank(String) to isBlank(CharSequence)
	 */
	global static Boolean isBlank(String str)
	{
		return str == null || str.trim() == null || str.trim().length() == 0;
	}

  /**
	 * @description <p>Checks if a CharSequence is not empty (""), not null and not whitespace only.</p>
	 * <p/>
	 * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isNotBlank(null)      = false
	 * CMN_UTIL_String.isNotBlank("")        = false
	 * CMN_UTIL_String.isNotBlank(" ")       = false
	 * CMN_UTIL_String.isNotBlank("bob")     = true
	 * CMN_UTIL_String.isNotBlank("  bob  ") = true
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if the CharSequence is
	 *  not empty and not null and not whitespace only
	 * @since 2.0
	 * @since 3.0 Changed signature from isNotBlank(String) to isNotBlank(CharSequence)
	 */
	global static Boolean isNotBlank(String str)
	{
		return !isBlank(str);
	}

  /**
	 * @description <p>Checks if a CharSequence is empty ("") or null.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isEmpty(null)      = true
	 * CMN_UTIL_String.isEmpty("")        = true
	 * CMN_UTIL_String.isEmpty(" ")       = false
	 * CMN_UTIL_String.isEmpty("bob")     = false
	 * CMN_UTIL_String.isEmpty("  bob  ") = false
	 * </pre>
	 * <p/>
	 * <p>NOTE: This method changed in Lang version 2.0.
	 * It no longer trims the CharSequence.
	 * That functionality is available in isBlank().</p>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if the CharSequence is empty or null
	 * @since 3.0 Changed signature from isEmpty(String) to isEmpty(CharSequence)
	 */
	global static Boolean isEmpty(String str)
	{
		return str == null || str.length() == 0;
	}

  /**
	 * @description <p>Checks if a CharSequence is not empty ("") and not null.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.isNotEmpty(null)      = false
	 * CMN_UTIL_String.isNotEmpty("")        = false
	 * CMN_UTIL_String.isNotEmpty(" ")       = true
	 * CMN_UTIL_String.isNotEmpty("bob")     = true
	 * CMN_UTIL_String.isNotEmpty("  bob  ") = true
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 *
	 * @return {@code true} if the CharSequence is not empty and not null
	 * @since 3.0 Changed signature from isNotEmpty(String) to isNotEmpty(CharSequence)
	 */
	global static Boolean isNotEmpty(String str)
	{
		return !isEmpty(str);
	}

  /**
	 * @description Join an array
	 *
	 * @param objectArray - The array to join
	 *
	 * @return The string containing the joined array
	 */
	global static String joinArray(Object[] objectArray)
	{
		return joinArray(objectArray, null);
	}

  /**
	 * @description <p>Joins the elements of the provided array into a single String
	 * containing the provided list of elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * Null objects or empty strings within the array are represented by
	 * empty strings.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.join(null, *)               = null
	 * CMN_UTIL_String.join([], *)                 = ""
	 * CMN_UTIL_String.join([null], *)             = ""
	 * CMN_UTIL_String.join(["a", "b", "c"], ';')  = "a;b;c"
	 * CMN_UTIL_String.join(["a", "b", "c"], null) = "abc"
	 * CMN_UTIL_String.join([null, "", "a"], ';')  = ";;a"
	 * </pre>
	 *
	 * @param objectArray the array of values to join together, may be null
	 * @param separator the separator character to use
	 *
	 * @return the joined String, {@code null} if null array input
	 * @since 2.0
	 */
	global static String joinArray(Object[] objectArray, String separator)
	{
		if(objectArray == null)
		{
			return null;
		}
		return joinArray(objectArray, separator, 0, objectArray.size());
	}

  /**
	 * @description <p>Joins the elements of the provided array into a single String
	 * containing the provided list of elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * Null objects or empty strings within the array are represented by
	 * empty strings.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.join(null, *)               = null
	 * CMN_UTIL_String.join([], *)                 = ""
	 * CMN_UTIL_String.join([null], *)             = ""
	 * CMN_UTIL_String.join(["a", "b", "c"], ';')  = "a;b;c"
	 * CMN_UTIL_String.join(["a", "b", "c"], null) = "abc"
	 * CMN_UTIL_String.join([null, "", "a"], ';')  = ";;a"
	 * </pre>
	 *
	 * @param objectArray the array of values to join together, may be null
	 * @param separator the separator character to use
	 * @param startIndex the first index to start joining from.  It is
	 * an error to pass in a start index past the end of the array
	 * @param endIndex the index to stop joining from (exclusive). It is
	 * an error to pass in an end index past the end of the array
	 *
	 * @return the joined String, {@code null} if null array input
	 * @since 2.0
	 */
	global static String joinArray(
			Object[] objectArray,
			String separator,
			Integer startIndex,
			Integer endIndex
	)
	{
		if(objectArray == null)
		{
			return null;
		}
		if(separator == null)
		{
			separator = EMPTY;
		}

		String buf = '';
		if(startIndex < 0)
		{
			startIndex = 0;
		}
		Boolean isFirst = true;
		for(Integer i = startIndex; i < endIndex && i < objectArray.size(); i++)
		{
			if(objectArray[i] != null)
			{
				if(isFirst)
				{
					isFirst = false;
				}
				else
				{
					buf += separator;
				}
				buf += objectArray[i];
			}
		}
		return buf;
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param strings the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinStrings(Set<String> strings, String separator)
	{
		return joinSet(strings, separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param blobSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Blob> blobSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.blobToObject(blobSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param booleanSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Boolean> booleanSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.booleanToObject(booleanSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param dateSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Date> dateSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.dateToObject(dateSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param datetimeSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Datetime> datetimeSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.datetimeToObject(datetimeSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param decimalSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Decimal> decimalSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.decimalToObject(decimalSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param doubleSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Double> doubleSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.doubleToObject(doubleSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param idSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Id> idSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.idToObject(idSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param integerSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Integer> integerSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.integerToObject(integerSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param longSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Long> longSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.longToObject(longSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param timeSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Time> timeSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.timeToObject(timeSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param stringSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<String> stringSet, String separator)
	{
		return joinSet(CMN_UTIL_Set.stringToObject(stringSet), separator);
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param objectSet the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinSet(Set<Object> objectSet, String separator)
	{
		if(objectSet == null || objectSet.size() == 0)
		{
			return null;
		}
		Boolean isFirst = true;
		String returnString = '';
		for(Object anObject : objectSet)
		{
			if(CMN_UTIL_String.isBlank('' + anObject))
			{
				continue;
			}
			if(isFirst)
			{
				isFirst = false;
			}
			else
			{
				if(separator != null)
				{
					returnString += separator;
				}
			}
			if(anObject instanceof Blob)
			{
				returnString += '' + ((Blob)anObject).toString() + '';
			}
			else if(anObject instanceof Boolean)
			{
				returnString += ((Boolean)anObject);
			}
			else if(anObject instanceof Date)
			{
				returnString += '' + ((Date)anObject) + '';
			}
			else if(anObject instanceof Datetime)
			{
				returnString += '' + ((Datetime)anObject) + '';
			}
			else if(anObject instanceof Integer)
			{
				returnString += ((Integer)anObject);
			}
			else if(anObject instanceof Long)
			{
				returnString += ((Long)anObject);
			}
			else if(anObject instanceof Decimal)
			{
				returnString += ((Decimal)anObject);
			}
			else if(anObject instanceof String)
			{
				returnString += '' + ((String)anObject) + '';
			}
			else if(anObject instanceof Time)
			{
				returnString += '' + ((Time)anObject) + '';
			}
		}
		return returnString;
	}

  /**
	 * @description <p>Joins the elements of the provided {@code Iterator} into
	 * a single String containing the provided elements.</p>
	 * <p/>
	 * <p>No delimiter is added before or after the list.
	 * A {@code null} separator is the same as an empty String ("").</p>
	 * <p/>
	 * <p>See the examples here: {@link #join(Object[],String)}. </p>
	 *
	 * @param strings the {@code Iterator} of values to join together, may be null
	 * @param separator the separator character to use, null treated as ""
	 *
	 * @return the joined String, {@code null} if null iterator input
	 */
	global static String joinStrings(List<String> strings, String separator)
	{
		if(strings == null || strings.size() == 0)
		{
			return null;
		}
		Set<String> setToJoin = new Set<String>();
		for(String value : strings)
		{
			setToJoin.add(value);
		}
		return joinStrings(setToJoin, separator);
	}

  /**
	 * @description <p>Finds the last index within a CharSequence, handling {@code null}.
	 * This method uses {@link String#lastIndexOf(String)} if possible.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.lastIndexOf(null, *)          = -1
	 * CMN_UTIL_String.lastIndexOf(*, null)          = -1
	 * CMN_UTIL_String.lastIndexOf("", "")           = 0
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "a")  = 7
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b")  = 5
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "ab") = 4
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "")   = 8
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 *
	 * @return the last index of the search String,
	 *  -1 if no match or {@code null} string input
	 * @since 2.0
	 * @since 3.0 Changed signature from lastIndexOf(String, String) to lastIndexOf(CharSequence, CharSequence)
	 */
	global static Integer lastIndexOf(String str, String searchStr)
	{
		if(str == null || searchStr == null)
		{
			return -1;
		}
		return str.lastIndexOf(searchStr);
	}

  /**
	 * @description <p>Finds the last index within a CharSequence, handling {@code null}.
	 * This method uses {@link String#lastIndexOf(String, int)} if possible.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.
	 * A negative start position returns {@code -1}.
	 * An empty ("") search CharSequence always matches unless the start position is negative.
	 * A start position greater than the string length searches the whole string.
	 * The search starts at the startPos and works backwards; matches starting after the start
	 * position are ignored.
	 * </p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.lastIndexOf(null, *, *)          = -1
	 * CMN_UTIL_String.lastIndexOf(*, null, *)          = -1
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "a", 8)  = 7
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", 8)  = 5
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "ab", 8) = 4
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", 9)  = 5
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", -1) = -1
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "a", 0)  = 0
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", 0)  = -1
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", 1)  = -1
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "b", 2)  = 2
	 * CMN_UTIL_String.lastIndexOf("aabaabaa", "ba", 2)  = 2
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStr the CharSequence to find, may be null
	 * @param startPos the start position, negative treated as zero
	 *
	 * @return the last index of the search CharSequence (always &le; startPos),
	 *  -1 if no match or {@code null} string input
	 * @since 2.0
	 * @since 3.0 Changed signature from lastIndexOf(String, String, int) to lastIndexOf(CharSequence, CharSequence, int)
	 */
	global static Integer lastIndexOf(
			String str,
			String searchStr,
			Integer startPos
	)
	{
		if(str == null || searchStr == null || startPos < 0)
		{
			return -1;
		}
		return lastIndexOf(substring(str, 0, startPos + 1), searchStr);
	}

  /**
	 * @description <p>Find the latest index of any of a set of potential substrings.</p>
	 * <p/>
	 * <p>A {@code null} CharSequence will return {@code -1}.
	 * A {@code null} search array will return {@code -1}.
	 * A {@code null} or zero length search array entry will be ignored,
	 * but a search array containing "" will return the length of {@code str}
	 * if {@code str} is not null. This method uses {@link String#indexOf(String)} if possible</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.lastIndexOfAny(null, *)                    = -1
	 * CMN_UTIL_String.lastIndexOfAny(*, null)                    = -1
	 * CMN_UTIL_String.lastIndexOfAny(*, [])                      = -1
	 * CMN_UTIL_String.lastIndexOfAny(*, [null])                  = -1
	 * CMN_UTIL_String.lastIndexOfAny("zzabyycdxx", ["ab", "cd"]) = 6
	 * CMN_UTIL_String.lastIndexOfAny("zzabyycdxx", ["cd", "ab"]) = 6
	 * CMN_UTIL_String.lastIndexOfAny("zzabyycdxx", ["mn", "op"]) = -1
	 * CMN_UTIL_String.lastIndexOfAny("zzabyycdxx", ["mn", "op"]) = -1
	 * CMN_UTIL_String.lastIndexOfAny("zzabyycdxx", ["mn", ""])   = 10
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param searchStrs the CharSequences to search for, may be null
	 *
	 * @return the last index of any of the CharSequences, -1 if no match
	 * @since 3.0 Changed signature from lastIndexOfAny(String, String[]) to lastIndexOfAny(CharSequence, CharSequence)
	 */
	global static Integer lastIndexOfAny(String str, String[] searchStrs)
	{
		if((str == null) || (searchStrs == null))
		{
			return -1;
		}
		Integer sz = searchStrs.size();
		Integer ret = -1;
		Integer tmp = 0;
		for(Integer i = 0; i < sz; i++)
		{
			String searchStr = searchStrs[i];
			if(searchStr == null)
			{
				continue;
			}
			tmp = str.lastIndexOf(searchStr);
			if(tmp > ret)
			{
				ret = tmp;
			}
		}
		return ret;
	}

  /**
	 * @description <p>Gets the leftmost {@code len} characters of a String.</p>
	 * <p/>
	 * <p>If {@code len} characters are not available, or the
	 * String is {@code null}, the String will be returned without
	 * an exception. An empty String is returned if len is negative.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.left(null, *)    = null
	 * CMN_UTIL_String.left(*, -ve)     = ""
	 * CMN_UTIL_String.left("", *)      = ""
	 * CMN_UTIL_String.left("abc", 0)   = ""
	 * CMN_UTIL_String.left("abc", 2)   = "ab"
	 * CMN_UTIL_String.left("abc", 4)   = "abc"
	 * </pre>
	 *
	 * @param str the String to get the leftmost characters from, may be null
	 * @param len the length of the required String
	 *
	 * @return the leftmost characters, {@code null} if null String input
	 */
	global static String left(String str, Integer len)
	{
		if(str == null)
		{
			return null;
		}
		if(len < 0)
		{
			return EMPTY;
		}
		if(str.length() <= len)
		{
			return str;
		}
		return str.substring(0, len);
	}

  /**
	 * @description <p>Gets {@code len} characters from the middle of a String.</p>
	 * <p/>
	 * <p>If {@code len} characters are not available, the remainder
	 * of the String will be returned without an exception. If the
	 * String is {@code null}, {@code null} will be returned.
	 * An empty String is returned if len is negative or exceeds the
	 * length of {@code str}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.mid(null, *, *)    = null
	 * CMN_UTIL_String.mid(*, *, -ve)     = ""
	 * CMN_UTIL_String.mid("", 0, *)      = ""
	 * CMN_UTIL_String.mid("abc", 0, 2)   = "ab"
	 * CMN_UTIL_String.mid("abc", 0, 4)   = "abc"
	 * CMN_UTIL_String.mid("abc", 2, 4)   = "c"
	 * CMN_UTIL_String.mid("abc", 4, 2)   = ""
	 * CMN_UTIL_String.mid("abc", -2, 2)  = "ab"
	 * </pre>
	 *
	 * @param str the String to get the characters from, may be null
	 * @param pos the position to start from, negative treated as zero
	 * @param len the length of the required String
	 *
	 * @return the middle characters, {@code null} if null String input
	 */
	global static String mid(String str, Integer pos, Integer len)
	{
		if(str == null)
		{
			return null;
		}
		if(len < 0 || pos >= str.length())
		{
			return EMPTY;
		}
		if(pos < 0)
		{
			pos = 0;
		}
		if(str.length() <= (pos + len))
		{
			return str.substring(pos);
		}
		return str.substring(pos, pos + len);
	}

  /**
	 * @description <p>Overlays part of a String with another String.</p>
	 * <p/>
	 * <p>A {@code null} string input returns {@code null}.
	 * A negative index is treated as zero.
	 * An index greater than the string length is treated as the string length.
	 * The start index is always the smaller of the two indices.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.overlay(null, *, *, *)            = null
	 * CMN_UTIL_String.overlay("", "abc", 0, 0)          = "abc"
	 * CMN_UTIL_String.overlay("abcdef", null, 2, 4)     = "abef"
	 * CMN_UTIL_String.overlay("abcdef", "", 2, 4)       = "abef"
	 * CMN_UTIL_String.overlay("abcdef", "", 4, 2)       = "abef"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", 2, 4)   = "abzzzzef"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", 4, 2)   = "abzzzzef"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", -1, 4)  = "zzzzef"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", 2, 8)   = "abzzzz"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", -2, -3) = "zzzzabcdef"
	 * CMN_UTIL_String.overlay("abcdef", "zzzz", 8, 10)  = "abcdefzzzz"
	 * </pre>
	 *
	 * @param str the String to do overlaying in, may be null
	 * @param overlay the String to overlay, may be null
	 * @param startIndex the position to start overlaying at
	 * @param endIndex the position to stop overlaying before
	 *
	 * @return overlayed String, {@code null} if null String input
	 * @since 2.0
	 */
	global static String overlay(
			String str,
			String overlay,
			Integer startIndex,
			Integer endIndex
	)
	{
		//'', 'abc', 0, 0
		if(str == null)
		{
			return null;
		}
		if(overlay == null)
		{
			overlay = EMPTY;
		}
		Integer len = str.length();
		if(startIndex < 0)
		{
			startIndex = 0;
		}
		if(startIndex > len)
		{
			startIndex = len;
		}
		if(endIndex < 0)
		{
			endIndex = 0;
		}
		if(endIndex > len)
		{
			endIndex = len;
		}
		if(startIndex > endIndex)
		{
			Integer temp = startIndex;
			startIndex = endIndex;
			endIndex = temp;
		}
		return new CMN_UTIL_StringBuffer()
				.append(substring(str, 0, startIndex))
				.append(overlay)
				.append(substring(str, endIndex))
				.toStr();
	}

  /**
	 * @description <p>Left pad a String with spaces (' ').</p>
	 * <p/>
	 * <p>The String is padded to the size of {@code size}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.leftPad(null, *)   = null
	 * CMN_UTIL_String.leftPad("", 3)     = "   "
	 * CMN_UTIL_String.leftPad("bat", 3)  = "bat"
	 * CMN_UTIL_String.leftPad("bat", 5)  = "  bat"
	 * CMN_UTIL_String.leftPad("bat", 1)  = "bat"
	 * CMN_UTIL_String.leftPad("bat", -1) = "bat"
	 * </pre>
	 *
	 * @param str the String to pad out, may be null
	 * @param size the size to pad to
	 *
	 * @return left padded String or original String if no padding is necessary,
	 *  {@code null} if null String input
	 */
	global static String leftPad(String str, Integer size)
	{
		return leftPad(str, size, ' ');
	}

  /**
	 * @description <p>Left pad a String with a specified String.</p>
	 * <p/>
	 * <p>Pad to a size of {@code size}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.leftPad(null, *, *)      = null
	 * CMN_UTIL_String.leftPad("", 3, "z")      = "zzz"
	 * CMN_UTIL_String.leftPad("bat", 3, "yz")  = "bat"
	 * CMN_UTIL_String.leftPad("bat", 5, "yz")  = "yzbat"
	 * CMN_UTIL_String.leftPad("bat", 8, "yz")  = "yzyzybat"
	 * CMN_UTIL_String.leftPad("bat", 1, "yz")  = "bat"
	 * CMN_UTIL_String.leftPad("bat", -1, "yz") = "bat"
	 * CMN_UTIL_String.leftPad("bat", 5, null)  = "  bat"
	 * CMN_UTIL_String.leftPad("bat", 5, "")    = "  bat"
	 * </pre>
	 *
	 * @param str the String to pad out, may be null
	 * @param size the size to pad to
	 * @param padStr the String to pad with, null or empty treated as single space
	 *
	 * @return left padded String or original String if no padding is necessary,
	 *  {@code null} if null String input
	 */
	global static String leftPad(String str, Integer size, String padStr)
	{
		if(str == null)
		{
			return null;
		}
		if(isEmpty(padStr))
		{
			padStr = ' ';
		}
		Integer padLen = padStr.length();
		Integer strLen = str.length();
		Integer padCharCount = size - strLen;
		if(padCharCount <= 0)
		{
			return str;
		}
		if(padCharCount == padLen)
		{
			return padStr + str;
		}
		else if(padCharCount < padLen)
		{
			return padStr.substring(0, padCharCount) + str;
		}
		else
		{
			String padding = '';
			for(Integer i = 0; i < padCharCount; i++)
			{
				padding += padStr.substring(
						Math.mod(i, padLen),
						Math.mod(i, padLen) + 1
				);
			}
			return padding + str;
		}
	}

  /**
	 * @description Gets a CharSequence length or {@code 0} if the CharSequence is
	 * {@code null}.
	 *
	 * @param str a CharSequence or {@code null}
	 *
	 * @return CharSequence length or {@code 0} if the CharSequence is
	 *         {@code null}.
	 * @since 2.4
	 * @since 3.0 Changed signature from length(String) to length(CharSequence)
	 */
	global static Integer length(String str)
	{
		return str == null ? 0 : str.length();
	}

  /**
	 * @description <p>Converts a String to lower case as per {@link String#toLowerCase()}.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.lowerCase(null)  = null
	 * CMN_UTIL_String.lowerCase("")    = ""
	 * CMN_UTIL_String.lowerCase("aBc") = "abc"
	 * </pre>
	 * <p/>
	 * <p><strong>Note:</strong> As described in the documentation for {@link String#toLowerCase()},
	 * the result of this method is affected by the current locale.
	 * For platform-independent case transformations, the method {@link #lowerCase(String, Locale)}
	 * should be used with a specific locale (e.g. {@link Locale#ENGLISH}).</p>
	 *
	 * @param str the String to lower case, may be null
	 *
	 * @return the lower cased String, {@code null} if null String input
	 */
	global static String lowerCase(String str)
	{
		if(str == null)
		{
			return null;
		}
		return str.toLowerCase();
	}

  /**
	 * @description <p>Removes all occurrences of a substring from within the source string.</p>
	 * <p/>
	 * <p>A {@code null} source string will return {@code null}.
	 * An empty ("") source string will return the empty string.
	 * A {@code null} remove string will return the source string.
	 * An empty ("") remove string will return the source string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.remove(null, *)        = null
	 * CMN_UTIL_String.remove("", *)          = ""
	 * CMN_UTIL_String.remove(*, null)        = *
	 * CMN_UTIL_String.remove(*, "")          = *
	 * CMN_UTIL_String.remove("queued", "ue") = "qd"
	 * CMN_UTIL_String.remove("queued", "zz") = "queued"
	 * </pre>
	 *
	 * @param str the source String to search, may be null
	 * @param remove the String to search for and remove, may be null
	 *
	 * @return the substring with the string removed if found,
	 *  {@code null} if null String input
	 * @since 2.1
	 */
	global static String remove(String str, String remove)
	{
		if(isEmpty(str) || isEmpty(remove))
		{
			return str;
		}
		return replace(str, remove, EMPTY, -1);
	}

  /**
	 * @description <p>Removes a substring only if it is at the beginning of a source string,
	 * otherwise returns the source string.</p>
	 * <p/>
	 * <p>A {@code null} source string will return {@code null}.
	 * An empty ("") source string will return the empty string.
	 * A {@code null} search string will return the source string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.removeStart(null, *)      = null
	 * CMN_UTIL_String.removeStart("", *)        = ""
	 * CMN_UTIL_String.removeStart(*, null)      = *
	 * CMN_UTIL_String.removeStart("www.domain.com", "www.")   = "domain.com"
	 * CMN_UTIL_String.removeStart("domain.com", "www.")       = "domain.com"
	 * CMN_UTIL_String.removeStart("www.domain.com", "domain") = "www.domain.com"
	 * CMN_UTIL_String.removeStart("abc", "")    = "abc"
	 * </pre>
	 *
	 * @param str the source String to search, may be null
	 * @param remove the String to search for and remove, may be null
	 *
	 * @return the substring with the string removed if found,
	 *  {@code null} if null String input
	 * @since 2.1
	 */
	global static String removeStart(String str, String remove)
	{
		if(isEmpty(str) || isEmpty(remove))
		{
			return str;
		}
		if(str.startsWith(remove))
		{
			if(remove.length() >= str.length())
			{
				return '';
			}
			else
			{
				return str.substring(remove.length());
			}
		}
		return str;
	}

  /**
	 * @description <p>Case insensitive removal of a substring if it is at the beginning of a source string,
	 * otherwise returns the source string.</p>
	 * <p/>
	 * <p>A {@code null} source string will return {@code null}.
	 * An empty ("") source string will return the empty string.
	 * A {@code null} search string will return the source string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.removeStartIgnoreCase(null, *)      = null
	 * CMN_UTIL_String.removeStartIgnoreCase("", *)        = ""
	 * CMN_UTIL_String.removeStartIgnoreCase(*, null)      = *
	 * CMN_UTIL_String.removeStartIgnoreCase("www.domain.com", "www.")   = "domain.com"
	 * CMN_UTIL_String.removeStartIgnoreCase("www.domain.com", "WWW.")   = "domain.com"
	 * CMN_UTIL_String.removeStartIgnoreCase("domain.com", "www.")       = "domain.com"
	 * CMN_UTIL_String.removeStartIgnoreCase("www.domain.com", "domain") = "www.domain.com"
	 * CMN_UTIL_String.removeStartIgnoreCase("abc", "")    = "abc"
	 * </pre>
	 *
	 * @param str the source String to search, may be null
	 * @param remove the String to search for (case insensitive) and remove, may be null
	 *
	 * @return the substring with the string removed if found,
	 *  {@code null} if null String input
	 * @since 2.4
	 */
	global static String removeStartIgnoreCase(String str, String remove)
	{
		if(isEmpty(str) || isEmpty(remove))
		{
			return str;
		}
		if(startsWithIgnoreCase(str, remove))
		{
			return str.substring(remove.length());
		}
		return str;
	}

  /**
	 * @description <p>Removes a substring only if it is at the end of a source string,
	 * otherwise returns the source string.</p>
	 * <p/>
	 * <p>A {@code null} source string will return {@code null}.
	 * An empty ("") source string will return the empty string.
	 * A {@code null} search string will return the source string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.removeEnd(null, *)      = null
	 * CMN_UTIL_String.removeEnd("", *)        = ""
	 * CMN_UTIL_String.removeEnd(*, null)      = *
	 * CMN_UTIL_String.removeEnd("www.domain.com", ".com.")  = "www.domain.com"
	 * CMN_UTIL_String.removeEnd("www.domain.com", ".com")   = "www.domain"
	 * CMN_UTIL_String.removeEnd("www.domain.com", "domain") = "www.domain.com"
	 * CMN_UTIL_String.removeEnd("abc", "")    = "abc"
	 * </pre>
	 *
	 * @param str the source String to search, may be null
	 * @param remove the String to search for and remove, may be null
	 *
	 * @return the substring with the string removed if found,
	 *  {@code null} if null String input
	 * @since 2.1
	 */
	global static String removeEnd(String str, String remove)
	{
		if(isEmpty(str) || isEmpty(remove))
		{
			return str;
		}
		if(str.endsWith(remove))
		{
			return str.substring(0, str.length() - remove.length());
		}
		return str;
	}

  /**
	 * @description <p>Case insensitive removal of a substring if it is at the end of a source string,
	 * otherwise returns the source string.</p>
	 * <p/>
	 * <p>A {@code null} source string will return {@code null}.
	 * An empty ("") source string will return the empty string.
	 * A {@code null} search string will return the source string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.removeEndIgnoreCase(null, *)      = null
	 * CMN_UTIL_String.removeEndIgnoreCase("", *)        = ""
	 * CMN_UTIL_String.removeEndIgnoreCase(*, null)      = *
	 * CMN_UTIL_String.removeEndIgnoreCase("www.domain.com", ".com.")  = "www.domain.com"
	 * CMN_UTIL_String.removeEndIgnoreCase("www.domain.com", ".com")   = "www.domain"
	 * CMN_UTIL_String.removeEndIgnoreCase("www.domain.com", "domain") = "www.domain.com"
	 * CMN_UTIL_String.removeEndIgnoreCase("abc", "")    = "abc"
	 * CMN_UTIL_String.removeEndIgnoreCase("www.domain.com", ".COM") = "www.domain")
	 * CMN_UTIL_String.removeEndIgnoreCase("www.domain.COM", ".com") = "www.domain")
	 * </pre>
	 *
	 * @param str the source String to search, may be null
	 * @param remove the String to search for (case insensitive) and remove, may be null
	 *
	 * @return the substring with the string removed if found,
	 *  {@code null} if null String input
	 * @since 2.4
	 */
	global static String removeEndIgnoreCase(String str, String remove)
	{
		if(isEmpty(str) || isEmpty(remove))
		{
			return str;
		}
		if(endsWithIgnoreCase(str, remove))
		{
			return str.substring(0, str.length() - remove.length());
		}
		return str;
	}

  /**
	 * @description <p>Repeat a String {@code repeat} times to form a
	 * new String.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.repeat(null, 2) = null
	 * CMN_UTIL_String.repeat("", 0)   = ""
	 * CMN_UTIL_String.repeat("", 2)   = ""
	 * CMN_UTIL_String.repeat("a", 3)  = "aaa"
	 * CMN_UTIL_String.repeat("ab", 2) = "abab"
	 * CMN_UTIL_String.repeat("a", -2) = ""
	 * </pre>
	 *
	 * @param str the String to repeat, may be null
	 * @param repeat number of times to repeat str, negative treated as zero
	 *
	 * @return a new String consisting of the original String repeated,
	 *  {@code null} if null String input
	 */
	global static String repeat(String str, Integer repeat)
	{
		if(str == null)
		{
			return null;
		}
		if(repeat <= 0)
		{
			return EMPTY;
		}
		Integer inputLength = str.length();
		if(repeat == 1 || inputLength == 0)
		{
			return str;
		}
		if(inputLength == 1 && repeat <= PAD_LIMIT)
		{
			return padding(repeat, charAt(str, 0));
		}

		String buf = '';
		for(Integer i = 0; i < repeat; i++)
		{
			buf += str;
		}
		return buf;
	}

  /**
	 * @description padding for integer based input
	 *
	 * @param repeat as input
	 * @param padChar as input
	 *
	 * @return padded string
	 */
	private static String padding(Integer repeat, String padChar)
	{
		String buf = '';
		for(Integer i = 0; i < repeat; i++)
		{
			buf += padChar;
		}
		return buf;
	}

  /**
	 * @description <p>Replaces all occurrences of a String within another String.</p>
	 * <p/>
	 * <p>A {@code null} reference passed to this method is a no-op.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.replace(null, *, *)        = null
	 * CMN_UTIL_String.replace("", *, *)          = ""
	 * CMN_UTIL_String.replace("any", null, *)    = "any"
	 * CMN_UTIL_String.replace("any", *, null)    = "any"
	 * CMN_UTIL_String.replace("any", "", *)      = "any"
	 * CMN_UTIL_String.replace("aba", "a", null)  = "aba"
	 * CMN_UTIL_String.replace("aba", "a", "")    = "b"
	 * CMN_UTIL_String.replace("aba", "a", "z")   = "zbz"
	 * </pre>
	 *
	 * @param text text to search and replace in, may be null
	 * @param searchString the String to search for, may be null
	 * @param replacement the String to replace it with, may be null
	 *
	 * @return the text with any replacements processed,
	 *  {@code null} if null String input
	 */
	global static String replace(
			String text,
			String searchString,
			String replacement
	)
	{
		return replace(text, searchString, replacement, -1);
	}

  /**
	 * @description replace but only one found instance
	 *
	 * @param text as input
	 * @param searchString as input
	 * @param replacement as input
	 *
	 * @return single replaced string
	 */
	global static String replaceOnce(
			String text,
			String searchString,
			String replacement
	)
	{
		return replace(text, searchString, replacement, 1);
	}

  /**
	 * @description <p>Replaces a String with another String inside a larger String,
	 * for the first {@code max} values of the search String.</p>
	 * <p/>
	 * <p>A {@code null} reference passed to this method is a no-op.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.replace(null, *, *, *)         = null
	 * CMN_UTIL_String.replace("", *, *, *)           = ""
	 * CMN_UTIL_String.replace("any", null, *, *)     = "any"
	 * CMN_UTIL_String.replace("any", *, null, *)     = "any"
	 * CMN_UTIL_String.replace("any", "", *, *)       = "any"
	 * CMN_UTIL_String.replace("any", *, *, 0)        = "any"
	 * CMN_UTIL_String.replace("abaa", "a", null, -1) = "abaa"
	 * CMN_UTIL_String.replace("abaa", "a", "", -1)   = "b"
	 * CMN_UTIL_String.replace("abaa", "a", "z", 0)   = "abaa"
	 * CMN_UTIL_String.replace("abaa", "a", "z", 1)   = "zbaa"
	 * CMN_UTIL_String.replace("abaa", "a", "z", 2)   = "zbza"
	 * CMN_UTIL_String.replace("abaa", "a", "z", -1)  = "zbzz"
	 * </pre>
	 *
	 * @param text text to search and replace in, may be null
	 * @param searchString the String to search for, may be null
	 * @param replacement the String to replace it with, may be null
	 * @param max maximum number of values to replace, or {@code -1} if no maximum
	 *
	 * @return the text with any replacements processed {@code null} if null String input
	 */
	global static String replace(
			String text,
			String searchString,
			String replacement,
			Integer max
	)
	{
		if(
				isEmpty(text) ||
						isEmpty(searchString) ||
						replacement == null ||
						max == 0
				)
		{
			return text;
		}
		Integer startIndex = 0;
		Integer endIndex = indexOf(text, searchString, startIndex);
		if(endIndex == -1)
		{
			return text;
		}
		Integer replLength = searchString.length();
		Integer increase = replacement.length() - replLength;
		increase = (increase < 0 ? 0 : increase);
		increase *= (max < 0 ? 16 : (max > 64 ? 64 : max));
		CMN_UTIL_StringBuffer buf = new CMN_UTIL_StringBuffer();
		while(endIndex != -1)
		{
			buf.append(substring(text, startIndex, endIndex)).append(replacement);
			startIndex = endIndex + replLength;
			if(--max == 0)
			{
				break;
			}
			endIndex = indexOf(text, searchString, startIndex);
		}
		buf.append(substring(text, startIndex));
		return buf.toStr();
	}

  /**
	 * @description <p>
	 * Replaces all occurrences of Strings within another String.
	 * </p>
	 * <p/>
	 * <p>
	 * A {@code null} reference passed to this method is a no-op, or if
	 * any "search string" or "string to replace" is null, that replace will be
	 * ignored. This will not repeat. For repeating replaces, call the
	 * overloaded method.
	 * </p>
	 * <p/>
	 * <pre>
	 *  CMN_UTIL_String.replaceEach(null, *, *)        = null
	 *  CMN_UTIL_String.replaceEach("", *, *)          = ""
	 *  CMN_UTIL_String.replaceEach("aba", null, null) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[0], null) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", null, new String[0]) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{"a"}, null)  = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{"a"}, new String[]{""})  = "b"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{null}, new String[]{"a"})  = "aba"
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"w", "t"})  = "wcte"
	 *  (example of how it does not repeat)
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"})  = "dcte"
	 * </pre>
	 *
	 * @param text text to search and replace in, no-op if null
	 * @param searchList the Strings to search for, no-op if null
	 * @param replacementList the Strings to replace them with, no-op if null
	 *
	 * @return the text with any replacements processed, {@code null} if
	 *         null String input
	 * @throws IllegalArgumentException
	 *             if the lengths of the arrays are not the same (null is ok,
	 *             and/or size 0)
	 * @since 2.4
	 */
	global static String replaceEach(
			String text,
			String[] searchList,
			String[] replacementList
	)
	{
		return replaceEach(text, searchList, replacementList, false, 0);
	}

  /**
	 * @description <p>
	 * Replaces all occurrences of Strings within another String.
	 * </p>
	 * <p/>
	 * <p>
	 * A {@code null} reference passed to this method is a no-op, or if
	 * any "search string" or "string to replace" is null, that replace will be
	 * ignored.
	 * </p>
	 * <p/>
	 * <pre>
	 *  CMN_UTIL_String.replaceEachRepeatedly(null, *, *) = null
	 *  CMN_UTIL_String.replaceEachRepeatedly("", *, *) = ""
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", null, null) = "aba"
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", new String[0], null) = "aba"
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", null, new String[0]) = "aba"
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", new String[]{"a"}, null) = "aba"
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", new String[]{"a"}, new String[]{""}) = "b"
	 *  CMN_UTIL_String.replaceEachRepeatedly("aba", new String[]{null}, new String[]{"a"}) = "aba"
	 *  CMN_UTIL_String.replaceEachRepeatedly("abcde", new String[]{"ab", "d"}, new String[]{"w", "t"}) = "wcte"
	 *  (example of how it repeats)
	 *  CMN_UTIL_String.replaceEachRepeatedly("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"}) = "tcte"
	 *  CMN_UTIL_String.replaceEachRepeatedly("abcde", new String[]{"ab", "d"}, new String[]{"d", "ab"}) = IllegalStateException
	 * </pre>
	 *
	 * @param text text to search and replace in, no-op if null
	 * @param searchList the Strings to search for, no-op if null
	 * @param replacementList the Strings to replace them with, no-op if null
	 * @param repeat if replacement should repeat or not
	 *
	 * @return the text with any replacements processed, {@code null} if
	 *         null String input
	 * @throws IllegalStateException
	 *             if the search is repeating and there is an endless loop due
	 *             to outputs of one being inputs to another
	 * @throws IllegalArgumentException
	 *             if the lengths of the arrays are not the same (null is ok,
	 *             and/or size 0)
	 * @since 2.4
	 */
	global static String replaceEachRepeatedly(
			String text,
			String[] searchList,
			String[] replacementList,
			Boolean repeat
	)
	{
		Integer timeToLive = 0;
		if(searchList != null)
		{
			timeToLive = searchList.size();
		}
		return replaceEach(text, searchList, replacementList, repeat, timeToLive);
	}

  /**
	 * @description <p>
	 * Replace all occurrences of Strings within another String.
	 * This is a private recursive helper method for {@link #replaceEachRepeatedly(String, String[], String[])} and
	 * {@link #replaceEach(String, String[], String[])}
	 * </p>
	 * <p/>
	 * <p>
	 * A {@code null} reference passed to this method is a no-op, or if
	 * any "search string" or "string to replace" is null, that replace will be
	 * ignored.
	 * </p>
	 * <p/>
	 * <pre>
	 *  CMN_UTIL_String.replaceEach(null, *, *, *, *) = null
	 *  CMN_UTIL_String.replaceEach("", *, *, *, *) = ""
	 *  CMN_UTIL_String.replaceEach("aba", null, null, *, *) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[0], null, *, *) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", null, new String[0], *, *) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{"a"}, null, *, *) = "aba"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{"a"}, new String[]{""}, *, >=0) = "b"
	 *  CMN_UTIL_String.replaceEach("aba", new String[]{null}, new String[]{"a"}, *, >=0) = "aba"
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"w", "t"}, *, >=0) = "wcte"
	 *  (example of how it repeats)
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"}, false, >=0) = "dcte"
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"}, true, >=2) = "tcte"
	 *  CMN_UTIL_String.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "ab"}, *, *) = IllegalStateException
	 * </pre>
	 *
	 * @param text text to search and replace in, no-op if null
	 * @param searchList the Strings to search for, no-op if null
	 * @param replacementList the Strings to replace them with, no-op if null
	 * @param repeat if true, then replace repeatedly
	 *       until there are no more possible replacements or timeToLive < 0
	 * @param timeToLive if less than 0 then there is a circular reference and endless
	 *            loop
	 *
	 * @return the text with any replacements processed, {@code null} if
	 *         null String input
	 * @throws IllegalStateException
	 *             if the search is repeating and there is an endless loop due
	 *             to outputs of one being inputs to another
	 * @throws IllegalArgumentException
	 *             if the lengths of the arrays are not the same (null is ok,
	 *             and/or size 0)
	 * @since 2.4
	 */
	global static String replaceEach(
			String text,
			String[] searchList,
			String[] replacementList,
			Boolean repeat,
			Integer timeToLive
	)
	{
		// Performance note: This creates very few new objects (one major goal)
		// let me know if there are performance requests, we can create a harness to measure

		if(
				text == null ||
						text.length() == 0 ||
						searchList == null ||
						searchList.size() == 0 ||
						replacementList == null ||
						replacementList.size() == 0
				)
		{
			return text;
		}

		// if recursing, this shouldn't be less than 0
		if(timeToLive < 0)
		{
			throw new CMN_UTIL_Exceptions.IllegalStateException(
					'TimeToLive of ' +
							timeToLive +
							' is less than 0: ' +
							text
			);
		}

		Integer searchLength = searchList.size();
		Integer replacementLength = replacementList.size();

		// make sure lengths are ok, these need to be equal
		if(searchLength != replacementLength)
		{
			throw new IllegalArgumentException(
					'Search and Replace array lengths don\'t match: ' +
							searchLength +
							' vs ' +
							replacementLength
			);
		}

		// keep track of which still have matches
		Boolean[] noMoreMatchesForReplIndex = new List<Boolean>(searchLength);
		for(Integer i = 0; i < noMoreMatchesForReplIndex.size(); i++)
		{
			noMoreMatchesForReplIndex[i] = false;
		}

		// index on index that the match was found
		Integer textIndex = -1;
		Integer replaceIndex = -1;
		Integer tempIndex = -1;

		// index of replace array that will replace the search string found
		// NOTE: logic duplicated below START
		for(Integer i = 0; i < searchLength; i++)
		{
			if(
					noMoreMatchesForReplIndex[i] ||
							searchList[i] == null ||
							searchList[i].length() == 0 ||
							replacementList[i] == null
					)
			{
				continue;
			}
			tempIndex = indexOf(text, searchList[i]);

			// see if we need to keep searching for this
			if(tempIndex == -1)
			{
				noMoreMatchesForReplIndex[i] = true;
			}
			else
			{
				if(textIndex == -1 || tempIndex < textIndex)
				{
					textIndex = tempIndex;
					replaceIndex = i;
				}
			}
		}
		// NOTE: logic mostly below END

		// no search strings found, we are done
		if(textIndex == -1)
		{
			return text;
		}

		Integer start = 0;

		CMN_UTIL_StringBuffer buf = new CMN_UTIL_StringBuffer();

		while(textIndex != -1)
		{
			for(Integer i = start; i < textIndex; i++)
			{
				buf.append(charAt(text, i));
			}
			buf.append(replacementList[replaceIndex]);

			start = textIndex + searchList[replaceIndex].length();

			textIndex = -1;
			replaceIndex = -1;
			tempIndex = -1;
			// find the next earliest match
			// NOTE: logic mostly duplicated above START
			for(Integer i = 0; i < searchLength; i++)
			{
				if(
						noMoreMatchesForReplIndex[i] ||
								searchList[i] == null ||
								searchList[i].length() == 0 ||
								replacementList[i] == null
						)
				{
					continue;
				}
				tempIndex = indexOf(text, searchList[i], start);

				// see if we need to keep searching for this
				if(tempIndex == -1)
				{
					noMoreMatchesForReplIndex[i] = true;
				}
				else
				{
					if(textIndex == -1 || tempIndex < textIndex)
					{
						textIndex = tempIndex;
						replaceIndex = i;
					}
				}
			}
			// NOTE: logic duplicated above END
		}
		Integer textLength = text.length();
		for(Integer i = start; i < textLength; i++)
		{
			buf.append(charAt(text, i));
		}
		String result = buf.toStr();
		if(!repeat)
		{
			return result;
		}

		return replaceEach(
				result,
				searchList,
				replacementList,
				repeat,
				timeToLive - 1
		);
	}

  /**
	 * @description <p>Replaces multiple characters in a String in one go.
	 * This method can also be used to delete characters.</p>
	 * <p/>
	 * <p>For example:<br>
	 * <code>replaceChars(&quot;hello&quot;, &quot;ho&quot;, &quot;jy&quot;) = jelly</code>.</p>
	 * <p/>
	 * <p>A {@code null} string input returns {@code null}.
	 * An empty ("") string input returns an empty string.
	 * A null or empty set of search characters returns the input string.</p>
	 * <p/>
	 * <p>The length of the search characters should normally equal the length
	 * of the replace characters.
	 * If the search characters is longer, then the extra search characters
	 * are deleted.
	 * If the search characters is shorter, then the extra replace characters
	 * are ignored.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.replaceChars(null, *, *)           = null
	 * CMN_UTIL_String.replaceChars("", *, *)             = ""
	 * CMN_UTIL_String.replaceChars("abc", null, *)       = "abc"
	 * CMN_UTIL_String.replaceChars("abc", "", *)         = "abc"
	 * CMN_UTIL_String.replaceChars("abc", "b", null)     = "ac"
	 * CMN_UTIL_String.replaceChars("abc", "b", "")       = "ac"
	 * CMN_UTIL_String.replaceChars("abcba", "bc", "yz")  = "ayzya"
	 * CMN_UTIL_String.replaceChars("abcba", "bc", "y")   = "ayya"
	 * CMN_UTIL_String.replaceChars("abcba", "bc", "yzx") = "ayzya"
	 * </pre>
	 *
	 * @param str String to replace characters in, may be null
	 * @param searchChars a set of characters to search for, may be null
	 * @param replaceChars a set of characters to replace, may be null
	 *
	 * @return modified String, {@code null} if null string input
	 * @since 2.0
	 */
	global static String replaceChars(
			String str,
			String searchChars,
			String replaceChars
	)
	{
		if(isEmpty(str) || isEmpty(searchChars))
		{
			return str;
		}
		if(replaceChars == null)
		{
			replaceChars = EMPTY;
		}
		Boolean modified = false;
		Integer replaceCharsLength = replaceChars.length();
		Integer strLength = str.length();
		String buf = '';
		for(Integer i = 0; i < strLength; i++)
		{
			String ch = charAt(str, i);
			Integer index = indexOf(searchChars, ch);
			if(index >= 0)
			{
				modified = true;
				if(index < replaceCharsLength)
				{
					buf += charAt(replaceChars, index);
				}
			}
			else
			{
				buf += ch;
			}
		}
		if(modified)
		{
			return buf;
		}
		return str;
	}

  /**
	 * @description <p>Reverses a String as per {@link StringBuilder#reverse()}.</p>
	 * <p/>
	 * <p>A {@code null} String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.reverse(null)  = null
	 * CMN_UTIL_String.reverse("")    = ""
	 * CMN_UTIL_String.reverse("bat") = "tab"
	 * </pre>
	 *
	 * @param str the String to reverse, may be null
	 *
	 * @return the reversed String, {@code null} if null String input
	 */
	global static String reverse(String str)
	{
		if(str == null)
		{
			return null;
		}
		String returnString = '';
		for(Integer i = (str.length() - 1); i >= 0; i--)
		{
			returnString += charAt(str, i);
		}
		return returnString;
	}

  /**
	 * @description <p>Reverses a String that is delimited by a specific character.</p>
	 * <p/>
	 * <p>The Strings between the delimiters are not reversed.
	 * Thus java.lang.String becomes String.lang.java (if the delimiter
	 * is {@code '.'}).</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.reverseDelimited(null, *)      = null
	 * CMN_UTIL_String.reverseDelimited("", *)        = ""
	 * CMN_UTIL_String.reverseDelimited("a.b.c", 'x') = "a.b.c"
	 * CMN_UTIL_String.reverseDelimited("a.b.c", ".") = "c.b.a"
	 * </pre>
	 *
	 * @param str the String to reverse, may be null
	 * @param separatorChar the separator character to use
	 *
	 * @return the reversed String, {@code null} if null String input
	 * @since 2.0
	 */
	global static String reverseDelimited(String str, String separatorChar)
	{
		if(str == null)
		{
			return null;
		}
		if(separatorChar == null)
		{
			separatorChar = ' ';
		}
		CMN_UTIL_Character.validateChar(separatorChar);
		return joinArray(
				CMN_UTIL_Array.reverse(split(str, separatorChar)),
				separatorChar
		);
	}

  /**
	 * @description <p>Gets the rightmost {@code len} characters of a String.</p>
	 * <p/>
	 * <p>If {@code len} characters are not available, or the String
	 * is {@code null}, the String will be returned without an
	 * an exception. An empty String is returned if len is negative.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.right(null, *)    = null
	 * CMN_UTIL_String.right(*, -ve)     = ""
	 * CMN_UTIL_String.right("", *)      = ""
	 * CMN_UTIL_String.right("abc", 0)   = ""
	 * CMN_UTIL_String.right("abc", 2)   = "bc"
	 * CMN_UTIL_String.right("abc", 4)   = "abc"
	 * </pre>
	 *
	 * @param str the String to get the rightmost characters from, may be null
	 * @param len the length of the required String
	 *
	 * @return the rightmost characters, {@code null} if null String input
	 */
	global static String right(String str, Integer len)
	{
		if(str == null)
		{
			return null;
		}
		if(len <= 0)
		{
			return EMPTY;
		}
		if(str.length() <= len)
		{
			return str;
		}
		return str.substring(str.length() - len);
	}

  /**
	 * @description <p>Right pad a String with spaces (' ').</p>
	 * <p/>
	 * <p>The String is padded to the size of {@code size}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.rightPad(null, *)   = null
	 * CMN_UTIL_String.rightPad("", 3)     = "   "
	 * CMN_UTIL_String.rightPad("bat", 3)  = "bat"
	 * CMN_UTIL_String.rightPad("bat", 5)  = "bat  "
	 * CMN_UTIL_String.rightPad("bat", 1)  = "bat"
	 * CMN_UTIL_String.rightPad("bat", -1) = "bat"
	 * </pre>
	 *
	 * @param str the String to pad out, may be null
	 * @param size the size to pad to
	 *
	 * @return right padded String or original String if no padding is necessary,
	 *  {@code null} if null String input
	 */
	global static String rightPad(String str, Integer size)
	{
		return rightPad(str, size, ' ');
	}

  /**
	 * @description <p>Right pad a String with a specified String.</p>
	 * <p/>
	 * <p>The String is padded to the size of {@code size}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.rightPad(null, *, *)      = null
	 * CMN_UTIL_String.rightPad("", 3, "z")      = "zzz"
	 * CMN_UTIL_String.rightPad("bat", 3, "yz")  = "bat"
	 * CMN_UTIL_String.rightPad("bat", 5, "yz")  = "batyz"
	 * CMN_UTIL_String.rightPad("bat", 8, "yz")  = "batyzyzy"
	 * CMN_UTIL_String.rightPad("bat", 1, "yz")  = "bat"
	 * CMN_UTIL_String.rightPad("bat", -1, "yz") = "bat"
	 * CMN_UTIL_String.rightPad("bat", 5, null)  = "bat  "
	 * CMN_UTIL_String.rightPad("bat", 5, "")    = "bat  "
	 * </pre>
	 *
	 * @param str the String to pad out, may be null
	 * @param size the size to pad to
	 * @param padStr the String to pad with, null or empty treated as single space
	 *
	 * @return right padded String or original String if no padding is necessary,
	 *  {@code null} if null String input
	 */
	global static String rightPad(String str, Integer size, String padStr)
	{
		if(str == null)
		{
			return null;
		}
		if(isEmpty(padStr))
		{
			padStr = ' ';
		}
		Integer padLen = padStr.length();
		Integer strLen = str.length();
		Integer padCharCount = size - strLen;
		if(padCharCount <= 0)
		{
			return str; // returns original String when possible
		}

		if(padCharCount == padLen)
		{
			return str + padStr;
		}
		else if(padCharCount < padLen)
		{
			return str + padStr.substring(0, padCharCount);
		}
		else
		{
			String padding = '';
			for(Integer i = 0; i < padCharCount; i++)
			{
				padding += padStr.substring(
						Math.mod(i, padLen),
						Math.mod(i, padLen) + 1
				);
			}
			return str + padding;
		}
	}

  /**
	 * @description <p>Swaps the case of a String changing upper and title case to
	 * lower case, and lower case to upper case.</p>
	 * <p/>
	 * <ul>
	 *  <li>Upper case character converts to Lower case</li>
	 *  <li>Title case character converts to Lower case</li>
	 *  <li>Lower case character converts to Upper case</li>
	 * </ul>
	 * <p/>
	 * <p>For a word based algorithm, see {@link org.apache.commons.lang3.text.WordUtils#swapCase(String)}.
	 * A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.swapCase(null)                 = null
	 * CMN_UTIL_String.swapCase("")                   = ""
	 * CMN_UTIL_String.swapCase("The dog has a BONE") = "tHE DOG HAS A bone"
	 * </pre>
	 * <p/>
	 * <p>NOTE: This method changed in Lang version 2.0.
	 * It no longer performs a word based algorithm.
	 * If you only use ASCII, you will notice no change.
	 * That functionality is available in org.apache.commons.lang3.text.WordUtils.</p>
	 *
	 * @param str the String to swap case, may be null
	 *
	 * @return the changed String, {@code null} if null String input
	 */
	global static String swapCase(String str)
	{
		if(isBlank(str))
		{
			return str;
		}
		String buffer = '';
		String ch;
		for(Integer i = 0; i < str.length(); i++)
		{
			ch = str.substring(i, i + 1);
			if(CMN_UTIL_Character.isUpperCase(ch))
			{
				ch = lowerCase(ch);
			}
			else if(CMN_UTIL_Character.isLowerCase(ch))
			{
				ch = upperCase(ch);
			}
			buffer += ch;
		}
		return buffer;
	}

  /**
	 * @description <p>Case insensitive check if a CharSequence starts with a specified prefix.</p>
	 * <p/>
	 * <p>{@code null}s are handled without exceptions. Two {@code null}
	 * references are considered to be equal. The comparison is case insensitive.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.startsWithIgnoreCase(null, null)      = true
	 * CMN_UTIL_String.startsWithIgnoreCase(null, "abc")     = false
	 * CMN_UTIL_String.startsWithIgnoreCase("abcdef", null)  = false
	 * CMN_UTIL_String.startsWithIgnoreCase("abcdef", "abc") = true
	 * CMN_UTIL_String.startsWithIgnoreCase("ABCDEF", "abc") = true
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param prefix the prefix to find, may be null
	 *
	 * @return {@code true} if the CharSequence starts with the prefix, case insensitive, or
	 *  both {@code null}
	 * @since 2.4
	 * @since 3.0 Changed signature from startsWithIgnoreCase(String, String) to startsWithIgnoreCase(CharSequence, CharSequence)
	 */
	global static Boolean startsWithIgnoreCase(String str, String prefix)
	{
		return startsWith(str, prefix, true);
	}

  /**
	 * @description <p>Check if a CharSequence starts with a specified prefix.</p>
	 * <p/>
	 * <p>{@code null}s are handled without exceptions. Two {@code null}
	 * references are considered to be equal. The comparison is case sensitive.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.startsWith(null, null)      = true
	 * CMN_UTIL_String.startsWith(null, "abc")     = false
	 * CMN_UTIL_String.startsWith("abcdef", null)  = false
	 * CMN_UTIL_String.startsWith("abcdef", "abc") = true
	 * CMN_UTIL_String.startsWith("ABCDEF", "abc") = false
	 * </pre>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param prefix the prefix to find, may be null
	 *
	 * @return {@code true} if the CharSequence starts with the prefix, case sensitive, or
	 *  both {@code null}
	 * @since 2.4
	 * @since 3.0 Changed signature from startsWith(String, String) to startsWith(CharSequence, CharSequence)
	 */
	global static Boolean startsWith(String str, String prefix)
	{
		return startsWith(str, prefix, false);
	}

  /**
	 * @description <p>Check if a CharSequence starts with a specified prefix (optionally case insensitive).</p>
	 *
	 * @param str the CharSequence to check, may be null
	 * @param prefix the prefix to find, may be null
	 * @param ignoreCase indicates whether the compare should ignore case
	 *  (case insensitive) or not.
	 *
	 * @return {@code true} if the CharSequence starts with the prefix or
	 *  both {@code null}
	 */
	private static Boolean startsWith(
			String str,
			String prefix,
			Boolean ignoreCase
	)
	{
		if(str == null || prefix == null)
		{
			return (str == null && prefix == null);
		}
		if(prefix.length() > str.length())
		{
			return false;
		}
		return regionMatches(str, ignoreCase, 0, prefix, 0, prefix.length());
	}

  /**
	 * @description checks if string matches within a string given a region boundary
	 *
	 * @param str as input
	 * @param toffset as input
	 * @param other as input
	 * @param ooffset as input
	 * @param len as input
	 *
	 * @return other string matches with str based on region boundary
	 */
	global static Boolean regionMatches(
			String str,
			Integer toffset,
			String other,
			Integer ooffset,
			Integer len
	)
	{
		return regionMatches(str, false, toffset, other, ooffset, len);
	}

  /**
	 * @description checks if string matches within a string given a region boundary, ignoring case
	 *
	 * @param str as input
	 * @param toffset as input
	 * @param other as input
	 * @param ooffset as input
	 * @param len as input
	 *
	 * @return other string matches with str based on region boundary
	 */
	global static Boolean regionMatchesIgnoreCase(
			String str,
			Integer toffset,
			String other,
			Integer ooffset,
			Integer len
	)
	{
		return regionMatches(str, true, toffset, other, ooffset, len);
	}

  /**
	 * @description checks if string matches within a string given a region boundary, ignoring case (option)
	 *
	 * @param str as input
	 * @param ignoreCase as input
	 * @param toffset as input
	 * @param other as input
	 * @param ooffset as input
	 * @param len as input
	 *
	 * @return other string matches with str based on region boundary
	 */
	global static Boolean regionMatches(
			String str,
			Boolean ignoreCase,
			Integer toffset,
			String other,
			Integer ooffset,
			Integer len
	)
	{
		str = substring(str, toffset, toffset + len);
		other = substring(other, ooffset, ooffset + len);
		if(ignoreCase)
		{
			return equalsIgnoreCase(str, other);
		}
		return equals(str, other);
	}

  /**
	 * @description <p>Splits the provided text into an array, using whitespace as the
	 * separator.
	 * Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as one separator.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.split(null)       = null
	 * CMN_UTIL_String.split("")         = []
	 * CMN_UTIL_String.split("abc def")  = ["abc", "def"]
	 * CMN_UTIL_String.split("abc  def") = ["abc", "def"]
	 * CMN_UTIL_String.split(" abc ")    = ["abc"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 */
	global static String[] split(String str)
	{
		return split(str, null, -1);
	}

  /**
	 * @description <p>Splits the provided text into an array, separators specified.
	 * This is an alternative to using StringTokenizer.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as one separator.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separatorChars splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.split(null, *)         = null
	 * CMN_UTIL_String.split("", *)           = []
	 * CMN_UTIL_String.split("abc def", null) = ["abc", "def"]
	 * CMN_UTIL_String.split("abc def", " ")  = ["abc", "def"]
	 * CMN_UTIL_String.split("abc  def", " ") = ["abc", "def"]
	 * CMN_UTIL_String.split("ab:cd:ef", ":") = ["ab", "cd", "ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separatorChars the characters used as the delimiters,
	 *  {@code null} splits on whitespace
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 */
	global static String[] split(String str, String separatorChars)
	{
		return splitWorker(str, separatorChars, -1, false);
	}

  /**
	 * @description <p>Splits the provided text into an array with a maximum length,
	 * separators specified.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as one separator.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separatorChars splits on whitespace.</p>
	 * <p/>
	 * <p>If more than {@code max} delimited substrings are found, the last
	 * returned string includes all characters after the first {@code max - 1}
	 * returned strings (including separator characters).</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.split(null, *, *)            = null
	 * CMN_UTIL_String.split("", *, *)              = []
	 * CMN_UTIL_String.split("ab cd ef", null, 0)   = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.split("ab   cd ef", null, 0) = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.split("ab:cd:ef", ":", 0)    = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.split("ab:cd:ef", ":", 2)    = ["ab", "cd:ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separatorChars the characters used as the delimiters,
	 *  {@code null} splits on whitespace
	 * @param max the maximum number of elements to include in the
	 *  array. A zero or negative value implies no limit
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 */
	global static String[] split(String str, String separatorChars, Integer max)
	{
		return splitWorker(str, separatorChars, max, false);
	}

  /**
	 * @description <p>Splits the provided text into an array, using whitespace as the
	 * separator, preserving all tokens, including empty tokens created by
	 * adjacent separators. This is an alternative to using StringTokenizer.
	 * Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as separators for empty tokens.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitPreserveAllTokens(null)       = null
	 * CMN_UTIL_String.splitPreserveAllTokens("")         = []
	 * CMN_UTIL_String.splitPreserveAllTokens("abc def")  = ["abc", "def"]
	 * CMN_UTIL_String.splitPreserveAllTokens("abc  def") = ["abc", "", "def"]
	 * CMN_UTIL_String.splitPreserveAllTokens(" abc ")    = ["", "abc", ""]
	 * </pre>
	 *
	 * @param str the String to parse, may be {@code null}
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.1
	 */
	global static String[] splitPreserveAllTokens(String str)
	{
		return splitWorker(str, null, -1, true);
	}

  /**
	 * @description <p>Splits the provided text into an array, separators specified,
	 * preserving all tokens, including empty tokens created by adjacent
	 * separators. This is an alternative to using StringTokenizer.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as separators for empty tokens.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separatorChars splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitPreserveAllTokens(null, *)           = null
	 * CMN_UTIL_String.splitPreserveAllTokens("", *)             = []
	 * CMN_UTIL_String.splitPreserveAllTokens("abc def", null)   = ["abc", "def"]
	 * CMN_UTIL_String.splitPreserveAllTokens("abc def", " ")    = ["abc", "def"]
	 * CMN_UTIL_String.splitPreserveAllTokens("abc  def", " ")   = ["abc", "", def"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab:cd:ef", ":")   = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab:cd:ef:", ":")  = ["ab", "cd", "ef", ""]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab:cd:ef::", ":") = ["ab", "cd", "ef", "", ""]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab::cd:ef", ":")  = ["ab", "", cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens(":cd:ef", ":")     = ["", cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("::cd:ef", ":")    = ["", "", cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens(":cd:ef:", ":")    = ["", cd", "ef", ""]
	 * </pre>
	 *
	 * @param str the String to parse, may be {@code null}
	 * @param separatorChars the characters used as the delimiters,
	 *  {@code null} splits on whitespace
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.1
	 */
	global static String[] splitPreserveAllTokens(
			String str,
			String separatorChars
	)
	{
		return splitWorker(str, separatorChars, -1, true);
	}

  /**
	 * @description <p>Splits the provided text into an array with a maximum length,
	 * separators specified, preserving all tokens, including empty tokens
	 * created by adjacent separators.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as separators for empty tokens.
	 * Adjacent separators are treated as one separator.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separatorChars splits on whitespace.</p>
	 * <p/>
	 * <p>If more than {@code max} delimited substrings are found, the last
	 * returned string includes all characters after the first {@code max - 1}
	 * returned strings (including separator characters).</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitPreserveAllTokens(null, *, *)            = null
	 * CMN_UTIL_String.splitPreserveAllTokens("", *, *)              = []
	 * CMN_UTIL_String.splitPreserveAllTokens("ab de fg", null, 0)   = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab   de fg", null, 0) = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab:cd:ef", ":", 0)    = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab:cd:ef", ":", 2)    = ["ab", "cd:ef"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab   de fg", null, 2) = ["ab", "  de fg"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab   de fg", null, 3) = ["ab", "", " de fg"]
	 * CMN_UTIL_String.splitPreserveAllTokens("ab   de fg", null, 4) = ["ab", "", "", "de fg"]
	 * </pre>
	 *
	 * @param str the String to parse, may be {@code null}
	 * @param separatorChars the characters used as the delimiters,
	 *  {@code null} splits on whitespace
	 * @param max the maximum number of elements to include in the
	 *  array. A zero or negative value implies no limit
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.1
	 */
	global static String[] splitPreserveAllTokens(
			String str,
			String separatorChars,
			Integer max
	)
	{
		return splitWorker(str, separatorChars, max, true);
	}

  /**
	 * @description Performs the logic for the {@code split} and
	 * {@code splitPreserveAllTokens} methods that return a maximum array
	 * length.
	 *
	 * @param str the String to parse, may be {@code null}
	 * @param separatorChars the separate character
	 * @param max the maximum number of elements to include in the
	 *  array. A zero or negative value implies no limit.
	 * @param preserveAllTokens if {@code true}, adjacent separators are
	 * treated as empty token separators; if {@code false}, adjacent
	 * separators are treated as one separator.
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 */
	private static String[] splitWorker(
			String str,
			String separatorChars,
			Integer max,
			Boolean preserveAllTokens
	)
	{
		if(str == null)
		{
			return null;
		}
		Integer len = str.length();
		if(len == 0)
		{
			return new List<String> {};
		}

		List<String> theList = new List<String>();
		Integer sizePlus1 = 1;
		Integer i = 0;
		Integer start = 0;
		Boolean match = false;
		Boolean lastMatch = false;
		if(separatorChars == null)
		{
			// Null separator means use whitespace
			while(i < len)
			{
				if(CMN_UTIL_Character.isWhitespace(charAt(str, i)))
				{
					if(match || preserveAllTokens)
					{
						lastMatch = true;
						if(sizePlus1++ == max)
						{
							i = len;
							lastMatch = false;
						}
						if(start == i)
						{
							theList.add('');
						}
						else
						{
							theList.add(str.substring(start, i));
						}
						match = false;
					}
					start = ++i;
					continue;
				}
				lastMatch = false;
				match = true;
				i++;
			}
		}
		else if(separatorChars.length() == 1)
		{
			// Optimise 1 character case
			String sep = charAt(separatorChars, 0);
			while(i < len)
			{
				if(charAt(str, i) == sep)
				{
					if(match || preserveAllTokens)
					{
						lastMatch = true;
						if(sizePlus1++ == max)
						{
							i = len;
							lastMatch = false;
						}
						if(start == i)
						{
							theList.add('');
						}
						else
						{
							theList.add(str.substring(start, i));
						}
						match = false;
					}
					start = ++i;
					continue;
				}
				lastMatch = false;
				match = true;
				i++;
			}
		}
		else
		{
			// standard case
			while(i < len)
			{
				if(separatorChars.indexOf(charAt(str, i)) >= 0)
				{
					if(match || preserveAllTokens)
					{
						lastMatch = true;
						if(sizePlus1++ == max)
						{
							i = len;
							lastMatch = false;
						}
						theList.add(start == i ? '' : str.substring(start, i));
						match = false;
					}
					start = ++i;
					continue;
				}
				lastMatch = false;
				match = true;
				i++;
			}
		}
		if(match || (preserveAllTokens && lastMatch))
		{
			if(start == i)
			{
				theList.add('');
			}
			else
			{
				theList.add(str.substring(start, i));
			}
		}
		return theList;
	}

  /**
	 * @description <p>Splits the provided text into an array, separator string specified.</p>
	 * <p/>
	 * <p>The separator(s) will not be included in the returned String array.
	 * Adjacent separators are treated as one separator.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separator splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitByWholeSeparator(null, *)               = null
	 * CMN_UTIL_String.splitByWholeSeparator("", *)                 = []
	 * CMN_UTIL_String.splitByWholeSeparator("ab de fg", null)      = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab   de fg", null)    = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab:cd:ef", ":")       = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab-!-cd-!-ef", "-!-") = ["ab", "cd", "ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separator String containing the String to be used as a delimiter,
	 *  {@code null} splits on whitespace
	 *
	 * @return an array of parsed Strings, {@code null} if null String was input
	 */
	global static String[] splitByWholeSeparator(String str, String separator)
	{
		return splitByWholeSeparatorWorker(str, separator, -1, false);
	}

  /**
	 * @description <p>Splits the provided text into an array, separator string specified.
	 * Returns a maximum of {@code max} substrings.</p>
	 * <p/>
	 * <p>The separator(s) will not be included in the returned String array.
	 * Adjacent separators are treated as one separator.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separator splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitByWholeSeparator(null, *, *)               = null
	 * CMN_UTIL_String.splitByWholeSeparator("", *, *)                 = []
	 * CMN_UTIL_String.splitByWholeSeparator("ab de fg", null, 0)      = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab   de fg", null, 0)    = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab:cd:ef", ":", 2)       = ["ab", "cd:ef"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab-!-cd-!-ef", "-!-", 5) = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitByWholeSeparator("ab-!-cd-!-ef", "-!-", 2) = ["ab", "cd-!-ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separator String containing the String to be used as a delimiter,
	 *  {@code null} splits on whitespace
	 * @param max the maximum number of elements to include in the returned
	 *  array. A zero or negative value implies no limit.
	 *
	 * @return an array of parsed Strings, {@code null} if null String was input
	 */
	global static String[] splitByWholeSeparator(
			String str,
			String separator,
			Integer max
	)
	{
		return splitByWholeSeparatorWorker(str, separator, max, false);
	}

  /**
	 * @description <p>Splits the provided text into an array, separator string specified. </p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as separators for empty tokens.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separator splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(null, *)               = null
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("", *)                 = []
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab de fg", null)      = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab   de fg", null)    = ["ab", "", "", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab:cd:ef", ":")       = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab-!-cd-!-ef", "-!-") = ["ab", "cd", "ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separator String containing the String to be used as a delimiter,
	 *  {@code null} splits on whitespace
	 *
	 * @return an array of parsed Strings, {@code null} if null String was input
	 * @since 2.4
	 */
	global static String[] splitByWholeSeparatorPreserveAllTokens(
			String str,
			String separator
	)
	{
		return splitByWholeSeparatorWorker(str, separator, -1, true);
	}

  /**
	 * @description <p>Splits the provided text into an array, separator string specified.
	 * Returns a maximum of {@code max} substrings.</p>
	 * <p/>
	 * <p>The separator is not included in the returned String array.
	 * Adjacent separators are treated as separators for empty tokens.
	 * For more control over the split use the StrTokenizer class.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} separator splits on whitespace.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens(null, *, *)               = null
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("", *, *)                 = []
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab de fg", null, 0)      = ["ab", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab   de fg", null, 0)    = ["ab", "", "", "de", "fg"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab:cd:ef", ":", 2)       = ["ab", "cd:ef"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab-!-cd-!-ef", "-!-", 5) = ["ab", "cd", "ef"]
	 * CMN_UTIL_String.splitByWholeSeparatorPreserveAllTokens("ab-!-cd-!-ef", "-!-", 2) = ["ab", "cd-!-ef"]
	 * </pre>
	 *
	 * @param str the String to parse, may be null
	 * @param separator String containing the String to be used as a delimiter,
	 *  {@code null} splits on whitespace
	 * @param max the maximum number of elements to include in the returned
	 *  array. A zero or negative value implies no limit.
	 *
	 * @return an array of parsed Strings, {@code null} if null String was input
	 * @since 2.4
	 */
	global static String[] splitByWholeSeparatorPreserveAllTokens(
			String str,
			String separator,
			Integer max
	)
	{
		return splitByWholeSeparatorWorker(str, separator, max, true);
	}

  /**
	 * @description Performs the logic for the {@code splitByWholeSeparatorPreserveAllTokens} methods.
	 *
	 * @param str the String to parse, may be {@code null}
	 * @param separator String containing the String to be used as a delimiter,
	 *  {@code null} splits on whitespace
	 * @param max the maximum number of elements to include in the returned
	 *  array. A zero or negative value implies no limit.
	 * @param preserveAllTokens if {@code true}, adjacent separators are
	 * treated as empty token separators; if {@code false}, adjacent
	 * separators are treated as one separator.
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.4
	 */
	private static String[] splitByWholeSeparatorWorker(
			String str,
			String separator,
			Integer max,
			Boolean preserveAllTokens
	)
	{
		if(str == null)
		{
			return null;
		}
		Integer len = str.length();
		if(len == 0)
		{
			return new List<String> {};
		}

		if((separator == null) || (EMPTY.equals(separator)))
		{
			// Split on whitespace.
			return splitWorker(str, null, max, preserveAllTokens);
		}
		Integer separatorLength = separator.length();

		List<String> substrings = new List<String>();
		Integer numberOfSubstrings = 0;
		Integer begIndex = 0;
		Integer endIndex = 0;
		while(endIndex < len)
		{
			endIndex = str.indexOf(separator, begIndex);

			if(endIndex > -1)
			{
				if(endIndex > begIndex)
				{
					numberOfSubstrings += 1;

					if(numberOfSubstrings == max)
					{
						endIndex = len;
						substrings.add(str.substring(begIndex));
					}
					else
					{
						// The following is OK, because String.substring( begIndex, endIndex ) excludes
						// the character at the position 'endIndex'.
						substrings.add(str.substring(begIndex, endIndex));

						// Set the starting point for the next search.
						// The following is equivalent to begIndex = endIndex + (separatorLength - 1) + 1,
						// which is the right calculation:
						begIndex = endIndex + separatorLength;
					}
				}
				else
				{
					// We found a consecutive occurrence of the separator, so skip it.
					if(preserveAllTokens)
					{
						numberOfSubstrings += 1;
						if(numberOfSubstrings == max)
						{
							endIndex = len;
							substrings.add(str.substring(begIndex));
						}
						else
						{
							substrings.add(EMPTY);
						}
					}
					begIndex = endIndex + separatorLength;
				}
			}
			else
			{
				// String.substring( begIndex ) goes from 'begIndex' to the endIndex of the String.
				substrings.add(str.substring(begIndex));
				endIndex = len;
			}
		}

		return substrings;
	}

  /**
	 * @description <p>Splits a String by Character type as returned by
	 * {@code java.lang.Character.getType(char)}. Groups of contiguous
	 * characters of the same type are returned as complete tokens.
	 * <pre>
	 * CMN_UTIL_String.splitByCharacterType(null)         = null
	 * CMN_UTIL_String.splitByCharacterType("")           = []
	 * CMN_UTIL_String.splitByCharacterType("ab de fg")   = ["ab", " ", "de", " ", "fg"]
	 * CMN_UTIL_String.splitByCharacterType("ab   de fg") = ["ab", "   ", "de", " ", "fg"]
	 * CMN_UTIL_String.splitByCharacterType("ab:cd:ef")   = ["ab", ":", "cd", ":", "ef"]
	 * CMN_UTIL_String.splitByCharacterType("number5")    = ["number", "5"]
	 * CMN_UTIL_String.splitByCharacterType("fooBar")     = ["foo", "B", "ar"]
	 * CMN_UTIL_String.splitByCharacterType("foo200Bar")  = ["foo", "200", "B", "ar"]
	 * CMN_UTIL_String.splitByCharacterType("ASFRules")   = ["ASFR", "ules"]
	 * </pre>
	 *
	 * @param str the String to split, may be {@code null}
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.4
	 */
	global static String[] splitByCharacterType(String str)
	{
		return splitByCharacterType(str, false);
	}

  /**
	 * @description <p>Splits a String by Character type as returned by
	 * {@code java.lang.Character.getType(char)}. Groups of contiguous
	 * characters of the same type are returned as complete tokens, with the
	 * following exception: the character of type
	 * {@code Character.UPPERCASE_LETTER}, if any, immediately
	 * preceding a token of type {@code Character.LOWERCASE_LETTER}
	 * will belong to the following token rather than to the preceding, if any,
	 * {@code Character.UPPERCASE_LETTER} token.
	 * <pre>
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase(null)         = null
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("")           = []
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("ab de fg")   = ["ab", " ", "de", " ", "fg"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("ab   de fg") = ["ab", "   ", "de", " ", "fg"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("ab:cd:ef")   = ["ab", ":", "cd", ":", "ef"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("number5")    = ["number", "5"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("fooBar")     = ["foo", "Bar"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("foo200Bar")  = ["foo", "200", "Bar"]
	 * CMN_UTIL_String.splitByCharacterTypeCamelCase("ASFRules")   = ["ASF", "Rules"]
	 * </pre>
	 *
	 * @param str the String to split, may be {@code null}
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.4
	 */
	global static String[] splitByCharacterTypeCamelCase(String str)
	{
		return splitByCharacterType(str, true);
	}

  /**
	 * @description <p>Splits a String by Character type as returned by
	 * {@code java.lang.Character.getType(char)}. Groups of contiguous
	 * characters of the same type are returned as complete tokens, with the
	 * following exception: if {@code camelCase} is {@code true},
	 * the character of type {@code Character.UPPERCASE_LETTER}, if any,
	 * immediately preceding a token of type {@code Character.LOWERCASE_LETTER}
	 * will belong to the following token rather than to the preceding, if any,
	 * {@code Character.UPPERCASE_LETTER} token.
	 *
	 * @param str the String to split, may be {@code null}
	 * @param camelCase whether to use so-called "camel-case" for letter types
	 *
	 * @return an array of parsed Strings, {@code null} if null String input
	 * @since 2.4
	 */
	private static String[] splitByCharacterType(String str, Boolean camelCase)
	{
		if(str == null)
		{
			return null;
		}
		if(str.length() == 0)
		{
			return CMN_UTIL_Array.EMPTY_STRING_ARRAY;
		}
		List<String> aList = new List<String>();
		Integer tokenStart = 0;
		Integer currentType = CMN_UTIL_Character.getType(charAt(str, tokenStart));
		for(Integer pos = tokenStart + 1; pos < str.length(); pos++)
		{
			Integer theType = CMN_UTIL_Character.getType(charAt(str, pos));
			if(theType == currentType)
			{
				continue;
			}
			if(
					camelCase &&
							theType == CMN_UTIL_Character.LOWERCASE_LETTER &&
							currentType == CMN_UTIL_Character.UPPERCASE_LETTER
					)
			{
				Integer newTokenStart = pos - 1;
				if(newTokenStart != tokenStart)
				{
					aList.add(substring(str, tokenStart, newTokenStart));
					tokenStart = newTokenStart;
				}
			}
			else
			{
				aList.add(substring(str, tokenStart, pos));
				tokenStart = pos;
			}
			currentType = theType;
		}
		aList.add(substring(str, tokenStart, str.length()));
		return aList;
	}

  /**
	 * @description <p>Strips whitespace from the start and end of a String.</p>
	 * <p/>
	 * <p>This is similar to {@link #trim(String)} but removes whitespace.
	 * Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.strip(null)     = null
	 * CMN_UTIL_String.strip("")       = ""
	 * CMN_UTIL_String.strip("   ")    = ""
	 * CMN_UTIL_String.strip("abc")    = "abc"
	 * CMN_UTIL_String.strip("  abc")  = "abc"
	 * CMN_UTIL_String.strip("abc  ")  = "abc"
	 * CMN_UTIL_String.strip(" abc ")  = "abc"
	 * CMN_UTIL_String.strip(" ab c ") = "ab c"
	 * </pre>
	 *
	 * @param str the String to remove whitespace from, may be null
	 *
	 * @return the stripped String, {@code null} if null String input
	 */
	global static String strip(String str)
	{
		return strip(str, null);
	}

  /**
	 * @description <p>Strips whitespace from the start and end of a String  returning
	 * {@code null} if the String is empty ("") after the strip.</p>
	 * <p/>
	 * <p>This is similar to {@link #trimToNull(String)} but removes whitespace.
	 * Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.stripToNull(null)     = null
	 * CMN_UTIL_String.stripToNull("")       = null
	 * CMN_UTIL_String.stripToNull("   ")    = null
	 * CMN_UTIL_String.stripToNull("abc")    = "abc"
	 * CMN_UTIL_String.stripToNull("  abc")  = "abc"
	 * CMN_UTIL_String.stripToNull("abc  ")  = "abc"
	 * CMN_UTIL_String.stripToNull(" abc ")  = "abc"
	 * CMN_UTIL_String.stripToNull(" ab c ") = "ab c"
	 * </pre>
	 *
	 * @param str the String to be stripped, may be null
	 *
	 * @return the stripped String,
	 *  {@code null} if whitespace, empty or null String input
	 * @since 2.0
	 */
	global static String stripToNull(String str)
	{
		if(str == null)
		{
			return null;
		}
		str = strip(str, null);
		return str.length() == 0 ? null : str;
	}

  /**
	 * @description <p>Strips whitespace from the start and end of a String  returning
	 * an empty String if {@code null} input.</p>
	 * <p/>
	 * <p>This is similar to {@link #trimToEmpty(String)} but removes whitespace.
	 * Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.stripToEmpty(null)     = ""
	 * CMN_UTIL_String.stripToEmpty("")       = ""
	 * CMN_UTIL_String.stripToEmpty("   ")    = ""
	 * CMN_UTIL_String.stripToEmpty("abc")    = "abc"
	 * CMN_UTIL_String.stripToEmpty("  abc")  = "abc"
	 * CMN_UTIL_String.stripToEmpty("abc  ")  = "abc"
	 * CMN_UTIL_String.stripToEmpty(" abc ")  = "abc"
	 * CMN_UTIL_String.stripToEmpty(" ab c ") = "ab c"
	 * </pre>
	 *
	 * @param str the String to be stripped, may be null
	 *
	 * @return the trimmed String, or an empty String if {@code null} input
	 * @since 2.0
	 */
	global static String stripToEmpty(String str)
	{
		return str == null ? EMPTY : strip(str, null);
	}

  /**
	 * @description <p>Strips any of a set of characters from the start and end of a String.
	 * This is similar to {@link String#trim()} but allows the characters
	 * to be stripped to be controlled.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * An empty string ("") input returns the empty string.</p>
	 * <p/>
	 * <p>If the stripChars String is {@code null}, whitespace is
	 * stripped as defined by {@link Character#isWhitespace(char)}.
	 * Alternatively use {@link #strip(String)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.strip(null, *)          = null
	 * CMN_UTIL_String.strip("", *)            = ""
	 * CMN_UTIL_String.strip("abc", null)      = "abc"
	 * CMN_UTIL_String.strip("  abc", null)    = "abc"
	 * CMN_UTIL_String.strip("abc  ", null)    = "abc"
	 * CMN_UTIL_String.strip(" abc ", null)    = "abc"
	 * CMN_UTIL_String.strip("  abcyx", "xyz") = "  abc"
	 * </pre>
	 *
	 * @param str the String to remove characters from, may be null
	 * @param stripChars the characters to remove, null treated as whitespace
	 *
	 * @return the stripped String, {@code null} if null String input
	 */
	global static String strip(String str, String stripChars)
	{
		if(isEmpty(str))
		{
			return str;
		}
		str = stripStart(str, stripChars);
		return stripEnd(str, stripChars);
	}

  /**
	 * @description <p>Strips any of a set of characters from the start of a String.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * An empty string ("") input returns the empty string.</p>
	 * <p/>
	 * <p>If the stripChars String is {@code null}, whitespace is
	 * stripped as defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.stripStart(null, *)          = null
	 * CMN_UTIL_String.stripStart("", *)            = ""
	 * CMN_UTIL_String.stripStart("abc", "")        = "abc"
	 * CMN_UTIL_String.stripStart("abc", null)      = "abc"
	 * CMN_UTIL_String.stripStart("  abc", null)    = "abc"
	 * CMN_UTIL_String.stripStart("abc  ", null)    = "abc  "
	 * CMN_UTIL_String.stripStart(" abc ", null)    = "abc "
	 * CMN_UTIL_String.stripStart("yxabc  ", "xyz") = "abc  "
	 * </pre>
	 *
	 * @param str the String to remove characters from, may be null
	 * @param stripChars the characters to remove, null treated as whitespace
	 *
	 * @return the stripped String, {@code null} if null String input
	 */
	global static String stripStart(String str, String stripChars)
	{
		Integer strLen;
		if(str == null || (strLen = str.length()) == 0)
		{
			return str;
		}
		Integer start = 0;
		if(stripChars == null)
		{
			while(
					(start != strLen) && CMN_UTIL_Character.isWhitespace(charAt(str, start))
					)
			{
				start++;
			}
		}
		else if(stripChars.length() == 0)
		{
			return str;
		}
		else
		{
			while(
					(start != strLen) && (stripChars.indexOf(charAt(str, start)) != -1)
					)
			{
				start++;
			}
		}
		return substring(str, start);
	}

  /**
	 * @description <p>Strips any of a set of characters from the end of a String.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * An empty string ("") input returns the empty string.</p>
	 * <p/>
	 * <p>If the stripChars String is {@code null}, whitespace is
	 * stripped as defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.stripEnd(null, *)          = null
	 * CMN_UTIL_String.stripEnd("", *)            = ""
	 * CMN_UTIL_String.stripEnd("abc", "")        = "abc"
	 * CMN_UTIL_String.stripEnd("abc", null)      = "abc"
	 * CMN_UTIL_String.stripEnd("  abc", null)    = "  abc"
	 * CMN_UTIL_String.stripEnd("abc  ", null)    = "abc"
	 * CMN_UTIL_String.stripEnd(" abc ", null)    = " abc"
	 * CMN_UTIL_String.stripEnd("  abcyx", "xyz") = "  abc"
	 * CMN_UTIL_String.stripEnd("120.00", ".0")   = "12"
	 * </pre>
	 *
	 * @param str the String to remove characters from, may be null
	 * @param stripChars the set of characters to remove, null treated as whitespace
	 *
	 * @return the stripped String, {@code null} if null String input
	 */
	global static String stripEnd(String str, String stripChars)
	{
		Integer endIndex;
		if(str == null || (endIndex = str.length()) == 0)
		{
			return str;
		}

		if(stripChars == null)
		{
			while(
					(endIndex != 0) &&
							CMN_UTIL_Character.isWhitespace(charAt(str, endIndex - 1))
					)
			{
				endIndex--;
			}
		}
		else if(stripChars.length() == 0)
		{
			return str;
		}
		else
		{
			while(
					(endIndex != 0) && (stripChars.indexOf(charAt(str, endIndex - 1)) != -1)
					)
			{
				endIndex--;
			}
		}
		return substring(str, 0, endIndex);
	}

  /**
	 * @description Strip a set of characters from an array
	 *
	 * @param arrayStrings - the array to remove characters from, may be null
	 *
	 * @return The array containing the split string items
	 */
	global static String[] stripAll(String[] arrayStrings)
	{
		return stripAll(arrayStrings, null);
	}

  /**
	 * @description <p>Strips any of a set of characters from the start and end of every
	 * String in an array.</p>
	 * <p>Whitespace is defined by {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <p>A new array is returned each time, except for length zero.
	 * A {@code null} array will return {@code null}.
	 * An empty array will return itself.
	 * A {@code null} array entry will be ignored.
	 * A {@code null} stripChars will strip whitespace as defined by
	 * {@link Character#isWhitespace(char)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.stripAll(null, *)                = null
	 * CMN_UTIL_String.stripAll([], *)                  = []
	 * CMN_UTIL_String.stripAll(["abc", "  abc"], null) = ["abc", "abc"]
	 * CMN_UTIL_String.stripAll(["abc  ", null], null)  = ["abc", null]
	 * CMN_UTIL_String.stripAll(["abc  ", null], "yz")  = ["abc  ", null]
	 * CMN_UTIL_String.stripAll(["yabcz", null], "yz")  = ["abc", null]
	 * </pre>
	 *
	 * @param strs the array to remove characters from, may be null
	 * @param stripChars the characters to remove, null treated as whitespace
	 *
	 * @return the stripped Strings, {@code null} if null array input
	 */
	global static String[] stripAll(String[] strs, String stripChars)
	{
		Integer strsLen;
		if(strs == null || (strsLen = strs.size()) == 0)
		{
			return strs;
		}
		String[] newArr = new List<String>(strsLen);
		for(Integer i = 0; i < strsLen; i++)
		{
			newArr[i] = strip(strs[i], stripChars);
		}
		return newArr;
	}

  /**
	 * @description <p>Gets a substring from the specified String avoiding exceptions.</p>
	 * <p/>
	 * <p>A negative start position can be used to start {@code n}
	 * characters from the end of the String.</p>
	 * <p/>
	 * <p>A {@code null} String will return {@code null}.
	 * An empty ("") String will return "".</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substring(null, *)   = null
	 * CMN_UTIL_String.substring("", *)     = ""
	 * CMN_UTIL_String.substring("abc", 0)  = "abc"
	 * CMN_UTIL_String.substring("abc", 2)  = "c"
	 * CMN_UTIL_String.substring("abc", 4)  = ""
	 * CMN_UTIL_String.substring("abc", -2) = "bc"
	 * CMN_UTIL_String.substring("abc", -4) = "abc"
	 * </pre>
	 *
	 * @param str the String to get the substring from, may be null
	 * @param startIndex the position to start from, negative means
	 *  count back from the end of the String by this many characters
	 *
	 * @return substring from start position, {@code null} if null String input
	 */
	global static String substring(String str, Integer startIndex)
	{
		if(str == null)
		{
			return null;
		}
		// handle negatives, which means last n characters
		if(startIndex < 0)
		{
			startIndex = str.length() + startIndex; // remember startIndex is negative
		}
		if(startIndex < 0)
		{
			startIndex = 0;
		}
		if(startIndex >= str.length())
		{
			return EMPTY;
		}
		return str.substring(startIndex);
	}

  /**
	 * @description <p>Gets a substring from the specified String avoiding exceptions.</p>
	 * <p/>
	 * <p>A negative start position can be used to start/end {@code n}
	 * characters from the end of the String.</p>
	 * <p/>
	 * <p>The returned substring starts with the character in the {@code start}
	 * position and ends before the {@code end} position. All position counting is
	 * zero-based -- i.e., to start at the beginning of the string use
	 * {@code start = 0}. Negative start and end positions can be used to
	 * specify offsets relative to the end of the String.</p>
	 * <p/>
	 * <p>If {@code start} is not strictly to the left of {@code end}, ""
	 * is returned.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substring(null, *, *)    = null
	 * CMN_UTIL_String.substring("", * ,  *)    = "";
	 * CMN_UTIL_String.substring("abc", 0, 2)   = "ab"
	 * CMN_UTIL_String.substring("abc", 2, 0)   = ""
	 * CMN_UTIL_String.substring("abc", 2, 4)   = "c"
	 * CMN_UTIL_String.substring("abc", 4, 6)   = ""
	 * CMN_UTIL_String.substring("abc", 2, 2)   = ""
	 * CMN_UTIL_String.substring("abc", -2, -1) = "b"
	 * CMN_UTIL_String.substring("abc", -4, 2)  = "ab"
	 * </pre>
	 *
	 * @param str the String to get the substring from, may be null
	 * @param startIndex the position to start from, negative means
	 *  count back from the end of the String by this many characters
	 * @param endIndex the position to end at (exclusive), negative means
	 *  count back from the end of the String by this many characters
	 *
	 * @return substring from start position to end position,
	 *  {@code null} if null String input
	 */
	global static String substring(
			String str,
			Integer startIndex,
			Integer endIndex
	)
	{
		if(str == null)
		{
			return null;
		}
		// handle negatives
		if(endIndex < 0)
		{
			endIndex = str.length() + endIndex; // remember endIndex is negative
		}
		if(startIndex < 0)
		{
			startIndex = str.length() + startIndex; // remember startIndex is negative
		}

		// check length next
		if(endIndex > str.length())
		{
			endIndex = str.length();
		}

		// if startIndex is greater than endIndex, return ''
		if(startIndex >= endIndex)
		{
			return EMPTY;
		}

		if(startIndex < 0)
		{
			startIndex = 0;
		}
		if(endIndex < 0)
		{
			endIndex = 0;
		}
		return str.substring(startIndex, endIndex);
	}

  /**
	 * @description <p>Gets the substring before the first occurrence of a separator.
	 * The separator is not returned.</p>
	 * <p/>
	 * <p>A {@code null} string input will return {@code null}.
	 * An empty ("") string input will return the empty string.
	 * A {@code null} separator will return the input string.</p>
	 * <p/>
	 * <p>If nothing is found, the string input is returned.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringBefore(null, *)      = null
	 * CMN_UTIL_String.substringBefore("", *)        = ""
	 * CMN_UTIL_String.substringBefore("abc", "a")   = ""
	 * CMN_UTIL_String.substringBefore("abcba", "b") = "a"
	 * CMN_UTIL_String.substringBefore("abc", "c")   = "ab"
	 * CMN_UTIL_String.substringBefore("abc", "d")   = "abc"
	 * CMN_UTIL_String.substringBefore("abc", "")    = ""
	 * CMN_UTIL_String.substringBefore("abc", null)  = "abc"
	 * </pre>
	 *
	 * @param str the String to get a substring from, may be null
	 * @param separator the String to search for, may be null
	 *
	 * @return the substring before the first occurrence of the separator,
	 *  {@code null} if null String input
	 * @since 2.0
	 */
	global static String substringBefore(String str, String separator)
	{
		if(isEmpty(str) || separator == null)
		{
			return str;
		}
		if(separator.length() == 0)
		{
			return EMPTY;
		}
		Integer pos = str.indexOf(separator);
		if(pos == -1)
		{
			return str;
		}
		return substring(str, 0, pos);
	}

  /**
	 * @description <p>Gets the substring after the first occurrence of a separator.
	 * The separator is not returned.</p>
	 * <p/>
	 * <p>A {@code null} string input will return {@code null}.
	 * An empty ("") string input will return the empty string.
	 * A {@code null} separator will return the empty string if the
	 * input string is not {@code null}.</p>
	 * <p/>
	 * <p>If nothing is found, the empty string is returned.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringAfter(null, *)      = null
	 * CMN_UTIL_String.substringAfter("", *)        = ""
	 * CMN_UTIL_String.substringAfter(*, null)      = ""
	 * CMN_UTIL_String.substringAfter("abc", "a")   = "bc"
	 * CMN_UTIL_String.substringAfter("abcba", "b") = "cba"
	 * CMN_UTIL_String.substringAfter("abc", "c")   = ""
	 * CMN_UTIL_String.substringAfter("abc", "d")   = ""
	 * CMN_UTIL_String.substringAfter("abc", "")    = "abc"
	 * </pre>
	 *
	 * @param str the String to get a substring from, may be null
	 * @param separator the String to search for, may be null
	 *
	 * @return the substring after the first occurrence of the separator,
	 *  {@code null} if null String input
	 * @since 2.0
	 */
	global static String substringAfter(String str, String separator)
	{
		if(isEmpty(str))
		{
			return str;
		}
		if(separator == null)
		{
			return EMPTY;
		}
		Integer pos = str.indexOf(separator);
		if(pos == -1)
		{
			return EMPTY;
		}
		return substring(str, pos + separator.length());
	}

  /**
	 * @description <p>Gets the substring before the last occurrence of a separator.
	 * The separator is not returned.</p>
	 * <p/>
	 * <p>A {@code null} string input will return {@code null}.
	 * An empty ("") string input will return the empty string.
	 * An empty or {@code null} separator will return the input string.</p>
	 * <p/>
	 * <p>If nothing is found, the string input is returned.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringBeforeLast(null, *)      = null
	 * CMN_UTIL_String.substringBeforeLast("", *)        = ""
	 * CMN_UTIL_String.substringBeforeLast("abcba", "b") = "abc"
	 * CMN_UTIL_String.substringBeforeLast("abc", "c")   = "ab"
	 * CMN_UTIL_String.substringBeforeLast("a", "a")     = ""
	 * CMN_UTIL_String.substringBeforeLast("a", "z")     = "a"
	 * CMN_UTIL_String.substringBeforeLast("a", null)    = "a"
	 * CMN_UTIL_String.substringBeforeLast("a", "")      = "a"
	 * </pre>
	 *
	 * @param str the String to get a substring from, may be null
	 * @param separator the String to search for, may be null
	 *
	 * @return the substring before the last occurrence of the separator,
	 *  {@code null} if null String input
	 * @since 2.0
	 */
	global static String substringBeforeLast(String str, String separator)
	{
		if(isEmpty(str) || isEmpty(separator))
		{
			return str;
		}
		Integer pos = str.lastIndexOf(separator);
		if(pos == -1)
		{
			return str;
		}
		return substring(str, 0, pos);
	}

  /**
	 * @description <p>Gets the substring after the last occurrence of a separator.
	 * The separator is not returned.</p>
	 * <p/>
	 * <p>A {@code null} string input will return {@code null}.
	 * An empty ("") string input will return the empty string.
	 * An empty or {@code null} separator will return the empty string if
	 * the input string is not {@code null}.</p>
	 * <p/>
	 * <p>If nothing is found, the empty string is returned.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringAfterLast(null, *)      = null
	 * CMN_UTIL_String.substringAfterLast("", *)        = ""
	 * CMN_UTIL_String.substringAfterLast(*, "")        = ""
	 * CMN_UTIL_String.substringAfterLast(*, null)      = ""
	 * CMN_UTIL_String.substringAfterLast("abc", "a")   = "bc"
	 * CMN_UTIL_String.substringAfterLast("abcba", "b") = "a"
	 * CMN_UTIL_String.substringAfterLast("abc", "c")   = ""
	 * CMN_UTIL_String.substringAfterLast("a", "a")     = ""
	 * CMN_UTIL_String.substringAfterLast("a", "z")     = ""
	 * </pre>
	 *
	 * @param str the String to get a substring from, may be null
	 * @param separator the String to search for, may be null
	 *
	 * @return the substring after the last occurrence of the separator,
	 *  {@code null} if null String input
	 * @since 2.0
	 */
	global static String substringAfterLast(String str, String separator)
	{
		if(isEmpty(str))
		{
			return str;
		}
		if(isEmpty(separator))
		{
			return EMPTY;
		}
		Integer pos = str.lastIndexOf(separator);
		if(pos == -1 || pos == (str.length() - separator.length()))
		{
			return EMPTY;
		}
		return substring(str, pos + separator.length());
	}

  /**
	 * @description <p>Gets the String that is nested in between two instances of the
	 * same String.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} tag returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringBetween(null, *)            = null
	 * CMN_UTIL_String.substringBetween("", "")             = ""
	 * CMN_UTIL_String.substringBetween("", "tag")          = null
	 * CMN_UTIL_String.substringBetween("tagabctag", null)  = null
	 * CMN_UTIL_String.substringBetween("tagabctag", "")    = ""
	 * CMN_UTIL_String.substringBetween("tagabctag", "tag") = "abc"
	 * </pre>
	 *
	 * @param str the String containing the substring, may be null
	 * @param tag the String before and after the substring, may be null
	 *
	 * @return the substring, {@code null} if no match
	 * @since 2.0
	 */
	global static String substringBetween(String str, String tag)
	{
		return substringBetween(str, tag, tag);
	}

  /**
	 * @description Get the substring between the open and close strings
	 *
	 * @param str - The original string used to extract the between
	 * @param open - Opening string
	 * @param close - closing string
	 *
	 * @return The substring between the open and close string
	 */
	global static String substringBetween(String str, String open, String close)
	{
		if(str == null || open == null || close == null)
		{
			return null;
		}
		Integer start = str.indexOf(open);
		if(start != -1)
		{
			Integer endIndex = str.indexOf(close, start + open.length());
			if(endIndex != -1)
			{
				return substring(str, start + open.length(), endIndex);
			}
		}
		return null;
	}

  /**
	 * @description <p>Gets the String that is nested in between two Strings. The search is case INSENSITIVE
	 * Only the first match is returned.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} open/close returns {@code null} (no match).
	 * An empty ("") open and close returns an empty string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringBetweenIgnoreCase("wx[b]yz", "[", "]") = "b"
	 * CMN_UTIL_String.substringBetweenIgnoreCase(null, *, *)          = null
	 * CMN_UTIL_String.substringBetweenIgnoreCase(*, null, *)          = null
	 * CMN_UTIL_String.substringBetweenIgnoreCase(*, *, null)          = null
	 * CMN_UTIL_String.substringBetweenIgnoreCase("", "", "")          = ""
	 * CMN_UTIL_String.substringBetweenIgnoreCase("", "", "]")         = null
	 * CMN_UTIL_String.substringBetweenIgnoreCase("", "[", "]")        = null
	 * CMN_UTIL_String.substringBetweenIgnoreCase("yabcz", "", "")     = ""
	 * CMN_UTIL_String.substringBetweenIgnoreCase("yabcZ", "Y", "z")   = "abc"
	 * CMN_UTIL_String.substringBetweenIgnoreCase("yabczyabcz", "y", "z")   = "abc"
	 * </pre>
	 *
	 * @param str the String containing the substring, may be null
	 * @param open the String before the substring, may be null
	 * @param close the String after the substring, may be null
	 *
	 * @return the substring, {@code null} if no match
	 * @since 2.0
	 */
	global static String substringBetweenIgnoreCase(String str, String open, String close)
	{
		if(str == null || open == null || close == null)
		{
			return null;
		}

		Integer start = str.indexOfIgnoreCase(open);

		if(start != -1)
		{
			Integer endIndex = str.indexOfIgnoreCase(close, start + open.length());

			if(endIndex != -1)
			{
				return substring(str, start + open.length(), endIndex);
			}
		}

		return null;
	}

  /**
	 * @description <p>Gets the String that is nested in between two Strings.
	 * Only the first match is returned.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.
	 * A {@code null} open/close returns {@code null} (no match).
	 * An empty ("") open and close returns an empty string.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.substringBetween("wx[b]yz", "[", "]") = "b"
	 * CMN_UTIL_String.substringBetween(null, *, *)          = null
	 * CMN_UTIL_String.substringBetween(*, null, *)          = null
	 * CMN_UTIL_String.substringBetween(*, *, null)          = null
	 * CMN_UTIL_String.substringBetween("", "", "")          = ""
	 * CMN_UTIL_String.substringBetween("", "", "]")         = null
	 * CMN_UTIL_String.substringBetween("", "[", "]")        = null
	 * CMN_UTIL_String.substringBetween("yabcz", "", "")     = ""
	 * CMN_UTIL_String.substringBetween("yabcz", "y", "z")   = "abc"
	 * CMN_UTIL_String.substringBetween("yabczyabcz", "y", "z")   = "abc"
	 * </pre>
	 *
	 * @param str the String containing the substring, may be null
	 * @param open the String before the substring, may be null
	 * @param close the String after the substring, may be null
	 *
	 * @return the substring, {@code null} if no match
	 * @since 2.0
	 */
	global static String[] substringsBetween(
			String str,
			String open,
			String close
	)
	{
		if(str == null || isEmpty(open) || isEmpty(close))
		{
			return null;
		}
		Integer strLen = str.length();
		if(strLen == 0)
		{
			return CMN_UTIL_Array.EMPTY_STRING_ARRAY;
		}
		Integer closeLen = close.length();
		Integer openLen = open.length();
		List<String> returnList = new List<String>();
		Integer pos = 0;
		while(pos < (strLen - closeLen))
		{
			Integer start = str.indexOf(open, pos);
			if(start < 0)
			{
				break;
			}
			start += openLen;
			Integer endIndex = str.indexOf(close, start);
			if(endIndex < 0)
			{
				break;
			}
			returnList.add(substring(str, start, endIndex));
			pos = endIndex + closeLen;
		}
		if(returnList.isEmpty())
		{
			return null;
		}
		return returnList;
	}

  /**
	 * @description <p>Removes control characters (char &lt;= 32) from both
	 * ends of this String, handling {@code null} by returning
	 * {@code null}.</p>
	 * <p/>
	 * <p>The String is trimmed using {@link String#trim()}.
	 * Trim removes start and end characters &lt;= 32.
	 * To strip whitespace use {@link #strip(String)}.</p>
	 * <p/>
	 * <p>To trim your choice of characters, use the
	 * {@link #strip(String, String)} methods.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.trim(null)          = null
	 * CMN_UTIL_String.trim("")            = ""
	 * CMN_UTIL_String.trim("     ")       = ""
	 * CMN_UTIL_String.trim("abc")         = "abc"
	 * CMN_UTIL_String.trim("    abc    ") = "abc"
	 * </pre>
	 *
	 * @param str the String to be trimmed, may be null
	 *
	 * @return the trimmed string, {@code null} if null String input
	 */
	global static String trim(String str)
	{
		if(str == null)
		{
			return null;
		}
		return str.trim();
	}

  /**
	 * @description trim all strings contained in collection
	 *
	 * @param aList as input
	 *
	 * @return list of trimmed strings
	 */
	global static List<String> trimAll(List<String> aList)
	{
		List<String> returnValue = null;
		if(aList != null)
		{
			returnValue = new List<String>();
			if(aList.size() > 0)
			{
				for(String value : aList)
				{
					returnValue.add(trim(value));
				}
			}
		}
		return returnValue;
	}

  /**
	 * @description trim all strings contained in collection
	 *
	 * @param aList as input
	 *
	 * @return list of trimmed strings
	 */
	global static Set<String> trimAll(Set<String> aList)
	{
		Set<String> returnValue = null;
		if(aList != null)
		{
			returnValue = new Set<String>();
			if(aList.size() > 0)
			{
				for(String value : aList)
				{
					returnValue.add(trim(value));
				}
			}
		}
		return returnValue;
	}

  /**
	 * @description <p>Removes control characters (char &lt;= 32) from both
	 * ends of this String returning {@code null} if the String is
	 * empty ("") after the trim or if it is {@code null}.
	 * <p/>
	 * <p>The String is trimmed using {@link String#trim()}.
	 * Trim removes start and end characters &lt;= 32.
	 * To strip whitespace use {@link #stripToNull(String)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.trimToNull(null)          = null
	 * CMN_UTIL_String.trimToNull("")            = null
	 * CMN_UTIL_String.trimToNull("     ")       = null
	 * CMN_UTIL_String.trimToNull("abc")         = "abc"
	 * CMN_UTIL_String.trimToNull("    abc    ") = "abc"
	 * </pre>
	 *
	 * @param str the String to be trimmed, may be null
	 *
	 * @return the trimmed String,
	 *  {@code null} if only chars &lt;= 32, empty or null String input
	 * @since 2.0
	 */
	global static String trimToNull(String str)
	{
		String ts = trim(str);
		return isEmpty(ts) ? null : ts;
	}

  /**
	 * @description <p>Removes control characters (char &lt;= 32) from both
	 * ends of this String returning an empty String ("") if the String
	 * is empty ("") after the trim or if it is {@code null}.
	 * <p/>
	 * <p>The String is trimmed using {@link String#trim()}.
	 * Trim removes start and end characters &lt;= 32.
	 * To strip whitespace use {@link #stripToEmpty(String)}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.trimToEmpty(null)          = ""
	 * CMN_UTIL_String.trimToEmpty("")            = ""
	 * CMN_UTIL_String.trimToEmpty("     ")       = ""
	 * CMN_UTIL_String.trimToEmpty("abc")         = "abc"
	 * CMN_UTIL_String.trimToEmpty("    abc    ") = "abc"
	 * </pre>
	 *
	 * @param str the String to be trimmed, may be null
	 *
	 * @return the trimmed String, or an empty String if {@code null} input
	 * @since 2.0
	 */
	global static String trimToEmpty(String str)
	{
		return str == null ? EMPTY : str.trim();
	}

  /**
	 * @description <p>Uncapitalizes a String, changing the first character to lower case as
	 * per {@link Character#toLowerCase(int)}. No other characters are changed.</p>
	 * <p/>
	 * <p>For a word based algorithm, see {@link org.apache.commons.lang3.text.WordUtils#uncapitalize(String)}.
	 * A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.uncapitalize(null)  = null
	 * CMN_UTIL_String.uncapitalize("")    = ""
	 * CMN_UTIL_String.uncapitalize("cat") = "cat"
	 * CMN_UTIL_String.uncapitalize("Cat") = "cat"
	 * CMN_UTIL_String.uncapitalize("CAT") = "cAT"
	 * </pre>
	 *
	 * @param str the String to uncapitalize, may be null
	 *
	 * @return the uncapitalized String, {@code null} if null String input
	 * @since 2.0
	 */
	global static String uncapitalize(String str)
	{
		if(isBlank(str))
		{
			return str;
		}
		return lowerCase(str.substring(0, 1)) + str.substring(1);
	}

  /**
	 * @description <p>Converts a String to upper case as per {@link String#toUpperCase()}.</p>
	 * <p/>
	 * <p>A {@code null} input String returns {@code null}.</p>
	 * <p/>
	 * <pre>
	 * CMN_UTIL_String.upperCase(null)  = null
	 * CMN_UTIL_String.upperCase("")    = ""
	 * CMN_UTIL_String.upperCase("aBc") = "ABC"
	 * </pre>
	 * <p/>
	 * <p><strong>Note:</strong> As described in the documentation for {@link String#toUpperCase()},
	 * the result of this method is affected by the current locale.
	 * For platform-independent case transformations, the method {@link #lowerCase(String, Locale)}
	 * should be used with a specific locale (e.g. {@link Locale#ENGLISH}).</p>
	 *
	 * @param str the String to upper case, may be null
	 *
	 * @return the upper cased String, {@code null} if null String input
	 */
	global static String upperCase(String str)
	{
		if(str == null)
		{
			return null;
		}
		return str.toUpperCase();
	}

  /**
	 * @description ensures char is in start of string
	 *
	 * @param str as input
	 * @param charc as input
	 *
	 * @return string with ensure char at start of string
	 */
	global static String ensureStringStartsEndsWithChar(
			String str,
			String charc
	)
	{
		String returnStr = str;
		if(returnStr != null && charc != null)
		{
			returnStr = CMN_UTIL_String.startsWith(str, charc)
					? returnStr
					: charc + returnStr;
			returnStr = CMN_UTIL_String.endsWith(str, charc)
					? returnStr
					: returnStr + charc;
		}
		return returnStr;
	}

  /**
	 * @description returns input string as array of chars
	 *
	 * @param str as input
	 *
	 * @return char array based on input string
	 */
	global static String[] toCharArray(String str)
	{
		List<String> strs = new List<String>();
		if(str != null && str.length() > 0)
		{
			for(Integer i = 0; i < str.length(); i++)
			{
				strs.add(str.substring(i, i + 1));
			}
		}
		return strs;
	}

  /**
	 * @description input string and returns trimmed string in lowercase
	 *
	 * @param str as input
	 *
	 * @return string of trimmed lowercase based on input
	 */
	global static String trimLower(String str)
	{
		return CMN_UTIL_String.lowerCase(CMN_UTIL_String.trim(str));
	}

  /**
	 * @description stripMarkup(null) -> null
	 * stripMarkup('') -> ''
	 * stripMarkup('Title!   ABC 123') -> 'Title! ABC 123'
	 * stripMarkup('<html><body><h1>Title!</h1><p>ABC 123</p></html>') -> 'Title! ABC 123'
	 *
	 * @param str as input
	 *
	 * @return string stripped of markup
	 */
	global static String stripMarkup(String str)
	{
		String returnValue = null;
		if(str != null)
		{
			returnValue = CMN_UTIL_String.trim(
					Pattern.compile('[ ]{2,}')
							.matcher(Pattern.compile('<(.|\\n)*?>').matcher(str).replaceAll(' '))
							.replaceAll(' ')
			);
		}
		return returnValue;
	}

  /**
	 * @description generated as random string used for testing
	 *
	 * @param len as input
	 *
	 * @return returned randomly generated string based on input length
	 */
	global static String generateRandomString(Integer len)
	{
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

		String randStr = EMPTY;

		while(randStr.length() < len)
		{
			Integer idx = Math.mod(
					Math.abs(Crypto.getRandomInteger()),
					chars.length()
			);
			randStr += chars.substring(idx, idx + 1);
		}
		return randStr;
	}

  /**
	 * @description Will return and Id if the string is a valid Id else null
	 *
	 * @param stringId as input
	 *
	 * @return Id
	 */
	global static Id validateId(String stringId)
	{
		Id validatedId = null;

		try
		{
			validatedId = Id.valueOf(stringId);
		}
		catch(Exception error)
		{
		        System.debug(LoggingLevel.INFO, 'Do nothing here as the conversion to Id failed');
		}

		return validatedId;
	}

  /**
	 * @description Puts ellipses in input strings that are longer than than maxCharacters. Shorter strings or
	 * 			null is returned unchanged.
	 *
	 * @param input the input String that may be subjected to shortening
	 * @param maxCharacters the maximum characters that are acceptable for the unshortended String. Must be at least 3, otherwise a String with ellipses is too long already.
	 * @param charactersAfterEllipsis the number of characters that should appear after the ellipsis (0 or larger)
	 *
	 * @return the truncated String with trailing ellipses
	 */
	global static String ellipsisTrim(
			String input,
			Integer maxCharacters,
			Integer charactersAfterEllipsis
	)
	{
		String ellipsisCharacters = '...';

		Integer ellipsisCharactersLength = ellipsisCharacters.length();

		if(maxCharacters < ellipsisCharactersLength)
		{
			throw new IllegalArgumentException(
					'maxCharacters must be at least ' +
							ellipsisCharactersLength +
							'because the ellipsis already take up ' +
							ellipsisCharactersLength +
							' characters'
			);
		}

		return input == null ||
				input.length() <= maxCharacters
				? input
				: input.substring(
						0,
						maxCharacters -
								ellipsisCharactersLength -
								charactersAfterEllipsis
				) +
						'...' +
						input.substring(input.length() - charactersAfterEllipsis);
	}

  /**
	 * @description Will trim the decimal point and any number after decimal point and return number in string format
	 *
	 * @param valueToTrim the decimal to trim
	 *
	 * @return A string containing trimmed decimal
	 */
	global static String trimDecimal(Decimal valueToTrim)
	{
		return trimDecimal(String.valueOf(valueToTrim));
	}

  /**
	 * @description Will trim the decimal point and any number after decimal point and return number in string format
	 *
	 * @param valueToTrim the decimal to trim
	 *
	 * @return A string containing trimmed decimal
	 */
	global static String trimDecimal(String valueToTrim)
	{
		return valueToTrim.remove(valueToTrim.substringAfterLast(DOT)).remove(DOT);
	}
}