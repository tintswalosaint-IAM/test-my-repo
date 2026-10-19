/**
 * Controller to prepare data that will be displayed in final offer sceen
 *
 * <p>DBP-3038</p>
 *
 * @author Salesforce
 *
 * @date Jun 22nd 2021
 */
public with sharing class AOB_CTRL_declineError {
	/**
     * Method used to get User Name
     * @param	applicationId
     * @return	string containing name
     */
    @AuraEnabled
    public static string getCustomerName(Id applicationId) {
        try {
            AOB_Application__c app=[select AOB_customer__r.name from AOB_Application__c where id=:applicationId];
            return app.AOB_customer__r.name;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,'AOB_CTRL_declineError:getCustomerName');
            throw new AuraHandledException(error.getMessage());
        }
    }
}