/**
 * @description Interface containing methods Trigger Handlers must implement to enforce best practice
 * and bulkification of triggers.
 * The Base code was originally sourced from https://meltedwires.com/2013/06/05/trigger-pattern-for-tidy-streamlined-bulkified-triggers-revisited/
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public interface CMN_INT_TriggerHandler {
  /**
   * @description This method is called prior to execution of a BEFORE Trigger. Use this to cache
   * 				any data required into maps prior execution of the Trigger.
   */
  void bulkBefore();

  /**
   * @description This method is called prior to execution of an AFTER Trigger. Use this to cache
   * 				any data required into maps prior execution of the Trigger.
   */
  void bulkAfter();

  /**
   * @description This method is called iteratively for each record to be inserted during a BEFORE
   * Trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
   *
   * @param so as input
   */
  void beforeInsert(SObject so);

  /**
   * @description This method is called iteratively for each record to be updated during a BEFORE
   * Trigger.
   *
   * @param oldSo as input
   * @param so as input
   */
  void beforeUpdate(SObject oldSo, SObject so);

  /**
   * @description This method is called iteratively for each record to be deleted during a BEFORE
   * Trigger.
   *
   * @param so as input
   */
  void beforeDelete(SObject so);

  /**
   * @description This method is called iteratively for each record inserted during an AFTER
   * 				Trigger. Always put field validation in the 'After' methods in case another trigger
   * 				has modified any values. The record is 'read only' by this point.
   *
   * @param so as input
   */
  void afterInsert(SObject so);

  /**
   * @description This method is called iteratively for each record updated during an AFTER
   * 			 Trigger.
   *
   * @param oldSo as input
   * @param so as input
   */
  void afterUpdate(SObject oldSo, SObject so);

  /**
   * @description This method is called iteratively for each record deleted during an AFTER
   * 				Trigger.
   *
   * @param so as input
   */
  void afterDelete(SObject so);

  /**
   * @description This method is called iteratively for each record undeleted during an AFTER
   * 				Trigger.
   *
   * @param so as input
   */
  void afterUndelete(SObject so);

  /**
   * @description This method is called once all records have been processed by the Trigger. Use this
   * 				method to accomplish any final operations such as creation or updates of other records.
   */
  void andFinally();

  /**
   * @description Does this trigger support recursion.
   *
   * @return If true, this trigger will execute again based on updates made during the triggers execution
   */
  Boolean allowRecursion();

  /**
   * @description Does this trigger allow being called as part of another's trigger
   *
   * @return If true, can be called from another trigger
   */
  Boolean allowNonSelfInitiated();
}