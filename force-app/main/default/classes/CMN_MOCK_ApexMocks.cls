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
public inherited sharing class CMN_MOCK_ApexMocks implements System.StubProvider {
  public static final Integer NEVER = 0;

  private final CMN_MOCK_MethodCountRecorder methodCountRecorder;
  private final CMN_MOCK_MethodReturnValueRecorder methodReturnValueRecorder;

  private CMN_MOCK_MethodVerifier methodVerifier;
  private CMN_MOCK_VerificationMode verificationMode;
  private CMN_MOCK_Answer myAnswer;

  public Boolean Verifying { get; set; }

  public Boolean Stubbing {
    get {
      return methodReturnValueRecorder.Stubbing;
    }
    private set;
  }

  public List<Exception> DoThrowWhenExceptions {
    get {
      return methodReturnValueRecorder.DoThrowWhenExceptions;
    }
    set {
      methodReturnValueRecorder.DoThrowWhenExceptions = value;
    }
  }

  /**
   * @description Construct an ApexMocks instance.
   */
  public CMN_MOCK_ApexMocks() {
    Verifying = false;

    this.methodCountRecorder = new CMN_MOCK_MethodCountRecorder();

    this.verificationMode = new CMN_MOCK_VerificationMode();

    this.methodVerifier = new CMN_MOCK_AnyOrder();

    this.methodReturnValueRecorder = new CMN_MOCK_MethodReturnValueRecorder();

    this.methodReturnValueRecorder.Stubbing = false;
  }

  /**
   * @description Creates mock object of given class or interface.
   *
   * @param classToMock class or interface to mock.
   *
   * @return mock object.
   */
  public Object mock(Type classToMock) {
    return Test.createStub(classToMock, this);
  }

  /**
   * @description Inherited from StubProvider.
   *
   * @param stubbedObject The stubbed object.
   * @param stubbedMethodName The name of the invoked method.
   * @param returnType The return type of the invoked method.
   * @param listOfParamTypes A list of the parameter types of the invoked method.
   * @param listOfParamNames A list of the parameter names of the invoked method.
   * @param listOfArgs The actual argument values passed into this method at runtime.
   *
   * @return The stubbed return value. Null by default, unless you prepared one that matches this method and argument values in stubbing.
   */
  public Object handleMethodCall(
    Object stubbedObject,
    String stubbedMethodName,
    Type returnType,
    List<Type> listOfParamTypes,
    List<String> listOfParamNames,
    List<Object> listOfArgs
  ) {
    return mockNonVoidMethod(
      stubbedObject,
      stubbedMethodName,
      listOfParamTypes,
      listOfArgs
    );
  }

  public static String extractTypeName(Object mockInstance) {
    return String.valueOf(mockInstance).split(':').get(0);
  }

  /**
   * @description Verify a method was called on a mock object.
   *
   * @param mockInstance The mock object instance.
   *
   * @return The mock object instance.
   */
  public Object verify(Object mockInstance) {
    return verify(mockInstance, this.times(1));
  }

  /**
   * @description Verify a method was called on a mock object.
   *
   * @param mockInstance The mock object instance.
   * @param verificationMode Defines the constraints for performing the verification (e.g. the minimum and maximum expected invocation counts).
   *
   * @return The mock object instance.
   */
  public Object verify(
    Object mockInstance,
    CMN_MOCK_VerificationMode verificationMode
  ) {
    Verifying = true;
    this.verificationMode = verificationMode;

    return mockInstance;
  }

  /**
   * @description Verify a method was called on a mock object.
   *
   * @param mockInstance The mock object instance.
   * @param times The number of times you expect the method to have been called.
   *
   * @return The mock object instance.
   */
  public Object verify(Object mockInstance, Integer times) {
    return verify(mockInstance, this.times(times));
  }

  /**
   * @description Verify a method was called on a mock object.
   *
   * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
   */
  public void verifyMethodCall(CMN_MOCK_InvocationOnMock mockInvocation) {
    this.methodVerifier.verifyMethodCall(mockInvocation, verificationMode);
    this.methodVerifier = new CMN_MOCK_AnyOrder();

    Verifying = false;
  }

  /**
   * @description Tell ApexMocks framework you are about to start stubbing using when() calls.
   */
  public void startStubbing() {
    methodReturnValueRecorder.Stubbing = true;
  }

  /**
   * @description Tell ApexMocks framework you are about to stop stubbing using when() calls.
   */
  public void stopStubbing() {
    methodReturnValueRecorder.Stubbing = false;
  }

  /**
   * @description Setup when stubbing for a mock object instance.
   *
   * @param ignoredRetVal This is the return value from the method called on the mockInstance, and is ignored here since we are about to setup
   *        the stubbed return value using thenReturn() (see MethodReturnValue class below).
   *
   * @return mock method return value
   */
  public CMN_MOCK_MethodReturnValue when(Object ignoredRetVal) {
    return ignoredRetVal != null
      ? methodReturnValueRecorder.MethodReturnValue
      : methodReturnValueRecorder.MethodReturnValue;
  }

  /**
   * @description Record a method was called on a mock object.
   *
   * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
   */
  public void recordMethod(CMN_MOCK_InvocationOnMock mockInvocation) {
    methodCountRecorder.recordMethod(mockInvocation);
  }

  /**
   * @description Prepare a stubbed method return value.
   *
   * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
   *
   * @return The MethodReturnValue instance.
   */
  public CMN_MOCK_MethodReturnValue prepareMethodReturnValue(
    CMN_MOCK_InvocationOnMock mockInvocation
  ) {
    return methodReturnValueRecorder.prepareMethodReturnValue(mockInvocation);
  }

  /**
   * @description Get the method return value for the given method call.
   *
   * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
   *
   * @return The MethodReturnValue instance.
   */
  public CMN_MOCK_MethodReturnValue getMethodReturnValue(
    CMN_MOCK_InvocationOnMock mockInvocation
  ) {
    return methodReturnValueRecorder.getMethodReturnValue(mockInvocation);
  }

  /**
   * @description Setup exception stubbing for a void method.
   *
   * @param e The exception to throw.
   * @param mockInstance The mock object instance.
   *
   * @return object
   */
  public Object doThrowWhen(Exception e, Object mockInstance) {
    methodReturnValueRecorder.prepareDoThrowWhenExceptions(
      new List<Exception>{ e }
    );
    return mockInstance;
  }

  /**
   * @description Setup exception stubbing for a void method.
   *
   * @param exps The list of exceptions to throw.
   * @param mockInstance The mock object instance.
   *
   * @return object
   */
  public Object doThrowWhen(List<Exception> exps, Object mockInstance) {
    methodReturnValueRecorder.prepareDoThrowWhenExceptions(exps);
    return mockInstance;
  }

  /**
   * @description Setup answer stubbing for a void method.
   *
   * @param answer The answer to invoke.
   * @param mockInstance The mock object instance.
   *
   * @return object
   */
  public Object doAnswer(CMN_MOCK_Answer answer, Object mockInstance) {
    this.myAnswer = answer;
    return mockInstance;
  }

  /**
   * @description Mock a void method. Called by generated mock instance classes, not directly by a developers
   * code.
   *
   * @param mockInstance The mock object instance.
   * @param methodName The method for which to prepare a return value.
   * @param methodArgTypes The method argument types for which to prepare a return value.
   * @param methodArgValues The method argument values for which to prepare a return value.
   */
  public void mockVoidMethod(
    Object mockInstance,
    String methodName,
    List<Type> methodArgTypes,
    List<Object> methodArgValues
  ) {
    mockNonVoidMethod(
      mockInstance,
      methodName,
      methodArgTypes,
      methodArgValues
    );
  }

  /**
   * @description Mock a non-void method. Called by generated mock instance classes, not directly by a developers
   * code.
   *
   * @param mockInstance The mock object instance.
   * @param methodName The method for which to prepare a return value.
   * @param methodArgTypes The method argument types for which to prepare a return value.
   * @param methodArgValues The method argument values for which to prepare a return value.
   *
   * @return object
   */
  public Object mockNonVoidMethod(
    Object mockInstance,
    String methodName,
    List<Type> methodArgTypes,
    List<Object> methodArgValues
  ) {
    CMN_MOCK_QualifiedMethod qm = new CMN_MOCK_QualifiedMethod(
      extractTypeName(mockInstance),
      methodName,
      methodArgTypes,
      mockInstance
    );
    CMN_MOCK_MethodArgValues argValues = new CMN_MOCK_MethodArgValues(
      methodArgValues
    );

    CMN_MOCK_InvocationOnMock invocation = new CMN_MOCK_InvocationOnMock(
      qm,
      argValues,
      mockInstance
    );

    if (Verifying) {
      verifyMethodCall(invocation);
    } else if (Stubbing) {
      CMN_MOCK_MethodReturnValue methodReturnValue = prepareMethodReturnValue(
        invocation
      );

      if (DoThrowWhenExceptions != null) {
        methodReturnValue.thenThrowMulti(DoThrowWhenExceptions);
        DoThrowWhenExceptions = null;
        return null;
      }

      if (this.myAnswer != null) {
        methodReturnValue.thenAnswer(this.myAnswer);
        this.myAnswer = null;
        return null;
      }

      return null;
    } else {
      recordMethod(invocation);
      return returnValue(invocation);
    }

    return null;
  }

  public class ApexMocksException extends Exception {
  }

  private Object returnValue(CMN_MOCK_InvocationOnMock invocation) {
    CMN_MOCK_MethodReturnValue methodReturnValue = getMethodReturnValue(
      invocation
    );

    if (methodReturnValue != null) {
      if (methodReturnValue.Answer == null) {
        throw new CMN_MOCK_ApexMocks.ApexMocksException(
          'The stubbing is not correct, no return values have been set.'
        );
      }

      Object returnedValue = methodReturnValue.Answer.answer(invocation);

      if (returnedValue == null) {
        return null;
      }

      if (returnedValue instanceof Exception) {
        throw ((Exception) returnedValue);
      }

      return returnedValue;
    }

    return null;
  }

  /**
   * @description Sets how many times the method is expected to be called.
   * For InOrder verification we copy Mockito behavior which is as follows;
   * <ul>
   * <li>Consume the specified number of matching invocations, ignoring non-matching invocations in between</li>
   * <li>Fail an assert if the very next invocation matches, but additional matches can still exist so long as at least one non-matching invocation exists before them</li>
   * </ul>
   * For example if you had a(); a(); b(); a();
   * then inOrder.verify(myMock, 2)).a(); or inOrder.verify(myMock, 3)).a(); would pass but not inOrder.verify(myMock, 1)).a();
   *
   * @param times The number of times you expect the method to have been called.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode times(Integer times) {
    return new CMN_MOCK_VerificationMode().times(times);
  }

  /**
   * @description Sets how many times the method is expected to be called for an InOrder verifier. Available Only with the InOrder verification.
   * A verification mode using calls will not fail if the method is called more times than expected.
   *
   * @param times The number of times you expect the method to have been called in the InOrder verifying ( no greedy verify).
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode calls(Integer times) {
    return new CMN_MOCK_VerificationMode().calls(times);
  }

  /**
   * @description Sets a custom assert message for the verify.
   *
   * @param customAssertMessage The custom message for the assert in case the assert is false. The custom message is queued to the default message.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode description(String customAssertMessage) {
    return new CMN_MOCK_VerificationMode().description(customAssertMessage);
  }

  /**
   * @description Sets the minimum number of times the method is expected to be called.
   * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
   *
   * @param atLeastTimes The minimum number of times you expect the method to have been called.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode atLeast(Integer atLeastTimes) {
    return new CMN_MOCK_VerificationMode().atLeast(atLeastTimes);
  }

  /**
   * @description Sets the maximum number of times the method is expected to be called. Not available in the InOrder verification.
   *
   * @param atMostTimes The maximum number of times the method is expected to be called.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode atMost(Integer atMostTimes) {
    return new CMN_MOCK_VerificationMode().atMost(atMostTimes);
  }

  /**
   * @description Sets that the method is called at least once.
   * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode atLeastOnce() {
    return new CMN_MOCK_VerificationMode().atLeastOnce();
  }

  /**
   * @description Sets the range of how many times the method is expected to be called. Not available in the InOrder verification.
   *
   * @param atLeastTimes The minimum number of times you expect the method to have been called.
   * @param atMostTimes The maximum number of times the method is expected to be called.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode between(
    Integer atLeastTimes,
    Integer atMostTimes
  ) {
    return new CMN_MOCK_VerificationMode().between(atLeastTimes, atMostTimes);
  }

  /**
   * @description Sets that the method is not expected to be called.
   *
   * @return The CMN_MOCK_VerificationMode object instance with the proper settings.
   */
  public CMN_MOCK_VerificationMode never() {
    return new CMN_MOCK_VerificationMode().never();
  }

  /**
   * @description Sets the CMN_MOCK_VerificationMode object.
   * To internal use only.
   * Used to pass the verification mode that has been set in the  verify of the CMN_MOCK_InOrder class.
   *
   * @param verifyOrderingMode as input
   */
  public void setOrderedVerifier(CMN_MOCK_InOrder verifyOrderingMode) {
    this.methodVerifier = verifyOrderingMode;
  }
}