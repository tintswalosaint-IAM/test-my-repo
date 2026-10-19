/**
 * @description       : Test class to tests the methods available in INS_Create_Quote_Members
 * @author            : Shamsul Arifeen
 * @date October 2023
 **/
@isTest
public class INS_Create_Quote_Members_Test {

    @isTest
    static void testCreateQuoteMembers() {
        // Create a test InsurancePolicyParticipant record
        InsurancePolicyParticipant member = new InsurancePolicyParticipant();
        // Set member fields as needed for testing
        member.BirthDate__c = Date.newInstance(1980, 1, 1);
        member.RelationshipToInsured = 'SPOUSE';
        member.IdentityNumber__c = '12345';
        member.Catering__c = 100;
        member.funeral_Cover__c = 100;
        member.Tombstone__c = 100;
        member.Radio_Announcement__c = 100;
        member.Transport__c = 100;
        member.Shopping__c = 100;

        String quoteNumber = '12345';
        Boolean isUpdate = false;

        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        InsurancePolicyParticipant createdQuoteMembers = new InsurancePolicyParticipant();
        // Call the createQuoteMembers method
        Test.startTest();
        createdQuoteMembers = INS_Create_Quote_Members.createQuoteMembers(member, quoteNumber, isUpdate, 'KE');
        member.RelationshipToInsured = 'CHILD';
        createdQuoteMembers = INS_Create_Quote_Members.createQuoteMembers(member, quoteNumber, isUpdate, 'UG');
        member.RelationshipToInsured = 'MOTHER';
        createdQuoteMembers = INS_Create_Quote_Members.createQuoteMembers(member, quoteNumber, isUpdate, 'UG');
        member.RelationshipToInsured = 'COUSIN';
        createdQuoteMembers = INS_Create_Quote_Members.createQuoteMembers(member, quoteNumber, isUpdate, 'KE');
        createdQuoteMembers = INS_Create_Quote_Members.createQuoteMembers(member, quoteNumber, true, 'UG');
        Test.stopTest();
        Assert.areNotEqual(null, createdQuoteMembers, 'InsurancePolicyParticipant should not be null');
    }

    @isTest
    static void testDeleteQuoteMembers() {
        // Set member ID and quote number for testing
        String memberId = 'memberId123';
        String quoteNumber = '12345';

        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the deleteQuoteMembers method
        Test.startTest();
        try {
            INS_Create_Quote_Members.deleteQuoteMembers(memberId, quoteNumber);
        } catch (Exception e) {
            Assert.areNotEqual(null, e.getMessage(), 'Test Meassage');
        }
        Test.stopTest();
    }


    /**
     * @description    : Mock Test Class for INS_Create_Quick_Quote_Test Access Token, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
         * @description    : generating fake responses
         * @author         : Shams Ul Arifeen
         * @param request  : HTTPRequest object
         * @return         : HTTPResponse
         **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"members":[{"memberId":"memberId123","idNumber":"12345","benefits":[{"benefitType":"CATERING","benefitId":"benefitId123","premium":100},{"benefitType":"FUNERAL","benefitId":"benefitId123","premium":100},{"benefitType":"TOMBSTONE","benefitId":"benefitId123","premium":100},{"benefitType":"REPATRIATION","benefitId":"benefitId123","premium":100},{"benefitType":"AIRTIME","benefitId":"benefitId123","premium":100},{"benefitType":"GROCERYBENEFIT","benefitId":"benefitId123","premium":100}]}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}