/**
 * @description AOB_CTRL_ClosePageModal
 * Controller class for close page modal web component
 *
 * ACTION  TICKET    DATE       OWNER           COMMENT
 * New     SFP-14147 17-06-2022 Gill Lumley     Method getApplicationRecord to retrieve days to expiry 
 */
public with sharing class AOB_CTRL_ClosePageModal {
    /**
     * @description	gets number of days to expiry
     * @param 	applicationId Application Id
     * @return AOB_Application__c
     */
    @AuraEnabled
    public static AOB_Application__c getApplicationRecord(id applicationId) {
        try {
            return [SELECT id, AOB_DaysUptoExpiry__c FROM AOB_Application__c WHERE id = :applicationId];
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_ClosePageModel.getApplicationRecord');
            throw new AuraHandledException(error.getMessage());
        }
    }

}