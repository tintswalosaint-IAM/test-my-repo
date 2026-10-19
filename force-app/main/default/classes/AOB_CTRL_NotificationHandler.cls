/**
 * Class for all callback notifications
 *
 * <p></p>
 *
 * @author Maryem BOURHI(mbourhi @salesforce.com)
 *
 * @date Nov 24th 2020
 */
public with sharing class AOB_CTRL_NotificationHandler {
  /**
   * @description gets the current application record
   * @param	applicationId 
   * @return list
   */
  @auraEnabled
  public static AOB_Application__c getApplicationRecord(id applicationId) {
    return [
      SELECT id, AOB_TECH_ONLINEOFFERStatus__c, AOB_TECH_WFRStatus__c,AOB_TECH_ONLINEOFFERMessage__c,AOB_WFR_Retry_Number__c
      FROM AOB_Application__c
      WHERE id = :applicationId
    ];
  }
}