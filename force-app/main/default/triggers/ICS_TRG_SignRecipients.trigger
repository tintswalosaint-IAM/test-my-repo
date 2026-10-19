/**
 * Created by Ikyatha Naidu 24/02/2024.
 */
trigger ICS_TRG_SignRecipients on echosign_dev1__SIGN_Recipients__c (after Insert,after Update) {
    CMN_FACTORY_TriggerHandler.createHandler(ICS_TRH_Recipients.class);
}