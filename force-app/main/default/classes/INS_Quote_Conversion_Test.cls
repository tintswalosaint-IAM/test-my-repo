/**
 * @description  test class for INS_Quote_Conversion
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date Nov 07th 2023
 */
@isTest
private class INS_Quote_Conversion_Test {
	
        /**
     * @description  test method for QuoteConversion success
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param 
     * @date Nov 07th 2023
     */
    
    @isTest
    static void testQuoteConversionSuccess() {

        INS_Quote_Conversion.Request testRequest = new INS_Quote_Conversion.Request();
        testRequest.quoteNumber = 'TestQuoteNumber';
        testRequest.otp = 'TestOTP';

        List<INS_Quote_Conversion.Request> requestList = new List<INS_Quote_Conversion.Request>();
        requestList.add(testRequest);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, getMockSuccessResponse()));

        // Call the method
        Test.startTest();
        List<INS_Quote_Conversion.Response> result = INS_Quote_Conversion.quoteConversion(requestList);

        // Assert the results
        Assert.areEqual(1, result.size(), 'matched the expected value');
        Assert.areEqual(true, result[0].isSuccess, 'matched the expected value');
     	Test.stopTest();
    }

    /**
     * @description  test method for QuoteConversion Failure
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param 
     * @date Nov 07th 2023
     */
    
    @isTest
    static void testQuoteConversionFailure() {

        INS_Quote_Conversion.Request testRequest = new INS_Quote_Conversion.Request();
        testRequest.quoteNumber = 'TestQuoteNumber';
        testRequest.otp = 'TestOTP';

        List<INS_Quote_Conversion.Request> requestList = new List<INS_Quote_Conversion.Request>();
        requestList.add(testRequest);
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, getMockSuccessResponseError()));
        
        // Call the method
        Test.startTest();
        List<INS_Quote_Conversion.Response> result= null;
        try{
         result = INS_Quote_Conversion.quoteConversion(requestList);
        }
        catch (Exception ex){
        // Assert the results
        Assert.areEqual(null, result, 'incase of exception result should be null');
        }
       
     	Test.stopTest();
    }
		
            /**
         * @description Mock getMockSuccessResponse for the callout
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param .
         * @return String.
         * @date Nov 07th 2023
         */
        private static String getMockSuccessResponse() {
            return '{"PolicyNumber": "TestPolicyNumber", "referenceNumber": "TestReferenceNumber", "validationResult": {"isValid": true}}';
        }
    /**
         * @description Mock getMockSuccessResponseError for the callout
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param .
         * @return String.
         * @date Nov 07th 2023
         */
        private static String getMockSuccessResponseError() {
            return '{"PolicyNumber": "", "referenceNumber": "", "validationResult": {"isValid": false}}';
        }

            /**
     * @description Mock HTTP response generator for the callout
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param .
     * @return .
     * @date Nov 07th 2023
     */
    // Mock HTTP response generator for the callout
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        /**
         * @description Mock HTTP response generator for the callout
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param statusCode
         * @param responseBody
         * @return HTTPResponse
         * @date Nov 07th 2023
        */
        MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
		/**
         * @description Mock HTTP response generator for the callout
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param request
         * @return HTTPResponse
         * @date Nov 07th 2023
        */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }
}