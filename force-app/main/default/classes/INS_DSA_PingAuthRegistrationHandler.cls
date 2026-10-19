/**
* @class Name        : INS_DSA_PingAuthRegistrationHandler
* @description       : Authentication handler implementation for Direct Sales Agent Portal Ping
* @story             : SFP-53279
* @author            : Jaco de Lange
* @date              : 09/10/2025
*/
global with sharing class INS_DSA_PingAuthRegistrationHandler extends INS_API_AuthRegistrationHandlerPing {

    /**
    * @description Handles Ping specific data extraction. The response data
    *               from Ping is mostly stored as attributes in the attribute
    *               map as opposed to being set directly on the user data object.   
    *
    * @param contact  data parameter that comes from the SSO provider
    * @param userDataWrapper User data parameter that comes from the SSO provider
    * @return INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult
    */
    global override INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
        INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult accessCheckResult = new INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult();
        return accessCheckResult; 
    }
    /**
    * @description Handles Ping specific data extraction. The response data
    *               from Ping is mostly stored as attributes in the attribute
    *               map as opposed to being set directly on the user data object.
    *
    * @param contact  data parameter that comes from the SSO provider
    * @return INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult
    */
    global override INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
        INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult accessCheckResult = new INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult();
        return accessCheckResult;
    }
}