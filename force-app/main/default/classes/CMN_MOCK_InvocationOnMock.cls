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
 * An invocation on a mock.
 * A place holder for mock, the method that was called and the arguments that were passed.
 * <p/>
 * <p>VCCC-378</p>
 * @group Core
 */
public inherited sharing class CMN_MOCK_InvocationOnMock {
  private CMN_MOCK_QualifiedMethod qm;
  private CMN_MOCK_MethodArgValues methodArg;
  private Object mockInstance;

  /**
   * @description Constructor for the class.
   *
   * @param qm The CMN_MOCK_QualifiedMethod instance to be stored.
   * @param args The CMN_MOCK_MethodArgValues instance to be stored.
   * @param mockInstance The mock instance to be stored.
   */
  public CMN_MOCK_InvocationOnMock(
    CMN_MOCK_QualifiedMethod qm,
    CMN_MOCK_MethodArgValues args,
    Object mockInstance
  ) {
    this.qm = qm;
    this.methodArg = args;
    this.mockInstance = mockInstance;
  }

  /**
   * @description Returns the argument at the given index.
   *
   * @param index The index of the wanted argument.
   *  @throws ApexMocksException in case the index is out of range.
   *
   * @return The argument at the given index.
   */
  public Object getArgument(Integer index) {
    validateIndex(index);
    return methodArg.argValues[index];
  }

  /**
   * @description Returns the list of arguments passed to the method.
   *
   * @return The list of arguments.
   */
  public List<Object> getArguments() {
    return methodArg.argValues;
  }

  /**
   * @description Returns CMN_MOCK_MethodArgValues instance that represents the arguments passed to the method.
   *
   * @return The CMN_MOCK_MethodArgValues instance that represents the arguments passed to the method.
   */
  public CMN_MOCK_MethodArgValues getMethodArgValues() {
    return methodArg;
  }

  /**
   * @description Returns the CMN_MOCK_QualifiedMethod instance that represent the fully qualified method called within the invocation.
   *
   * @return The method stored in the invocation.
   */
  public CMN_MOCK_QualifiedMethod getMethod() {
    return qm;
  }

  /**
   * @description Returns the mock object on which the invocation occurs.
   *
   * @return The mock object on which the invocation occurs.
   */
  public Object getMock() {
    return mockInstance;
  }

  /**
   * @description validate index of method args
   *
   * @param index as input
   */
  private void validateIndex(Integer index) {
    if (index < 0 || index >= methodArg.argValues.size()) {
      throw new CMN_MOCK_ApexMocks.ApexMocksException(
        'Invalid index, must be greater or equal to zero and less of ' +
        methodArg.argValues.size() +
        '.'
      );
    }
  }
}