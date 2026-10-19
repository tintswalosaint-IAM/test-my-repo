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
 * 'Classic' invocation verifier - checks that a method was called with the given arguments the expected number of times.
 * The order of method calls is not important.
 * <p/>
 * <p>VCCC-378</p>
 * @group Core
 */
public class CMN_MOCK_AnyOrder extends CMN_MOCK_MethodVerifier {
  /**
   * @description Verifies a method was invoked the expected number of times, with the expected arguments.
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
    Integer methodCount = getMethodCount(qm, methodArg);

    String qualifier = '';
    Integer expectedCount = null;

    if (
      (verificationMode.VerifyMin == verificationMode.VerifyMax) &&
      methodCount != verificationMode.VerifyMin
    ) {
      expectedCount = verificationMode.VerifyMin;
    } else if (
      verificationMode.VerifyMin != null &&
      verificationMode.VerifyMin > methodCount
    ) {
      expectedCount = verificationMode.VerifyMin;
      qualifier = ' or more times';
    } else if (
      verificationMode.VerifyMax != null &&
      verificationMode.VerifyMax < methodCount
    ) {
      expectedCount = verificationMode.VerifyMax;
      qualifier = ' or fewer times';
    }

    if (expectedCount != null) {
      throwException(
        qm,
        '',
        expectedCount,
        qualifier,
        methodCount,
        verificationMode.CustomAssertMessage
      );
    }
  }

  /**
   * @description get method count
   *
   * @param qm as input
   * @param methodArg as input
   *
   * @return method count
   */
  private Integer getMethodCount(
    CMN_MOCK_QualifiedMethod qm,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    List<CMN_MOCK_IMatcher> matchers = CMN_MOCK_Match.Matching
      ? CMN_MOCK_Match.getAndClearMatchers(methodArg.argValues.size())
      : null;
    Integer returnValue = 0;

    List<CMN_MOCK_MethodArgValues> methodArgs = CMN_MOCK_MethodCountRecorder.getMethodArgumentsByTypeName()
      .get(qm);

    if (methodArgs != null) {
      if (matchers != null) {
        for (CMN_MOCK_MethodArgValues args : methodArgs) {
          if (CMN_MOCK_Match.matchesAllArgs(args, matchers)) {
            capture(matchers);

            returnValue++;
          }
        }
      } else {
        return countCalls(methodArgs, methodArg);
      }
    }

    return returnValue;
  }

  /**
   * @description counts number of calls
   *
   * @param methodArgs as input
   * @param methodArg as input
   *
   * @return number of calls
   */
  private Integer countCalls(
    List<CMN_MOCK_MethodArgValues> methodArgs,
    CMN_MOCK_MethodArgValues methodArg
  ) {
    Integer count = 0;

    for (CMN_MOCK_MethodArgValues arg : methodArgs) {
      if (arg == methodArg)
        count++;
    }

    return count;
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
    if (verificationMode.Method == CMN_MOCK_VerificationMode.ModeName.calls) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'The calls() method is available only in the InOrder Verification.'
      );
    }
  }
}