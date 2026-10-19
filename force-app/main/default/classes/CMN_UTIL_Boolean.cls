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
global class CMN_UTIL_Boolean {
  /**
   * @description <p>Checks if a {@code Boolean} value is {@code false},
   * handling {@code null} by returning {@code false}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.isFalse(Boolean.TRUE)  = false
   *   BooleanUtils.isFalse(Boolean.FALSE) = true
   *   BooleanUtils.isFalse(null)          = false
   * </pre>
   *
   * @param bool the boolean to check, null returns {@code false}
   *
   * @return {@code true} only if the input is non-null and false
   * @since 2.1
   */
  global static Boolean isFalse(Boolean bool) {
    if (bool == null) {
      return false;
    }
    return !bool;
  }

  /**
   * @description <p>Checks if a {@code Boolean} value is <i>not</i> {@code false},
   * handling {@code null} by returning {@code true}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.isNotFalse(Boolean.TRUE)  = true
   *   BooleanUtils.isNotFalse(Boolean.FALSE) = false
   *   BooleanUtils.isNotFalse(null)          = true
   * </pre>
   *
   * @param bool the boolean to check, null returns {@code true}
   *
   * @return {@code true} if the input is null or true
   * @since 2.3
   */
  global static Boolean isNotFalse(Boolean bool) {
    if (bool == null) {
      return true;
    }
    return bool;
  }

  /**
   * @description <p>Checks if a {@code Boolean} value is <i>not</i> {@code true},
   * handling {@code null} by returning {@code true}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.isNotTrue(Boolean.TRUE)  = false
   *   BooleanUtils.isNotTrue(Boolean.FALSE) = true
   *   BooleanUtils.isNotTrue(null)          = true
   * </pre>
   *
   * @param bool the boolean to check, null returns {@code true}
   *
   * @return {@code true} if the input is null or false
   * @since 2.3
   */
  global static Boolean isNotTrue(Boolean bool) {
    if (bool == null) {
      return true;
    }
    return !bool;
  }

  /**
   * @description <p>Checks if a {@code Boolean} value is {@code true},
   * handling {@code null} by returning {@code false}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.isTrue(Boolean.TRUE)  = true
   *   BooleanUtils.isTrue(Boolean.FALSE) = false
   *   BooleanUtils.isTrue(null)          = false
   * </pre>
   *
   * @param bool the boolean to check, null returns {@code false}
   *
   * @return {@code true} only if the input is non-null and true
   * @since 2.1
   */
  global static Boolean isTrue(Boolean bool) {
    if (bool == null) {
      return false;
    }
    return bool;
  }

  /**
   * @description <p>Negates the specified boolean.</p>
   * <p/>
   * <p>If {@code null} is passed in, {@code null} will be returned.</p>
   * <p/>
   * <p>NOTE: This returns null and will throw a NullPointerException if unboxed to a boolean. </p>
   * <p/>
   * <pre>
   *   BooleanUtils.negate(Boolean.TRUE)  = Boolean.FALSE;
   *   BooleanUtils.negate(Boolean.FALSE) = Boolean.TRUE;
   *   BooleanUtils.negate(null)          = null;
   * </pre>
   *
   * @param bool the Boolean to negate, may be null
   *
   * @return the negated Boolean, or {@code null} if {@code null} input
   */
  global static Boolean negate(Boolean bool) {
    if (bool == null) {
      return null;
    }
    return !bool;
  }

  /**
   * @description <p>Converts a Boolean to a boolean handling {@code null}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toBooleanDefaultIfNull(Boolean.TRUE, false) = true
   *   BooleanUtils.toBooleanDefaultIfNull(Boolean.FALSE, true) = false
   *   BooleanUtils.toBooleanDefaultIfNull(null, true)          = true
   * </pre>
   *
   * @param bool the boolean to convert
   * @param defaultVal the boolean value to return if {@code null}
   *
   * @return {@code true} or {@code false}
   */
  global static Boolean toBooleanDefaultIfNull(
    Boolean bool,
    Boolean defaultVal
  ) {
    if (bool == null) {
      return defaultVal;
    }
    return bool;
  }

  /**
   * @description <p>Converts an int to a boolean using the convention that {@code zero}
   * is {@code false}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toBoolean(0) = false
   *   BooleanUtils.toBoolean(1) = true
   *   BooleanUtils.toBoolean(2) = true
   * </pre>
   *
   * @param value the int to convert
   *
   * @return {@code true} if non-zero, {@code false}
   *  if zero
   */
  global static Boolean toBoolean(Integer value) {
    if (value == null) {
      return false;
    }
    return value != 0;
  }

  /**
   * @description <p>Converts a String to a boolean (optimised for performance).</p>
   * <p/>
   * <p>{@code 'true'}, {@code 'on'}, {@code 'y'}, {@code 't'} or {@code 'yes'}
   * (case insensitive) will return {@code true}. Otherwise,
   * {@code false} is returned.</p>
   * <p/>
   * <p>This method performs 4 times faster (JDK1.4) than
   * {@code Boolean.valueOf(String)}. However, this method accepts
   * 'on' and 'yes', 't', 'y' as true values.
   * <p/>
   * <pre>
   *   BooleanUtils.toBoolean(null)    = false
   *   BooleanUtils.toBoolean("true")  = true
   *   BooleanUtils.toBoolean("TRUE")  = true
   *   BooleanUtils.toBoolean("tRUe")  = true
   *   BooleanUtils.toBoolean("on")    = true
   *   BooleanUtils.toBoolean("yes")   = true
   *   BooleanUtils.toBoolean("false") = false
   *   BooleanUtils.toBoolean("x gti") = false
   *   BooleanUtils.toBooleanObject("y") = true
   *   BooleanUtils.toBooleanObject("n") = false
   *   BooleanUtils.toBooleanObject("t") = true
   *   BooleanUtils.toBooleanObject("f") = false
   * </pre>
   *
   * @param value the String to check
   *
   * @return the boolean value of the string, {@code false} if no match or the String is null
   */
  global static Boolean stringToBoolean(String value) {
    if (value == null) {
      return false;
    }
    return (CMN_UTIL_String.equalsIgnoreCase(value, 'true'));
  }

  /**
   * @description converts an int to a boolean specifying  the conversion values.
   *
   * @param value the Integer to convert, may be null
   * @param trueValue the value to match for true, may be null
   * @param falseValue the value to match for false, may be null
   *
   * @return true or false
   * @throws java.lang.IllegalArgumentException - if no match
   */
  global static Boolean toBoolean(
    Integer value,
    Integer trueValue,
    Integer falseValue
  ) {
    if (value == trueValue) {
      return true;
    } else if (value == falseValue) {
      return false;
    }
    throw new IllegalArgumentException();
  }

  /**
   * @description <p>Converts a boolean to an int using the convention that
   * {@code zero} is {@code false}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toInteger(true)  = 1
   *   BooleanUtils.toInteger(false) = 0
   * </pre>
   *
   * @param bool the boolean to convert
   *
   * @return one if {@code true}, zero if {@code false}
   */
  global static Integer toInteger(Boolean bool) {
    if (bool == null) {
      throw new IllegalArgumentException();
    } else if (bool) {
      return 1;
    }
    return 0;
  }

  /**
   * @description <p>Converts a Boolean to a String returning {@code 'yes'},
   * {@code 'no'}, or {@code null}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toStringYesNo(Boolean.TRUE)  = "yes"
   *   BooleanUtils.toStringYesNo(Boolean.FALSE) = "no"
   *   BooleanUtils.toStringYesNo(null)          = null;
   * </pre>
   *
   * @param bool the Boolean to check
   *
   * @return {@code 'yes'}, {@code 'no'}, or {@code null}
   */
  global static String toStringYesNo(Boolean bool) {
    if (bool == null) {
      return null;
    } else if (bool) {
      return 'yes';
    }
    return 'no';
  }

  /**
   * @description <p>Converts a boolean to a String returning {@code 'Y'}
   * or {@code 'N'}.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toStringYesNo(true)   = "Y"
   *   BooleanUtils.toStringYesNo(false)  = "N"
   * </pre>
   *
   * @param bool the Boolean to check
   *
   * @return {@code 'Y'}, {@code 'N'}, or {@code null}
   */
  global static String toStringYn(Boolean bool) {
    if (bool == null) {
      return null;
    } else if (bool) {
      return 'Y';
    }
    return 'N';
  }

  /**
   * @description <p>Converts a boolean to a String returning one of the input Strings.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.toString(true, "true", "false")   = "true"
   *   BooleanUtils.toString(false, "true", "false")  = "false"
   * </pre>
   *
   * @param bool the Boolean to check
   * @param trueString the String to return if {@code true}, may be {@code null}
   * @param falseString the String to return if {@code false}, may be {@code null}
   *
   * @return one of the two input Strings
   */
  global static String toString(
    Boolean bool,
    String trueString,
    String falseString
  ) {
    if (bool == null) {
      return null;
    } else if (bool) {
      return trueString;
    }
    return falseString;
  }

  /**
   * @description <p>Performs an xor on an array of Booleans.</p>
   * <p/>
   * <pre>
   *   BooleanUtils.xor(new Boolean[] { Boolean.TRUE, Boolean.TRUE })   = Boolean.FALSE
   *   BooleanUtils.xor(new Boolean[] { Boolean.FALSE, Boolean.FALSE }) = Boolean.FALSE
   *   BooleanUtils.xor(new Boolean[] { Boolean.TRUE, Boolean.FALSE })  = Boolean.TRUE
   * </pre>
   *
   * @param booleanArray an array of {@code Boolean}s
   *
   * @return {@code true} if the xor is successful.
   * @throws IllegalArgumentException if {@code array} is {@code null}
   * @throws IllegalArgumentException if {@code array} is empty.
   * @throws IllegalArgumentException if {@code array} contains a {@code null}
   */
  global static Boolean xor(Boolean[] booleanArray) {
    if ((booleanArray == null) || booleanArray.isEmpty()) {
      throw new IllegalArgumentException();
    }

    Boolean firstItem = booleanArray[0];

    for (Boolean bool : booleanArray) {
      if (bool != firstItem) {
        return false;
      }
    }
    return true;
  }
}