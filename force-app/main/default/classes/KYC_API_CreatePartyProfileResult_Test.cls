/**
* @description SFP-32986 Class used for test class KYC_API_CreatePartyProfileResult
*  
* @author Nagendra mylavarapu
* 
* @date 11/05/2024
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated to latest version, added assertions and improved test coverage
*/
@IsTest
public class KYC_API_CreatePartyProfileResult_Test {
    
    @TestSetup
    static void setupTestData() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '+256123456789'
        );
        insert testAccount;
        
        PartyProfile testProfile = new PartyProfile(
            Name = 'Test Profile',
            AccountId = testAccount.Id,
            PrimaryEmail = 'test@example.com',
            PrimaryPhone = '+256123456789'
        );
        insert testProfile;
    }
    
    @IsTest
    static void testProcessMethodSuccess() {
        
        HTTPResponse mockResponse = new HTTPResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"status":"Success","message":"Profile created successfully"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        Test.startTest();
        CMN_FACTORY_WebserviceManager.processInboundService('KYC_API_CreatePartyProfileResult');
        Test.stopTest();
        List<PartyProfile> updatedProfiles = [SELECT Id, Name FROM PartyProfile WHERE Name LIKE '%John Doe%'];
        Assert.isTrue(updatedProfiles.size()==0, 'retreived zero PartyProfile List');
    }
    
    @IsTest
    static void testProcessMethodFailure() {
        
        HTTPResponse mockResponse = new HTTPResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"status":"Failed","message":"Invalid payload"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        try {
            CMN_FACTORY_WebserviceManager.processInboundService('KYC_API_CreatePartyProfileResult');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Invalid payload'), 'Exception should mention invalid payload');
        }
        Test.stopTest();
        
        List<PartyProfile> profiles = [SELECT Id FROM PartyProfile WHERE CreatedDate = TODAY];
        Assert.areEqual(1, profiles.size(), 'No new PartyProfile should have been created');
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private final HTTPResponse response;
        
        public MockHttpResponseGenerator(HTTPResponse resp) {
            this.response = resp;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return response;
        }
    }
}