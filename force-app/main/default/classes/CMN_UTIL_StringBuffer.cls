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
 * A sequence of characters.
 * A string buffer is like a {@link String}, but can be modified. At any
 * point in time it contains some particular sequence of characters, but
 * the length and content of the sequence can be changed through certain
 * method calls.
 * <p/>
 * String buffers are safe for use. The methods
 * are synchronized where necessary so that all the operations on any
 * particular instance behave as if they occur in some serial order
 * that is consistent with the order of the method calls made.
 * <p/>
 * <p/>
 * <p/>
 * The principal operations on a {@code StringBuffer} are the
 * {@code append} and {@code insert} methods, which are
 * overloaded so as to accept data of any type. Each effectively
 * converts a given datum to a string and then appends or inserts the
 * characters of that string to the string buffer. The
 * {@code append} method always adds these characters at the end
 * of the buffer; the {@code insert} method adds the characters at
 * a specified point.
 * <p/>
 * For example, if {@code z} refers to a string buffer object
 * whose current contents are {@code "start"}, then
 * the method call {@code z.append("le")} would cause the string
 * buffer to contain {@code "startle"}, whereas
 * {@code z.insert(4, "le")} would alter the string buffer to
 * contain {@code "starlet"}.
 * <p/>
 * In general, if sb refers to an instance of a {@code StringBuffer},
 * then {@code sb.append(x)} has the same effect as
 * {@code sb.insert(sb.length(), x)}.
 * <p/>
 * Every string buffer has a capacity. As long as the length of the
 * character sequence contained in the string buffer does not exceed
 * the capacity, it is not necessary to allocate a new internal
 * buffer array. If the internal buffer overflows, it is
 * automatically made larger.
 * <p/>
 * Unless otherwise noted, passing a {@code null} argument to a constructor
 * or method in this class will cause a {@link NullPointerException} to be
 * thrown.
 * <p/>
 * The {@code StringBuilder} class should generally be used in preference to
 * this one, as it supports all of the same operations but it is faster, as
 * it performs no synchronization.
 * <p/>
 * <p>VCCC-378</p>
 */
public class CMN_UTIL_StringBuffer {
  private String theString;

  public CMN_UTIL_StringBuffer() {
    this('');
  }

  /**
   * @description append to string
   *
   * @param str as input
   */
  public CMN_UTIL_StringBuffer(String str) {
    theString = str;
  }

  /**
   * @description append to string
   *
   * @param d as input
   */
  public CMN_UTIL_StringBuffer(Decimal d) {
    theString = '' + d;
  }

  /**
   * @description append to string
   *
   * @param d as input
   */
  public CMN_UTIL_StringBuffer(Double d) {
    theString = '' + d;
  }

  /**
   * @description append to string
   *
   * @param l as input
   */
  public CMN_UTIL_StringBuffer(Long l) {
    theString = '' + l;
  }

  /**
   * @description append to string
   *
   * @param i as input
   */
  public CMN_UTIL_StringBuffer(Integer i) {
    theString = '' + i;
  }

  /**
   * @description append to string
   *
   * @param b as input
   */
  public CMN_UTIL_StringBuffer(Blob b) {
    theString = '' + b;
  }

  /**
   * @description append to string
   *
   * @param b as input
   */
  public CMN_UTIL_StringBuffer(Boolean b) {
    theString = '' + b;
  }

  /**
   * @description append to string
   *
   * @param d as input
   */
  public CMN_UTIL_StringBuffer(Date d) {
    theString = '' + d;
  }

  /**
   * @description append to string
   *
   * @param d as input
   */
  public CMN_UTIL_StringBuffer(Datetime d) {
    theString = '' + d;
  }

  /**
   * @description append to string
   *
   * @param id as input
   */
  public CMN_UTIL_StringBuffer(Id id) {
    theString = '' + id;
  }

  /**
   * @description append to string
   *
   * @param t as input
   */
  public CMN_UTIL_StringBuffer(Time t) {
    theString = '' + t;
  }

  /**
   * @description Appends the specified {@code CharSequence} to this
   * sequence.
   * <p>
   * The characters of the {@code CharSequence} argument are appended,
   * in order, increasing the length of this sequence by the length of the
   * argument.
   * <p/>
   * <p>The result of this method is exactly the same as if it were an
   * invocation of this.append(s, 0, s.length());
   * <p/>
   * <p>This method synchronizes on {@code this}, the destination
   * object, but does not synchronize on the source ({@code s}).
   * <p/>
   * <p>If {@code s} is {@code null}, then the four characters
   * {@code "null"} are appended.
   *
   * @param str the {@code CharSequence} to append.
   *
   * @return a reference to this inner string
   */
  public CMN_UTIL_StringBuffer append(String str) {
    theString += str;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param d as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Decimal d) {
    theString += d;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param d as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Double d) {
    theString += d;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param l as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Long l) {
    theString += l;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param i as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Integer i) {
    theString += i;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param b as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Blob b) {
    theString += b;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param b as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Boolean b) {
    theString += b;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param d as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Date d) {
    theString += d;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param d as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Datetime d) {
    theString += d;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param id as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Id id) {
    theString += id;
    return this;
  }

  /**
   * @description append to string and return
   *
   * @param t as input
   *
   * @return this string buffer instance
   */
  public CMN_UTIL_StringBuffer append(Time t) {
    theString += t;
    return this;
  }

  /**
   * @description toString implementation
   *
   * @return string of the buffer
   */
  public String toStr() {
    return theString;
  }
}