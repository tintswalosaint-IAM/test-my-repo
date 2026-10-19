/**
* @description Authentication handler implementation for Ping
*
* Story: SFP-31800
*
* @author Ikyatha Naidu ,Swapnil Walse
*
* @date 04/11/2023
*****************************************************************
* @last modified on  : 13-03-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version 
*/
global with sharing class ICS_PingAuthRegistrationHandler extends ICS_API_AuthRegistrationHandlerPing {
    /**
    * @description Handles Ping specific data extraction. The response data
    *               from Ping is mostly stored as attributes in the attribute
    *               map as opposed to being set directly on the user data object.
    *
    * @param contact  data parameter that comes from the SSO provider
    * @param userDataWrapper User data parameter that comes from the SSO provider
    * @return ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult
    */
    global override ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
        ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult accessCheckResult = new ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult();
        return accessCheckResult; 
    }
    /**
    * @description Handles Ping specific data extraction. The response data
    *               from Ping is mostly stored as attributes in the attribute
    *               map as opposed to being set directly on the user data object.
    *
    * @param contact  data parameter that comes from the SSO provider
    * @return ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult
    */
    global override ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
        ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult accessCheckResult = new ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult();
        return accessCheckResult;
    }
}