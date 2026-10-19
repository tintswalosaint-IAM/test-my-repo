/**
* @Name of the Class : ICS_PingAuthRegistrationHandler_Test
* @description class used as Test class for  SBO-UK Ping Feature for Registration Handler - Story:SFP-31800
* @author Ikyatha Naidu
* @date 01/03/2024
***********************************************************
* @last modified on  : 28-03-2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-31800 class used to add test class methods
*/
@isTest
private class ICS_PingAuthRegistrationHandler_Test {
      /**
   * @description This method is use to verifyUserAccessForCreateTest.UserAccessCheckResult
   */
    @isTest
    static void verifyUserAccessForCreateTest() {
        contact con =ICS_DAL_TestFactory.createContact();
        Test.startTest();       
        Assert.areEqual(true,(con !=null),'Contact Created');
        ICS_PingAuthRegistrationHandler handler = new ICS_PingAuthRegistrationHandler();
        ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult result = handler.verifyUserAccessForCreate(con, null);
        Assert.areEqual(true,(result !=null),'Generated the response');
        Test.stopTest();
    }
 /**
   * @description This method is use to verifyUserAccessForCreateTest.UserAccessCheckResult
   */
    @isTest
    static void verifyUserAccessForUpdateTest() {
        contact con =ICS_DAL_TestFactory.createContact();
        Test.startTest();       
        ICS_PingAuthRegistrationHandler handler = new ICS_PingAuthRegistrationHandler();
        ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult result = handler.verifyUserAccessForUpdate(con);
        Assert.areEqual(true,(result !=null),'test message');
        Test.stopTest();
    }

}