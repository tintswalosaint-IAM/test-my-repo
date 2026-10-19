/**
* @class Name        : INS_DSA_PingAuthRegistrationHandler_Test
* @description       : Test class for INS_DSA_PingAuthRegistrationHandler
* @story             : SFP-53279
* @author            : Jaco de Lange
* @date              : 10/10/2025
*/
@isTest
private class INS_DSA_PingAuthRegistrationHandler_Test {
    @isTest
    static void verifyUserAccessForCreateTest() {
        Test.startTest();
            Contact testContact = new Contact();  
            testContact.Email='test@test.com';
            testContact.lastName='pingTest';
            insert testContact;
            Assert.areEqual(true,(testContact !=null),'test message');
            INS_DSA_PingAuthRegistrationHandler handler = new INS_DSA_PingAuthRegistrationHandler();
            INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult result = handler.verifyUserAccessForCreate(testContact, null);
            Assert.areEqual(true,(result !=null),'test message');
        Test.stopTest();
    }

    @isTest
    static void verifyUserAccessForUpdateTest() {
        Test.startTest();
            Contact testContact = new Contact();  
            testContact.Email='test1@test.com';
            testContact.lastName='pingTest';
            insert testContact; 
            INS_DSA_PingAuthRegistrationHandler handler = new INS_DSA_PingAuthRegistrationHandler();
            INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult result = handler.verifyUserAccessForUpdate(testContact);
            Assert.areEqual(true,(result !=null),'test message');
    	Test.stopTest();
    }
}