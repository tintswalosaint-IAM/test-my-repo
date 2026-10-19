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
private class CMN_MOCK_AnyOrder_TEST {
  private static final String BASIC_VERIFY_ASSERTION_MESSAGE = 'Expected : {0}, Actual: {1} -- Wanted but not invoked: ';

  /**
   * @description replicating the apex mocks tests with the new syntax
   */
  @IsTest
  private static void whenVerifyMultipleCallsWithMatchersShouldReturnCorrectMethodCallCounts() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
      .add(CMN_MOCK_Match.anyString());
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).add('fred');
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(CMN_MOCK_Match.stringContains('fred'));
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
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never()))
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

    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
      .add(
        (String) CMN_MOCK_Match.anyOf(
          CMN_MOCK_Match.eq('bob'),
          CMN_MOCK_Match.eq('fred')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        (String) CMN_MOCK_Match.anyOf(
          CMN_MOCK_Match.eq('bob'),
          CMN_MOCK_Match.eq('jack')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
      .add(
        (String) CMN_MOCK_Match.noneOf(
          CMN_MOCK_Match.eq('jack'),
          CMN_MOCK_Match.eq('tim')
        )
      );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
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

    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
      .add((String) CMN_MOCK_Match.isNot(CMN_MOCK_Match.eq('jack')));
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
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(3)))
      .get((Integer) CMN_MOCK_Match.matches(new isOdd()));
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
      .get((Integer) CMN_MOCK_Match.matches(new isEven()));
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
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2))).add('bob');
  }

  @IsTest
  private static void verifyMethodNotCalled() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.get(0);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never())).add('bob');
    ((CMN_MOCK_List.IList) mocks.verify(mockList)).get(0);
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
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never()))
      .set(0, 'fred');
  }

  @IsTest
  private static void verifyMethodCallWhenNoCallsBeenMadeForType() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never())).add('bob');
  }

  @IsTest
  private static void whenVerifyMethodNeverCalledMatchersAreReset() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never()))
      .get(CMN_MOCK_Match.anyInteger());
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(CMN_MOCK_Match.anyString());
  }

  /**
   * @description times
   */
  @IsTest
  private static void verifyTimesMethodHasBeenCalled() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(3))).add('bob');
  }

  @IsTest
  private static void verifyTimesMethodHasBeenCalledWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob1');
    mockList.add('bob2');
    mockList.add('bob3');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(3)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifyTimesMethodFailsWhenCalledLessTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(4))).add('bob');

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 4, 3);
    }
  }

  @IsTest
  private static void thatVerifyTimesMethodFailsWhenCalledMoreTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2))).add('bob');

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 2, 3);
    }
  }

  @IsTest
  private static void thatVerifyTimesMethodFailsWhenCalledLessTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(4)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 4, 3);
    }
  }

  @IsTest
  private static void thatVerifyTimesMethodFailsWhenCalledMoreTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.times(2)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 2, 3);
    }
  }

  /**
   * @description description messages
   */
  @IsTest
  private static void thatCustomMessageIsAdded() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    String customAssertMessage = 'Custom message to explain the reason of the verification';

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(
          mockList,
          mocks.times(2).description(customAssertMessage)
        ))
        .add(CMN_MOCK_Match.anyString());

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      String exceptionMessage = exc.getMessage();

      String expectedMessage =
        String.format(
          BASIC_VERIFY_ASSERTION_MESSAGE,
          new List<String>{ '2', '3' }
        ) +
        CMN_MOCK_List.getStubClassName() +
        '.add(String). ' +
        customAssertMessage +
        '.';

      System.assertEquals(
        expectedMessage,
        exceptionMessage,
        'The exception was caught, but the message was not as expected. ' +
        'Expected: [' +
        expectedMessage +
        '],  Actual: [' +
        exceptionMessage +
        '].'
      );
    }
  }

  /**
   * @description atLeast methods
   */
  @IsTest
  private static void thatVerifiesAtLeastNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(2))).add('bob');
  }

  @IsTest
  private static void thatVerifiesAtLeastNumberOfTimesWhenIsCalledMoreTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(2))).add('bob');
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(3)))
        .add('bob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifiesAtLeastNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(2)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifiesAtLeastNumberOfTimesWhenIsCalledMoreTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(2)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeast(3)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  /**
   * @description at most methods
   */
  @IsTest
  private static void thatVerifiesAtMostNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(5))).add('bob');
  }

  @IsTest
  private static void thatVerifiesAtMostSameNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(3))).add('bob');
  }

  @IsTest
  private static void thatThrownExceptionIfCalledMoreThanAtMostNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(3)))
        .add('bob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 3 times when instead is called four times'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or fewer times, Actual: 4 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifiesAtMostNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(5)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifiesAtMostSameNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(3)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatThrownExceptionIfCalledMoreThanAtMostNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atMost(3)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 3 times when instead is called four times'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or fewer times, Actual: 4 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  /**
   * @description ast least once methods
   */
  @IsTest
  private static void thatVerifiesAtLeastOnceNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add('bob');
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceNumberOfTimesWhenIsCalledMoreTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add('bob');
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastOnceNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('rob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
        .add('bob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called at least once when instead is never called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred', 'fred', 'fred', 'fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceNumberOfTimesWhenIsCalledMoreTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('bob');
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('bob');
    mockList.add('fred', 'fred', 'fred', 'fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastOnceNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('fred', 'fred', 'fred', 'fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
        .add(CMN_MOCK_Match.anyString());

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called at lest once when instead is never called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  /**
   * @description between methods
   */
  @IsTest
  private static void thatVerifiesBetweenNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
      .add('bob');
  }

  @IsTest
  private static void thatBetweenThrownExceptionIfCalledLessThanAtLeastNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
        .add('bob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called at least 3 times when instead is called only twice'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifiesBetweenNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatBetweenThrownExceptionIfCalledLessThanAtLeastNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 3 times when instead is called only twice'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 3 or more times, Actual: 2 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatBetweenThrownExceptionIfCalledMoreThanAtMostNumberOfTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
        .add('bob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called at most 5 times when instead is called six times'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 5 or fewer times, Actual: 6 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatBetweenThrownExceptionIfCalledMoreThanAtMostNumberOfTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.between(3, 5)))
        .add(CMN_MOCK_Match.anyString());

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called 5 times when instead is called six times'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 5 or fewer times, Actual: 6 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  /**
   * @description never methods
   */
  @IsTest
  private static void verifyNeverMethodHasNotBeenCalled() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob1');
    mockList.add('bob2');
    mockList.add('bob3');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never())).add('bob');
  }

  @IsTest
  private static void verifyNeverMethodHasBeenNotCalledWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('fred', 'fred', 'fred', 'fred');
    mockList.add('fred', 'fred', 'fred', 'fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never()))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifyNeverFailsWhenCalledMoreTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never())).add('bob');

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 0, 2);
    }
  }

  @IsTest
  private static void thatVerifyNeverFailsWhenCalledMoreTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.never()))
        .add(CMN_MOCK_Match.anyString());

      System.assert(false, 'an exception was expected');
    } catch (Exception exc) {
      assertFailMessage(exc.getMessage(), 0, 3);
    }
  }

  /**
   * @description as least once methods
   */
  @IsTest
  private static void thatVerifiesAtLeastOnce() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('bob');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add('bob');
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceWhenIsCalledMoreTimes() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add('bob');
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastOnce() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('bob');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
        .add('rob');

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called one times when instead is not called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatVerifiesAtLeastOnceWhenIsCalledMoreTimesWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');
    mockList.add('fred');
    mockList.add('fred');

    // Then
    ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
      .add(CMN_MOCK_Match.anyString());
  }

  @IsTest
  private static void thatThrownExceptionIfCalledLessThanAtLeastOnceWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('bob');
    mockList.add('fred');

    // Then
    try {
      ((CMN_MOCK_List.IList) mocks.verify(mockList, mocks.atLeastOnce()))
        .add(CMN_MOCK_Match.stringStartsWith('rob'));

      System.assert(
        false,
        'an exception was expected because we are asserting that the method is called once when instead is not called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ex) {
      String expectedMessage =
        'Expected : 1 or more times, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      String actualMessage = ex.getMessage();
      System.assertEquals(
        expectedMessage,
        actualMessage,
        'the exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  /*
   *	HELPER METHODS
   */

  /**
   * @description helper methods
   *
   * @param exceptionMessage as input
   * @param expectedInvocations as input
   * @param actualInvocations as input
   */
  private static void assertFailMessage(
    String exceptionMessage,
    Integer expectedInvocations,
    Integer actualInvocations
  ) {
    String expectedMessage = String.format(
      BASIC_VERIFY_ASSERTION_MESSAGE,
      new List<String>{
        String.valueOf(expectedInvocations),
        String.valueOf(actualInvocations)
      }
    );
    System.assert(
      exceptionMessage.contains(expectedMessage),
      'The exception was caught, but the message was not as expected. ' +
      'Expected: [' +
      expectedMessage +
      '],  Actual: [' +
      exceptionMessage +
      '].'
    );
  }

  /**
   * @description helper classes
   */
  private class isOdd implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return arg instanceof Integer ? Math.mod((Integer) arg, 2) == 1 : false;
    }
  }

  /**
   * @description isEven match utility test class
   */
  private class isEven implements CMN_MOCK_IMatcher {
    public Boolean matches(Object arg) {
      return arg instanceof Integer ? Math.mod((Integer) arg, 2) == 0 : false;
    }
  }
}