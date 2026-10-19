@isTest
private with sharing class INS_Quote_Helper_Test {

    @isTest
    static void testCreateBenefit() {
        INS_Quick_Quote_Wrapper.QuoteBenefit benefit = INS_Quote_Helper.createBenefit('Type1', 100, '123','MONTHLY');
        Assert.areNotEqual(null, benefit.benefitId, 'Benefit Id should not be null');
        Assert.areEqual(100.0, benefit.benefitAmountValue, 'Benefit Amount should be 100.0');
        Assert.areEqual('Type1', benefit.benefitKey, 'Benefit Key should be Type1');
    }

    @isTest
    static void testCreateMemberBenefit() {
        INS_Quick_Quote_Wrapper.MemberBenefit memberBenefit = INS_Quote_Helper.createMemberBenefit('Type2', 150.0, '456','MONTHLY');
        Assert.areEqual('456', memberBenefit.benefitId, 'Benefit Id should be 456');
        Assert.areEqual(150.0, memberBenefit.benefitAmountValue, 'Benefit Amount should be 150.0');
        Assert.areEqual('Type2', memberBenefit.benefitKey, 'Benefit Key should be Type2');
    }

    @isTest
    static void testGetAccessToken() {
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForAccessToken());

        // Call the getAccessToken method
        Test.startTest();
        String accessTokenQuote = INS_Quote_Helper.getAccessToken('Quote');
        String accessTokenCustomer = INS_Quote_Helper.getAccessToken('Customer Verification');
        String accessTokenOTP = INS_Quote_Helper.getAccessToken('OTP');
        Test.stopTest();

        Assert.areNotEqual(null, accessTokenQuote, 'Access token should not be null');
        Assert.areNotEqual(null, accessTokenCustomer, 'Access token should not be null');
        Assert.areNotEqual(null, accessTokenOTP, 'Access token should not be null');
        Assert.areEqual('mockAccessToken123', accessTokenQuote, 'Access token should be mockAccessToken123');
        Assert.areEqual('mockAccessToken123', accessTokenCustomer, 'Access token should be mockAccessToken123');
        Assert.areEqual('mockAccessToken123', accessTokenOTP, 'Access token should be mockAccessToken123');
    }

     /**
     * @description    : Mock Test Class for INS_Create_Quick_Quote_Test Access Token, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGeneratorForAccessToken implements HttpCalloutMock {

        /**
          * @description    : generating fake responses
          * @author         : Shams Ul Arifeen
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
         public HTTPResponse respond(HTTPRequest request) {
             // Create a mock HTTP response for getAccessToken callout
             HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"access_token": "mockAccessToken123"}'); // Mock access token response
             response.setStatusCode(200);
             return response;
         }
     }
}