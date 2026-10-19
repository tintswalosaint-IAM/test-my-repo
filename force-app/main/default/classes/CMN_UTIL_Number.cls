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
global class CMN_UTIL_Number {
  /**
   * @description number format exception
   */
  global class NumberFormatException extends Exception {
  }

  global static final Integer MAX_INTEGER = 2147483647;
  global static final Integer MIN_INTEGER = -2147483647;
  global static final CMN_UTIL_NumberRange.IntegerRange MAX_INTEGER_RANGE = new CMN_UTIL_NumberRange.IntegerRange(
    MIN_INTEGER,
    MAX_INTEGER
  );

  global static final Long MAX_LONG = 9223372036854775807L;
  global static final Long MIN_LONG = -9223372036854775807L;
  global static final CMN_UTIL_NumberRange.LongRange MAX_LONG_RANGE = new CMN_UTIL_NumberRange.LongRange(
    MIN_LONG,
    MAX_LONG
  );

  /**
   * @description Parses the string argument as a signed integer in the radix
   * specified by the second argument. The characters in the string
   * must all be digits of the specified radix (as determined by
   * whether {@link java.lang.Character#digit(char, int)} returns a
   * non-negative value), except that the first character may be an
   * ASCII minus sign {@code '-'} ({@code '\u005Cu002D'}) to
   * indicate a negative value or an ASCII plus sign {@code '+'}
   * ({@code '\u005Cu002B'}) to indicate a positive value. The
   * resulting integer value is returned.
   * <p/>
   * <p>An exception of type {@code NumberFormatException} is
   * thrown if any of the following situations occurs:
   * <ul>
   * <li>The first argument is {@code null} or is a string of
   * length zero.
   * <p/>
   * <li>The radix is either smaller than
   * {@link java.lang.Character#MIN_RADIX} or
   * larger than {@link java.lang.Character#MAX_RADIX}.
   * <p/>
   * <li>Any character of the string is not a digit of the specified
   * radix, except that the first character may be a minus sign
   * {@code '-'} ({@code '\u005Cu002D'}) or plus sign
   * {@code '+'} ({@code '\u005Cu002B'}) provided that the
   * string is longer than length 1.
   * <p/>
   * <li>The value represented by the string is not a value of type
   * {@code int}.
   * </ul>
   * <p/>
   * <p>Examples:
   * <blockquote><pre>
   * parseInt("0", 10) returns 0
   * parseInt("473", 10) returns 473
   * parseInt("+42", 10) returns 42
   * parseInt("-0", 10) returns 0
   * parseInt("-FF", 16) returns -255
   * parseInt("1100110", 2) returns 102
   * parseInt("2147483647", 10) returns 2147483647
   * parseInt("-2147483648", 10) returns -2147483648
   * parseInt("2147483648", 10) throws a NumberFormatException
   * parseInt("99", 8) throws a NumberFormatException
   * parseInt("Kona", 10) throws a NumberFormatException
   * parseInt("Kona", 27) returns 411787
   * </pre></blockquote>
   *
   * @param str the {@code String} containing the integer
   *                  representation to be parsed
   * @param radix the radix to be used while parsing {@code s}.
   *
   * @return the integer represented by the string argument in the
   *             specified radix.
   * @exception  NumberFormatException if the {@code String}
   *             does not contain a parsable {@code int}.
   */
  global static Integer parseInt(String str, Integer radix) {
    return parseLong(str, radix).intValue();
  }

  /**
   * @description Parses the string argument as a signed decimal {@code long}.
   * The characters in the string must all be decimal digits, except
   * that the first character may be an ASCII minus sign {@code '-'}
   * ({@code \u005Cu002D'}) to indicate a negative value or an
   * ASCII plus sign {@code '+'} ({@code '\u005Cu002B'}) to
   * indicate a positive value. The resulting {@code long} value is
   * returned, exactly as if the argument and the radix {@code 10}
   * were given as arguments to the {@link
   * #parseLong(java.lang.String, int)} method.
   * <p/>
   * <p>Note that neither the character {@code L}
   * ({@code '\u005Cu004C'}) nor {@code l}
   * ({@code '\u005Cu006C'}) is permitted to appear at the end
   * of the string as a type indicator, as would be permitted in
   * Java programming language source code.
   *
   * @param str a {@code String} containing the {@code long}
   *             representation to be parsed
   * @param radix as input
   *
   * @return the {@code long} represented by the argument in
   *             decimal.
   * @throws     NumberFormatException  if the string does not contain a
   *             parsable {@code long}.
   */
  global static Long parseLong(String str, Integer radix) {
    str = CMN_UTIL_String.upperCase(CMN_UTIL_String.trim(str));
    if (CMN_UTIL_String.isBlank(str)) {
      throw new NumberFormatException();
    }
    if (radix < 2 || radix > 36) {
      throw new IllegalArgumentException(
        'invalid radix parameter: ' +
        radix +
        '; radix must be >= 2 and <= 36'
      );
    }
    Boolean isNegative = false;
    if (CMN_UTIL_String.startsWith(str, '-')) {
      isNegative = true;
      str = CMN_UTIL_String.removeStart(str, '-');
    }
    String validChars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      .substring(0, radix);
    if (!CMN_UTIL_String.containsOnly(str, validChars)) {
      throw new NumberFormatException(
        'Invalid characters found in number: ' +
        str +
        ', with radix = ' +
        radix
      );
    }
    final Integer LENGTH = CMN_UTIL_String.length(str);
    Long returnValue = 0;
    for (Integer i = 0; i < LENGTH; i++) {
      returnValue += (validChars.indexOf(
          str.substring(LENGTH - i - 1, LENGTH - i)
        ) * Math.pow(radix, i))
        .longValue();
    }
    if (isNegative) {
      returnValue = -returnValue;
    }
    return returnValue;
  }

  /**
   * @description Returns a string representation of the integer argument as an
   * unsigned integer in base&nbsp;2.
   * <p/>
   * <p>The unsigned integer value is the argument plus 2<sup>32</sup>
   * if the argument is negative; otherwise it is equal to the
   * argument.  This value is converted to a string of ASCII digits
   * in binary (base&nbsp;2) with no extra leading {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Integer#parseUnsignedInt(String, int)
   * Integer.parseUnsignedInt(s, 2)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * characters {@code '0'} ({@code '\u005Cu0030'}) and {@code
   * '1'} ({@code '\u005Cu0031'}) are used as binary digits.
   *
   * @param i an integer to be converted to a string.
   *
   * @return the string representation of the unsigned integer value
   *          represented by the argument in binary (base&nbsp;2).
   * @since   JDK1.0.2
   */
  global static String toBinaryString(Integer i) {
    return toString(i, 2);
  }

  /**
   * @description Returns a string representation of the integer argument as an
   * unsigned integer in base&nbsp;8.
   * <p/>
   * <p>The unsigned integer value is the argument plus 2<sup>32</sup>
   * if the argument is negative; otherwise, it is equal to the
   * argument.  This value is converted to a string of ASCII digits
   * in octal (base&nbsp;8) with no extra leading {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Integer#parseUnsignedInt(String, int)
   * Integer.parseUnsignedInt(s, 8)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * following characters are used as octal digits:
   * <p/>
   * <blockquote>
   * {@code 01234567}
   * </blockquote>
   * <p/>
   * These are the characters {@code '\u005Cu0030'} through
   * {@code '\u005Cu0037'}.
   *
   * @param i an integer to be converted to a string.
   *
   * @return the string representation of the unsigned integer value
   *          represented by the argument in octal (base&nbsp;8).
   */
  global static String toOctalString(Integer i) {
    return toString(i, 8);
  }

  /**
   * @description Returns a string representation of the integer argument as an
   * unsigned integer in base&nbsp;16.
   * <p/>
   * <p>The unsigned integer value is the argument plus 2<sup>32</sup>
   * if the argument is negative; otherwise, it is equal to the
   * argument.  This value is converted to a string of ASCII digits
   * in hexadecimal (base&nbsp;16) with no extra leading
   * {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Integer#parseUnsignedInt(String, int)
   * Integer.parseUnsignedInt(s, 16)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * following characters are used as hexadecimal digits:
   * <p/>
   * <blockquote>
   *  {@code 0123456789abcdef}
   * </blockquote>
   * <p/>
   * These are the characters {@code '\u005Cu0030'} through
   * {@code '\u005Cu0039'} and {@code '\u005Cu0061'} through
   * {@code '\u005Cu0066'}. If uppercase letters are
   * desired, the {@link java.lang.String#toUpperCase()} method may
   * be called on the result:
   * <p/>
   * <blockquote>
   *  {@code Integer.toHexString(n).toUpperCase()}
   * </blockquote>
   *
   * @param i an integer to be converted to a string.
   *
   * @return the string representation of the unsigned integer value
   *          represented by the argument in hexadecimal (base&nbsp;16).
   */
  global static String toHexString(Integer i) {
    return toString(i, 16);
  }

  /**
   * @description Returns a string representation of the first argument in the
   * radix specified by the second argument.
   * <p/>
   * <p>If the radix is smaller than {@code Character.MIN_RADIX}
   * or larger than {@code Character.MAX_RADIX}, then the radix
   * {@code 10} is used instead.
   * <p/>
   * <p>If the first argument is negative, the first element of the
   * result is the ASCII minus character {@code '-'}
   * ({@code '\u005Cu002D'}). If the first argument is not
   * negative, no sign character appears in the result.
   * <p/>
   * <p>The remaining characters of the result represent the magnitude
   * of the first argument. If the magnitude is zero, it is
   * represented by a single zero character {@code '0'}
   * ({@code '\u005Cu0030'}); otherwise, the first character of
   * the representation of the magnitude will not be the zero
   * character.  The following ASCII characters are used as digits:
   * <p/>
   * <blockquote>
   *   {@code 0123456789abcdefghijklmnopqrstuvwxyz}
   * </blockquote>
   * <p/>
   * These are {@code '\u005Cu0030'} through
   * {@code '\u005Cu0039'} and {@code '\u005Cu0061'} through
   * {@code '\u005Cu007A'}. If {@code radix} is
   * <var>N</var>, then the first <var>N</var> of these characters
   * are used as radix-<var>N</var> digits in the order shown. Thus,
   * the digits for hexadecimal (radix 16) are
   * {@code 0123456789abcdef}. If uppercase letters are
   * desired, the {@link java.lang.String#toUpperCase()} method may
   * be called on the result:
   * <p/>
   * <blockquote>
   *  {@code Integer.toString(n, 16).toUpperCase()}
   * </blockquote>
   *
   * @param i an integer to be converted to a string.
   * @param radix the radix to use in the string representation.
   *
   * @return a string representation of the argument in the specified radix.
   */
  global static String toString(Integer i, Integer radix) {
    if (i == null) {
      return null;
    }
    return toString((Long) i, radix);
  }

  /**
   * @description Returns a string representation of the {@code long}
   * argument as an unsigned integer in base&nbsp;2.
   * <p/>
   * <p>The unsigned {@code long} value is the argument plus
   * 2<sup>64</sup> if the argument is negative; otherwise, it is
   * equal to the argument.  This value is converted to a string of
   * ASCII digits in binary (base&nbsp;2) with no extra leading
   * {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Long#parseUnsignedLong(String, int) Long.parseUnsignedLong(s,
   * 2)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * characters {@code '0'} ({@code '\u005Cu0030'}) and {@code
   * '1'} ({@code '\u005Cu0031'}) are used as binary digits.
   *
   * @param l a {@code long} to be converted to a string.
   *
   * @return the string representation of the unsigned {@code long}
   *          value represented by the argument in binary (base&nbsp;2).
   */
  global static String toBinaryString(Long l) {
    return toString(l, 2);
  }

  /**
   * @description Returns a string representation of the {@code long}
   * argument as an unsigned integer in base&nbsp;8.
   * <p/>
   * <p>The unsigned {@code long} value is the argument plus
   * 2<sup>64</sup> if the argument is negative; otherwise, it is
   * equal to the argument.  This value is converted to a string of
   * ASCII digits in octal (base&nbsp;8) with no extra leading
   * {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Long#parseUnsignedLong(String, int) Long.parseUnsignedLong(s,
   * 8)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * following characters are used as octal digits:
   * <p/>
   * <blockquote>
   *  {@code 01234567}
   * </blockquote>
   * <p/>
   * These are the characters {@code '\u005Cu0030'} through
   * {@code '\u005Cu0037'}.
   *
   * @param l a {@code long} to be converted to a string.
   *
   * @return the string representation of the unsigned {@code long}
   *          value represented by the argument in octal (base&nbsp;8).
   */
  global static String toOctalString(Long l) {
    return toString(l, 8);
  }

  /**
   * @description Returns a string representation of the {@code long}
   * argument as an unsigned integer in base&nbsp;16.
   * <p/>
   * <p>The unsigned {@code long} value is the argument plus
   * 2<sup>64</sup> if the argument is negative; otherwise, it is
   * equal to the argument.  This value is converted to a string of
   * ASCII digits in hexadecimal (base&nbsp;16) with no extra
   * leading {@code 0}s.
   * <p/>
   * <p>The value of the argument can be recovered from the returned
   * string {@code s} by calling {@link
   * Long#parseUnsignedLong(String, int) Long.parseUnsignedLong(s,
   * 16)}.
   * <p/>
   * <p>If the unsigned magnitude is zero, it is represented by a
   * single zero character {@code '0'} ({@code '\u005Cu0030'});
   * otherwise, the first character of the representation of the
   * unsigned magnitude will not be the zero character. The
   * following characters are used as hexadecimal digits:
   * <p/>
   * <blockquote>
   *  {@code 0123456789abcdef}
   * </blockquote>
   * <p/>
   * These are the characters {@code '\u005Cu0030'} through
   * {@code '\u005Cu0039'} and  {@code '\u005Cu0061'} through
   * {@code '\u005Cu0066'}.  If uppercase letters are desired,
   * the {@link java.lang.String#toUpperCase()} method may be called
   * on the result:
   * <p/>
   * <blockquote>
   *  {@code Long.toHexString(n).toUpperCase()}
   * </blockquote>
   *
   * @param l a {@code long} to be converted to a string.
   *
   * @return the string representation of the unsigned {@code long}
   *          value represented by the argument in hexadecimal
   *          (base&nbsp;16).
   * @since   JDK 1.0.2
   */
  global static String toHexString(Long l) {
    return toString(l, 16);
  }

  /**
   * @description Returns a string representation of the first argument in the
   * radix specified by the second argument.
   * <p/>
   * <p>If the radix is smaller than {@code Character.MIN_RADIX}
   * or larger than {@code Character.MAX_RADIX}, then the radix
   * {@code 10} is used instead.
   * <p/>
   * <p>If the first argument is negative, the first element of the
   * result is the ASCII minus sign {@code '-'}
   * ({@code '\u005Cu002d'}). If the first argument is not
   * negative, no sign character appears in the result.
   * <p/>
   * <p>The remaining characters of the result represent the magnitude
   * of the first argument. If the magnitude is zero, it is
   * represented by a single zero character {@code '0'}
   * ({@code '\u005Cu0030'}); otherwise, the first character of
   * the representation of the magnitude will not be the zero
   * character.  The following ASCII characters are used as digits:
   * <p/>
   * <blockquote>
   *   {@code 0123456789abcdefghijklmnopqrstuvwxyz}
   * </blockquote>
   * <p/>
   * These are {@code '\u005Cu0030'} through
   * {@code '\u005Cu0039'} and {@code '\u005Cu0061'} through
   * {@code '\u005Cu007a'}. If {@code radix} is
   * <var>N</var>, then the first <var>N</var> of these characters
   * are used as radix-<var>N</var> digits in the order shown. Thus,
   * the digits for hexadecimal (radix 16) are
   * {@code 0123456789abcdef}. If uppercase letters are
   * desired, the {@link java.lang.String#toUpperCase()} method may
   * be called on the result:
   * <p/>
   * <blockquote>
   *  {@code Long.toString(n, 16).toUpperCase()}
   * </blockquote>
   *
   * @param l a {@code long} to be converted to a string.
   * @param radix the radix to use in the string representation.
   *
   * @return a string representation of the argument in the specified radix.
   */
  global static String toString(Long l, Integer radix) {
    if (l == null) {
      return null;
    }
    if (radix < 2 || radix > 36) {
      throw new IllegalArgumentException(
        'invalid radix parameter: ' +
        radix +
        '; radix must be >= 2 and <= 36'
      );
    }
    return (l < 0 ? '-' : '') +
      toStringPrivate(
        Math.abs(l),
        radix,
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.substring(0, radix)
      );
  }

  /**
   * @description to string private utility method
   *
   * @param l as input
   * @param radix as input
   * @param validChars as input
   *
   * @return string from long radix and valid chars
   */
  private static String toStringPrivate(
    Long l,
    Integer radix,
    String validChars
  ) {
    Integer r = Math.mod(l, radix).intValue();
    String result;
    if (l - r == 0) {
      result = CMN_UTIL_String.charAt(validChars, r);
    } else {
      result =
        toStringPrivate(((l - r) / radix), radix, validChars) +
        CMN_UTIL_String.charAt(validChars, r);
    }
    return result;
  }
}