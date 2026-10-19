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
 * Contains counterparts for helper methods in the native System class.
 */
public class CMN_MOCK_System {
  /**
   * @description Verifies that the supplied argument is meaningfully equivalent to the expected argument, as defined by its matcher.
   * See fflib_SystemTest for examples of usage.
   *
   * @param ignoredReturnValue Dummy value, returned on registering an CMN_MOCK_IMatcher.
   * @param value The object instance upon which we are checking equality.
   */
  public static void assertEquals(Object ignoredReturnValue, Object value) {
    assertEquals(ignoredReturnValue, value, null);
  }

  /**
   * @description Verifies that the supplied argument is meaningfully equivalent to the expected argument, as defined by its matcher.
   * See fflib_SystemTest for examples of usage.
   *
   * @param ignoredReturnValue Dummy value, returned on registering an CMN_MOCK_IMatcher.
   * @param value The object instance upon which we are checking equality.
   * @param customAssertMessage Provides context or additional information for the assertion.
   */
  public static void assertEquals(
    Object ignoredReturnValue,
    Object value,
    String customAssertMessage
  ) {
    CMN_MOCK_IMatcher matcher = null;
    try {
      List<CMN_MOCK_IMatcher> matchers = CMN_MOCK_Match.getAndClearMatchers(1);
      matcher = matchers[0];
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'CMN_MOCK_System.assertEquals expects you to register exactly 1 CMN_MOCK_IMatcher (typically through the helpers in CMN_MOCK_Match).'
      );
    }

    if (!matcher.matches(value)) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        String.format(
          'Expected : {0}, Actual: {1}{2}',
          new List<String>{
            String.valueOf(matcher),
            String.valueOf(value),
            String.isBlank(customAssertMessage)
              ? ''
              : (' -- ' + customAssertMessage)
          }
        )
      );
    }
  }
}