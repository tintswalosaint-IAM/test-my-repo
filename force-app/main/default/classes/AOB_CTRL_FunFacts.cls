/**
 * Controller for the web facial recognition fun facts component
 *
 * <p>DBP-1462</p>
 *
 * @author Maryem BOURHI(mbourhi @salesforce.com)
 *
 * @date Dec 21st 2020
 */
public with sharing class AOB_CTRL_FunFacts {
  /**
   * @description	gets Available fun facts
   * @return List of fun facts
   */
  @AuraEnabled
  public static List<AOB_FunFact__c> getFunFactsList(id applicationId) {
    try {
      List<AOB_ApplicationLineItem__c> appLineItems = [
        SELECT Id, AOB_CardDeliveryFee__c, AOB_Product__r.AOB_FunFactCategory__c
        FROM AOB_ApplicationLineItem__c
        WHERE AOB_Application__c = :applicationId
      ];
      set<String> productCategs = new Set<String>();
      for (AOB_ApplicationLineItem__c appLineItem : appLineItems) {
        productCategs.add(appLineItem.AOB_Product__r.AOB_FunFactCategory__c);
      }
      List<AOB_FunFact__c> facts = [
        SELECT
          id,
          AOB_Didyouknow__c,
          AOB_ProductCategory__c,
          AOB_ClientSince__c,
          AOB_Clientname__c,
          AOB_Fact__c
        FROM AOB_FunFact__c
        WHERE
          AOB_ProductCategory__c IN :productCategs
          OR AOB_ProductCategory__c = NULL
      ];
      return facts;
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, 'AOB_CTRL_PersonalDetails.getWFRUrl');
      throw new AuraHandledException(error.getMessage());
    }
  }
}