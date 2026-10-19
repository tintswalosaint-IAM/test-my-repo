/**
 * @description Public class to return a feature switch record
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_FeatureSwitches {
  /**
   * @description Retrieves the feature switch for a particular user or profile
   *
   * @param instanceId A user Id or Profile Id or Org Id
   *
   * @return A feature switch
   */
  public static CMN_FeatureSwitches__c getFeatureSwitch(Id instanceId) {
    return instanceId == null
      ? CMN_FeatureSwitches__c.getInstance()
      : CMN_FeatureSwitches__c.getInstance(instanceId);
  }

  /**
   * @description This method gets the org defaults for the feature switch
   *
   * @return A feature switch
   */
  public static CMN_FeatureSwitches__c getOrgFeatureSwitchRecord() {
    return CMN_FeatureSwitches__c.getOrgDefaults();
  }
}