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
private class CMN_MOCK_InOrder_TEST {
  private static CMN_MOCK_ApexMocks MY_MOCKS = new CMN_MOCK_ApexMocks();

  @IsTest
  private static void thatVerifyInOrderAllTheMethodsCalled() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-2');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-3');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');

    assertVerifyInOrderExceptionForAddMethod(
      '1-2',
      inOrder1,
      firstMock,
      'It should fail because 1-2 is in the wrong order',
      1,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderDifferentMethodsCalledWithSameArguments() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.addMore('1-1');
    firstMock.add('1-2');
    firstMock.addMore('1-2');
    firstMock.add('1-3');
    firstMock.addMore('1-3');
    firstMock.add('1-4');
    firstMock.addMore('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .addMore('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .addMore('1-3');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');
  }

  @IsTest
  private static void thatVerifyInOrderDifferentMethodsCalledWithSameArgumentsOrderFail() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.addMore('1-1');
    firstMock.add('1-2');
    firstMock.addMore('1-2');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .addMore('1-1');

    assertVerifyInOrderExceptionForAddMethod(
      '1-1',
      inOrder1,
      firstMock,
      'It should fail because 1-1 is called before the addMore(1-1)',
      1,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderDifferentMethodsCalledWithSameArgumentsDoubleCallFail() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.addMore('1-1');
    firstMock.add('1-2');
    firstMock.addMore('1-2');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .addMore('1-1');

    assertVerifyInOrderExceptionForAddMoreMethod(
      '1-1',
      inOrder1,
      firstMock,
      'It should fail because addMore(1-1) is called only Once',
      1,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderCallMethodWithMatches() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-0');
    firstMock.add('1-11');
    firstMock.add('1-12');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(2)))
      .add(CMN_MOCK_Match.stringStartsWith('1-1'));
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');
  }

  @IsTest
  private static void thatVerifyInOrderCallMethodWithMatchesFailsIfVerifyACallAlreadyInTheMatcher() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-0');
    firstMock.add('1-11');
    firstMock.add('1-12');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(2)))
      .add(CMN_MOCK_Match.stringStartsWith('1-1'));
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');

    assertVerifyInOrderExceptionForAddMethod(
      '1-11',
      inOrder1,
      firstMock,
      'It should fail because addMore(1-11) has been already verified using the matchers',
      1,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderCallMethodWithMultipleMatches() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When

    firstMock.add('1-0');
    firstMock.add('1-1');
    firstMock.add('1-3');
    firstMock.add('1-4');

    firstMock.add('2-0');
    firstMock.add('2-1');
    firstMock.add('2-3');
    firstMock.add('2-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(4)))
      .add(CMN_MOCK_Match.stringStartsWith('1-'));
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(4)))
      .add(CMN_MOCK_Match.stringStartsWith('2-'));
  }

  @IsTest
  private static void thatVerifyInOrderCallMethodWithMultipleMatchesMixed() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-2');
    firstMock.add('2-2');
    firstMock.add('1-3');
    firstMock.add('2-3');
    firstMock.add('1-4');
    firstMock.add('2-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(4)))
      .add(CMN_MOCK_Match.stringStartsWith('1-'));
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add(CMN_MOCK_Match.stringStartsWith('2-'));
  }

  @IsTest
  private static void thatVerifyInOrderCallMethodWithMultipleMatchesMixedFailWhenMatcherHaveAlreadyVerifiedMethod() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-2');
    firstMock.add('2-2');
    firstMock.add('1-3');
    firstMock.add('2-3');
    firstMock.add('1-4');
    firstMock.add('2-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(4)))
      .add(CMN_MOCK_Match.stringStartsWith('1-'));

    assertVerifyInOrderExceptionForAddMethod(
      '1-11',
      inOrder1,
      firstMock,
      'It should fail because only one call for the 2- is available to verify',
      4,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderCanSkipMethodsCalledUntilFindTheOneThatNeedsVerify() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');

    assertVerifyInOrderExceptionForAddMethod(
      '1-2',
      inOrder1,
      firstMock,
      'It should fail because is out of order',
      1,
      0
    );
  }

  @IsTest
  private static void thatVerifyInOrderCanHandleMultipleMethodsCalls() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(3)))
      .add('1-2');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-4');
  }

  @IsTest
  private static void thatVerifyInOrderCanHandleMultipleMethodsCallsAndNotFailsIfVerifyCountIsGreaterThenExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(2)))
      .add('1-2');
  }

  @IsTest
  private static void thatVerifyInOrderCanHandleMultipleMethodsCallsButFailsIfVerifyCountIsLessThenExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-2');
    firstMock.add('1-3');
    firstMock.add('1-4');

    // Then

    assertVerifyInOrderExceptionForAddMethod(
      '1-2',
      inOrder1,
      firstMock,
      'It should fail because is actually called only 3 times',
      4,
      3
    );
  }

  @IsTest
  private static void thatVerifyInOrderCanHandleMultipleMocks() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List secondMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List thirdMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );

    CMN_MOCK_InOrder inOrder = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock, secondMock }
    );

    // When
    firstMock.add('1-1');
    secondMock.add('2-1');
    thirdMock.add('3-1');

    firstMock.add('1-2');
    secondMock.add('2-2');
    thirdMock.add('3-2');

    firstMock.add('1-1');
    firstMock.add('1-3');
    secondMock.add('2-3');
    thirdMock.add('3-3');

    // Then
    ((CMN_MOCK_List.IList) inOrder.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder.verify(secondMock, MY_MOCKS.calls(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-2');
    ((CMN_MOCK_List.IList) inOrder.verify(secondMock, MY_MOCKS.calls(1)))
      .add('2-2');
    ((CMN_MOCK_List.IList) inOrder.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-3');
    ((CMN_MOCK_List.IList) inOrder.verify(secondMock, MY_MOCKS.calls(1)))
      .add('2-3');

    ((CMN_MOCK_List.IList) MY_MOCKS.verify(thirdMock, MY_MOCKS.times(3)))
      .add(CMN_MOCK_Match.stringStartsWith('3-'));
  }

  @IsTest
  private static void thatVerifyInOrderCanHandleMixedInOrderInstance() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List secondMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List thirdMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );

    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );
    CMN_MOCK_InOrder inOrder2 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock, secondMock }
    );

    // When
    firstMock.add('1-1');
    secondMock.add('2-1');
    thirdMock.add('3-1');

    firstMock.add('1-2');
    secondMock.add('2-2');
    thirdMock.add('3-2');

    firstMock.add('1-1');
    firstMock.add('1-3');
    secondMock.add('2-3');
    thirdMock.add('3-3');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(2)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-3');

    ((CMN_MOCK_List.IList) inOrder2.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder2.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-2');
    ((CMN_MOCK_List.IList) inOrder2.verify(secondMock, MY_MOCKS.calls(1)))
      .add('2-2');
    ((CMN_MOCK_List.IList) inOrder2.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-3');
    ((CMN_MOCK_List.IList) inOrder2.verify(secondMock, MY_MOCKS.calls(1)))
      .add('2-3');

    ((CMN_MOCK_List.IList) MY_MOCKS.verify(thirdMock, MY_MOCKS.times(3)))
      .add(CMN_MOCK_Match.stringStartsWith('3-'));
  }

  @IsTest
  private static void thatVerifyInOrderThrownExceptionIfVerifyMockInstanceNotInTheSet() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List secondMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );

    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    secondMock.add('2-1');

    // Then

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(secondMock, MY_MOCKS.calls(1)))
        .add('2-1');
      System.assert(
        false,
        'An exception was expected, because this verify is not in the list of the mocks to verify'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockexcep) {
      String expectedMessage =
        'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';
      System.assertEquals(
        expectedMessage,
        mockexcep.getMessage(),
        'an exception has been caught as expected, however the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyInOrderThrownExceptionWithCustomMessage() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );

    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    String customErrorMesage = 'Some custom error message';

    // When
    firstMock.add('1-1');
    firstMock.add('1-2');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-2');
    // Then
    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(
          firstMock,
          MY_MOCKS.description(customErrorMesage)
        ))
        .add('1-1');
      System.assert(false, 'expected some exception ');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String expectedMessage =
        'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String). Some custom error message.';
      System.assertEquals(
        expectedMessage,
        e.getMessage(),
        'the verify throw an Exception, but the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyAtMostThrowsExceptionBecauseNotImplemented() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atMost(3)))
        .add('1-1');
      System.assert(
        false,
        'an exception was expected because the method is not implemented for the InOrder class'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'The atMost method is not implemented for the CMN_MOCK_InOrder class';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyBetweenThrowsExceptionBecauseNotImplemented() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.between(3, 5)))
        .add('1-1');
      System.assert(
        false,
        'an exception was expected because the method is not implemented for the InOrder class'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'The between method is not implemented for the CMN_MOCK_InOrder class';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNever() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.never()))
      .add('3-1');
  }

  @IsTest
  private static void thatVerifyNeverWithMatchers() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.never()))
      .add(CMN_MOCK_Match.stringStartsWith('3-'));
  }

  @IsTest
  private static void thatVerifyNeverFailsWhenCalled() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.never()))
        .add('1-1');
      System.assert(
        false,
        'expected some exception because the method has been called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String expectedMessage =
        'In Order: Expected : 0, Actual: 4 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';

      System.assertEquals(
        expectedMessage,
        e.getMessage(),
        'the verify throw an Exception, but the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNeverFailsWhenCalledWithMatchers() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.never()))
        .add(CMN_MOCK_Match.stringStartsWith('1-'));
      System.assert(
        false,
        'expected some exception because the method has been called'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String expectedMessage =
        'In Order: Expected : 0, Actual: 4 -- Wanted but not invoked: ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String).';

      System.assertEquals(
        expectedMessage,
        e.getMessage(),
        'the verify throw an Exception, but the message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyThrowsExceptionWhenCallsIsInvochedFromStandardMock() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    new CMN_MOCK_InOrder(MY_MOCKS, new List<Object>{ firstMock });

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    try {
      ((CMN_MOCK_List.IList) MY_MOCKS.verify(firstMock, MY_MOCKS.calls(1)))
        .add('1-1');
      System.assert(
        false,
        'an exception was expected because the method is only implemented for the InOrder class'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'The calls() method is available only in the InOrder Verification.';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNoMoreInteractionsFails() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1', '1-1', '1-1', '1-1');
    firstMock.addMore('2-1');
    firstMock.add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1', '1-1', '1-1', '1-1');

    // Then
    try {
      inOrder1.verifyNoMoreInteractions();
      System.assert(
        false,
        'an exception was expected because there are other interactions'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage =
        'No more Interactions were expected after the ' +
        CMN_MOCK_List.getStubClassName() +
        '.add(String, String, String, String) method.';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNoMoreInteractionsFailsWhenOnLyOneMethodLeft() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1', '1-1', '1-1', '1-1');
    firstMock.addMore('2-1');
    firstMock.add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .addMore('2-1');

    // Then
    try {
      inOrder1.verifyNoMoreInteractions();
      System.assert(
        false,
        'an exception was expected because there are other interactions'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage =
        'No more Interactions were expected after the ' +
        CMN_MOCK_List.getStubClassName() +
        '.addMore(String) method.';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNoMoreInteractionsPass() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List secondMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );
    CMN_MOCK_InOrder inOrder2 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ secondMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    secondMock.add('1-1');
    secondMock.add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');

    inOrder1.verifyNoMoreInteractions();

    ((CMN_MOCK_List.IList) inOrder2.verify(secondMock, MY_MOCKS.calls(2)))
      .add('1-1');

    inOrder2.verifyNoMoreInteractions();
  }

  @IsTest
  private static void thatVerifyNoMoreInteractionsFailsWhenNoInteracionOccurs() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    try {
      inOrder1.verifyNoMoreInteractions();
      System.assert(
        false,
        'an exception was expected because there are other interactions'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'No Interactions expected on this InOrder Mock instance!';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNoInteractionsFails() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    try {
      inOrder1.verifyNoInteractions();
      System.assert(
        false,
        'an exception was expected because there are other interactions'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'No Interactions expected on this InOrder Mock instance!';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyNoInteractionsPass() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_List secondMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    secondMock.add('1-2');
    //Then
    inOrder1.verifyNoInteractions();
  }

  @IsTest
  private static void thatStrictVerificationCanBePerformed() {
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('4-1');
    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('4-1');
  }

  @IsTest
  private static void thatMixedVerificationDoNotInterfierWithOtherImplementationChecking() {
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('4-1');
    // Then
    ((CMN_MOCK_List.IList) MY_MOCKS.verify(firstMock, MY_MOCKS.times(2)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('4-1');

    ((CMN_MOCK_List.IList) MY_MOCKS.verify(firstMock, MY_MOCKS.times(2)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyAtLeastPassWithSameCallsOfAssertion() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
    firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1'); //all consumed until there by -> verify(firstMock, MY_MOCKS.atLeast(3))).add('1-1');
    firstMock.add('2-1'); //finally consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(3)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');
  }

  @IsTest
  private static void thatVerifyAtLeastPassWithMoreCallsThenAsserted() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
    firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1'); //it verifies until here, but
    firstMock.add('1-1'); //this is consumed as well
    firstMock.add('2-1'); //finally consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');
  }

  @IsTest
  private static void thatVerifyAtLeastThrowsErrorIfCalledLessTimes() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
    firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1'); //there are then only 3 calls available, the assert 4 would fail
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(4)))
        .add('1-1');
      System.assert(
        false,
        'an exception was expected because the atLeast is asserting for 4 calls when instead there are only 3 not consumed calls'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyAtLeastConsumeAllTheInstances() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
    firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1'); // the verify atLeast(2) it verifies until here, but it keep going through the instances
    firstMock.add('1-1');
    firstMock.add('2-1'); //so this would fail because have to first consume all the instances of the ('1-1')
    firstMock.add('1-1');
    firstMock.add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .add('1-1');

    // Then
    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
        .add('2-1');
      System.assert(
        false,
        'an exception was expected because the atLeast have consumed all the interactions of 1-1'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyAtLeastConsumeAllTheInstancesForOnlyTheMethodVerified() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1'); // verify(firstMock, MY_MOCKS.atLeast(2))).add('2-1'); consume until here
    firstMock.add('1-1');
    firstMock.add('1-1'); //those are then free for the second atLeast assertion

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyAtLeastOnce() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce()))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyAtLeastOnceConsumesInstancesUntilLastMethodVerified() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1'); // consumed until there by -> verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');
    firstMock.add('2-1'); // free for another assertion

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce()))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce()))
      .add('2-1');
  }

  @IsTest
  private static void thatVerifyAtLeastOnceThrowsErrorIfCalledLessTimes() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce()))
        .add('1-3');
      System.assert(
        false,
        'an exception was expected because the atLeastOnce is asserting for 1 calls when instead the method is not called at all with that argument'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyAtLeastOnceConsumesAllTheInstances() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1'); //all the instance have been consumed

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce()))
      .add('1-1');

    // Then
    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
        .add('2-1');
      System.assert(
        false,
        'an exception was expected because the atLeast have consumed all the interactions of 1-1'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyTimes() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(3)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyTimesThrowsExceptionIfCalledMoreTimesThanExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(2)))
        .add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 2, Actual: 3 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyTimesThrowsExceptionIfCalledLessTimesThanExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(4)))
        .add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(4)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
  }

  @IsTest
  private static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls2() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(3)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls3() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(3)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(2)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls4() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(5)))
      .add('1-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('1-1');
  }

  @IsTest
  private static void thatVerifyTimesThrowsExceptionWhenAnotherMethodIsCalledBetweenMethodsCalls() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(5)))
        .add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 5, Actual: 4 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatStrictVerificationCanBeEnforced() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(3)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(1)))
      .add('2-1');
  }

  @IsTest
  private static void thatTimesOneIsTheDefaultVerification() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 1, Actual: 4 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';

      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );

      //In Order: Expected : 1, Actual: 4 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).
      //In Order: Expected : 1, Actual: 4 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).
    }
  }

  @IsTest
  private static void thatWithOldNotation() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 3)).add('1-1');
  }

  @IsTest
  private static void thatWithOldNotationThrowsExceptionIfCalledMoreTimesThanExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 2)).add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 2, Actual: 3 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatWithOldNotationThrowsExceptionIfCalledLessTimesThanExpected() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 4)).add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatWithOldNotationPassWhenAnotherMethodIsCalledBetweenMethodsCalls() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 4)).add('1-1');
  }

  @IsTest
  private static void thatWithOldNotationThrowsExceptionWhenAnotherMethodIsCalledBetweenMethodsCalls() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
      .add('2-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 5)).add('1-1');
      System.assert(
        false,
        'exception expected because the method is called more times than expected in the verification'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 5, Actual: 4 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void thatStrictVerificationCanBeEnforcedWithOldNotation() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 1)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 1)).add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 3)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 1)).add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 1)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 1)).add('2-1');
  }

  @IsTest
  private static void thatStrictVerificationCanBeEnforcedWithOldNotationUsingDefaultTimesOne() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    // When
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('1-1');
    firstMock.add('2-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, 3)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('2-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('1-1');
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock)).add('2-1');
  }

  @IsTest
  private static void thatVerifyAtLeastConsumesAllTheInstances2() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    //When
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('1-1');
    firstMock.add('2-1');
    firstMock.add('2-1');
    firstMock.add('2-1');
    firstMock.add('2-1');
    firstMock.add('2-1');
    firstMock.add('1-1');

    // Then
    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .add('1-1');

    try {
      ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(1)))
        .add('2-1');
      System.assert(
        false,
        'exception expected because the atLeast have consumed all the calls'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException mockExcept) {
      String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: CMN_MOCK_List__sfdc_ApexStub.add(String).';
      System.assertEquals(
        expectedMessage,
        mockExcept.getMessage(),
        ' the error message is not as expected'
      );
    }
  }

  @IsTest
  private static void verifyAtLeastAndCapture() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    //When
    firstMock.get2(1, '1-1');
    firstMock.get2(2, '2-1');
    firstMock.get2(1, '3-1');
    firstMock.get2(1, '4-1');
    firstMock.get2(2, '5-1');

    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.atLeast(2)))
      .get2(CMN_MOCK_Match.eqInteger(1), (String) argument.capture());

    System.assertEquals(
      '4-1',
      (String) argument.getValue(),
      'the last value captured is not as expected'
    );
  }

  @IsTest
  private static void verifyTimesAndCaptor() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    //When
    firstMock.get2(1, '1-1');
    firstMock.get2(2, '1-2');
    firstMock.get2(1, '2-1');
    firstMock.get2(2, '2-2');
    firstMock.get2(1, '3-1');
    firstMock.get2(2, '3-2');
    firstMock.get2(1, '4-1');
    firstMock.get2(2, '4-2');
    firstMock.get2(1, '5-1');
    firstMock.get2(2, '5-2');

    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.times(5)))
      .get2(CMN_MOCK_Match.eqInteger(1), (String) argument.capture());

    System.assertEquals(
      '5-1',
      (String) argument.getValue(),
      'the last value captured is not as expected'
    );
  }

  @IsTest
  private static void verifyCallsAndCapture() {
    // Given
    CMN_MOCK_List firstMock = (CMN_MOCK_List) MY_MOCKS.mock(
      CMN_MOCK_List.class
    );
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      MY_MOCKS,
      new List<Object>{ firstMock }
    );

    //When
    firstMock.get2(1, '1-1');
    firstMock.get2(2, '1-2');
    firstMock.get2(1, '2-1');
    firstMock.get2(2, '2-2');
    firstMock.get2(1, '3-1');
    firstMock.get2(2, '3-2');
    firstMock.get2(1, '4-1');
    firstMock.get2(2, '4-2');
    firstMock.get2(1, '5-1');
    firstMock.get2(2, '5-2');

    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(firstMock, MY_MOCKS.calls(2)))
      .get2(CMN_MOCK_Match.eqInteger(1), (String) argument.capture());

    System.assertEquals(
      '2-1',
      (String) argument.getValue(),
      'the last value captured is not as expected'
    );
  }

  private static void assertVerifyInOrderExceptionForAddMoreMethod(
    String argument,
    CMN_MOCK_InOrder inOrderInstance,
    CMN_MOCK_List.IList mockToVerify,
    String expectedFailingReasson,
    Integer expectedCount,
    Integer actualCounts
  ) {
    try {
      ((CMN_MOCK_List.IList) inOrderInstance.verify(
          mockToVerify,
          MY_MOCKS.calls(1)
        ))
        .addMore(argument);
      System.assert(false, 'expected some exception ' + expectedFailingReasson);
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String message = 'In Order: Expected : {0}, Actual: {1} -- Wanted but not invoked: {2}.addMore(String).';

      String expectedMessage = String.format(
        message,
        new List<String>{
          '' + expectedCount,
          '' + actualCounts,
          CMN_MOCK_List.getStubClassName()
        }
      );

      System.assertEquals(
        expectedMessage,
        e.getMessage(),
        'the verify throw an Exception, but the message is not as expected'
      );
    }
  }

  private static void assertVerifyInOrderExceptionForAddMethod(
    String argument,
    CMN_MOCK_InOrder inOrderInstance,
    CMN_MOCK_List.IList mockToVerify,
    String expectedFailingReasson,
    Integer expectedCount,
    Integer actualCounts
  ) {
    try {
      ((CMN_MOCK_List.IList) inOrderInstance.verify(
          mockToVerify,
          MY_MOCKS.calls(expectedCount)
        ))
        .add(argument);
      System.assert(false, 'expected some exception ' + expectedFailingReasson);
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String message = 'In Order: Expected : {0}, Actual: {1} -- Wanted but not invoked: {2}.add(String).';

      String expectedMessage = String.format(
        message,
        new List<String>{
          '' + expectedCount,
          '' + actualCounts,
          CMN_MOCK_List.getStubClassName()
        }
      );

      System.assertEquals(
        expectedMessage,
        e.getMessage(),
        'the verify throw an Exception, but the message is not as expected'
      );
    }
  }
}