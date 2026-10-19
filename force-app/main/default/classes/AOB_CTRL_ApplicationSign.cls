/**
 * Controller to display data in OTP Modal screen on Back-button press from Commerce
 *
 * <p>DBP-3231</p>
 *
 * @author (mark.bailey2@standardbank.co.za)
 *
 * @date Jul 2nd 2021
 */
public with sharing class AOB_CTRL_ApplicationSign {
    /**
     * Method used to get Product Name
     * @param	applicationId
     * @return	string containing name
     */
    @AuraEnabled
    public static string getProductName(Id applicationId) {
        try {
            AOB_ApplicationLineItem__c app=[select id, AOB_Product__c, AOB_Product__r.Name from AOB_ApplicationLineItem__c where AOB_Application__c =:applicationId LIMIT 1];
			return app.AOB_Product__r.Name;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,'AOB_CTRL_ApplicationSign:getProductName');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
     * Method used to get Application Signed Flag
     * @param	applicationId
     * @return	boolean containing signed flag
     */
    @AuraEnabled
    public static boolean getApplicationSigned(Id applicationId){
        try {
            AOB_ApplicationLineItem__c app=[select id, AOB_TECH_Signed__c from AOB_ApplicationLineItem__c where AOB_Application__c =:applicationId LIMIT 1];
			return app.AOB_TECH_Signed__c;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,'AOB_CTRL_ApplicationSign:getApplicationSigned');
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * Method used to set Application Signed Flag
     * @param	applicationId
     * @return	boolean containing signed flag
     */
    @AuraEnabled
    public static boolean setApplicationSigned(Id applicationId){
        try {
            AOB_ApplicationLineItem__c app=[select id, AOB_TECH_Signed__c from AOB_ApplicationLineItem__c where AOB_Application__c =:applicationId LIMIT 1];
			app.AOB_TECH_Signed__c = true;
            update app;
            return app.AOB_TECH_Signed__c;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,'AOB_CTRL_ApplicationSign:setApplicationSigned');
            throw new AuraHandledException(error.getMessage());
        }
    }
}