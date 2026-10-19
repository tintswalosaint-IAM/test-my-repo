/**
 * @description Provides Query methods related for TriggersToDisable Custom Setting
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_TriggersToDisable {
  /**
   * @description Will return base fields to return on a query
   *
   * @return A list of Trigger To Enable Custom Setting fields
   */
  @TestVisible
  private static Set<String> getDefaultFields() {
    return new Set<String>{ 'CMN_ClassName__c', 'Id', 'Name' };
  }

  /**
   * @description Will check if a trigger has been disabled
   *
   * @param triggerName The name of the trigger to check (must be the class name)
   *
   * @return Returns true if a row is NOT found for the given triggerName
   */
  public static Boolean isTriggerEnabled(String triggerName) {
    SObject foundItem = CMN_DAL_SObjectSelector.findByField(
      CMN_TriggersToDisable__c.SObjectType,
      CMN_TriggersToDisable__c.CMN_ClassName__c,
      triggerName,
      getDefaultFields(),
      false
    );

    return foundItem == null;
  }
}