/**
 * test classes for AOB_API_HttpWfrNotify
 *
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date May 5th 2022
 */
@IsTest
/*
 * @description Test class to test the methods of AOB_URL_HttpWfrNotify 
 */
private class AOB_URL_HttpWfrNotify_TEST {
    @isTest
    static void testWfrNotify() {
        // Set up a test request
        RestRequest request = new RestRequest();
        String communityURL = AOB_Utils.getAppSettingByLabel(AOB_Constants.COMMUNITY);
        request.requestUri = communityURL + '/services/apexrest/v1/wfrNotify/';
        request.httpMethod = 'PATCH';
        RestContext.request = new System.RestRequest();
        RestContext.response = new System.RestResponse();
        String requestString = '{"wfrStatus":"Verification Passed","wfrMessage":"2022.05.03.16.32.58 Success","wfrErrorCode":"00"}';
        RestContext.request.requestBody = Blob.valueOf(requestString);
        AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify) System.JSON.deserialize(requestString, AOB_DTO_HttpWfrNotify.WfrNotify.class);
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        insert admin;
        System.runAs(admin) {
            Test.startTest();
            AOB_URL_HttpWfrNotify.updateApplication();
            System.assertNotEquals([SELECT Id FROM AOB_Application__C], null, 'Application should be valid');
            Test.stopTest();
        }
    }
}