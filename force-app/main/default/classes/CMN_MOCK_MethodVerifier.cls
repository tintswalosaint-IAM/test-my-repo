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
 * This class implements the actual verification.
 * <p/>
 * <p>VCCC-378</p>
 * @group Core
 */
public abstract class CMN_MOCK_MethodVerifier {
  /**
   * @description Verify a method was called on a mock object.
   *
   * @param mockInvocation The object holding all the data of the invocation, like the method and arguments and the mock instance.
   * @param verificationMode The verification mode that holds the setting about how the verification should be performed.
   */
  public void verifyMethodCall(
    CMN_MOCK_InvocationOnMock mockInvocation,
    CMN_MOCK_VerificationMode verificationMode
  ) {
    validateMode(verificationMode);

    verify(
      mockInvocation.getMethod(),
      mockInvocation.getMethodArgValues(),
      verificationMode
    );
  }

  /**
   * @description Method that actually performs the verify
   *
   * @param qm The method to be verified.
   * @param methodArg The arguments of the method that needs to be verified.
   * @param verificationMode The verification mode that holds the setting about how the verification should be performed.
   */
  protected abstract void verify(
    CMN_MOCK_QualifiedMethod qm,
    CMN_MOCK_MethodArgValues methodArg,
    CMN_MOCK_VerificationMode verificationMode
  );

  /**
   * @description Method that validates the verification mode used in the verify.
   * Not all the methods from the CMN_MOCK_VerificationMode are implemented
   * for the different classes that extends the CMN_MOCK_MethodVerifier.
   * The error is thrown at run time, so this method is called in the method that actually performs the verify.
   *
   * @param verificationMode The verification mode that has to have been verified.
   * @throws Exception with message for the CMN_MOCK_VerificationMode not implemented.
   */
  protected abstract void validateMode(
    CMN_MOCK_VerificationMode verificationMode
  );

  /**
   * @description Method that performs the argument capturing.
   * Captures argument values during verification.
   *
   * @param matchers The list of matcher with which a method is verified.
   */
  protected void capture(List<CMN_MOCK_IMatcher> matchers) {
    for (CMN_MOCK_IMatcher matcher : matchers) {
      if (matcher instanceof CMN_MOCK_ArgumentCaptor.AnyObject) {
        ((CMN_MOCK_ArgumentCaptor.AnyObject) matcher).storeArgument();
      }
    }
  }

  /**
   * @description throws exception method
   *
   * @param qm as input
   * @param inOrder as input
   * @param expectedCount as input
   * @param qualifier as input
   * @param methodCount as input
   * @param customAssertMessage as input
   */
  protected void throwException(
    CMN_MOCK_QualifiedMethod qm,
    String inOrder,
    Integer expectedCount,
    String qualifier,
    Integer methodCount,
    String customAssertMessage
  ) {
    String assertMessage = 'Wanted but not invoked: ' + qm + '.';

    if (customAssertMessage != null) {
      assertMessage = assertMessage + ' ' + customAssertMessage + '.';
    }

    String message = '{0}Expected : {1}{2}, Actual: {3} -- {4}';

    List<String> errorParameters = new List<String>{
      inOrder,
      expectedCount + '',
      qualifier,
      methodCount + '',
      assertMessage
    };

    throw new CMN_MOCK_ApexMocks.ApexMocksException(
      String.format(message, errorParameters)
    );
  }
}