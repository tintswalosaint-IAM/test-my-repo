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
@IsTest(SeeAllData=false)
private class CMN_MOCK_Match_TEST {
  @IsTest
  private static void whenMatchesAllArgsWithOneMatchReturnsTrue() {
    //Given
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      new List<Object>{ null }
    );
    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch()
    };

    //When
    Boolean match = CMN_MOCK_Match.matchesAllArgs(argValues, targetMatchers);

    //Then
    System.assert(match);
  }

  @IsTest
  private static void whenMatchesAllArgsWithManyMatchesReturnsTrue() {
    //Given
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      new List<Object>{ null, null, null, null }
    );

    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch(),
      new AlwaysMatch(),
      new AlwaysMatch(),
      new AlwaysMatch()
    };

    //When
    Boolean match = CMN_MOCK_Match.matchesAllArgs(argValues, targetMatchers);

    //Then
    System.assert(match);
  }

  @IsTest
  private static void whenMatchesAllArgsWithOneMismatchReturnsFalse() {
    //Given
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      new List<Object>{ null }
    );
    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new NeverMatch()
    };

    //When
    Boolean match = CMN_MOCK_Match.matchesAllArgs(argValues, targetMatchers);

    //Then
    System.assert(!match);
  }

  @IsTest
  private static void whenMatchesAllArgsWithManyMismatchesReturnsFalse() {
    //Given
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      new List<Object>{ null, null, null, null }
    );

    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new NeverMatch(),
      new NeverMatch(),
      new NeverMatch(),
      new NeverMatch()
    };

    //When
    Boolean match = CMN_MOCK_Match.matchesAllArgs(argValues, targetMatchers);

    //Then
    System.assert(!match);
  }

  @IsTest
  private static void whenMatchesAllArgsWithMatchesAndMismatchesReturnsFalse() {
    //Given
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      new List<Object>{ null, null, null, null }
    );

    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch(),
      new AlwaysMatch(),
      new NeverMatch(),
      new AlwaysMatch()
    };

    //When
    Boolean match = CMN_MOCK_Match.matchesAllArgs(argValues, targetMatchers);

    //Then
    System.assert(!match);
  }

  @IsTest
  private static void whenMatchesAllArgsWithNullMethodArgsThrowsException() {
    //Given
    CMN_MOCK_MethodArgValues methodArg = null;
    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch()
    };

    //When
    try {
      CMN_MOCK_Match.matchesAllArgs(methodArg, targetMatchers);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      System.assertEquals('MethodArgs cannot be null', e.getMessage());
    }
  }

  @IsTest
  private static void whenMatchesAllArgsWithNullMethodArgsArgValuesThrowsException() {
    //Given
    CMN_MOCK_MethodArgValues methodArg = new CMN_MOCK_MethodArgValues(null);
    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch()
    };

    //When
    try {
      CMN_MOCK_Match.matchesAllArgs(methodArg, targetMatchers);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      System.assertEquals(
        'MethodArgs.argValues cannot be null',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void whenMatchesAllArgsWithNullMatchersThrowsException() {
    //Given
    CMN_MOCK_MethodArgValues methodArg = new CMN_MOCK_MethodArgValues(
      new List<Object>{ 'Test' }
    );
    List<CMN_MOCK_IMatcher> targetMatchers = null;

    //When
    try {
      CMN_MOCK_Match.matchesAllArgs(methodArg, targetMatchers);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      System.assertEquals('Matchers cannot be null', e.getMessage());
    }
  }

  @IsTest
  private static void whenMatchesAllArgsWithDifferentSizeArgValuesAndMatchersThrowsException() {
    //Given
    CMN_MOCK_MethodArgValues methodArg = new CMN_MOCK_MethodArgValues(
      new List<Object>{ 'Test' }
    );
    List<CMN_MOCK_IMatcher> targetMatchers = new List<CMN_MOCK_IMatcher>{
      new AlwaysMatch(),
      new AlwaysMatch()
    };

    //When
    try {
      CMN_MOCK_Match.matchesAllArgs(methodArg, targetMatchers);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      String expectedMessage =
        'MethodArgs and matchers must have the same count' +
        ', MethodArgs: (' +
        methodArg.argValues.size() +
        ') ' +
        methodArg.argValues +
        ', Matchers: (' +
        targetMatchers.size() +
        ') ' +
        targetMatchers;

      System.assertEquals(expectedMessage, e.getMessage());
    }
  }

  @IsTest
  private static void whenMatchesWithOneMatcherSetsMatchingToTrue() {
    //Given
    CMN_MOCK_IMatcher matcher = new AlwaysMatch();

    //When
    CMN_MOCK_Match.matches(matcher);

    //Then
    System.assert(CMN_MOCK_Match.Matching);
  }

  @IsTest
  private static void whenMatchesWithOneMatcherRegistersMatcher() {
    //Given
    CMN_MOCK_IMatcher matcher = new AlwaysMatch();

    //When
    CMN_MOCK_Match.matches(matcher);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );

    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(matcher === registeredMatchers[0]);
  }

  @IsTest
  private static void whenMatchesWithOneMatcherReturnsNull() {
    //Given
    CMN_MOCK_IMatcher matcher = new AlwaysMatch();

    //When
    Object retval = CMN_MOCK_Match.matches(matcher);

    //Then
    System.assertEquals(null, retval);
  }

  @IsTest
  private static void allOfWithNoArgsThrowsException() {
    //Given/When
    try {
      CMN_MOCK_Match.allOf((List<Object>) null);
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      System.assertEquals('Must register matchers to combine', e.getMessage());
    }
  }

  @IsTest
  private static void allOfWithEmptyArgsThrowsException() {
    //Given/When
    try {
      CMN_MOCK_Match.allOf(new List<Object>{});
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      System.assertEquals('Must register matchers to combine', e.getMessage());
    }
  }

  @IsTest
  private static void allOfWithoutRegisteringInnerMatchersThrowsException() {
    //Given/When
    try {
      //Should be using CMN_MOCK_Match.allOf(new List<Object>{ CMN_MOCK_Match.myMatcher('Hello') })
      //to register the inner matcher.
      CMN_MOCK_Match.allOf(new List<Object>{ 'Hello' });
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      //Then
      String expectedMessage =
        'Error reclaiming inner matchers for combined matcher. ' +
        'Wanted 1 matchers but only got ' +
        new List<CMN_MOCK_IMatcher>();
      System.assertEquals(expectedMessage, e.getMessage());
    }
  }

  @IsTest
  private static void allOfWith2ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.allOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void allOfWith3ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.allOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void allOfWith4ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.allOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3'),
      CMN_MOCK_Match.eq('hello4')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void allOfWithListArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.allOf(new List<Object>{ CMN_MOCK_Match.eq('hello') });

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void anyOfWith2ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void anyOfWith3ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void anyOfWith4ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3'),
      CMN_MOCK_Match.eq('hello4')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void anyOfWithListArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyOf(new List<Object>{ CMN_MOCK_Match.eq('hello') });

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void isNotRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.isNot(CMN_MOCK_Match.eq('hello1'));

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void noneOfWith2ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.noneOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void noneOfWith3ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.noneOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void noneOfWith4ArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.noneOf(
      CMN_MOCK_Match.eq('hello1'),
      CMN_MOCK_Match.eq('hello2'),
      CMN_MOCK_Match.eq('hello3'),
      CMN_MOCK_Match.eq('hello4')
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void noneOfWithListArgsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.noneOf(new List<Object>{ CMN_MOCK_Match.eq('hello') });

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Combined
    );
  }

  @IsTest
  private static void eqRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eq('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqBooleanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqBoolean(true);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqDateRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqDate(Date.today());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqDatetimeRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqDatetime(System.now());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqDecimalRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqDecimal(123);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqDoubleRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqDouble(123);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqIdRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqId('001000000000001AAA');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqIntegerRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqInteger(123);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqListRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqList(new List<String>{ 'hello' });

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqLongRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqLong(123);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqSObjectFieldRegistersCorrectMatcherType() {
    //Given/When
    Schema.SObjectField f = Schema.getGlobalDescribe()
      .get('Account')
      .getDescribe()
      .fields.getMap()
      .get('Id');
    CMN_MOCK_Match.eqSObjectField(f);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqSObjectTypeRegistersCorrectMatcherType() {
    //Given/When
    Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
    CMN_MOCK_Match.eqSObjectType(ot);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  public static void eqStringRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.eqString('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.Eq
    );
  }

  @IsTest
  private static void refEqRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.refEq('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.RefEq
    );
  }

  @IsTest
  private static void anyBooleanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyBoolean();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyBoolean
    );
  }

  @IsTest
  private static void anyDateRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyDate();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyDate
    );
  }

  @IsTest
  private static void anyDatetimeRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyDatetime();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyDatetime
    );
  }

  @IsTest
  private static void anyDecimalRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyDecimal();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyDecimal
    );
  }

  @IsTest
  private static void anyDoubleRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyDouble();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyDouble
    );
  }

  @IsTest
  private static void anyFieldSetRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyFieldSet();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyFieldSet
    );
  }

  @IsTest
  private static void anyIdRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyId();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyId
    );
  }

  @IsTest
  private static void anyIntegerRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyInteger();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyInteger
    );
  }

  @IsTest
  private static void anyListRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyList();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyList
    );
  }

  @IsTest
  private static void anyLongRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyLong();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyLong
    );
  }

  @IsTest
  private static void anyObjectRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyObject();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyObject
    );
  }

  @IsTest
  private static void anyStringRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anyString();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnyString
    );
  }

  @IsTest
  private static void anySObjectRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anySObject();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnySObject
    );
  }

  @IsTest
  private static void anySObjectFieldRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anySObjectField();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnySObjectField
    );
  }

  @IsTest
  private static void anySObjectTypeRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.anySObjectType();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.AnySObjectType
    );
  }

  @IsTest
  private static void dateAfterRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.dateAfter(Date.today());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeAfter
    );
  }

  @IsTest
  private static void dateBeforeRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.dateBefore(Date.today());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeBefore
    );
  }

  @IsTest
  private static void dateBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.dateBetween(Date.today(), Date.today());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeBetween
    );
  }

  @IsTest
  private static void datetimeAfterRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.datetimeAfter(System.now());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeAfter
    );
  }

  @IsTest
  private static void datetimeBeforeRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.datetimeBefore(System.now());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeBefore
    );
  }

  @IsTest
  private static void datetimeBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.datetimeBetween(System.now(), System.now());

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DatetimeBetween
    );
  }

  @IsTest
  private static void decimalBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.decimalBetween(0, 10);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalBetween
    );
  }

  @IsTest
  private static void decimalLessThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.decimalLessThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalLessThan
    );
  }

  @IsTest
  private static void decimalMoreThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.decimalMoreThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalMoreThan
    );
  }

  @IsTest
  private static void doubleBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.doubleBetween(0, 10);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalBetween
    );
  }

  @IsTest
  private static void doubleLessThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.doubleLessThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalLessThan
    );
  }

  @IsTest
  private static void doubleMoreThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.doubleMoreThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalMoreThan
    );
  }

  @IsTest
  private static void fieldSetEquivalentWithNullFieldSetThrowsException() {
    try {
      CMN_MOCK_Match.fieldSetEquivalentTo(null);
      System.assert(false, 'ExpectedException');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Arg cannot be null: null', e.getMessage());
    }
  }

  @IsTest
  private static void fieldSetEquivalentToRegistersCorrectMatcherType() {
    Schema.FieldSet anyFieldSet = CMN_MOCK_ApexMocksUtils_TEST.findAnyFieldSet();
    if (anyFieldSet == null) {
      return;
    }

    //Given/When
    CMN_MOCK_Match.fieldSetEquivalentTo(anyFieldSet);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.FieldSetEquivalentTo
    );
  }

  @IsTest
  private static void integerBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.integerBetween(0, 10);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalBetween
    );
  }

  @IsTest
  private static void integerLessThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.integerLessThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalLessThan
    );
  }

  @IsTest
  private static void integerMoreThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.integerMoreThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalMoreThan
    );
  }

  @IsTest
  private static void isNotNullRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.isNotNull();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.IsNotNull
    );
  }

  @IsTest
  private static void isNullRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.isNull();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.IsNull
    );
  }

  @IsTest
  private static void listContainsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.listContains('fred');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.ListContains
    );
  }

  @IsTest
  private static void listIsEmptyRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.listIsEmpty();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.ListIsEmpty
    );
  }

  @IsTest
  private static void longBetweenRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.longBetween(0, 10);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalBetween
    );
  }

  @IsTest
  private static void longLessThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.longLessThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalLessThan
    );
  }

  @IsTest
  private static void longMoreThanRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.longMoreThan(0);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.DecimalMoreThan
    );
  }

  @IsTest
  private static void sObjectOfTypeRegistersCorrectMatcherType() {
    //Given
    Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
    if (ot == null) {
      return;
    }

    //When
    CMN_MOCK_Match.sObjectOfType(ot);

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectOfType
    );
  }

  @IsTest
  private static void sObjectWithRegistersCorrectMatcherType() {
    //Given
    Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
    if (ot == null) {
      return;
    }

    Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

    //When
    CMN_MOCK_Match.sObjectWith(
      new Map<Schema.SObjectField, Object>{ f => null }
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectWith
    );
  }

  @IsTest
  private static void sObjectsWithRegistersCorrectMatcherType() {
    //Given
    Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
    if (ot == null) {
      return;
    }

    Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

    //When
    CMN_MOCK_Match.sObjectsWith(
      new List<Map<Schema.SObjectField, Object>>{
        new Map<Schema.SObjectField, Object>{ f => null }
      }
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectsWith
    );
  }

  @IsTest
  private static void sObjectsWithMatchInOrderRegistersCorrectMatcherType() {
    //Given
    Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
    if (ot == null) {
      return;
    }

    Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

    //When
    CMN_MOCK_Match.sObjectsWith(
      new List<Map<Schema.SObjectField, Object>>{
        new Map<Schema.SObjectField, Object>{ f => null }
      },
      false
    );

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectsWith,
      registeredMatchers
    );
  }

  @IsTest
  private static void sObjectWithIdRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.sObjectWithId('001000000000001AAA');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectWithId
    );
  }

  @IsTest
  private static void sObjectWithNameRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.sObjectWithName('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.SObjectWithName
    );
  }

  @IsTest
  private static void stringContainsRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringContains('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringContains
    );
  }

  @IsTest
  private static void stringEndsWithRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringEndsWith('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringEndsWith
    );
  }

  @IsTest
  private static void stringIsBlankRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringIsBlank();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringIsBlank
    );
  }

  @IsTest
  private static void stringIsNotBlankRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringIsNotBlank();

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringIsNotBlank
    );
  }

  @IsTest
  private static void stringMatchesRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringMatches('[a-z]*');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringMatches
    );
  }

  @IsTest
  private static void stringStartsWithRegistersCorrectMatcherType() {
    //Given/When
    CMN_MOCK_Match.stringStartsWith('hello');

    //Then
    List<CMN_MOCK_IMatcher> registeredMatchers = CMN_MOCK_Match.getAndClearMatchers(
      1
    );
    System.assertNotEquals(null, registeredMatchers);
    System.assertEquals(1, registeredMatchers.size());
    System.assert(
      registeredMatchers[0] instanceof CMN_MOCK_MatcherDefinitions.StringStartsWith
    );
  }

  private class AlwaysMatch implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return true;
    }
  }

  private class NeverMatch implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return false;
    }
  }
}