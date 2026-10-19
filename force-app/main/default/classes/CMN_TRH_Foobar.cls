/**
 * @description Class is use to get the base object methods that support the INT_Trigger interface
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_TRH_Foobar extends CMN_TRH_BaseObject {
  @TestVisible
  private static Boolean INSERT_NEW_FOO = true;
  @TestVisible
  private static Boolean INITIATE_EXCEPTION = false;

  /**
   * @description implementation of bulk after
   */
  public override void bulkAfter() {
    super.bulkAfter();

    //For some scenarios in unit tests we don't want to insert another item
    if (
      INSERT_NEW_FOO &&
      (Trigger.isUpdate ||
      Trigger.isInsert ||
      Trigger.isUndelete)
    ) {
      //Insert item, this should not result in a second call to trigger
      insert CMN_DAL_DataFactory.newFoobar();
    }
  }

  /**
   * @description implementation of example after insert
   *
   * @param so as input
   */
  public override void afterInsert(SObject so) {
    super.afterInsert(so);

    CMN_Foobar__c newFoobar = (CMN_Foobar__c) so;
    if (INITIATE_EXCEPTION) {
      delete newFoobar;
    }
  }

  /**
   * @description implementation of example allowRecursion
   *
   * @return override or default (result now is not allow recursion)
   */
  public override Boolean allowRecursion() {
    return !super.allowRecursion();
  }
}