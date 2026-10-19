/**
 * Contains a context-specific methods that are automatically called when the adobe Recipients trigger is executed
 *
 * @author Ikyatha Naidu
 *
 * @date 24/02/2024
 */
public inherited sharing class ICS_TRH_Recipients extends CMN_TRH_BaseObject {
    Public List<Echosign_Dev1__SIGN_Recipients__c> newRecipientsList = new List<Echosign_Dev1__SIGN_Recipients__c>();
    public override void afterUpdate(SObject oldRecipient, SObject newRecipient) {
		super.afterUpdate(oldRecipient,newRecipient);
        if((string)oldRecipient.get('echosign_dev1__Status__c') != (string)newRecipient.get('echosign_dev1__Status__c')
          && newRecipient.get('echosign_dev1__Status__c')==ICS_Constants.Signed 
          ){
            newRecipientsList.add((Echosign_Dev1__SIGN_Recipients__c)newRecipient);
        }
	}
	public override void andFinally() {
    	super.andFinally();
        if(newRecipientsList.size()>0){ 
            ICS_CTRL_UpdateAdobeSignStatus.updateStatusesOnSignature(newRecipientsList);
        }
  }
}