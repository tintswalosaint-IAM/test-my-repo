/**
 * Controller for aob_cmp_beforeWeBegin component
 *
 * <p>DPB-1156</p>
 *
 * @author Achraf ABOUL (aaboul@salesforce.com)
 *
 * @date Nov 10th 2020
 */
public with sharing class AOB_CTRL_BeforeWeBegin {
  /**
   * This method is use to get information related to products
   * @param applicationId The current application Id
   * @return The list of related products with inner information
   */
  @AuraEnabled(cacheable=true)
  public static string getRelatedProducts(Id applicationId) {
    try {
      Set<Id> relatedProductIds = new Set<Id>();
      //Get list of related application line items
      List<AOB_ApplicationLineItem__c> relatedApplicationLineItems = [
        SELECT Id, AOB_Product__c
        FROM AOB_ApplicationLineItem__c
        WHERE AOB_Application__c = :applicationId
      ];
      //For each related application line item, add the product to relatedProductIds Set
      for (
        AOB_ApplicationLineItem__c eachApplicationLineItem : relatedApplicationLineItems
      ) {
        if (eachApplicationLineItem.AOB_Product__c != null) {
          relatedProductIds.add(eachApplicationLineItem.AOB_Product__c);
        }
      }
      //Query the related products and their children records : (required documents & product qualifications)
      List<Product2> relatedProducts = [
        SELECT
          Id,
          AOB_ProductCategory__c,
          (
            SELECT
              Id,
              AOB_Product__c,
              AOB_Description__c,
              AOB_HelpText__c,
              AOB_Order__c
            FROM Required_Documents__r
            ORDER BY AOB_Order__c
          ),
          (
            SELECT
              Id,
              AOB_Product__c,
              AOB_Description__c,
              AOB_HelpText__c,
              AOB_Order__c
            FROM Product_Qualifications__r
            ORDER BY AOB_Order__c
          )
        FROM Product2
        WHERE Id IN :relatedProductIds
      ];
      if (relatedProducts.isEmpty()) {
        throw new AuraHandledException(
          AOB_Constants.NO_PRODUCTS_DATA_EXCEPTION
        );
      }
      return JSON.serialize(relatedProducts);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  /**
   * This method is used to get the customer's first name
   * @param applicationId The current application Id
   * @return The customer's first name
   */
  @AuraEnabled(cacheable=true)
  public static string getCustomerName(Id applicationId){
    try {
      List<AOB_ApplicationLineItem__c> applicationsList = [SELECT AOB_Application__r.AOB_Customer__r.FirstName
                                                          FROM  AOB_ApplicationLineItem__c
                                                          WHERE AOB_Application__c =:applicationId];
      if(!applicationsList.isEmpty()){
        return applicationsList[0].AOB_Application__r.AOB_Customer__r.FirstName;
      }else{
        return '';
      }
    }catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}