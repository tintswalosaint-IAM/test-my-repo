/**
 * @description Base object which implements virtual methods that support the INT_Trigger interface
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public virtual without sharing class CMN_TRH_BaseObject implements CMN_INT_TriggerHandler {
  /**
   * @description This method is called prior to execution of a BEFORE Trigger. Use this to cache
   * any data required into maps prior execution of the Trigger.
   */
  public virtual void bulkBefore() {
  }

  /**
   * @description This method is called prior to execution of an AFTER Trigger. Use this to cache
   * any data required into maps prior execution of the Trigger.
   */
  public virtual void bulkAfter() {
  }

  /**
   * @description This method is called iteratively for each record to be inserted during a BEFORE
   * Trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   *
   * @param so as input
   */
  public virtual void beforeInsert(SObject so) {
  }

  /**
   * @description This method is called iteratively for each record to be updated during a BEFORE
   * Trigger.
   *
   * @param oldSo as input
   * @param so as input
   */
  public virtual void beforeUpdate(SObject oldSo, SObject so) {
  }

  /**
   * @description This method is called iteratively for each record to be deleted during a BEFORE
   * 				Trigger.
   *
   * @param so as input
   */
  public virtual void beforeDelete(SObject so) {
  }

  /**
   * @description This method is called iteratively for each record inserted during an AFTER
   * 				Trigger. Always put field validation in the 'After' methods in case another trigger
   * 				has modified any values. The record is 'read only' by this point.
   *
   * @param so as input
   */
  public virtual void afterInsert(SObject so) {
  }

  /**
   * @description This method is called iteratively for each record updated during an AFTER
   * 				Trigger.
   *
   * @param oldSo as input
   * @param so as input
   */
  public virtual void afterUpdate(SObject oldSo, SObject so) {
  }

  /**
   * @description This method is called iteratively for each record deleted during an AFTER
   * 				Trigger.
   *
   * @param so as input
   */
  public virtual void afterDelete(SObject so) {
  }

  /**
   * @description This method is called iteratively for each record UnDeleted during an AFTER
   * 				Trigger.
   *
   * @param so as input
   */
  public virtual void afterUndelete(SObject so) {
  }

  /**
   * @description This method is called once all records have been processed by the Trigger. Use this
   * method to accomplish any final operations such as creation or updates of other records.
   */
  public virtual void andFinally() {
  }

  /**
   * @description Does this trigger support recursion.
   *
   * @return if allow recursion
   */
  public virtual Boolean allowRecursion() {
    return true;
  }
  /**
   * @description Does this trigger allow being called as part of another trigger
   *
   * @return if allow non self initiated triggers
   */
  public virtual Boolean allowNonSelfInitiated() {
    return true;
  }
}