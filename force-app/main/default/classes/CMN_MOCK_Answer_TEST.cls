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
 *  <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=false)
private class CMN_MOCK_Answer_TEST {
  private static CMN_MOCK_InvocationOnMock actualInvocation = null;

  @IsTest
  private static void thatAnswersWithException() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.ExceptionForAnswer());
    mocks.stopStubbing();

    // When
    try {
      mockList.get2(0, 'Hi hi Hello Hi hi');
      System.assert(
        false,
        'an exception is expected to be thrown on the answer execution'
      );
    } catch (CMN_MOCK_ApexMocks.ApexMocksException ansExpt) {
      String expectedMessage = 'an error occurs on the execution of the answer';
      // Then
      System.assertEquals(
        expectedMessage,
        ansExpt.getMessage(),
        'the message from the answer is not as expected'
      );
    }
  }

  @IsTest
  private static void thatStoresMethodIntoInvocationOnMock() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.BasicAnswer());
    mocks.stopStubbing();

    // When
    mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    Object methodCalled = actualInvocation.getMethod();
    System.assert(
      methodCalled instanceof CMN_MOCK_QualifiedMethod,
      'the object returned is not a method as expected'
    );

    String expectedMethodSignature =
      CMN_MOCK_List.getStubClassName() + '.get2(Integer, String)';
    System.assertEquals(
      expectedMethodSignature,
      ((CMN_MOCK_QualifiedMethod) methodCalled).toString(),
      ' the method is no the one expected'
    );
  }

  @IsTest
  private static void thatAnswerOnlyForTheMethodStubbedWithAnswer() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(3)).thenReturn('ted');
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.BasicAnswer());
    mocks.stopStubbing();

    // When
    mockList.add('one');
    String noAnswered = mockList.get(3);
    mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    Object methodCalled = actualInvocation.getMethod();
    System.assert(
      methodCalled instanceof CMN_MOCK_QualifiedMethod,
      'the object returned is not a method as expected'
    );

    String expectedMethodSignature =
      CMN_MOCK_List.getStubClassName() + '.get2(Integer, String)';
    System.assertEquals(
      expectedMethodSignature,
      ((CMN_MOCK_QualifiedMethod) methodCalled).toString(),
      ' the method is no the one expected'
    );

    System.assertEquals(
      'ted',
      noAnswered,
      'the get method should have returned the stubbed string'
    );
  }

  @IsTest
  private static void thatMultipleAnswersAreHandled() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get(3))
      .thenAnswer(new CMN_MOCK_Answer_TEST.FirstAnswer());
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.SecondAnswer());
    mocks.stopStubbing();

    // When
    mockList.add('one');
    String answer1 = mockList.get(3);
    String answer2 = mockList.get2(0, 'Hi hi Hello Hi hi');

    System.assertEquals(
      'this is the first answer',
      answer1,
      'the answer wasnt the one expected'
    );
    System.assertEquals(
      'and this is the second one',
      answer2,
      'the answer wasnt the one expected'
    );
  }

  @IsTest
  private static void thatStoresMockInstanceIntoInvocationOnMock() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.BasicAnswer());
    mocks.stopStubbing();

    // When
    mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    System.assert(
      actualInvocation.getMock() instanceof CMN_MOCK_List.IList,
      'the object returned is not a mock instance as expected'
    );
    System.assertEquals(
      mockList,
      actualInvocation.getMock(),
      'the mock returned should be the mockList used in the stubbing'
    );
  }

  @IsTest
  private static void thatMethodsParametersAreAccessible() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.ProcessArgumentAnswer());
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    System.assertEquals(
      'Bye hi Hello Bye hi',
      actualValue,
      'the answer is not correct'
    );
  }

  @IsTest
  private static void thatAnswerOnlyForTheStubbedParameter() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.ProcessArgumentAnswer());
    mocks.stopStubbing();

    // When
    String actualValue1 = mockList.get2(0, 'some string for my method');
    String actualValue2 = mockList.get2(0, 'Hi hi Hello Hi hi');
    String actualValue3 = mockList.get2(
      0,
      'another string for the same method'
    );

    // Then
    System.assertEquals(
      'Bye hi Hello Bye hi',
      actualValue2,
      'the answer is not correct'
    );
    System.assertEquals(null, actualValue1, 'the answer is not correct');
    System.assertEquals(null, actualValue3, 'the answer is not correct');
  }

  @IsTest
  private static void thatMethodsParametersAreAccessibleWhenCalledWithMatchers() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(
        mockList.get2(CMN_MOCK_Match.anyInteger(), CMN_MOCK_Match.anyString())
      )
      .thenAnswer(new CMN_MOCK_Answer_TEST.ProcessArgumentAnswer());
    mocks.stopStubbing();

    // When
    String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

    // Then
    System.assertEquals(
      'Bye hi Hello Bye hi',
      actualValue,
      'the answer is not correct'
    );
  }

  @IsTest
  private static void thatExceptionIsThrownWhenAccessOutOfIndexArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.ExceptionForArgumentsOutOfBound());
    mocks.stopStubbing();

    // When
    mockList.get2(0, 'Hi hi Hello Hi hi');
  }

  @IsTest
  private static void thatExceptionIsThrownWhenAccessNegativeIndexArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.get2(0, 'Hi hi Hello Hi hi'))
      .thenAnswer(new CMN_MOCK_Answer_TEST.ExceptionForNegativeArgumentIndex());
    mocks.stopStubbing();

    // When
    mockList.get2(0, 'Hi hi Hello Hi hi');
  }

  @IsTest
  private static void thatArgumentListEmptyForMethodWithNoArgument() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    mocks.when(mockList.isEmpty())
      .thenAnswer(
        new CMN_MOCK_Answer_TEST.ArgumentListEmptyForMethodWithNoArgument()
      );
    mocks.stopStubbing();

    // When
    mockList.isEmpty();
  }

  @IsTest
  private static void thatAnswerToVoidMethod() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List) mocks.doAnswer(
        new CMN_MOCK_Answer_TEST.BasicAnswer(),
        mockList
      ))
      .addMore('Hi hi Hello Hi hi');
    mocks.stopStubbing();

    // When
    mockList.addMore('Hi hi Hello Hi hi');

    // Then
    Object methodCalled = actualInvocation.getMethod();
    System.assert(
      methodCalled instanceof CMN_MOCK_QualifiedMethod,
      'the object returned is not a method as expected'
    );

    String expectedMethodSignature =
      CMN_MOCK_List.getStubClassName() + '.addMore(String)';
    System.assertEquals(
      expectedMethodSignature,
      ((CMN_MOCK_QualifiedMethod) methodCalled).toString(),
      'Unexpected method name: ' + methodCalled
    );
  }

  @IsTest
  private static void thatAnswerToVoidAndNotVoidMethods() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    mocks.startStubbing();
    ((CMN_MOCK_List) mocks.doAnswer(
        new CMN_MOCK_Answer_TEST.FirstAnswer(),
        mockList
      ))
      .get(3);
    ((CMN_MOCK_List) mocks.doAnswer(
        new CMN_MOCK_Answer_TEST.BasicAnswer(),
        mockList
      ))
      .addMore('Hi hi Hello Hi hi');
    ((CMN_MOCK_List) mocks.doAnswer(
        new CMN_MOCK_Answer_TEST.SecondAnswer(),
        mockList
      ))
      .get2(4, 'Hi hi Hello Hi hi');
    mocks.stopStubbing();

    // When
    String answer1 = mockList.get(3);
    String answer2 = mockList.get2(4, 'Hi hi Hello Hi hi');
    mockList.addMore('Hi hi Hello Hi hi');

    // Then
    Object methodCalled = actualInvocation.getMethod();
    System.assert(
      methodCalled instanceof CMN_MOCK_QualifiedMethod,
      'the object returned is not a method as expected'
    );

    String expectedMethodSignature =
      CMN_MOCK_List.getStubClassName() + '.addMore(String)';
    System.assertEquals(
      expectedMethodSignature,
      ((CMN_MOCK_QualifiedMethod) methodCalled).toString(),
      'the last method called should be the addMore, so should be the last to set the actualInvocation variable.'
    );

    System.assertEquals(
      'this is the first answer',
      answer1,
      'the answer was not the one expected'
    );
    System.assertEquals(
      'and this is the second one',
      answer2,
      'the answer was not the one expected'
    );
  }

  @IsTest
  private static void thatAnswerToDifferentVoidMethods() {
    // Given
    CMN_MOCK_ApexMocks mocks = new CMN_MOCK_ApexMocks();
    CMN_MOCK_List mockList = (CMN_MOCK_List) mocks.mock(CMN_MOCK_List.class);

    CMN_MOCK_Answer_TEST.FirstAnswer answer1 = new CMN_MOCK_Answer_TEST.FirstAnswer();
    CMN_MOCK_Answer_TEST.SecondAnswer answer2 = new CMN_MOCK_Answer_TEST.SecondAnswer();

    System.assertEquals(
      null,
      answer1.getMessage(),
      'the answer message should be null at this stage'
    );
    System.assertEquals(
      null,
      answer2.getMessage(),
      'the answer message should be null at this stage'
    );

    mocks.startStubbing();
    ((CMN_MOCK_List) mocks.doAnswer(answer1, mockList))
      .addMore('Hi hi Hello Hi hi');
    ((CMN_MOCK_List) mocks.doAnswer(answer2, mockList)).add('Hello');
    mocks.stopStubbing();

    // When
    mockList.addMore('Hi hi Hello Hi hi');
    mockList.add('Hello');

    // Then
    System.assertEquals(
      'this is the first answer',
      answer1.getMessage(),
      'the answer was not the one expected'
    );
    System.assertEquals(
      'and this is the second one',
      answer2.getMessage(),
      'the answer was not the one expected'
    );
  }

  //Answers

  public class BasicAnswer implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;
      return null;
    }
  }

  public class ExceptionForAnswer implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'an error occurs on the execution of the answer'
      );
    }
  }

  public class ExceptionForArgumentsOutOfBound implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      try {
        invocation.getArgument(2);
        System.assert(
          false,
          'an exception was expected because the argument in the method are only 2'
        );
      } catch (CMN_MOCK_ApexMocks.ApexMocksException exp) {
        String expectedMessage = 'Invalid index, must be greater or equal to zero and less of 2.';
        String actualMessage = exp.getMessage();
        System.assertEquals(
          expectedMessage,
          actualMessage,
          'the message return by the exception is not as expected'
        );
      }
      return null;
    }
  }

  public class ExceptionForNegativeArgumentIndex implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      try {
        invocation.getArgument(-1);
        System.assert(
          false,
          'an exception was expected because the argument index cannot be negative'
        );
      } catch (CMN_MOCK_ApexMocks.ApexMocksException exp) {
        String expectedMessage = 'Invalid index, must be greater or equal to zero and less of 2.';
        String actualMessage = exp.getMessage();
        System.assertEquals(
          expectedMessage,
          actualMessage,
          'the message return by the exception is not as expected'
        );
      }
      return null;
    }
  }

  public class ArgumentListEmptyForMethodWithNoArgument implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      List<Object> emptyList = invocation.getArguments();

      System.assertEquals(
        0,
        emptyList.size(),
        'the argument list from a method without arguments should be empty'
      );

      return null;
    }
  }

  public class FirstAnswer implements CMN_MOCK_Answer {
    private String answerMessage;

    public String getMessage() {
      return this.answerMessage;
    }

    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      this.answerMessage = 'this is the first answer';

      return answerMessage;
    }
  }

  public class SecondAnswer implements CMN_MOCK_Answer {
    private String answerMessage;

    public String getMessage() {
      return this.answerMessage;
    }

    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      this.answerMessage = 'and this is the second one';

      return answerMessage;
    }
  }

  public class ProcessArgumentAnswer implements CMN_MOCK_Answer {
    public Object answer(CMN_MOCK_InvocationOnMock invocation) {
      actualInvocation = invocation;

      String argument = (String) invocation.getArgument(1);
      System.assertNotEquals(
        null,
        argument,
        ' the argument should have some value'
      );
      argument = argument.replace('Hi', 'Bye');
      return argument;
    }
  }
}