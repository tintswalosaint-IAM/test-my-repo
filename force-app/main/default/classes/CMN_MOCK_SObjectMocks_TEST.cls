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
private class CMN_MOCK_SObjectMocks_TEST {
  @IsTest
  private static void testSObjectDomain() {
    CMN_MOCK_ApexMocks mock = new CMN_MOCK_ApexMocks();

    CMN_MOCK_SObjectMocks.SObjectDomain domain = new CMN_MOCK_SObjectMocks.SObjectDomain(
      mock
    );

    mock.startStubbing();

    mock.when(domain.sObjectType()).thenReturn('CMN_Foobar__c');

    mock.stopStubbing();

    System.assert(true);
  }

  @IsTest
  private static void testSObjectSelector() {
    CMN_MOCK_ApexMocks mock = new CMN_MOCK_ApexMocks();

    CMN_MOCK_SObjectMocks.SObjectSelector selector = new CMN_MOCK_SObjectMocks.SObjectSelector(
      mock
    );

    mock.startStubbing();

    mock.when(selector.sObjectType()).thenReturn('CMN_Foobar__c');
    mock.when(
        selector.selectSObjectsById(
          new Set<Id>{
            CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.getSObjectType())
          }
        )
      )
      .thenReturn(new List<CMN_Foobar__c>{ new CMN_Foobar__c() });

    mock.stopStubbing();

    System.assert(true);
  }

  @IsTest
  private static void testSObjectUnitOfWork() {
    CMN_MOCK_ApexMocks mock = new CMN_MOCK_ApexMocks();

    CMN_MOCK_SObjectMocks.SObjectUnitOfWork unitOfWork = new CMN_MOCK_SObjectMocks.SObjectUnitOfWork(
      mock
    );

    mock.startStubbing();

    unitOfWork.registerNew(new CMN_Foobar__c());
    unitOfWork.registerNew(new List<CMN_Foobar__c>{ new CMN_Foobar__c() });
    unitOfWork.registerNew(
      new CMN_Foobar__c(),
      CMN_Foobar__c.CMN_Lookup__c.getDescribe().getSobjectField(),
      new CMN_Foobar__c()
    );
    unitOfWork.registerRelationship(
      new CMN_Foobar__c(),
      CMN_Foobar__c.CMN_Lookup__c.getDescribe().getSobjectField(),
      new CMN_Foobar__c()
    );
    unitOfWork.registerDirty(new CMN_Foobar__c());
    unitOfWork.registerDirty(
      new CMN_Foobar__c(),
      CMN_Foobar__c.CMN_Lookup__c.getDescribe().getSobjectField(),
      new CMN_Foobar__c()
    );
    unitOfWork.registerDirty(new List<CMN_Foobar__c>{ new CMN_Foobar__c() });
    unitOfWork.registerDeleted(new CMN_Foobar__c());
    unitOfWork.registerDeleted(new List<CMN_Foobar__c>{ new CMN_Foobar__c() });
    unitOfWork.commitWork();

    mock.stopStubbing();

    System.assert(true);
  }

  @IsTest
  private static void testSObjectTriggerHandler() {
    CMN_MOCK_ApexMocks mock = new CMN_MOCK_ApexMocks();

    CMN_MOCK_SObjectMocks.SObjectTriggerHandler triggerHandler = new CMN_MOCK_SObjectMocks.SObjectTriggerHandler(
      mock
    );

    mock.startStubbing();

    triggerHandler.bulkBefore();
    triggerHandler.bulkAfter();
    triggerHandler.beforeInsert(new CMN_Foobar__c());
    triggerHandler.beforeUpdate(new CMN_Foobar__c(), new CMN_Foobar__c());
    triggerHandler.beforeDelete(new CMN_Foobar__c());
    triggerHandler.afterInsert(new CMN_Foobar__c());
    triggerHandler.afterUpdate(new CMN_Foobar__c(), new CMN_Foobar__c());
    triggerHandler.afterDelete(new CMN_Foobar__c());
    triggerHandler.afterUndelete(new CMN_Foobar__c());
    triggerHandler.andFinally();
    triggerHandler.allowRecursion();
    triggerHandler.allowNonSelfInitiated();

    mock.stopStubbing();

    System.assert(true);
  }
}