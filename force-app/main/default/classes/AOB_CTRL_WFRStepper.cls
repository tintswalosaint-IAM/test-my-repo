/**
 * Controller for aob_comp_WFRStepper component
 *
 * <p>DPB-1460</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Dec 21st 2020
 */
public with sharing class AOB_CTRL_WFRStepper {
  public static final String Category = 'WFR';
  public static final String SettingName = 'AOB_WFR_Steps';
  /**
   * @description	gets the available steps for WFR
   * @return List of available steps
   */
  @AuraEnabled
  public static List<String> getWFRSteps() {
    List<AOB_AppSettings__mdt> appSettings = [
      SELECT AOB_Value__c
      FROM AOB_AppSettings__mdt
      WHERE AOB_Category__c = :Category AND DeveloperName = :SettingName
    ];
    if (appSettings.isEmpty()) {
      return new List<String>();
    } else {
      return appSettings[0].AOB_Value__c.split(';');
    }
  }
}