/**
 * @description       : Test class to tests the methods available in INS_CVC_Verification
 * @author            : Shamsul Arifeen
 * @date April 2024
 **/
@isTest
private class INS_CVC_Verification_Test {

    
    @isTest
    static void testGenerateCVCVerificationCode() {
        // Set up mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorCVCInitiate());
        INS_CVC_Verification.VerificationResponse verificationResponse = new INS_CVC_Verification.VerificationResponse();
        verificationResponse.verificationCodeId = '3233232';
        verificationResponse.validationPattern = '____****';

        // Call the method to generate CVC verification code
        INS_CVC_Verification.VerificationResponse result = INS_CVC_Verification.generateCVCVerificationCode('+254787033556', 'test@test.com', 'KE','', 'Liberty','123');
        Assert.areEqual('____****', result.validationPattern, 'Validation pattern should match expected pattern');
    }

    
    @isTest
    static void testValidateCVCVerificationCode() {
        // Set up mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorCVCValidate());

        // Call the method to validate CVC verification code
        INS_CVC_Verification.ValidationResponse validationResult = INS_CVC_Verification.validateCVCVerificationCode('1234', '_**__**_', 'KE');
        Assert.areEqual('Success', validationResult.validation, 'Verification code successfully validated');
    }

    @isTest
    static void testValidateFailedCVCVerificationCode() {
        // Set up mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorCVCValidationFailed());

        // Call the method to validate CVC verification code
        try{
            INS_CVC_Verification.validateCVCVerificationCode('1234', '_**__**_', 'KE');
        }catch(Exception ex){
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'exception was caught');
        }
    }

    /**
     * @description    : Mock Test Class for INS_CVC_Verification, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGeneratorCVCInitiate implements HttpCalloutMock{
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
            response.setBody('{"verificationCodeId":"ff237671-e399-472e-b69b-7bf6292d53b7","validationPattern":"____****","status":[{"name":"SMS_PENDING_ACCEPTED","description":"Message sent to next instance"},{"name":"EMAIL_SENT","description":"Email is delivered"}]}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description    : Mock Test Class for INS_CVC_Verification, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGeneratorCVCValidate implements HttpCalloutMock{
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
            response.setBody('{"validation":"Success","reason":"","errorCode":0}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description    : Mock Test Class for INS_CVC_Verification, generating fake responses for Failure
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGeneratorCVCValidationFailed implements HttpCalloutMock{
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
            response.setBody('{"validation":"failed","reason":"Failed to validate CVC Code","errorCode":0}');
            response.setStatusCode(200);
            return response;
        }
    }
}