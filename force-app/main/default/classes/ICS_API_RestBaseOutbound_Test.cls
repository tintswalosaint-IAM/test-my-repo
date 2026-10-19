/**
* @Name of the Class : ICS_API_RestBaseOutbound_Test
* @description  class used as Test class for ICS_API_RestBaseOutboundPing in SBO-UK Ping Feature for  - Story: SFP-31800
* @date September 2023
* @last modified on  : 28-03-2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-31800 class used for ICS_API_RestBaseOutbound_Test for SBO-UK

*/
@isTest
private class ICS_API_RestBaseOutbound_Test {
    /**
    * @description used to getResponseStatusCodeTest
    */ 
    @isTest
    public static void getResponseStatusCodeTest() {
        HttpRequest req = new HttpRequest();
        Test.startTest();
        ICS_API_RestBaseOutbound restBaseOutbound = new ICS_API_RestBaseOutbound();
        restBaseOutbound.getResponseStatusCode();
        restBaseOutbound.setHeaders();
      
        Assert.areEqual(true, (req != null), 'request received');
        restBaseOutbound.getResponseStatusCode();
        Test.stopTest();
    }

    /**
    * @description used to getResponseStatusCodeNegativeTest
    */
    @isTest
    public static void getResponseStatusCodeNegativeTest() {
        // Set up mock response with an error status code
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        Test.startTest();
        ICS_API_RestBaseOutbound restBaseOutbound = new ICS_API_RestBaseOutbound();
        
        // Injecting the mock response
        restBaseOutbound.response = mockResponse;
        
        Integer statusCode = restBaseOutbound.getResponseStatusCode();
        Test.stopTest();

        // Validate the status code is 500 (error status code)
        Assert.areEqual(500, statusCode, 'Expected status code 500');
    }

    /**
 * This private class `MockHttpResponseGenerator` implements the `HttpCalloutMock` interface.
 * It is used to mock HTTP callouts in a test environment by generating custom HTTP responses.
 * By implementing `HttpCalloutMock`, this class provides a method to define the behavior of HTTP callouts,
 *  enabling tests to verify the application's handling of various HTTP responses.
 */
     private class MockHttpResponseGenerator implements HttpCalloutMock {
/**
 * This private variable `response` is of type `HttpResponse`.
 * It is used to store the HTTP response in the context where it is defined.
 * The `response` variable can hold the details of an HTTP response, such as status code, headers, 
 * and body, allowing the application to process and analyze the response data.
 */
     private final HttpResponse response;
/**
 * This public constructor `MockHttpResponseGenerator` takes an `HttpResponse` object as a parameter.
 * It initializes a new instance of the `MockHttpResponseGenerator` class with the provided `HttpResponse`.
 * The constructor sets up the mock response that will be used in HTTP callout simulations within a test environment.
 */
    public MockHttpResponseGenerator(HttpResponse responseInfo) {
            response = responseInfo;
        }
/**
 * This public method `respond` takes an `HttpRequest` object as a parameter and returns an `HttpResponse` object.
 * It defines the behavior of an HTTP callout by generating an HTTP response based on the provided request.
 * This method is used within the context of HTTP callout mocking to simulate various HTTP responses for testing purposes.
 */
    public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}