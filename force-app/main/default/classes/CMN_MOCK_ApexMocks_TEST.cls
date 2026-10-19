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
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=false)
private class CMN_MOCK_ApexMocks_TEST {
  private static final CMN_MOCK_ApexMocks MY_MOCKS = new CMN_MOCK_ApexMocks();
  private static final CMN_MOCK_List MY_MOCK_LIST = (CMN_MOCK_List) MY_MOCKS.mock(
    CMN_MOCK_List.class
  );

  @IsTest
  private static void whenStubMultipleCallsWithMatchersShouldReturnExpectedValues() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(
        mockList.get2(CMN_MOCK_Match.anyInteger(), CMN_MOCK_Match.anyString())
      )
      .thenReturn('any');
    mocks.when(
        mockList.get2(
          CMN_MOCK_Match.anyInteger(),
          CMN_MOCK_Match.stringContains('Hello')
        )
      )
      .thenReturn('hello');
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    System.assertEquals('hello', actualValue);
  }

  @IsTest
  private static void whenVerifyMultipleCallsWithMatchersShouldReturnCorrectMethodCallCounts() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add(CMN_MOCK_Match.anyString());
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('fred');
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(CMN_MOCK_Match.stringContains('fred'));
  }

  @IsTest
  private static void whenStubExceptionWithMatchersShouldThrowException() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new MyException('Matcher Exception'),
        mockList
      ))
      .add(CMN_MOCK_Match.stringContains('Hello'));
    mocks.stopStubbing();

    // When
    mockList.add('Hi');

    try {
      mockList.add('Hi Hello Hi');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      //Then
      System.assertEquals('Matcher Exception', e.getMessage());
    }
  }

  @IsTest
  private static void whenVerifyWithCombinedMatchersShouldReturnCorrectMethodCallCounts() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, 0))
      .add(
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eq('bob'),
          CMN_MOCK_Match.stringContains('re')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eq('fred'),
          CMN_MOCK_Match.stringContains('re')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add(
        (String) CMN_MOCK_Match.anyOf(
          CMN_MOCK_Match.eq('bob'),
          CMN_MOCK_Match.eq('fred')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 1))
      .add(
        (String) CMN_MOCK_Match.anyOf(
          CMN_MOCK_Match.eq('bob'),
          CMN_MOCK_Match.eq('jack')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add(
        (String) CMN_MOCK_Match.noneOf(
          CMN_MOCK_Match.eq('jack'),
          CMN_MOCK_Match.eq('tim')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add(
        (String) CMN_MOCK_Match.noneOf(
          CMN_MOCK_Match.anyOf(
            CMN_MOCK_Match.eq('jack'),
            CMN_MOCK_Match.eq('jill')
          ),
          CMN_MOCK_Match.allOf(
            CMN_MOCK_Match.eq('tim'),
            CMN_MOCK_Match.stringContains('i')
          )
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add((String) CMN_MOCK_Match.isNot(CMN_MOCK_Match.eq('jack')));
  }

  @IsTest
  private static void whenStubCustomMatchersCanBeUsed() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get((Integer) CMN_MOCK_Match.matches(new isOdd())))
      .thenReturn('Odd');
    mocks.when(mockList.get((Integer) CMN_MOCK_Match.matches(new isEven())))
      .thenReturn('Even');
    mocks.stopStubbing();

    // When
    String s1 = mockList.get(1);
    String s2 = mockList.get(2);
    String s3 = mockList.get(3);
    String s4 = mockList.get(4);
    String s5 = mockList.get(5);

    // Then
    System.assertEquals('Odd', s1);
    System.assertEquals('Even', s2);
    System.assertEquals('Odd', s3);
    System.assertEquals('Even', s4);
    System.assertEquals('Odd', s5);
  }

  @IsTest
  private static void whenVerifyCustomMatchersCanBeUsed() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.get(1);
    mockList.get(2);
    mockList.get(3);
    mockList.get(4);
    mockList.get(5);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, 3))
      .get((Integer) CMN_MOCK_Match.matches(new isOdd()));
    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .get((Integer) CMN_MOCK_Match.matches(new isEven()));
  }

  @IsTest
  private static void whenStubWithMatcherAndNonMatcherArgumentsShouldThrowException() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    String expectedError =
      'The number of matchers defined (1).' +
      ' does not match the number expected (2)\n' +
      'If you are using matchers all arguments must be passed in as matchers.\n' +
      'For example myList.add(CMN_MOCK_Match.anyInteger(), \'String\') should be defined as myList.add(CMN_MOCK_Match.anyInteger(), CMN_MOCK_Match.eq(\'String\')).';

    // Then
    try {
      mocks.startStubbing();
      mocks.when(mockList.get2(CMN_MOCK_Match.anyInteger(), 'String literal'))
        .thenReturn('fail');
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(expectedError, e.getMessage());
    }
  }

  @IsTest
  private static void whenVerifyWithMatcherAndNonMatcherArgumentsShouldThrowException() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    String expectedError =
      'The number of matchers defined (1).' +
      ' does not match the number expected (2)\n' +
      'If you are using matchers all arguments must be passed in as matchers.\n' +
      'For example myList.add(CMN_MOCK_Match.anyInteger(), \'String\') should be defined as myList.add(CMN_MOCK_Match.anyInteger(), CMN_MOCK_Match.eq(\'String\')).';

    mockList.get2(1, 'String literal');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList))
        .get2(CMN_MOCK_Match.anyInteger(), 'String literal');
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(expectedError, e.getMessage());
    }
  }

  @IsTest
  private static void whenStubSameMethodWithMatchersAndNonMatchersShouldStubInOrder() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();

    mocks.when(mockList.get2(1, 'Non-matcher first')).thenReturn('Bad'); //Set the return value using the non-matcher arguments
    mocks.when(
        mockList.get2(
          CMN_MOCK_Match.eqInteger(1),
          CMN_MOCK_Match.stringContains('Non-matcher first')
        )
      )
      .thenReturn('Good'); //Override the return value using matcher arguments

    mocks.when(
        mockList.get2(
          CMN_MOCK_Match.eqInteger(1),
          CMN_MOCK_Match.stringContains('Matcher first')
        )
      )
      .thenReturn('Bad'); //Set the return value using the matcher arguments
    mocks.when(mockList.get2(1, 'Matcher first')).thenReturn('Good'); //Override the return value using non-matcher arguments

    mocks.stopStubbing();

    // When/Then
    System.assertEquals('Good', mockList.get2(1, 'Non-matcher first'));
    System.assertEquals('Good', mockList.get2(1, 'Matcher first'));
  }

  @IsTest
  private static void whenStubExceptionSameMethodWithMatchersAndNonMatchersShouldStubInOrder() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();

    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new CMN_MOCK_ApexMocks.ApexMocksException('Bad'),
        mockList
      ))
      .add('Non-matcher first'); //Set the exception value using the non-matcher arguments
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new CMN_MOCK_ApexMocks.ApexMocksException('Good'),
        mockList
      ))
      .add(CMN_MOCK_Match.stringContains('Non-matcher first')); //Override the exception value using matcher arguments

    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new CMN_MOCK_ApexMocks.ApexMocksException('Bad'),
        mockList
      ))
      .add(CMN_MOCK_Match.stringContains('Matcher first')); //Set the exception value using the matcher arguments
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new CMN_MOCK_ApexMocks.ApexMocksException('Good'),
        mockList
      ))
      .add('Matcher first'); //Override the exception value using non-matcher arguments

    mocks.stopStubbing();

    // When/Then
    try {
      mockList.add('Non-matcher first');
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Good', e.getMessage());
    }

    try {
      mockList.add('Matcher first');
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals('Good', e.getMessage());
    }
  }

  @IsTest
  private static void whenStubSingleCallWithSingleArgumentShouldReturnStubbedValue() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(0)).thenReturn('bob');
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get(0);

    // Then
    System.assertEquals('bob', actualValue);
  }

  @IsTest
  private static void whenStubSingleCallWithNullReturnValueItShouldReturnNull() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(0)).thenReturn(null);
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get(0);

    // Then
    System.assertEquals(null, actualValue);
  }

  @IsTest
  private static void whenStubMultipleCallsWithSingleArgumentShouldReturnStubbedValues() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(0)).thenReturn('bob');
    mocks.when(mockList.get(1)).thenReturn('fred');
    mocks.stopStubbing();

    // When
    String actualValueArg0 = mockList.get(0);
    String actualValueArg1 = mockList.get(1);
    String actualValueArg2 = mockList.get(2);

    // Then
    System.assertEquals('bob', actualValueArg0);
    System.assertEquals('fred', actualValueArg1);
    System.assertEquals(null, actualValueArg2);
  }

  @IsTest
  private static void whenStubSameCallWithDifferentArgumentValueShouldReturnLastStubbedValue() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(0)).thenReturn('bob1');
    mocks.when(mockList.get(0)).thenReturn('bob2');
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get(0);

    // Then
    System.assertEquals('bob2', actualValue);
  }

  @IsTest
  private static void whenStubCallWithNoArgumentsShouldReturnStubbedValue() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.isEmpty()).thenReturn(false);
    mocks.stopStubbing();

    // When
    Boolean actualValue = mockList.isEmpty();

    // Then
    System.assertEquals(false, actualValue);
  }

  @IsTest
  private static void verifySingleMethodCallWithNoArguments() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.isEmpty();

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).isEmpty();
  }

  @IsTest
  private static void verifySingleMethodCallWithSingleArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('bob');
  }

  @IsTest
  private static void verifyMultipleMethodCallsWithSameSingleArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2)).add('bob');
  }

  @IsTest
  private static void verifyMultipleMethodCallsWithDifferentSingleArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('bob');
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('fred');
  }

  @IsTest
  private static void verifyMethodCallsWithSameNameButDifferentArgumentTypes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add(new List<String>{ 'bob' });
    mockList.add((String) null);
    mockList.add((String[]) null);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('bob');
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(new List<String>{ 'bob' });
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add((String) null);
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add((String[]) null);
  }

  @IsTest
  private static void verifyMethodNotCalled() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.get(0);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER))
      .add('bob');
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).get(0);
  }

  @IsTest
  private static void stubAndVerifyMethodCallsWithNoArguments() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.isEmpty()).thenReturn(false);
    mocks.stopStubbing();

    mockList.clear();

    // When
    Boolean actualValue = mockList.isEmpty();

    // Then
    System.assertEquals(false, actualValue);
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).clear();
  }

  @IsTest
  private static void stubAndVerifyMethodCallsVoidMethod() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mockList.add(new List<String>{ 'one', 'two' });

    mocks.startStubbing();
    mocks.when(mockList.isEmpty()).thenReturn(false);
    mocks.stopStubbing();

    mockList.clear();

    // When
    Boolean actualValue = mockList.isEmpty();

    // Then
    System.assertEquals(false, actualValue);
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).clear();
  }

  @IsTest
  private static void whenStubExceptionTheExceptionShouldBeThrown() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(0))
      .thenThrow(new MyException('Stubbed exception.'));
    mocks.stopStubbing();

    // When
    try {
      mockList.get(0);
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('Stubbed exception.', e.getMessage());
    }
  }

  @IsTest
  private static void whenStubVoidMethodWithExceptionThenExceptionShouldBeThrown() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new MyException('Stubbed exception.'),
        mockList
      ))
      .clear();
    mocks.stopStubbing();

    // When
    try {
      mockList.clear();
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('Stubbed exception.', e.getMessage());
    }
  }

  @IsTest
  private static void whenStubMultipleVoidMethodsWithExceptionsThenExceptionsShouldBeThrown() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new MyException('clear stubbed exception.'),
        mockList
      ))
      .clear();
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new MyException('add stubbed exception.'),
        mockList
      ))
      .add('bob');
    mocks.stopStubbing();

    // When
    try {
      mockList.clear();
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('clear stubbed exception.', e.getMessage());
    }

    // When
    try {
      mockList.add('bob');
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('add stubbed exception.', e.getMessage());
    }
  }

  @IsTest
  private static void whenStubVoidMethodWithExceptionAndCallMethodTwiceThenExceptionShouldBeThrownTwice() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List.IList) mocks.doThrowWhen(
        new MyException('clear stubbed exception.'),
        mockList
      ))
      .clear();
    mocks.stopStubbing();

    // When
    try {
      mockList.clear();
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('clear stubbed exception.', e.getMessage());
    }

    // When
    try {
      mockList.clear();
      System.assert(false, 'Stubbed exception should have been thrown.');
    } catch (Exception e) {
      // Then
      System.assert(e instanceof MyException);
      System.assertEquals('clear stubbed exception.', e.getMessage());
    }
  }

  @IsTest
  private static void verifyMethodCallWhenNoCallsBeenMadeForType() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER))
      .add('bob');
  }

  @IsTest
  private static void verifySingleMethodCallWithMultipleArguments() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.set(0, 'bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).set(0, 'bob');
    ((CMN_MOCK_List.IList) mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER))
      .set(0, 'fred');
  }

  @IsTest
  private static void whenStubMultipleCallsWithMultipleArgumentShouldReturnStubbedValues() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'zero')).thenReturn('bob');
    mocks.when(mockList.get2(1, 'one')).thenReturn('fred');
    mocks.when(mockList.get2(0, 'two')).thenReturn('bob');
    mocks.when(mockList.get2(1, 'three')).thenReturn('bub');
    mocks.stopStubbing();

    // When
    String actualValueArg0 = mockList.get2(0, 'zero');
    String actualValueArg1 = mockList.get2(1, 'one');
    String actualValueArg2 = mockList.get2(0, 'two');
    String actualValueArg3 = mockList.get2(1, 'three');
    String actualValueArg4 = mockList.get2(0, 'three');

    // Then
    System.assertEquals('bob', actualValueArg0);
    System.assertEquals('fred', actualValueArg1);
    System.assertEquals('bob', actualValueArg2);
    System.assertEquals('bub', actualValueArg3);
    System.assertEquals(null, actualValueArg4);
  }

  @IsTest
  private static void whenStubNullConcreteArgValueCorrectValueIsReturned() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    String expected = 'hello';

    mocks.startStubbing();
    mocks.when(mockList.get(null)).thenReturn(expected);
    mocks.stopStubbing();

    // When
    String actual = mockList.get(null);

    // Then
    System.assertEquals(expected, actual);
  }

  @IsTest
  private static void whenSetDoThrowWhenExceptionsValuesAreSet() {
    //Given
    MyException e = new MyException('Test');
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();

    List<Exception> expsList = new List<Exception>{ e };

    //When
    mocks.DoThrowWhenExceptions = expsList;

    //Then
    System.assert(expsList === mocks.DoThrowWhenExceptions);
  }

  @IsTest
  private static void whenVerifyMethodNeverCalledMatchersAreReset() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER))
      .get(CMN_MOCK_Match.anyInteger());
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(CMN_MOCK_Match.anyString());
  }

  /* @IsTest
	static void whenMockIsGeneratedCanVerify()
	{
		// Given
		CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
		CMN_MOCK_List.IList mockList = new CMN_MOCK_ListMocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');

		// Then
		((CMN_MOCK_List.IList)mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER)).get(CMN_MOCK_Match.anyInteger());
		((CMN_MOCK_List.IList)mocks.verify(mockList)).add('bob');
	} */

  /* @IsTest
	static void whenMockIsGeneratedCanStubVerify()
	{
		// Given
		CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
		CMN_MOCK_List.IList mockList = new CMN_MOCK_ListMocks.Mockfflib_MyList(mocks);

		// When
		mocks.startStubbing();
		mocks.when(mockList.get(1)).thenReturn('One');
		mocks.when(mockList.get(CMN_MOCK_Match.integerMoreThan(2))).thenReturn('>Two');
		mocks.stopStubbing();

		// Then
		System.assertEquals(null, mockList.get(0));
		System.assertEquals('One', mockList.get(1));
		System.assertEquals(null, mockList.get(2));
		System.assertEquals('>Two', mockList.get(3));
	} */

  @IsTest
  private static void thatMultipleInstancesCanBeMockedIndependently() {
    CMN_MOCK_ApexMocksConfig.HasIndependentMocks = true;

    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List first = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_List second = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(first.get(0)).thenReturn('First');
    mocks.when(second.get(0)).thenReturn('Second');
    mocks.stopStubbing();

    // When
    String actual = first.get(0);

    // Then
    System.assertEquals('First', actual, 'Should have returned stubbed value');
    ((CMN_MOCK_List) mocks.verify(first)).get(0);
    ((CMN_MOCK_List) mocks.verify(second, mocks.never())).get(0);
  }

  @IsTest
  private static void thatMultipleInstancesCanBeMockedDependently() {
    CMN_MOCK_ApexMocksConfig.HasIndependentMocks = false;

    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List first = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_List second = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(first.get(0)).thenReturn('First');
    mocks.when(second.get(0)).thenReturn('Second');
    mocks.stopStubbing();

    // When
    String actual = first.get(0);

    // Then
    System.assertEquals('Second', actual, 'Should have returned stubbed value');
    ((CMN_MOCK_List) mocks.verify(first)).get(0);
    ((CMN_MOCK_List) mocks.verify(second)).get(0);
  }

  @IsTest
  private static void thatStubbingCanBeChainedFirstValueThenException() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturn('One')
      .thenThrow(new MyException('Stubbed exception.'));
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertExceptionMessage('Stubbed exception.');
  }

  @IsTest
  private static void thatStubbingMultipleMethodsCanBeChainedFirstExceptionThenValue() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrow(new MyException('Stubbed exception.'))
      .thenReturn('One');
    MY_MOCKS.when(MY_MOCK_LIST.get2(2, 'Hello.'))
      .thenThrow(new MyException('Stubbed exception2.'))
      .thenReturn('One2');
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('Stubbed exception.');
    assertReturnedValue('One');
    assertExceptionMessageForGet2('Stubbed exception2.');
    assertReturnedValueForGet2('One2');
  }

  @IsTest
  private static void thatStubbingMultipleMethodsCanBeChainedFirstValueThenException() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturn('One')
      .thenThrow(new MyException('Stubbed exception.'));
    MY_MOCKS.when(MY_MOCK_LIST.get2(2, 'Hello.'))
      .thenReturn('One2')
      .thenThrow(new MyException('Stubbed exception2.'));
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertExceptionMessage('Stubbed exception.');
    assertReturnedValueForGet2('One2');
    assertExceptionMessageForGet2('Stubbed exception2.');
  }

  @IsTest
  private static void thatStubbingReturnsDifferentValuesForDifferentCalls() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');
  }

  @IsTest
  private static void thatStubbingReturnsDifferentValuesForDifferentCallsAndRepeatLastValuesForFurtherCalls() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');

    assertReturnedValue('Three');
    assertReturnedValue('Three');
  }

  @IsTest
  private static void thatStubbingThrowsDifferentExceptionsForDifferentCalls() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingThrowsDifferentExceptionsForDifferentCallsAndRepeatLastExceptionForFurtherCalls() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertExceptionMessage('third.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingThrowsAndReturnsDifferentExceptionsAndValuesForDifferentCalls() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third })
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');

    assertReturnedValue('Three');
    assertReturnedValue('Three');
  }

  @IsTest
  private static void thatStubbingReturnsAndThrowsDifferentValuesAndExceptionsForDifferentCalls() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' })
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');

    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertExceptionMessage('third.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnWithSingleValue() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('One');
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Two');
    assertReturnedValue('Two');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnMultiWithSingleValue() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Two');
    assertReturnedValue('Two');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnMultiWithMultiValue() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'Four', 'Five', 'Six' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Four');
    assertReturnedValue('Five');
    assertReturnedValue('Six');

    assertReturnedValue('Six');
    assertReturnedValue('Six');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnWithMultiValues() {
    // Given
    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');

    assertReturnedValue('Three');
    assertReturnedValue('Three');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnMultiWithSingleException() {
    // Given
    MyException first = new MyException('first.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(first);
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('first.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnMultiWithMultiExceptions() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertExceptionMessage('third.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnWithMultiExceptions() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertExceptionMessage('third.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenReturnWithSingleException() {
    // Given
    MyException first = new MyException('first.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(first);
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('first.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowWithSingleValue() {
    // Given
    MyException first = new MyException('first.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(first);
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Two');
    assertReturnedValue('Two');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowMultiWithSingleValue() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn('Two');
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Two');
    assertReturnedValue('Two');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowMultiWithMultiValue() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'Four', 'Five', 'Six' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('Four');
    assertReturnedValue('Five');
    assertReturnedValue('Six');

    assertReturnedValue('Six');
    assertReturnedValue('Six');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowWithMultiValues() {
    // Given
    MyException first = new MyException('first.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(first);
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenReturnMulti(new List<String>{ 'One', 'Two', 'Three' });
    MY_MOCKS.stopStubbing();

    // Then
    assertReturnedValue('One');
    assertReturnedValue('Two');
    assertReturnedValue('Three');

    assertReturnedValue('Three');
    assertReturnedValue('Three');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowMultiWithSingleException() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');
    MyException fourth = new MyException('fourth.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(fourth);
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('fourth.');
    assertExceptionMessage('fourth.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowMultiWithMultiExceptions() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    MyException fourth = new MyException('fourth.');
    MyException fifth = new MyException('fifth.');
    MyException sixth = new MyException('sixth.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ fourth, fifth, sixth });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('fourth.');
    assertExceptionMessage('fifth.');
    assertExceptionMessage('sixth.');

    assertExceptionMessage('sixth.');
    assertExceptionMessage('sixth.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowWithMultiExceptions() {
    // Given
    MyException beforeFirst = new MyException('before first.');

    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(beforeFirst);
    MY_MOCKS.when(MY_MOCK_LIST.get(1))
      .thenThrowMulti(new List<Exception>{ first, second, third });
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('second.');
    assertExceptionMessage('third.');

    assertExceptionMessage('third.');
    assertExceptionMessage('third.');
  }

  @IsTest
  private static void thatStubbingMultipleTimesOverridePreviousThenThrowWithSingleException() {
    // Given
    MyException beforeFirst = new MyException('before first.');
    MyException first = new MyException('first.');

    // When
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(beforeFirst);
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(first);
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessage('first.');
    assertExceptionMessage('first.');
  }

  @IsTest
  private static void thatVoidMethodThrowsMultipleExceptions() {
    // Given
    new MyException('before first.');

    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    // When
    MY_MOCKS.startStubbing();
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ first, second, third },
        MY_MOCK_LIST
      ))
      .add('Hello');
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessageOnVoidMethod('first.');
    assertExceptionMessageOnVoidMethod('second.');
    assertExceptionMessageOnVoidMethod('third.');

    assertExceptionMessageOnVoidMethod('third.');
    assertExceptionMessageOnVoidMethod('third.');
  }

  @IsTest
  private static void thatMultipleVoidMethodsThrowsMultipleExceptions() {
    // Given
    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    MyException first2 = new MyException('first2.');
    MyException second2 = new MyException('second2.');
    MyException third2 = new MyException('third2.');

    // When
    MY_MOCKS.startStubbing();
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ first2, second2, third2 },
        MY_MOCK_LIST
      ))
      .addMore('Hello');
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ first, second, third },
        MY_MOCK_LIST
      ))
      .add('Hello');
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessageOnVoidMethod('first.');
    assertExceptionMessageOnVoidMethod('second.');
    assertExceptionMessageOnVoidMethod('third.');

    assertExceptionMessageOnVoidMethod('third.');
    assertExceptionMessageOnVoidMethod('third.');

    assertExceptionMessageOnAddMoreVoidMethod('first2.');
    assertExceptionMessageOnAddMoreVoidMethod('second2.');
    assertExceptionMessageOnAddMoreVoidMethod('third2.');

    assertExceptionMessageOnAddMoreVoidMethod('third2.');
    assertExceptionMessageOnAddMoreVoidMethod('third2.');
  }

  @IsTest
  private static void thatStubbingMutipleTimesVoidMethodThrowsMultipleExceptionsOverride() {
    // Given
    new MyException('before first.');

    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    MyException fourth = new MyException('fourth.');
    MyException fifth = new MyException('fifth.');
    MyException sixth = new MyException('sixth.');

    // When
    MY_MOCKS.startStubbing();
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ first, second, third },
        MY_MOCK_LIST
      ))
      .add('Hello');
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ fourth, fifth, sixth },
        MY_MOCK_LIST
      ))
      .add('Hello');
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessageOnVoidMethod('fourth.');
    assertExceptionMessageOnVoidMethod('fifth.');
    assertExceptionMessageOnVoidMethod('sixth.');

    assertExceptionMessageOnVoidMethod('sixth.');
    assertExceptionMessageOnVoidMethod('sixth.');
  }

  @IsTest
  private static void thatStubbingMutipleTimesVoidMethodThrowsMultipleExceptionsOverrideWithSingleException() {
    // Given
    new MyException('before first.');

    MyException first = new MyException('first.');
    MyException second = new MyException('second.');
    MyException third = new MyException('third.');

    MyException fourth = new MyException('fourth.');
    new MyException('fifth.');
    new MyException('sixth.');

    // When
    MY_MOCKS.startStubbing();
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(
        new List<Exception>{ first, second, third },
        MY_MOCK_LIST
      ))
      .add('Hello');
    ((CMN_MOCK_List.IList) MY_MOCKS.doThrowWhen(fourth, MY_MOCK_LIST))
      .add('Hello');
    MY_MOCKS.stopStubbing();

    // Then
    assertExceptionMessageOnVoidMethod('fourth.');
    assertExceptionMessageOnVoidMethod('fourth.');
  }

  @IsTest
  private static void thatExceptionIsThrownWhenStubbingIsNotDone() {
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1));
    MY_MOCKS.stopStubbing();

    try {
      MY_MOCK_LIST.get(1);

      System.assert(false, 'an exception was expected');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException myex) {
      System.assertEquals(
        'The stubbing is not correct, no return values have been set.',
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  @IsTest
  private static void thatExceptionIsThrownWhenReturnMultiPassEmptyList() {
    try {
      MY_MOCKS.startStubbing();
      MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturnMulti(new List<Object>());
      MY_MOCKS.stopStubbing();
      System.assert(false, 'an exception was expected');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException myex) {
      System.assertEquals(
        'The stubbing is not correct, no return values have been set.',
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  @IsTest
  private static void thatExceptionIsthrownWhenReturnMultiPassNullList() {
    try {
      MY_MOCKS.startStubbing();
      MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturnMulti(null);
      MY_MOCKS.stopStubbing();
      System.assert(false, 'an exception was expected');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException myex) {
      System.assertEquals(
        'The stubbing is not correct, no return values have been set.',
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  @IsTest
  private static void thatExceptionIsthrownWhenThrowMultiPassEmptyList() {
    try {
      MY_MOCKS.startStubbing();
      MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrowMulti(new List<Exception>());
      MY_MOCKS.stopStubbing();
      System.assert(false, 'an exception was expected');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException myex) {
      System.assertEquals(
        'The stubbing is not correct, no return values have been set.',
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  @IsTest
  private static void thatExceptionIsThrownWhenThrowMultiPassNullList() {
    try {
      MY_MOCKS.startStubbing();
      MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrowMulti(null);
      MY_MOCKS.stopStubbing();

      System.assert(false, 'an exception was expected');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException myex) {
      System.assertEquals(
        'The stubbing is not correct, no return values have been set.',
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  @IsTest
  private static void thatNullCanBeUsedAsReturnValue() {
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenReturn(null);
    MY_MOCKS.stopStubbing();

    System.assertEquals(
      null,
      MY_MOCK_LIST.get(1),
      'it should be possible stub using the null value'
    );
  }

  @IsTest
  private static void thatNullCanBeUsedAsExceptionValue() {
    MY_MOCKS.startStubbing();
    MY_MOCKS.when(MY_MOCK_LIST.get(1)).thenThrow(null);
    MY_MOCKS.stopStubbing();

    System.assertEquals(
      null,
      MY_MOCK_LIST.get(1),
      'it should be possible stub using the null value'
    );
  }

  @IsTest
  private static void mockVoidMethodException() {
    try {
      new CMN_MOCK_ApexMocks().mockVoidMethod(null, null, null, null);
    } catch (Exception e) {
      System.assert(true);
    }
  }

  private static void assertExceptionMessage(String expectedMessage) {
    try {
      MY_MOCK_LIST.get(1);
      System.assert(false, 'an exception was expected');
    } catch (MyException myex) {
      System.assertEquals(
        expectedMessage,
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  private static void assertExceptionMessageForGet2(String expectedMessage) {
    try {
      MY_MOCK_LIST.get2(2, 'Hello.');
      System.assert(false, 'an exception was expected');
    } catch (MyException myex) {
      System.assertEquals(
        expectedMessage,
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  private static void assertExceptionMessageOnVoidMethod(
    String expectedMessage
  ) {
    try {
      MY_MOCK_LIST.add('Hello');
      System.assert(false, 'an exception was expected');
    } catch (MyException myex) {
      System.assertEquals(
        expectedMessage,
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  private static void assertExceptionMessageOnAddMoreVoidMethod(
    String expectedMessage
  ) {
    try {
      MY_MOCK_LIST.addMore('Hello');
      System.assert(false, 'an exception was expected');
    } catch (MyException myex) {
      System.assertEquals(
        expectedMessage,
        myex.getMessage(),
        'the message reported by the exception is not correct'
      );
    }
  }

  private static void assertReturnedValue(String expectedValue) {
    System.assertEquals(
      expectedValue,
      MY_MOCK_LIST.get(1),
      'the method did not returned the expected value'
    );
  }

  private static void assertReturnedValueForGet2(String expectedValue) {
    System.assertEquals(
      expectedValue,
      MY_MOCK_LIST.get2(2, 'Hello.'),
      'the method did not returned the expected value'
    );
  }

  private class MyException extends Exception {
  }

  private class isOdd implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return arg instanceof Integer ? Math.mod((Integer) arg, 2) == 1 : false;
    }
  }

  private class isEven implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return arg instanceof Integer ? Math.mod((Integer) arg, 2) == 0 : false;
    }
  }
}