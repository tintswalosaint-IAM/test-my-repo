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
private class CMN_MOCK_ArgumentCaptor_TEST {
  @IsTest
  private static void thatArgumentValueIsCaptured() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
  }

  @IsTest
  private static void thatCanPerformFurtherAssertionsOnCapturedArgumentValue() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    //When
    TestInnerClass testValue = new TestInnerClass();
    testValue.i = 4;
    testValue.s = '5';

    mockList.set(1, testValue);

    //Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      TestInnerClass.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .set(CMN_MOCK_Match.anyInteger(), argument.capture());

    Object capturedArg = argument.getValue();
    System.assertNotEquals(null, capturedArg, 'CapturedArg should not be null');

    System.assert(
      capturedArg instanceof TestInnerClass,
      'CapturedArg should be SObject, instead was ' + capturedArg
    );

    TestInnerClass testValueCaptured = (TestInnerClass) capturedArg;

    System.assertEquals(
      4,
      testValueCaptured.i,
      'the values inside the argument captured should be the same of the original one'
    );
    System.assertEquals(
      '5',
      testValueCaptured.s,
      'the values inside the argument captured should be the same of the original one'
    );
  }

  @IsTest
  private static void thatCaptureArgumentOnlyFromVerifiedMethod() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred');
    //the next call should be ignored because is not the method that has under verify,
    //even if have the same type specified in the capturer.
    mockList.addMore('Barney');

    // Then

    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
    System.assertEquals(
      1,
      argument.getAllValues().size(),
      'the argument captured should be only one'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsForTheVerifiedMethods() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    List<String> stringList = new List<String>{ '3' };
    // When
    mockList.add('Fred');
    mockList.add(stringList);

    mockList.clear();

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add((String) argument.capture());
    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add((List<String>) argument.capture());

    System.assertEquals(
      stringList,
      (List<String>) argument.getValue(),
      'the argument captured is not as expected'
    );

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      2,
      argsCaptured.size(),
      'expected 2 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureArgumentFromRequestedParameter() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        (String) CMN_MOCK_Match.eq('Fred'),
        (String) CMN_MOCK_Match.eq('Barney'),
        (String) argument.capture(),
        (String) CMN_MOCK_Match.eq('Betty')
      );

    System.assertEquals(
      'Wilma',
      (String) argument.getValue(),
      'the argument captured is not as expected, should be Wilma because is the 3rd parameter in the call'
    );
  }

  @IsTest
  private static void thatCaptureLastArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Barney');
    mockList.add('Fred');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureAllArguments() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred');
    mockList.add('Barney');
    mockList.add('Wilma');
    mockList.add('Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 4))
      .add((String) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      4,
      argsCaptured.size(),
      'expected 4 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );
    System.assertEquals(
      'Wilma',
      (String) argsCaptured[2],
      'the third value is not as expected'
    );
    System.assertEquals(
      'Betty',
      (String) argsCaptured[3],
      'the forth value is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsFromMultipleMethods() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred');
    mockList.add('Barney');
    mockList.get2(3, 'pebble');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 2))
      .add((String) argument.capture());

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .get2((Integer) CMN_MOCK_Match.eq(3), (String) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      3,
      argsCaptured.size(),
      'expected 3 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );

    System.assertEquals(
      'pebble',
      (String) argsCaptured[2],
      'the third value is not as expected'
    );
  }

  @IsTest
  private static void thatCanHandleMultipleCapturesInOneMethodCall() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        (String) CMN_MOCK_Match.eq('Fred'),
        (String) argument.capture(),
        (String) argument.capture(),
        (String) CMN_MOCK_Match.eq('Betty')
      );

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      2,
      argsCaptured.size(),
      'expected 2 argument to be captured'
    );

    System.assertEquals(
      'Barney',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );

    System.assertEquals(
      'Wilma',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );
  }

  @IsTest
  private static void thatDoesNotCaptureIfNotVerified() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('3');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      List<String>.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, CMN_MOCK_ApexMocks.NEVER))
      .add((List<String>) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      0,
      argsCaptured.size(),
      'expected 0 argument to be captured'
    );

    System.assertEquals(
      null,
      argument.getValue(),
      'no value should be captured, so must return null'
    );
  }

  @IsTest
  private static void thatCaptureOnlyMethodsThatMatchesWithOtherMatcherAsWell() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Same', 'Same', 'First call', 'First call');
    mockList.add('Same', 'Same', 'Second call', 'Second call');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        CMN_MOCK_Match.eqString('Same'),
        CMN_MOCK_Match.eqString('Same'),
        (String) argument.capture(),
        CMN_MOCK_Match.eqString('First call')
      );

    System.assertEquals('First call', (String) argument.getValue());
  }

  @IsTest
  private static void thatDoesNotCaptureAnythingWhenCaptorIsWrappedInAMatcher() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Same', 'Same', 'First call', 'First call');
    mockList.add('Same', 'Same', 'Second call', 'Second call');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList))
      .add(
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eqString('Same'),
          CMN_MOCK_Match.eqString('Same'),
          argument.capture()
        ),
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eqString('Same'),
          CMN_MOCK_Match.eqString('Same'),
          argument.capture()
        ),
        (String) CMN_MOCK_Match.allOf(
          argument.capture(),
          CMN_MOCK_Match.eqString('First call')
        ),
        (String) CMN_MOCK_Match.allOf(
          argument.capture(),
          CMN_MOCK_Match.eqString('First call')
        )
      );

    List<Object> capturedValues = argument.getAllValues();

    System.assertEquals(
      0,
      capturedValues.size(),
      'nothing should have been capture because the matcher it not really a capture type, but a allOf()'
    );
    System.assertEquals(
      null,
      (String) argument.getValue(),
      'nothing should have been capture because the matcher it not really a capture type, but a allOf()'
    );
  }

  @IsTest
  private static void thatArgumentValueIsCapturedWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
  }

  @IsTest
  private static void thatCanPerformFurtherAssertionsOnCapturedArgumentValueWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    //When
    TestInnerClass testValue = new TestInnerClass();
    testValue.i = 4;
    testValue.s = '5';

    mockList.set(1, testValue);

    //Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      TestInnerClass.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .set(CMN_MOCK_Match.anyInteger(), argument.capture());

    Object capturedArg = argument.getValue();
    System.assertNotEquals(null, capturedArg, 'CapturedArg should not be null');

    System.assert(
      capturedArg instanceof TestInnerClass,
      'CapturedArg should be SObject, instead was ' + capturedArg
    );

    TestInnerClass testValueCaptured = (TestInnerClass) capturedArg;

    System.assertEquals(
      4,
      testValueCaptured.i,
      'the values inside the argument captured should be the same of the original one'
    );
    System.assertEquals(
      '5',
      testValueCaptured.s,
      'the values inside the argument captured should be the same of the original one'
    );
  }

  @IsTest
  private static void thatCaptureArgumentOnlyFromVerifiedMethodWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred');
    //the next call should be ignored because is not the method that has under verify,
    //even if have the same type specified in the capturer.
    mockList.addMore('Barney');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );
    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
    System.assertEquals(
      1,
      argument.getAllValues().size(),
      'the argument captured should be only one'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsForTheVerifiedMethodsWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    List<String> stringList = new List<String>{ '3' };
    // When
    mockList.add('Fred');
    mockList.add(stringList);

    mockList.clear();

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add((String) argument.capture());
    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add((List<String>) argument.capture());

    System.assertEquals(
      stringList,
      (List<String>) argument.getValue(),
      'the argument captured is not as expected'
    );

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      2,
      argsCaptured.size(),
      'expected 2 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureArgumentFromRequestedParameterWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add(
        (String) CMN_MOCK_Match.eq('Fred'),
        (String) CMN_MOCK_Match.eq('Barney'),
        (String) argument.capture(),
        (String) CMN_MOCK_Match.eq('Betty')
      );

    System.assertEquals(
      'Wilma',
      (String) argument.getValue(),
      'the argument captured is not as expected, should be Wilma because is the 3rd parameter in the call'
    );
  }

  @IsTest
  private static void thatCaptureLastArgumentWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Barney');
    mockList.add('Fred');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(2)))
      .add((String) argument.capture());

    System.assertEquals(
      'Fred',
      (String) argument.getValue(),
      'the argument captured is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred');
    mockList.add('Barney');
    mockList.add('Wilma');
    mockList.add('Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(4)))
      .add((String) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      4,
      argsCaptured.size(),
      'expected 4 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );
    System.assertEquals(
      'Wilma',
      (String) argsCaptured[2],
      'the third value is not as expected'
    );
    System.assertEquals(
      'Betty',
      (String) argsCaptured[3],
      'the forth value is not as expected'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsFromMultipleMethodsWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred');
    mockList.add('Barney');
    mockList.get2(3, 'pebble');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(2)))
      .add((String) argument.capture());

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .get2((Integer) CMN_MOCK_Match.eq(3), (String) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      3,
      argsCaptured.size(),
      'expected 3 argument to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );

    System.assertEquals(
      'pebble',
      (String) argsCaptured[2],
      'the third value is not as expected'
    );
  }

  @IsTest
  private static void thatCanHandleMultipleCapturesInOneMethodCallWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add(
        (String) CMN_MOCK_Match.eq('Fred'),
        (String) argument.capture(),
        (String) argument.capture(),
        (String) CMN_MOCK_Match.eq('Betty')
      );

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      2,
      argsCaptured.size(),
      'expected 2 argument to be captured'
    );

    System.assertEquals(
      'Barney',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );

    System.assertEquals(
      'Wilma',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );
  }

  @IsTest
  private static void thatDoesNotCaptureIfNotVerifiedWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('3');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      List<String>.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.never()))
      .add((List<String>) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      0,
      argsCaptured.size(),
      'expected 0 argument to be captured'
    );

    System.assertEquals(
      null,
      argument.getValue(),
      'no value should be captured, so must return null'
    );
  }

  @IsTest
  private static void thatCaptureOnlyMethodsThatMatchesWithOtherMatcherAsWellWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Same', 'Same', 'First call', 'First call');
    mockList.add('Same', 'Same', 'Second call', 'Second call');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add(
        CMN_MOCK_Match.eqString('Same'),
        CMN_MOCK_Match.eqString('Same'),
        (String) argument.capture(),
        CMN_MOCK_Match.eqString('First call')
      );

    System.assertEquals('First call', (String) argument.getValue());
  }

  @IsTest
  private static void thatDoesNotCaptureAnythingWhenCaptorIsWrappedInAMatcherWithInOrderVerification() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);
    CMN_MOCK_InOrder inOrder1 = new CMN_MOCK_InOrder(
      mocks,
      new List<Object>{ mockList }
    );

    // When
    mockList.add('Same', 'Same', 'First call', 'First call');
    mockList.add('Same', 'Same', 'Second call', 'Second call');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) inOrder1.verify(mockList, mocks.calls(1)))
      .add(
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eqString('Same'),
          CMN_MOCK_Match.eqString('Same'),
          argument.capture()
        ),
        (String) CMN_MOCK_Match.allOf(
          CMN_MOCK_Match.eqString('Same'),
          CMN_MOCK_Match.eqString('Same'),
          argument.capture()
        ),
        (String) CMN_MOCK_Match.allOf(
          argument.capture(),
          CMN_MOCK_Match.eqString('First call')
        ),
        (String) CMN_MOCK_Match.allOf(
          argument.capture(),
          CMN_MOCK_Match.eqString('First call')
        )
      );

    List<Object> capturedValues = argument.getAllValues();

    System.assertEquals(
      0,
      capturedValues.size(),
      'nothing should have been capture because the matcher it not really a capture type, but a allOf()'
    );
    System.assertEquals(
      null,
      (String) argument.getValue(),
      'nothing should have been capture because the matcher it not really a capture type, but a allOf()'
    );
  }

  @IsTest
  private static void thatCaptureAllArgumentsWhenMethodIsCalledWithTheSameArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    // When
    mockList.add('Fred');
    mockList.add('Barney');
    mockList.add('Wilma');
    mockList.add('Barney');
    mockList.add('Barney');
    mockList.add('Betty');

    // Then
    CMN_MOCK_ArgumentCaptor argument = CMN_MOCK_ArgumentCaptor.forClass(
      String.class
    );

    ((CMN_MOCK_List.IList) mocks.verify(mockList, 6))
      .add((String) argument.capture());

    List<Object> argsCaptured = argument.getAllValues();

    System.assertEquals(
      6,
      argsCaptured.size(),
      'expected 6 arguments to be captured'
    );

    System.assertEquals(
      'Fred',
      (String) argsCaptured[0],
      'the first value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[1],
      'the second value is not as expected'
    );
    System.assertEquals(
      'Wilma',
      (String) argsCaptured[2],
      'the third value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[3],
      'the fourth value is not as expected'
    );
    System.assertEquals(
      'Barney',
      (String) argsCaptured[4],
      'the fifth value is not as expected'
    );
    System.assertEquals(
      'Betty',
      (String) argsCaptured[5],
      'the sixth value is not as expected'
    );
  }

  private class TestInnerClass {
    public Integer i;
    public String s;
  }
}