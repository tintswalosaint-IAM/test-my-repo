/**
 * @description Public class to as part of post copy action to disable api calls from custom setting
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public with sharing class CMN_SPC_DisableApiCalls extends CMN_SPC_BaseWorker {
  /**
   * @description Method to override run class to disable feature switch org record
   */
  protected override void internalRun() {
    CMN_FeatureSwitches__c orgDefaultFeatureSwitch = CMN_DAL_FeatureSwitches.getOrgFeatureSwitchRecord();

    if (orgDefaultFeatureSwitch != null) {
      orgDefaultFeatureSwitch.CMN_DisableAllOutboundAPICalls__c = true;

      CMN_DAL_SObjectDomain.updateDBObject(orgDefaultFeatureSwitch);
    }
  }
}