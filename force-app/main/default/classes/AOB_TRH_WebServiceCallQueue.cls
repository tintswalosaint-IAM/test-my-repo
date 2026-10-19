/**
 * Contains a context-specific methods that are automatically called when the User trigger is executed
 *
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Feb 24th 2021
 */

public with sharing class AOB_TRH_WebServiceCallQueue extends CMN_TRH_BaseObject {
  private List<CMN_WebserviceCallQueue__c> newCalls = new List<CMN_WebserviceCallQueue__c>();

  public override void afterInsert(SObject so) {
    CMN_WebserviceCallQueue__c newCall = (CMN_WebserviceCallQueue__c) so;
    super.afterInsert(so);
    if (String.isNotBlank(newCall.CMN_Service__c)) {
      if (
        newCall.CMN_Service__c.startsWith('AOB') &&
        newCall.CMN_Status__c == 'Failed'
      ) {
        newCalls.add(newCall);
      }
    }
  }
  public override void afterUpdate(SObject so, SObject si) {
    CMN_WebserviceCallQueue__c newCall = (CMN_WebserviceCallQueue__c) si;
    CMN_WebserviceCallQueue__c oldCall = (CMN_WebserviceCallQueue__c) so;
    super.afterUpdate(so, si);
    if (String.isNotBlank(newCall.CMN_Service__c)) {
      if (
        newCall.CMN_Service__c.startsWith('AOB') &&
        newCall.CMN_Status__c == 'Failed'
      ) {
        newCalls.add(newCall);
      }
    }
  }

  public override void andFinally() {
    super.andFinally();
    AOB_SRV_WebserviceCallQueue.createTechnicalErrorCases(
      'TechnicalError',
      newCalls
    );
  }
}