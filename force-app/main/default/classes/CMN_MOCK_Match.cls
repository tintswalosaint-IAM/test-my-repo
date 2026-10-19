/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * <p>VCCC-378</p>
 **/
public class CMN_MOCK_Match {
  private static List<CMN_MOCK_IMatcher> matchers = new List<CMN_MOCK_IMatcher>();

  /**
   * @description Matching
   * True when comparing method arg values to matchers, false when comparing absolute arg values.
   */
  public static Boolean Matching = false;

  /**
   * @description Used internally by the mocking framework, you shouldn't need to call this method directly.
   * Copies the registered matchers, and then switches matching mode off.
   *
   * @param expectedSize The expected number of matchers to be returned. If this does not match the actual value an expection is thrown.
   *
   * @return List<CMN_MOCK_IMatcher> The registered matchers, collected while in matching mode.
   */
  public static List<CMN_MOCK_IMatcher> getAndClearMatchers(
    Integer expectedSize
  ) {
    Matching = false;

    List<CMN_MOCK_IMatcher> returnValue = matchers.clone();
    matchers.clear();

    if (returnValue.size() != expectedSize) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'The number of matchers defined (' +
        returnValue.size() +
        ').' +
        ' does not match the number expected (' +
        expectedSize +
        ')\n' +
        'If you are using matchers all arguments must be passed in as matchers.\n' +
        'For example myList.add(CMN_MOCK_Match.anyInteger(), \'String\') should be defined as myList.add(CMN_MOCK_Match.anyInteger(), CMN_MOCK_Match.eq(\'String\')).'
      );
    }

    return returnValue;
  }

  /**
   * @description Used internally by the mocking framework, you shouldn't need to call this method directly.
   * Compares all supplied method arg values to the supplied target matchers.
   *
   * @param methodArg The arguments supplied when the method was called
   * @param targetMatchers The matchers the arguments need to be compared with
   * @throws CMN_MOCK_ApexMocks.ApexMocksException Thrown when methodArgValues is null/empty, targetMatchers is null, or their sizes don't match
   *
   * @return Boolean True if all arg values satisfy all of the supplied matchers.
   */
  public static Boolean matchesAllArgs(
    CMN_MOCK_MethodArgValues methodArg,
    List<CMN_MOCK_IMatcher> targetMatchers
  ) {
    validateArgs(methodArg, targetMatchers);

    Integer matchersSize = targetMatchers.size();
    for (Integer i = 0; i < matchersSize; i++) {
      Object argValue = methodArg.argValues[i];
      CMN_MOCK_IMatcher matcher = targetMatchers[i];

      if (!matcher.matches(argValue)) {
        return false;
      }
    }

    return true;
  }

  private static void validateArgs(
    CMN_MOCK_MethodArgValues methodArg,
    List<CMN_MOCK_IMatcher> targetMatchers
  ) {
    if (methodArg == null) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'MethodArgs cannot be null'
      );
    }

    if (methodArg.argValues == null) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'MethodArgs.argValues cannot be null'
      );
    }

    if (targetMatchers == null) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'Matchers cannot be null'
      );
    }

    if (targetMatchers.size() != methodArg.argValues.size()) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'MethodArgs and matchers must have the same count' +
        ', MethodArgs: (' +
        methodArg.argValues.size() +
        ') ' +
        methodArg.argValues +
        ', Matchers: (' +
        targetMatchers.size() +
        ') ' +
        targetMatchers
      );
    }
  }

  /**
   * @description Registers a matcher which will be stubbed/verified against.
   *
   * @param matcher The matcher that needs to be compared
   *
   * @return Object Always returns null. This can then be cast into the correct arg type
   * so that the right method is called on the mock objects.
   */
  public static Object matches(CMN_MOCK_IMatcher matcher) {
    Matching = true;
    matchers.add(matcher);

    return null;
  }

  /**
   * @description COMBINED MATCHER
   * The allOf, anyOf and noneOf methods are overloaded to provide fluent matcher calls for up to 4 matcher conditions.
   * To connect 5 or more, the List<Object> version directly.
   * Registers a matcher which will check if the method is called with an arg that matches allOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call,
   * the correct method is invoked. (You may need to cast down to your specific object type)public static Object allOf(Object o1, Object o2)
   */
  public static Object allOf(Object o1, Object o2) {
    return allOf(new List<Object>{ o1, o2 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches allOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object allOf(Object o1, Object o2, Object o3) {
    return allOf(new List<Object>{ o1, o2, o3 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches allOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   * @param o4 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object allOf(Object o1, Object o2, Object o3, Object o4) {
    return allOf(new List<Object>{ o1, o2, o3, o4 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches allOf
   *
   * @param o A list of dummy objects returned by registering other matchers
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object allOf(List<Object> o) {
    return combined(CMN_MOCK_MatcherDefinitions.Connective.ALL, o);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object anyOf(Object o1, Object o2) {
    return anyOf(new List<Object>{ o1, o2 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object anyOf(Object o1, Object o2, Object o3) {
    return anyOf(new List<Object>{ o1, o2, o3 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   * @param o4 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object anyOf(Object o1, Object o2, Object o3, Object o4) {
    return anyOf(new List<Object>{ o1, o2, o3, o4 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyOf
   *
   * @param o A list of dummy objects returned by registering other matchers
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object anyOf(List<Object> o) {
    return combined(CMN_MOCK_MatcherDefinitions.Connective.AT_LEAST_ONE, o);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches isNot
   *
   * @param o1 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object isNot(Object o1) {
    return noneOf(new List<Object>{ o1 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches noneOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object noneOf(Object o1, Object o2) {
    return noneOf(new List<Object>{ o1, o2 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches noneOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object noneOf(Object o1, Object o2, Object o3) {
    return noneOf(new List<Object>{ o1, o2, o3 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches noneOf
   *
   * @param o1 A dummy object returned by registering another matcher
   * @param o2 A dummy object returned by registering another matcher
   * @param o3 A dummy object returned by registering another matcher
   * @param o4 A dummy object returned by registering another matcher
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object noneOf(Object o1, Object o2, Object o3, Object o4) {
    return noneOf(new List<Object>{ o1, o2, o3, o4 });
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches noneOf
   *
   * @param o A list of dummy objects returned by registering other matchers
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object noneOf(List<Object> o) {
    return combined(CMN_MOCK_MatcherDefinitions.Connective.NONE, o);
  }

  private static Object combined(
    CMN_MOCK_MatcherDefinitions.Connective connectiveExpression,
    List<Object> o
  ) {
    return matches(
      new CMN_MOCK_MatcherDefinitions.Combined(
        connectiveExpression,
        (gatherMatchers(o))
      )
    );
  }

  private static List<CMN_MOCK_IMatcher> gatherMatchers(
    Object[] ignoredMatcherObjects
  ) {
    if (ignoredMatcherObjects == null || ignoredMatcherObjects.isEmpty()) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'Must register matchers to combine'
      );
    }

    //Each ignored matcher object represents a matcher that has been registered against CMN_MOCK_Match.matchers,
    //but is actually for the connective matchers.
    List<CMN_MOCK_IMatcher> innerMatchers = new List<CMN_MOCK_IMatcher>();

    Integer innerMatcherCount = ignoredMatcherObjects.size();
    while (innerMatchers.size() < innerMatcherCount) {
      if (matchers.isEmpty()) {
        throw new CMN_MOCK_ApexMocks.ApexMocksException(
          'Error reclaiming inner matchers for combined matcher. Wanted ' +
          innerMatcherCount +
          ' matchers but only got ' +
          innerMatchers
        );
      }

      CMN_MOCK_IMatcher innerMatcher = matchers.remove(matchers.size() - 1);

      //Add to the start of the list to preserve the order in which matchers were declared.
      //Note. Apex throws list index out of bounds if inserting an element into an empty list at index 0S
      if (!innerMatchers.isEmpty()) {
        innerMatchers.add(0, innerMatcher);
      } else {
        innerMatchers.add(innerMatcher);
      }
    }

    return innerMatchers;
  }

  /**
   * @description ALL OTHER MATCHER METHODS
   * Registers a matcher which will check if the method is called with an arg that matches eq
   *
   * @param toMatch The Object to be compared
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object eq(Object toMatch) {
    return matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqBoolean
   *
   * @param toMatch The Boolean to be compared
   *
   * @return Boolean A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Boolean eqBoolean(Boolean toMatch) {
    return (Boolean) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqDate
   *
   * @param toMatch The Date to be compared
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date eqDate(Date toMatch) {
    return (Date) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqDatetime
   *
   * @param toMatch The Datetime to be compared
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime eqDatetime(Datetime toMatch) {
    return (Datetime) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqDecimal
   *
   * @param toMatch The Decimal to be compared
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal eqDecimal(Decimal toMatch) {
    return (Decimal) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqDouble
   *
   * @param toMatch The Double to be compared
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double eqDouble(Double toMatch) {
    return (Double) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqId
   *
   * @param toMatch The Id to be compared
   *
   * @return Id A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Id eqId(Id toMatch) {
    return (Id) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqInteger
   *
   * @param toMatch The Integer to be compared
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer eqInteger(Integer toMatch) {
    return (Integer) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqList
   *
   * @param toMatch The List to be compared
   *
   * @return List A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static List<Object> eqList(List<Object> toMatch) {
    return (List<Object>) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqLong
   *
   * @param toMatch The Long to be compared
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long eqLong(Long toMatch) {
    return (Long) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqSObjectField
   *
   * @param toMatch The SObjectField to be compared
   *
   * @return SObjectField A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static SObjectField eqSObjectField(SObjectField toMatch) {
    return (SObjectField) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqSObjectType
   *
   * @param toMatch The SObjectType to be compared
   *
   * @return SObjectType A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static SObjectType eqSObjectType(SObjectType toMatch) {
    return (SObjectType) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches eqString
   *
   * @param toMatch The String to be compared
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String eqString(String toMatch) {
    return (String) matches(new CMN_MOCK_MatcherDefinitions.Eq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches refEq
   *
   * @param toMatch The Object to be compared
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object refEq(Object toMatch) {
    return matches(new CMN_MOCK_MatcherDefinitions.RefEq(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyBoolean
   *
   * @return Boolean A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Boolean anyBoolean() {
    return (Boolean) matches(new CMN_MOCK_MatcherDefinitions.AnyBoolean());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyDate
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date anyDate() {
    return (Date) matches(new CMN_MOCK_MatcherDefinitions.AnyDate());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyDatetime
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime anyDatetime() {
    return (Datetime) matches(new CMN_MOCK_MatcherDefinitions.AnyDatetime());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyDecimal
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal anyDecimal() {
    return (Decimal) matches(new CMN_MOCK_MatcherDefinitions.AnyDecimal());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyDouble
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double anyDouble() {
    return (Double) matches(new CMN_MOCK_MatcherDefinitions.AnyDouble());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyFieldSet
   *
   * @return Schema.FieldSet A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Schema.FieldSet anyFieldSet() {
    return (Schema.FieldSet) matches(
      new CMN_MOCK_MatcherDefinitions.AnyFieldSet()
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyId
   *
   * @return Id A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Id anyId() {
    return (Id) matches(new CMN_MOCK_MatcherDefinitions.AnyId());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyInteger
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer anyInteger() {
    return (Integer) matches(new CMN_MOCK_MatcherDefinitions.AnyInteger());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyList
   *
   * @return List A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static List<Object> anyList() {
    return (List<Object>) matches(new CMN_MOCK_MatcherDefinitions.AnyList());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyLong
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long anyLong() {
    return (Long) matches(new CMN_MOCK_MatcherDefinitions.AnyLong());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyObject
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object anyObject() {
    return matches(new CMN_MOCK_MatcherDefinitions.AnyObject());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anyString
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String anyString() {
    return (String) matches(new CMN_MOCK_MatcherDefinitions.AnyString());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anySObject
   *
   * @return SObject A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static SObject anySObject() {
    return (SObject) matches(new CMN_MOCK_MatcherDefinitions.AnySObject());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anySObjectField
   *
   * @return SObjectField A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static SObjectField anySObjectField() {
    return (SObjectField) matches(
      new CMN_MOCK_MatcherDefinitions.AnySObjectField()
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches anySObjectType
   *
   * @return SObjectType A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static SObjectType anySObjectType() {
    return (SObjectType) matches(
      new CMN_MOCK_MatcherDefinitions.AnySObjectType()
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateAfter (not inclusive)
   *
   * @param fromDate The Date to be compared
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateAfter(Date fromDate) {
    return dateAfter(fromDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateAfter
   *
   * @param fromDate The Date to be compared
   * @param inclusive Whether or not a Date equal to fromDate should be considered a match
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateAfter(Date fromDate, Boolean inclusive) {
    return (Date) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeAfter(fromDate, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateBefore (not inclusive)
   *
   * @param toDate The Date to be compared
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateBefore(Date toDate) {
    return dateBefore(toDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateBefore
   *
   * @param toDate The Date to be compared
   * @param inclusive Whether or not a Date equal to toDate should be considered a match
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateBefore(Date toDate, Boolean inclusive) {
    return (Date) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeBefore(toDate, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateBetween (not inclusive)
   *
   * @param fromDate The lower bound Date to be compared
   * @param toDate The upper bound Date to be compared
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateBetween(Date fromDate, Date toDate) {
    return dateBetween(fromDate, false, toDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches dateBetween
   *
   * @param fromDate The lower bound Date to be compared
   * @param inclusiveFrom Whether or not a Date equal to fromDate should be considered a match
   * @param toDate The upper bound Date to be compared
   * @param inclusiveTo Whether or not a Date equal to toDate should be considered a match
   *
   * @return Date A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Date dateBetween(
    Date fromDate,
    Boolean inclusiveFrom,
    Date toDate,
    Boolean inclusiveTo
  ) {
    return (Date) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        fromDate,
        inclusiveFrom,
        toDate,
        inclusiveTo
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeAfter (not inclusive)
   *
   * @param fromDate The Datetime to be compared
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeAfter(Datetime fromDate) {
    return datetimeAfter(fromDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeAfter
   *
   * @param fromDate The Datetime to be compared
   * @param inclusive Whether or not a Datetime equal to fromDate should be considered a match
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeAfter(Datetime fromDate, Boolean inclusive) {
    return (Datetime) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeAfter(fromDate, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeBefore (not inclusive)
   *
   * @param toDate The Datetime to be compared
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeBefore(Datetime toDate) {
    return datetimeBefore(toDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeBefore
   *
   * @param toDate The Datetime to be compared
   * @param inclusive Whether or not a Datetime equal to toDate should be considered a match
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeBefore(Datetime toDate, Boolean inclusive) {
    return (Datetime) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeBefore(toDate, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeBetween (not inclusive)
   *
   * @param fromDate The lower bound Datetime to be compared
   * @param toDate The upper bound Datetime to be compared
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeBetween(Datetime fromDate, Datetime toDate) {
    return datetimeBetween(fromDate, false, toDate, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches datetimeBetween
   *
   * @param fromDate The lower bound Datetime to be compared
   * @param inclusiveFrom Whether or not a Datetime equal to fromDate should be considered a match
   * @param toDate The upper bound Datetime to be compared
   * @param inclusiveTo Whether or not a Datetime equal to toDate should be considered a match
   *
   * @return Datetime A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Datetime datetimeBetween(
    Datetime fromDate,
    Boolean inclusiveFrom,
    Datetime toDate,
    Boolean inclusiveTo
  ) {
    return (Datetime) matches(
      new CMN_MOCK_MatcherDefinitions.DatetimeBetween(
        fromDate,
        inclusiveFrom,
        toDate,
        inclusiveTo
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalBetween (not inclusive)
   *
   * @param lower The lower number to be compared
   * @param upper The upper number to be compared
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalBetween(Decimal lower, Decimal upper) {
    return decimalBetween(lower, false, upper, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalBetween
   *
   * @param lower The lower number to be compared
   * @param inclusiveLower Whether or not a number equal to the lower bound should be considered a match
   * @param upper The upper number to be compared
   * @param inclusiveUpper Whether or not a number equal to the upper bound should be considered a match
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalBetween(
    Decimal lower,
    Boolean inclusiveLower,
    Decimal upper,
    Boolean inclusiveUpper
  ) {
    return (Decimal) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(
        lower,
        inclusiveLower,
        upper,
        inclusiveUpper
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalLessThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalLessThan(Decimal toMatch) {
    return decimalLessThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalLessThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalLessThan(Decimal toMatch, Boolean inclusive) {
    return (Decimal) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalMoreThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalMoreThan(Decimal toMatch) {
    return decimalMoreThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches decimalMoreThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Decimal A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Decimal decimalMoreThan(Decimal toMatch, Boolean inclusive) {
    return (Decimal) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleBetween (not inclusive)
   *
   * @param lower The lower number to be compared
   * @param upper The upper number to be compared
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleBetween(Double lower, Double upper) {
    return doubleBetween(lower, false, upper, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleBetween
   *
   * @param lower The lower number to be compared
   * @param inclusiveLower Whether or not a number equal to the lower bound should be considered a match
   * @param upper The upper number to be compared
   * @param inclusiveUpper Whether or not a number equal to the upper bound should be considered a match
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleBetween(
    Double lower,
    Boolean inclusiveLower,
    Double upper,
    Boolean inclusiveUpper
  ) {
    return (Double) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(
        lower,
        inclusiveLower,
        upper,
        inclusiveUpper
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleLessThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleLessThan(Double toMatch) {
    return doubleLessThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleLessThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleLessThan(Double toMatch, Boolean inclusive) {
    return (Double) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleMoreThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleMoreThan(Double toMatch) {
    return doubleMoreThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches doubleMoreThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Double A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Double doubleMoreThan(Double toMatch, Boolean inclusive) {
    return (Double) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches FieldSetEquivalentTo
   *
   * @param toMatch The fieldSet to be compared
   *
   * @return Schema.FieldSet A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Schema.FieldSet fieldSetEquivalentTo(Schema.FieldSet toMatch) {
    return (Schema.FieldSet) matches(
      new CMN_MOCK_MatcherDefinitions.FieldSetEquivalentTo(toMatch)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerBetween (not inclusive)
   *
   * @param lower The lower number to be compared
   * @param upper The upper number to be compared
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerBetween(Integer lower, Integer upper) {
    return integerBetween(lower, false, upper, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerBetween
   *
   * @param lower The lower number to be compared
   * @param inclusiveLower Whether or not a number equal to the lower bound should be considered a match
   * @param upper The upper number to be compared
   * @param inclusiveUpper Whether or not a number equal to the upper bound should be considered a match
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerBetween(
    Integer lower,
    Boolean inclusiveLower,
    Integer upper,
    Boolean inclusiveUpper
  ) {
    return (Integer) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(
        lower,
        inclusiveLower,
        upper,
        inclusiveUpper
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerLessThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerLessThan(Integer toMatch) {
    return integerLessThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerLessThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerLessThan(Integer toMatch, Boolean inclusive) {
    return (Integer) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerMoreThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerMoreThan(Integer toMatch) {
    return integerMoreThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches integerMoreThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Integer A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Integer integerMoreThan(Integer toMatch, Boolean inclusive) {
    return (Integer) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches isNotNull
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object isNotNull() {
    return matches(new CMN_MOCK_MatcherDefinitions.IsNotNull());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches isNull
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object isNull() {
    return matches(new CMN_MOCK_MatcherDefinitions.IsNull());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches listContains
   *
   * @param toMatch The list to be compared
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object listContains(Object toMatch) {
    return matches(new CMN_MOCK_MatcherDefinitions.ListContains(toMatch));
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches listIsEmpty
   *
   * @return Object A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked. (You may need to cast down to your specific object type)
   */
  public static Object listIsEmpty() {
    return matches(new CMN_MOCK_MatcherDefinitions.ListIsEmpty());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longBetween (not inclusive)
   *
   * @param lower The lower number to be compared
   * @param upper The upper number to be compared
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longBetween(Long lower, Long upper) {
    return longBetween(lower, false, upper, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longBetween
   *
   * @param lower The lower number to be compared
   * @param inclusiveLower Whether or not a number equal to the lower bound should be considered a match
   * @param upper The upper number to be compared
   * @param inclusiveUpper Whether or not a number equal to the upper bound should be considered a match
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longBetween(
    Long lower,
    Boolean inclusiveLower,
    Long upper,
    Boolean inclusiveUpper
  ) {
    return (Long) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalBetween(
        lower,
        inclusiveLower,
        upper,
        inclusiveUpper
      )
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longLessThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longLessThan(Long toMatch) {
    return longLessThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longLessThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longLessThan(Long toMatch, Boolean inclusive) {
    return (Long) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalLessThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longMoreThan (not inclusive)
   *
   * @param toMatch The number to be compared
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longMoreThan(Long toMatch) {
    return longMoreThan(toMatch, false);
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches longMoreThan
   *
   * @param toMatch The number to be compared
   * @param inclusive Whether or not a number equal to toMatch should be considered a match
   *
   * @return Long A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static Long longMoreThan(Long toMatch, Boolean inclusive) {
    return (Long) matches(
      new CMN_MOCK_MatcherDefinitions.DecimalMoreThan(toMatch, inclusive)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an SObject of specified SObjectType
   *
   * @param objectType The SObjectType to be compared
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject sObjectOfType(Schema.SObjectType objectType) {
    return (SObject) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectOfType(objectType)
    );
  }
  /**
   * @description Registers a matcher which will check if the method is called with an SObject
   *
   * @param toMatch A Map of SObjectFields to required values, to be compared to concrete SObject records
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject sObjectWith(Map<Schema.SObjectField, Object> toMatch) {
    return (SObject) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectWith(toMatch)
    );
  }
  /**
   * @description Registers a matcher which will check if the method is called with a list of SObject
   *
   * @param toMatch A list of Map of SObjectFields to required values, to be compared to concrete SObject records
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject[] sObjectsWith(
    List<Map<Schema.SObjectField, Object>> toMatch
  ) {
    return (SObject[]) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectsWith(toMatch, true)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with a list of SObject
   *
   * @param toMatch A list of Map of SObjectFields to required values, to be compared to concrete SObject records. Comparison can be order dependent
   * @param matchInOrder as input
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject[] sObjectsWith(
    List<Map<Schema.SObjectField, Object>> toMatch,
    Boolean matchInOrder
  ) {
    return (SObject[]) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectsWith(toMatch, matchInOrder)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an SObject
   *
   * @param toMatch The Id to be compared
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject sObjectWithId(Id toMatch) {
    return (SObject) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectWithId(toMatch)
    );
  }
  /**
   * @description Registers a matcher which will check if the method is called with an SObject
   *
   * @param toMatch The name to be compared
   *
   * @return SObject a dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked
   */
  public static SObject sObjectWithName(String toMatch) {
    return (SObject) matches(
      new CMN_MOCK_MatcherDefinitions.SObjectWithName(toMatch)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringContains
   *
   * @param toMatch The substring to be compared
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringContains(String toMatch) {
    return (String) matches(
      new CMN_MOCK_MatcherDefinitions.StringContains(toMatch)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringEndsWith
   *
   * @param toMatch The substring to be compared
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringEndsWith(String toMatch) {
    return (String) matches(
      new CMN_MOCK_MatcherDefinitions.StringEndsWith(toMatch)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringIsBlank
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringIsBlank() {
    return (String) matches(new CMN_MOCK_MatcherDefinitions.StringIsBlank());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringIsNotBlank
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringIsNotBlank() {
    return (String) matches(new CMN_MOCK_MatcherDefinitions.StringIsNotBlank());
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringMatches
   *
   * @param regEx The regex String to be compared
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringMatches(String regEx) {
    return (String) matches(
      new CMN_MOCK_MatcherDefinitions.StringMatches(regEx)
    );
  }

  /**
   * @description Registers a matcher which will check if the method is called with an arg that matches stringStartsWith
   *
   * @param toMatch The substring to be compared
   *
   * @return String A dummy object of the correct type, so that when called inline as part of a method call, the correct method is invoked.
   */
  public static String stringStartsWith(String toMatch) {
    return (String) matches(
      new CMN_MOCK_MatcherDefinitions.StringStartsWith(toMatch)
    );
  }
}