/**
* @description AOB_CTRL_CameraMissing
* Controller for aob_cmp_cameraMissing component
*
* <p>SFP-9126</p>
*
* @author Gill Lumley
*
* @date 12 November 2021
*/
public with sharing class AOB_CTRL_CameraMissing {
    public static String url = 'url';
    public static String  errorMessage= 'Unable to locate commerce all accounts URL'; 
    public static final String SERVICE_NAME = AOB_CTRL_CameraMissing.class.getName();
    
    /**
     * @description getCommerceAccountsLink
    * This method is use to get the Commerce Accounts page url
    * @param N/A
    * @return The Commerce Accounts page url
    */
        @AuraEnabled(cacheable=true)
        public static string getCommerceAccountsLink(){
            try {
                return AOB_Utils.getAppSettingByCategory(url).get(AOB_Constants.COMMERCE_URL);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    
    }