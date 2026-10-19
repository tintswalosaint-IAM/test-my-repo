/**
 * Controller class for aob_comp_stepper component
 *
 * <p>DPB-1155</p>
 *
 * @author Achraf ABOUL (aaboul@salesforce.com)
 *
 * @date Nov 10th 2020
 */
public with sharing class AOB_CTRL_Stepper {
  /**
   * This method is used to get information related to the current application
   * @param applicationId The current application Id
   * @return The application record serialized
   */
  @AuraEnabled
  public static AOB_Application__c getApplicationStepInformation(
    Id applicationId
  ) {
    try {
      AOB_Application__c currentApplication = [
        SELECT
          Id,
          AOB_CurrentScreen__c,
          AOB_PreviousScreen__c,
          AOB_TECH_NumOfScreens__c,
          AOB_TECH_CurrentScreenNum__c
        FROM AOB_Application__c
        WHERE Id = :applicationId
      ];
      return currentApplication;
    } catch (Exception error) {
      CMN_UTIL_Logger.error(
        error,
        'AOB_CTRL_Stepper.getApplicationStepInformation'
      );
      throw new AuraHandledException(error.getMessage());
    }
  }

  /**
   * This method is used to get information related to the current application line item
   * @param applicationId The current application Id
   * @return The application line item record serialized
   */
  @AuraEnabled
  public static string getApplicationLineItemInformation(Id applicationId) {
    try {
      List<AOB_ApplicationLineItem__c> currentApplication = [
        SELECT Id, AOB_product__r.AOB_ProductCategory__c
        FROM AOB_ApplicationLineItem__c
        WHERE AOB_Application__c = :applicationId
      ];
      return currentApplication[0].AOB_product__r.AOB_ProductCategory__c;
    } catch (Exception error) {
      CMN_UTIL_Logger.error(
        error,
        'AOB_CTRL_Stepper.getApplicationStepInformation'
      );
      throw new AuraHandledException(error.getMessage());
    }
  }
}