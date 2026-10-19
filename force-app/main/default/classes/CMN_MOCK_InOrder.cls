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
 * @group Core
 */
public inherited sharing class CMN_MOCK_InOrder extends CMN_MOCK_MethodVerifier {
  private final List<Object> unorderedMockInstances;
  private Integer idxMethodCall = 0;

  private Set<CMN_MOCK_VerificationMode.ModeName> notImplementedMethods = new Set<CMN_MOCK_VerificationMode.ModeName>{
    CMN_MOCK_VerificationMode.ModeName.atMost,
    CMN_MOCK_VerificationMode.ModeName.between
  };

  private final CMN_MOCK_ApexMocks mocks;

  /**
   * @description Construct the InOrder instance.
   *
   * @param mocks The apex mock object instance.
   * @param unorderedMockInstances One or more mock implementation classes (listed in any order), whose ordered method calls require verification.
   */
  public CMN_MOCK_InOrder(
    CMN_MOCK_ApexMocks mocks,
    List<Object> unorderedMockInstances
  ) {
    this.unorderedMockInstances = unorderedMockInstances;
    this.mocks = mocks;
  }

  /**
   * @description Verify a method was called on a mock object.
   * It performs a no strict ordered verification.
   * The verification could be either greedy or not depending of the verificationMode passed.
   * Check the CMN_MOCK_VerificationMode methods for details.
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
    mocks.setOrderedVerifier(this);
    return mocks.verify(mockInstance, verificationMode);
  }

  /**
   * @description Verify a method was called on a mock object.
   * It performs the default times(1) verification for the InOrder.
   *
   * @param mockInstance The mock object instance.
   *
   * @return The mock object instance.
   */
  public Object verify(Object mockInstance) {
    mocks.setOrderedVerifier(this);
    return mocks.verify(mockInstance);
  }

  /**
   * @description Verify a method was called on a mock object.
   * Wrapper for the new syntax call to be conformed to the old style notation
   * It performs the equivalent of times(times) verification for the InOrder.
   *
   * @param mockInstance The mock object instance.
   * @param times The number of times you expect the method to have been called.
   *
   * @return The mock object instance.
   */
  public Object verify(Object mockInstance, Integer times) {
    mocks.setOrderedVerifier(this);
    return mocks.verify(mockInstance, times);
  }

  /**
   * @description Verify that after the last successful verified method no more interactions happened on the inOrderMock instance.
   * @throws Exception with message to help to identify the last method called.
   */
  public void verifyNoMoreInteractions() {
    if (idxMethodCall == 0) {
      verifyNoInteractions();
    }

    if (hasNextInteraction(unorderedMockInstances, idxMethodCall)) {
      CMN_MOCK_InvocationOnMock invocation = CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls()
        .get(idxMethodCall - 1);

      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'No more Interactions were expected after the ' +
        invocation.getMethod() +
        ' method.'
      );
    }
  }

  /**
   * @description Verify that no interactions at all happened on the inOrderMock instance.
   * @throws Exception with message.
   */
  public void verifyNoInteractions() {
    if (hasNextInteraction(unorderedMockInstances, 0)) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'No Interactions expected on this InOrder Mock instance!'
      );
    }
  }

  /**
   * @description Verifies a method was invoked the expected number of times, with the expected arguments.
   * The in-order verifier remembers the last method invocation it successfully verified,
   * and only considers subsequent method invocations for subsequent verifications.
   *
   * @param qm The method to be verified.
   * @param methodArg The arguments of the method that needs to be verified.
   * @param verificationMode The verification mode that holds the setting about how the verification should be performed.
   */
  protected override void verify(
    CMN_MOCK_QualifiedMethod qm,
    CMN_MOCK_MethodArgValues methodArg,
    CMN_MOCK_VerificationMode verificationMode
  ) {
    String inOrder = 'In Order: ';
    List<CMN_MOCK_IMatcher> matchers = CMN_MOCK_Match.Matching
      ? CMN_MOCK_Match.getAndClearMatchers(methodArg.argValues.size())
      : null;

    if (verificationMode.VerifyMin == 0 && verificationMode.VerifyMax == 0) {
      Integer methodCounts = countInteractions(matchers, qm, methodArg);
      if (methodCounts != 0) {
        throwException(
          qm,
          inOrder,
          CMN_MOCK_ApexMocks.NEVER,
          '',
          methodCounts,
          verificationMode.CustomAssertMessage
        );
      }
    }

    Integer i = 0;

    for (; i < verificationMode.VerifyMin; i++) {
      if (!verifyMethodCalled(matchers, qm, methodArg)) {
        throwException(
          qm,
          inOrder,
          verificationMode.VerifyMin,
          '',
          i,
          verificationMode.CustomAssertMessage
        );
      }
    }

    if (verificationMode.VerifyMin == verificationMode.VerifyMax) {
      if (hasNextInteraction(unorderedMockInstances, idxMethodCall)) {
        CMN_MOCK_InvocationOnMock nextMethod = getNextMethodCall(false);

        if (
          nextMethod.getMethod() == qm &&
          argumentsMatch(nextMethod.getMethodArgValues(), matchers, methodArg)
        ) {
          Integer methodCounts = i + countInteractions(matchers, qm, methodArg);
          throwException(
            qm,
            inOrder,
            verificationMode.VerifyMin,
            '',
            methodCounts,
            verificationMode.CustomAssertMessage
          );
        }
      }

      return;
    }

    //consuming all the calls in case is the atLeast or atLeastOnce method
    if (
      verificationMode.Method == CMN_MOCK_VerificationMode.ModeName.atLeast ||
      verificationMode.Method == CMN_MOCK_VerificationMode.ModeName.atLeastOnce
    ) {
      consumeInteractions(matchers, qm, methodArg);
    }
  }

  private Boolean verifyMethodCalled(
    List<CMN_MOCK_IMatcher> matchers,
    CMN_MOCK_QualifiedMethod qm,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    CMN_MOCK_InvocationOnMock calledMethod = getNextMethodCall();
    while (calledMethod != null) {
      if (
        calledMethod.getMethod() == qm &&
        argumentsMatch(calledMethod.getMethodArgValues(), matchers, methodArg)
      ) {
        //it's our method
        if (matchers != null) {
          capture(matchers);
        }
        return true;
      }

      calledMethod = getNextMethodCall();
    }

    return false;
  }

  private Integer countInteractions(
    List<CMN_MOCK_IMatcher> matchers,
    CMN_MOCK_QualifiedMethod qualifiedMethod,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    Integer interactionsCounter = 0;

    for (
      Integer i = idxMethodCall,
        len = CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls().size();
      i < len;
      i++
    ) {
      CMN_MOCK_InvocationOnMock invocation = CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls()
        .get(i);
      for (Object mockInstance : unorderedMockInstances) {
        if (
          invocation.getMock() === mockInstance &&
          (qualifiedMethod == invocation.getMethod()) &&
          (argumentsMatch(invocation.getMethodArgValues(), matchers, methodArg))
        ) {
          interactionsCounter++;
        }
      }
    }

    return interactionsCounter;
  }

  private void consumeInteractions(
    List<CMN_MOCK_IMatcher> matchers,
    CMN_MOCK_QualifiedMethod qualifiedMethod,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    Integer lastInteracionIndex = 0;

    //going all through the orderedMethodCalls to find all the interaction of the method
    for (
      Integer i = idxMethodCall,
        len = CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls().size();
      i < len;
      i++
    ) {
      CMN_MOCK_InvocationOnMock invocation = CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls()
        .get(i);
      for (Object mockInstance : unorderedMockInstances) {
        if (
          invocation.getMock() === mockInstance &&
          (qualifiedMethod == invocation.getMethod()) &&
          (argumentsMatch(invocation.getMethodArgValues(), matchers, methodArg))
        ) {
          //it's our method
          lastInteracionIndex = i;
          if (matchers != null) {
            capture(matchers);
          }
        }
      }
    }

    //now we can move the index to our last call
    idxMethodCall = lastInteracionIndex + 1;
  }

  private Boolean argumentsMatch(
    CMN_MOCK_MethodArgValues calledMethodArg,
    List<CMN_MOCK_IMatcher> matchers,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    //Check it was called with the right args.
    if (matchers != null) {
      if (CMN_MOCK_Match.matchesAllArgs(calledMethodArg, matchers)) {
        //Return now we've matched the method call
        return true;
      }
    } else if (calledMethodArg == methodArg) {
      //Return now we've matched the method call
      return true;
    }

    return false;
  }

  private CMN_MOCK_InvocationOnMock getNextMethodCall() {
    return getNextMethodCall(true);
  }

  private CMN_MOCK_InvocationOnMock getNextMethodCall(
    Boolean updateIdxMethodCall
  ) {
    Integer idx = 0;
    for (
      CMN_MOCK_InvocationOnMock invocation : CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls()
    ) {
      if (idx == idxMethodCall) {
        if (isForMockInstance(invocation)) {
          if (updateIdxMethodCall) {
            idxMethodCall++;
          }
          return invocation;
        }
      } else {
        idx++;
      }
    }

    return null;
  }

  private Boolean isForMockInstance(CMN_MOCK_InvocationOnMock invocation) {
    for (Object mi : unorderedMockInstances) {
      if (mi === invocation.getMock()) {
        return true;
      }
    }

    return false;
  }

  /**
   * @description Used by the CMN_MOCK_InOrder invocation verifier to find further interactions with a given mock instances.
   *
   * @param mockInstances The tracked mock instances - only methods called on these objects are counted as an invocation.
   * @param idxLastMethodCalled The index of the last matched method, used to offset the search for invocations
   * so we don't double count invocations.
   *
   * @return Whether or not there were further interactions.
   */
  private Boolean hasNextInteraction(
    List<Object> mockInstances,
    Integer idxLastMethodCalled
  ) {
    Integer idx = 0;

    for (
      CMN_MOCK_InvocationOnMock methodCall : CMN_MOCK_MethodCountRecorder.getOrderedMethodCalls()
    ) {
      if (isForMockInstance(methodCall)) {
        idx++;
        if (idx > idxLastMethodCalled) {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * @description Method that validate the verification mode used in the verify.
   * Not all the methods from the CMN_MOCK_VerificationMode are implemented
   * for the different classes that extends the CMN_MOCK_MethodVerifier.
   * The error is thrown at run time, so this method is called in the method that actually performs the verify.
   *
   * @param verificationMode The verification mode that have to been verified.
   * @throws Exception with message for the CMN_MOCK_VerificationMode not implemented.
   */
  protected override void validateMode(
    CMN_MOCK_VerificationMode verificationMode
  ) {
    if (notImplementedMethods.contains(verificationMode.Method)) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'The ' +
        verificationMode.Method.name() +
        ' method is not implemented for the CMN_MOCK_InOrder class'
      );
    }
  }
}