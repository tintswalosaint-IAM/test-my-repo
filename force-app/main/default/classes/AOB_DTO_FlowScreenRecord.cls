/**
 * to store the flow screen record with it's value from the API
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Jan 11th 2021
 */
public with sharing class AOB_DTO_FlowScreenRecord {
  @AuraEnabled
  public AOB_FinalOffer__c finalOffer { get; set; }
  @AuraEnabled
  public String value { get; set; }

  public AOB_DTO_FlowScreenRecord() {
    finalOffer = new AOB_FinalOffer__c();
  }
}