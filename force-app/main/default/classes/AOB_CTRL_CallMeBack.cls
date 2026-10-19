/**
 * Controller to display data in CallMeBack Modal screen on WFR screen
 *
 * <p>DBP-3334</p>
 *
 * @author (mark.bailey2@standardbank.co.za)
 *
 * @date Aug 27 2021
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-10055 06-04-2022 Gill Lumley   Add reason input parameter on method createLead and pass to AOB_SRV_PreAuthLeads.callLeadAPI
 * Changed SFP-10057 21-04-2022 Gill Lumley   add getPublicHolidayDates method
 */
/**
 * @description AOB_CTRL_CallMeBack
 */

public with sharing class AOB_CTRL_CallMeBack {
    public static String mainError='AOB_CTRL_CallMeBack';
    /**
     * @description getPhoneNumber

     * Method used to get Customer Phone Number
     * @param	applicationId
     * @return	string  phone number
     */
    @AuraEnabled
    public static string getPhoneNumber(Id applicationId) {
        try {
            AOB_Application__c app=[select id, AOB_Customer__r.Phone from AOB_Application__c where id =:applicationId LIMIT 1];
            return app.AOB_Customer__r.Phone;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,mainError+'getCellNumber');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /** 
     * @description callAccessToken
    * Method used to call API to get an access token to be able to call APIs
    * @return   String
    */
    @auraEnabled
    public static String callAccessToken(){
        try{
            return AOB_SRV_PreAuthLeads.getToken();
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, mainError+'callAccessToken');
            throw new AuraHandledException(error.getMessage());
        }
    }
     /**
     * @description getBusinessHours

     * Method used to get Business Hours
     * @return	string containing Business Hours
     */
    @AuraEnabled
    public static List<string> getBusinessHours() {
        try {
            return AOB_Utils.getBusinessHours();
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,mainError+'getBusinessHours');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
     * @description createLead
     * Method used to create the lead
     * @param token
     * @param applicationId
     * @param contactTime
     * @param contactDate
     * @param reason
     * @return created lead
     */
    @AuraEnabled
    public static integer createLead(String token, String applicationId, String contactTime, String contactDate, String reason) {
        try {
            return AOB_SRV_PreAuthLeads.callLeadAPI(token, applicationId, contactTime, contactDate, reason);
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,mainError+'createLead');
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
          * @description setCallBackRequested
     * Method used to set application field CallBackRequested to true
     * @param	applicationId
     * @return	boolean 
     */
    @AuraEnabled
    public static boolean setCallBackRequested( String applicationId) {
        try {
            AOB_Application__c app = [SELECT Id, AOB_Callback_Requested__c
                                      FROM AOB_Application__c WHERE Id = :applicationId LIMIT 1];
            
            app.AOB_Callback_Requested__c = true;
            update app;
            return app.AOB_Callback_Requested__c;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, mainError+'setCallBackRequested');
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description getPublicHolidayDates
     * Method used to get Public Holiday dates within a date range
     * @param Date fromDate
     * @param Date toDate
     * @return	list of public holiday dates
     */
    @AuraEnabled
    public static List<Date> getPublicHolidayDates(Date fromDate, Date toDate) {
        //system.debug('AOB_CTRL_CallMeBack - In public holiday method');
        try {
            return AOB_Utils.getPublicHolidayDates(AOB_Constants.SA_ISOCODE, fromDate, toDate);
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error,mainError+'getPublicHolidayDates');
            throw new AuraHandledException(error.getMessage());
        }
    }

}