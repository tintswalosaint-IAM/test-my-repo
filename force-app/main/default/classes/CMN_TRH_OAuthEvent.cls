/**
 * @description Oauth trigger handler for PKCE code verifier and related events
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 * @see CMN_SRV_OAuth
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date November 2020
 */
public inherited sharing class CMN_TRH_OAuthEvent extends CMN_TRH_BaseObject {
  private List<CMN_OAuth__c> entriesToInsert = new List<CMN_OAuth__c>();
  private List<CMN_OAuth__c> entriesToDelete = new List<CMN_OAuth__c>();

  /**
   * @description Will ensure that the event raised based on the event type
   *
   * @param so The platform event after insert
   */
  public override void afterInsert(SObject so) {
    super.afterInsert(so);

    CMN_OAuthEvent__e event = (CMN_OAuthEvent__e) so;

    CMN_OAuth__c record = new CMN_OAuth__c();

    record.CMN_CodeVerifier__c = event.CMN_CodeVerifier__c;
    record.CMN_CodeVerifierKey__c = event.CMN_CodeVerifierKey__c;

    if (
      event.CMN_EventType__c.equalsIgnoreCase(
        CMN_SRV_OAuth.EVENT_TYPE_CODE_VERIFIER_INSERT
      )
    ) {
      entriesToInsert.add(record);
    } else if (
      event.CMN_EventType__c.equalsIgnoreCase(
        CMN_SRV_OAuth.EVENT_TYPE_CODE_VERIFIER_DELETE
      )
    ) {
      entriesToDelete.add(record);
    }
  }

  /**
   * @description Executes after all other handling, will ensure oauth sobjects are inserted or deleted
   */
  public override void andFinally() {
    super.andFinally();

    CMN_SRV_OAuth.insertCodeVerifierOAuths(entriesToInsert);

    CMN_SRV_OAuth.deleteCodeVerifierOAuths(entriesToDelete);
  }
}