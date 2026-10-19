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
private class CMN_MOCK_System_TEST {
  @IsTest
  private static void assertEquals_WithNoMatchers_ShouldThrowException() {
    try {
      CMN_MOCK_System.assertEquals('Test String', 'Test String');
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(
        'CMN_MOCK_System.assertEquals expects you to register exactly 1 CMN_MOCK_IMatcher (typically through the helpers in CMN_MOCK_Match).',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void assertEquals_WithTooManyMatchers_ShouldThrowException() {
    //Register matchers prematurely
    CMN_MOCK_Match.stringStartsWith('Test S');
    CMN_MOCK_Match.stringEndsWith('t String');
    CMN_MOCK_Match.stringIsNotBlank();

    try {
      CMN_MOCK_System.assertEquals(
        CMN_MOCK_Match.stringStartsWith('Test S'),
        'Test String'
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(
        'CMN_MOCK_System.assertEquals expects you to register exactly 1 CMN_MOCK_IMatcher (typically through the helpers in CMN_MOCK_Match).',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void assertEquals_WithMismatch_ShouldThrowException() {
    try {
      CMN_MOCK_System.assertEquals(
        CMN_MOCK_Match.stringStartsWith('Test X'),
        'Test String'
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String expected = 'Actual: Test String';
      String actual = e.getMessage();
      System.assert(
        actual.contains(expected),
        'Expected: ' +
        expected +
        ', Actual: ' +
        actual
      );
    }
  }

  @IsTest
  private static void assertEquals_WithMatch_ShouldPass() {
    CMN_MOCK_System.assertEquals(
      CMN_MOCK_Match.stringStartsWith('Test S'),
      'Test String'
    );
  }

  @IsTest
  private static void assertEquals_WithCombinedMatcher_ShouldPass() {
    CMN_MOCK_System.assertEquals(
      CMN_MOCK_Match.allOf(
        CMN_MOCK_Match.stringStartsWith('Test S'),
        CMN_MOCK_Match.stringEndsWith('t String'),
        CMN_MOCK_Match.stringIsNotBlank()
      ),
      'Test String'
    );
  }

  @IsTest
  private static void assertEquals_WithCustomMessage_WithNoMatchers_ShouldThrowException() {
    try {
      CMN_MOCK_System.assertEquals(
        'Test String',
        'Test String',
        'My Custom Message'
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(
        'CMN_MOCK_System.assertEquals expects you to register exactly 1 CMN_MOCK_IMatcher (typically through the helpers in CMN_MOCK_Match).',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void assertEquals_WithCustomMessage_WithTooManyMatchers_ShouldThrowException() {
    //Register matchers prematurely
    CMN_MOCK_Match.stringStartsWith('Test S');
    CMN_MOCK_Match.stringEndsWith('t String');
    CMN_MOCK_Match.stringIsNotBlank();

    try {
      CMN_MOCK_System.assertEquals(
        CMN_MOCK_Match.stringStartsWith('Test S'),
        'Test String',
        'My Custom Message'
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      System.assertEquals(
        'CMN_MOCK_System.assertEquals expects you to register exactly 1 CMN_MOCK_IMatcher (typically through the helpers in CMN_MOCK_Match).',
        e.getMessage()
      );
    }
  }

  @IsTest
  private static void assertEquals_WithCustomMessage_WithMismatch_ShouldThrowException() {
    try {
      CMN_MOCK_System.assertEquals(
        CMN_MOCK_Match.stringStartsWith('Test X'),
        'Test String',
        'My Custom Message'
      );
      System.assert(false, 'Expected exception');
    } catch (CMN_MOCK_ApexMocks.ApexMocksException e) {
      String expected = 'Actual: Test String -- My Custom Message';
      String actual = e.getMessage();
      System.assert(
        actual.contains(expected),
        'Expected: ' +
        expected +
        ', Actual: ' +
        actual
      );
    }
  }

  @IsTest
  private static void assertEquals_WithCustomMessage_WithMatch_ShouldPass() {
    CMN_MOCK_System.assertEquals(
      CMN_MOCK_Match.stringStartsWith('Test S'),
      'Test String',
      'My Custom Message'
    );
  }

  @IsTest
  private static void assertEquals_WithCustomMessage_WithCombinedMatcher_ShouldPass() {
    CMN_MOCK_System.assertEquals(
      CMN_MOCK_Match.allOf(
        CMN_MOCK_Match.stringStartsWith('Test S'),
        CMN_MOCK_Match.stringEndsWith('t String'),
        CMN_MOCK_Match.stringIsNotBlank()
      ),
      'Test String',
      'My Custom Message'
    );
  }
}