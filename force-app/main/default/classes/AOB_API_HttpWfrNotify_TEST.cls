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
/**
* @description Test Class for AOB_API_HttpWfrNotify
*/
private class AOB_API_HttpWfrNotify_TEST {
    
  
    
    @isTest
    static void testWfrNotify() {
        /**
         * @description Test method for positive result
         */
        // Set up a test request
        RestRequest request = new RestRequest();
        String communityURL = AOB_Utils.getAppSettingByLabel(AOB_Constants.COMMUNITY);
        request.requestUri = communityURL + '/services/apexrest/v1/wfrNotify/a0r25000005WV7fAAG';
        request.httpMethod = 'PATCH';
        RestContext.request = new System.RestRequest();
        RestContext.response = new System.RestResponse();
        String requestString = '{"wfrStatus":"Verification Passed","wfrMessage":"2022.05.03.16.32.58 Success","wfrErrorCode":"00"}';
        RestContext.request.requestBody = Blob.valueOf(requestString);
        request.requestBody = Blob.valueOf(requestString);
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        insert admin;
        System.runAs(admin) {
            Test.startTest();
            AOB_URL_HttpWfrNotify.updateApplication();
            AOB_API_HttpWfrNotify.processRequestMock(request);
            AOB_API_HttpWfrNotify.processRequestMockException(request);
            System.assertNotEquals([SELECT Id FROM AOB_Application__C], null, 'Application should not be null');
            Test.stopTest();
        }
    }
    @isTest
    /**
     * @description Test method for mock result
     */
    static void testWfrNotifyMock() {
        
        // Set up a test request
        RestRequest request = new RestRequest();
        String requestString = '{"wfrStatus":"Verification Failed","wfrMessage":"2022.05.03.16.32.58 Failed","wfrErrorCode":"05"}';
        request.requestBody = Blob.valueOf(requestString);
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        insert admin;
        System.runAs(admin) {
            Test.startTest();
            AOB_API_HttpWfrNotify.processRequestMock(request);
            System.assertNotEquals([SELECT Id FROM AOB_Application__C], null, 'Application should not be null');
            Test.stopTest();
        }
    }
    @isTest
    /**
     * @description Test method for negative result
     */
    static void testWfrNotifyException() {
        
        // Set up a test request
        RestRequest request = new RestRequest();
        String requestString = '{"wfrStatus":"Verification Failed","wfrMessage":"2022.05.03.16.32.58 Failed","wfrErrorCode":"05"}';
        request.requestBody = Blob.valueOf(requestString);
        User admin = AOB_DAL_TestFactory.createUser('System Administrator', false);
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        insert admin;
        System.runAs(admin) {
            Test.startTest();
            AOB_API_HttpWfrNotify.processRequestMockException(request);
            System.assertNotEquals([SELECT Id FROM AOB_Application__C], null, 'Exception Occurred');
            Test.stopTest();
        }
    }
}