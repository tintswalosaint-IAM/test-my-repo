/**
 * @description       : Environment.INS_NamedCred_Password class to tests the methods available in INS_Customer_Verification
 * @author            : Shamsul Arifeen
 * @date October 2023
 **/
@isTest
public class INS_Customer_Verification_Test {

    @isTest
    static void verifyCustomer() {
        // Create a test user
        User testUser = new User(
            Username = 'testuser112xyz@example.com',
            LastName = '112xyz',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(),
            Country = 'UG',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            UserRoleId = null
        );
        insert testUser;

        // Create mock applicant details
        List<INS_Customer_Verification.RequestWrapper> requestWrapperList = new List<INS_Customer_Verification.RequestWrapper>();
        INS_Customer_Verification.RequestWrapper requestWrapper = new INS_Customer_Verification.RequestWrapper();
        InsurancePolicyParticipant applicant1 = new InsurancePolicyParticipant();
        applicant1.FirstName__c = 'TEST';
        applicant1.LastName__c = 'TEST';
        applicant1.BirthDate__c = Date.newInstance(1980, 1, 1);
        applicant1.IdentityNumber__c = 'TEST00101M53G';

        requestWrapper.applicantDetails = applicant1;
        requestWrapper.customerType = 'Liberty';
        requestWrapper.userCountry = 'UG';
        requestWrapperList.add(requestWrapper);

        // Create Account test data with the test user as the owner
        Account testAccount = new Account(
            FirstName = 'TEST',
            LastName = 'TEST',
            PersonBirthdate = Date.newInstance(1980, 1, 1),
            CMN_IdentityNumber__pc = 'TEST00101M53G',
            FinServ__CustomerType__c = 'Liberty',
            OwnerId = testUser.Id, // Assign the test user as the owner
            ExternalCIFCountry__c = 'UG'
        );
        insert testAccount;

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the verifyCustomer method
        Test.startTest();
        List <INS_Customer_Verification.CustomerVerificationResponse> responses = INS_Customer_Verification.verifyCustomer(requestWrapperList);
        Test.stopTest();

        // Assert the responses or perform other necessary validations
        System.assertEquals(1, responses.size(), 'Expected one response customer');
    }

    /**
     * @description    : Mock Environment.INS_NamedCred_Password Class for INS_Customer_Verification, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        /**
         * @description    : generating fake responses
         * @author         : Shams Ul Arifeen
         * @param request
         * @return         : HTTPResponse
         **/
        public HTTPResponse respond(HTTPRequest request){
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"customers":[{"uuid":"10302196855","accountNumber":"4418758","prominentInfluentialPerson":{"relationType":{}},"personDetails":{"firstName":"test","lastName":"test","otherName":"test test","preferredName":"KASSIM","dob":"1980-01-01T00:00:00.000","title":"041","citizenshipCountry":{}}}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}