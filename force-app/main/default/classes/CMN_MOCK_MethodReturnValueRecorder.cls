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
public with sharing class CMN_MOCK_MethodReturnValueRecorder {
  public Boolean Stubbing { get; set; }

  public List<Exception> DoThrowWhenExceptions { get; set; }

  /**
   * @description Map of matchers by method.
   * <p/>
   * Key: qualifiedMethod
   * Object: map of method return values by method.
   */

  private Map<CMN_MOCK_QualifiedMethod, List<CMN_MOCK_MatchersReturnValue>> matcherReturnValuesByMethod;

  public CMN_MOCK_MethodReturnValue MethodReturnValue { get; private set; }

  public CMN_MOCK_MethodReturnValueRecorder() {
    matcherReturnValuesByMethod = new Map<CMN_MOCK_QualifiedMethod, List<CMN_MOCK_MatchersReturnValue>>();

    MethodReturnValue = null;
  }

  /**
   * @description Prepare a stubbed method return value.
   *
   * @param invocation The object holding all the data of the invocation, like the method and arguments and the mock instance.
   *
   * @return The MethodReturnValue instance.
   */
  public CMN_MOCK_MethodReturnValue prepareMethodReturnValue(
    CMN_MOCK_InvocationOnMock invocation
  ) {
    MethodReturnValue = new CMN_MOCK_MethodReturnValue();

    List<CMN_MOCK_MatchersReturnValue> matcherReturnValues = matcherReturnValuesByMethod.get(
      invocation.getMethod()
    );
    if (matcherReturnValues == null) {
      matcherReturnValues = new List<CMN_MOCK_MatchersReturnValue>();
      matcherReturnValuesByMethod.put(
        invocation.getMethod(),
        matcherReturnValues
      );
    }

    List<Object> argValues = invocation.getMethodArgValues().argValues;

    //Register explicit arg values as 'equals' matchers, to preserve old behaviour
    if (!CMN_MOCK_Match.Matching) {
      for (Object arg : argValues) {
        if (arg == null) {
          CMN_MOCK_Match.isNull();
        } else {
          CMN_MOCK_Match.eq(arg);
        }
      }
    }

    List<CMN_MOCK_IMatcher> matchers = CMN_MOCK_Match.getAndClearMatchers(
      argValues.size()
    );
    matcherReturnValues.add(
      new CMN_MOCK_MatchersReturnValue(matchers, MethodReturnValue)
    );

    return MethodReturnValue;
  }

  /**
   * @description Get the method return value for the given method call.
   *
   * @param invocation The object holding all the data of the invocation, like the method and arguments and the mock instance.
   *
   * @return The MethodReturnValue instance.
   */
  public CMN_MOCK_MethodReturnValue getMethodReturnValue(
    CMN_MOCK_InvocationOnMock invocation
  ) {
    List<CMN_MOCK_MatchersReturnValue> matchersForMethods = matcherReturnValuesByMethod.get(
      invocation.getMethod()
    );
    if (matchersForMethods != null) {
      for (Integer i = matchersForMethods.size() - 1; i >= 0; i--) {
        CMN_MOCK_MatchersReturnValue matchersReturnValue = (CMN_MOCK_MatchersReturnValue) matchersForMethods.get(
          i
        );
        if (
          CMN_MOCK_Match.matchesAllArgs(
            invocation.getMethodArgValues(),
            matchersReturnValue.matchers
          )
        ) {
          return matchersReturnValue.returnValue;
        }
      }
    }

    return null;
  }

  /**
   * @description Prepare a stubbed exceptions for a void method.
   *
   * @param exps The list of exception to throw.
   */
  public void prepareDoThrowWhenExceptions(List<Exception> exps) {
    DoThrowWhenExceptions = exps;
  }
}