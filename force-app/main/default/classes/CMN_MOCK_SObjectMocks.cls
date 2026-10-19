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
 * <p>VCCC-378</p>
 * basic implementation of mocking for sobject related classes, generally mocking should
 * be used sparingly and carefully.
 **/
public class CMN_MOCK_SObjectMocks {
  /**
   * @description mock class for SObjectDomain
   */
  public virtual class SObjectDomain implements CMN_DAL_SObjectDomain.ISObjectDomain {
    private CMN_MOCK_ApexMocks mocks;

    public SObjectDomain(CMN_MOCK_ApexMocks mocks) {
      this.mocks = mocks;
    }

    public Schema.SObjectType sObjectType() {
      return (Schema.SObjectType) mocks.mockNonVoidMethod(
        this,
        'sObjectType',
        new List<Type>{},
        new List<Object>{}
      );
    }
  }

  /**
   * @description mock class for SObjectSelector
   */
  public virtual class SObjectSelector implements CMN_DAL_SObjectSelector.ISObjectSelector {
    private CMN_MOCK_ApexMocks mocks;

    public SObjectSelector(CMN_MOCK_ApexMocks mocks) {
      this.mocks = mocks;
    }

    public Schema.SObjectType sObjectType() {
      return (Schema.SObjectType) mocks.mockNonVoidMethod(
        this,
        'sObjectType',
        new List<Type>{},
        new List<Object>{}
      );
    }

    public List<SObject> selectSObjectsById(Set<Id> idSet) {
      return (List<SObject>) mocks.mockNonVoidMethod(
        this,
        'selectSObjectsById',
        new List<Type>{ Set<Id>.class },
        new List<Object>{ idSet }
      );
    }
  }

  /**
   * @description mock class for CMN_INT_TriggerHandler
   */
  public virtual class SObjectTriggerHandler implements CMN_INT_TriggerHandler {
    private CMN_MOCK_ApexMocks mocks;

    public SObjectTriggerHandler(CMN_MOCK_ApexMocks mocks) {
      this.mocks = mocks;
    }

    public void bulkBefore() {
      mocks.mockVoidMethod(
        this,
        'bulkBefore',
        new List<Type>{},
        new List<Object>{}
      );
    }

    public void bulkAfter() {
      mocks.mockVoidMethod(
        this,
        'bulkAfter',
        new List<Type>{},
        new List<Object>{}
      );
    }

    public void beforeInsert(SObject so) {
      mocks.mockVoidMethod(
        this,
        'beforeInsert',
        new List<Type>{ SObject.class },
        new List<Object>{ so }
      );
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
      mocks.mockVoidMethod(
        this,
        'beforeUpdate',
        new List<Type>{ SObject.class, SObject.class },
        new List<Object>{ oldSo, so }
      );
    }

    public void beforeDelete(SObject so) {
      mocks.mockVoidMethod(
        this,
        'beforeDelete',
        new List<Type>{ SObject.class },
        new List<Object>{ so }
      );
    }

    public void afterInsert(SObject so) {
      mocks.mockVoidMethod(
        this,
        'afterInsert',
        new List<Type>{ SObject.class },
        new List<Object>{ so }
      );
    }

    public void afterUpdate(SObject oldSo, SObject so) {
      mocks.mockVoidMethod(
        this,
        'afterUpdate',
        new List<Type>{ SObject.class, SObject.class },
        new List<Object>{ oldSo, so }
      );
    }

    public void afterDelete(SObject so) {
      mocks.mockVoidMethod(
        this,
        'afterDelete',
        new List<Type>{ SObject.class },
        new List<Object>{ so }
      );
    }

    public void afterUndelete(SObject so) {
      mocks.mockVoidMethod(
        this,
        'afterUndelete',
        new List<Type>{ SObject.class },
        new List<Object>{ so }
      );
    }

    public void andFinally() {
      mocks.mockVoidMethod(
        this,
        'andFinally',
        new List<Type>{},
        new List<Object>{}
      );
    }

    public Boolean allowRecursion() {
      return (Boolean) mocks.mockNonVoidMethod(
        this,
        'allowRecursion',
        new List<Type>{},
        new List<Boolean>{ true }
      );
    }

    public Boolean allowNonSelfInitiated() {
      return (Boolean) mocks.mockNonVoidMethod(
        this,
        'allowNonSelfInitiated',
        new List<Type>{},
        new List<Boolean>{ true }
      );
    }
  }

  /**
   * @description mock class for SObjectUnitOfWork
   */
  public virtual class SObjectUnitOfWork implements CMN_INT_SObjectUnitOfWork {
    private CMN_MOCK_ApexMocks mocks;

    public SObjectUnitOfWork(CMN_MOCK_ApexMocks mocks) {
      this.mocks = mocks;
    }

    public void registerNew(SObject record) {
      mocks.mockVoidMethod(
        this,
        'registerNew',
        new List<Type>{ SObject.class },
        new List<Object>{ record }
      );
    }

    public void registerNew(List<SObject> records) {
      mocks.mockVoidMethod(
        this,
        'registerNew',
        new List<Type>{ List<SObject>.class },
        new List<Object>{ records }
      );
    }

    public void registerNew(
      SObject record,
      Schema.SObjectField relatedToParentField,
      SObject relatedToParentRecord
    ) {
      mocks.mockVoidMethod(
        this,
        'registerNew',
        new List<Type>{
          SObject.class,
          Schema.SObjectField.class,
          SObject.class
        },
        new List<Object>{ record, relatedToParentField, relatedToParentRecord }
      );
    }

    public void registerRelationship(
      SObject record,
      Schema.SObjectField relatedToField,
      SObject relatedTo
    ) {
      mocks.mockVoidMethod(
        this,
        'registerRelationship',
        new List<Type>{
          SObject.class,
          Schema.SObjectField.class,
          SObject.class
        },
        new List<Object>{ record, relatedToField, relatedTo }
      );
    }

    public void registerDirty(SObject record) {
      mocks.mockVoidMethod(
        this,
        'registerDirty',
        new List<Type>{ SObject.class },
        new List<Object>{ record }
      );
    }

    public void registerDirty(
      SObject record,
      Schema.SObjectField relatedToParentField,
      SObject relatedToParentRecord
    ) {
      mocks.mockVoidMethod(
        this,
        'registerDirty',
        new List<Type>{ SObject.class },
        new List<Object>{ record }
      );
    }

    public void registerDirty(List<SObject> records) {
      mocks.mockVoidMethod(
        this,
        'registerDirty',
        new List<Type>{ List<SObject>.class },
        new List<Object>{ records }
      );
    }

    public void registerDeleted(SObject record) {
      mocks.mockVoidMethod(
        this,
        'registerDeleted',
        new List<Type>{ SObject.class },
        new List<Object>{ record }
      );
    }

    public void registerDeleted(List<SObject> records) {
      mocks.mockVoidMethod(
        this,
        'registerDeleted',
        new List<Type>{ List<SObject>.class },
        new List<Object>{ records }
      );
    }

    public void commitWork() {
      mocks.mockVoidMethod(
        this,
        'commitWork',
        new List<Type>{},
        new List<Object>{}
      );
    }
  }
}