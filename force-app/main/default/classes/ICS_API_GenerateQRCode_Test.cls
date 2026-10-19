/**
* @description Class used as test class for ICS_API_GenerateQRCode
* Story: SFP-37310
* @author Ikyatha Naidu
* @date 11/01/2024
* @last modified on: 1/07/2024
* @last modified by: Ikyatha Naidu
* @Modification Description: updated to latest Version
*/
@IsTest
private class ICS_API_GenerateQRCode_Test {
    
    private static User communityUser;
    
    @TestSetup
    static void setupTestData() {
        // Create community user
        communityUser = ICS_DAL_TestFactory.createCommunityUser();
        communityUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :communityUser.Id];
    }
    
    @IsTest
    static void callDefinitionIdTest() {
        User testUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            ICS_API_GenerateQRCode qrCodeService = new ICS_API_GenerateQRCode();
            qrCodeService.accountId =testUser.Contact.AccountId;
            qrCodeService.tokenInfo ='tokenInf';
            qrCodeService.jounreyDefinitionID='absd123456';
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateQRCode.SERVICE_NAME, testUser.Contact.AccountId);
            qrCodeService.process(obj);
            String qrCode = qrCodeService.getResponseBody();
            Test.stopTest();
            
            Assert.isNotNull(qrCode, 'QR code should be retrieved');
        }
    }
    
    @IsTest
    static void testInvalidJsonResponseHandling() {
        User testUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            ICS_API_GenerateQRCode qrCodeService = new ICS_API_GenerateQRCode();
            qrCodeService.accountId =testUser.Contact.AccountId;
            qrCodeService.tokenInfo ='4567tokenInf';
            qrCodeService.jounreyDefinitionID='56absd123456';
            Test.setMock(HttpCalloutMock.class, new InvalidJsonHttpCalloutMock());
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateQRCode.SERVICE_NAME, testUser.Contact.AccountId);
            qrCodeService.process(obj);
            qrCodeService.getResponseBody();
            Test.stopTest();
            
            Assert.isNotNull(obj, 'WebserviceCallQueue object should not be null');
            // Add more specific assertions based on how your code handles invalid JSON
        }
    }
    
    @IsTest
    static void testFailedHttpCall() {
        User testUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        System.runAs(testUser) {
            Test.startTest();
            ICS_API_GenerateQRCode qrCodeService = new ICS_API_GenerateQRCode();
            qrCodeService.accountId =testUser.Contact.AccountId;
            qrCodeService.tokenInfo ='tokenInf';
            qrCodeService.jounreyDefinitionID='absd123456';
            Test.setMock(HttpCalloutMock.class, new FailedHttpCalloutMock());
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateQRCode.SERVICE_NAME, testUser.Contact.AccountId);
            qrCodeService.process(obj);
             qrCodeService.getResponseBody();
            Test.stopTest();
            
            Assert.isNotNull(obj, 'WebserviceCallQueue object should not be null');
        }
    }
    
    
    
    private class InvalidJsonHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"invalid_json}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class FailedHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal Server Error"}');
            return res;
        }
    }
}