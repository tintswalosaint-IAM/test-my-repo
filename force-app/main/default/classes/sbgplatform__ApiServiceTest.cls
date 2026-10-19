/**
 * @description       : Test for ApiService
 * @author            : Derek Hughes
 * @group             : API
 * @last modified on  : 16-04-2024
 * @last modified by  : Derek Hughes
 * 
 * @last modified on  : 02-07-2025
 * @last modified by  : Milica Milicevic
 * @description       : Additional constructor to handle custom metadata type record structure addition. 
 *                      Additional test for new prepareHttpRequest with object request body.
 * @User-Story.       : SFP-50927
 * 
**/
@IsTest
public with sharing class ApiServiceTest {

    @isTest
    private static void testGet() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            // API_test api = new API_Test();
            API_Test api = new API_Test();
            String responseBody = (String)api.get('/testget?parm=HELLO');

            api
                .setTimeout(5000)
                .setDtoTypes(String.class, String.class)
                .setCorrelationIdHeader('x-correlation-id');

            Integer statusCode = api.getStatusCode();   
            String responseBody2 = api.getResponseBody();

            api.prepareHttpRequest('/testget', 'PATCH', '{}');

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect request Body returned.');
        Assert.areEqual('Hello World', responseBody2, 'Incorrect request Body returned.');
        Assert.areEqual(200, statusCode, 'Incorrect status code.');
    }


    @isTest
    private static void testGetCredentialException() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            API_Credential_Test api = new API_Credential_Test();
            String responseBody = (String)api.get('/testget?parm=HELLO');

        Test.stopTest();
        Assert.areEqual('Hello World', responseBody, 'Incorrect request Body returned.');

    }


    @isTest
    private static void testPost() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            String requestBody = '{"parm":"HELLO"}';
            String responseBody = (String)new API_Test().post('testpost', requestBody);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect request Body returned.');
    }

    @isTest
    private static void testPut() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            String requestBody = '{"parm":"HELLO"}';
            String responseBody = (String)new API_Test().put('testpost', requestBody);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Correct request Body returned.');
    }


    @isTest
    private static void testPatch() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            String requestBody = '{"parm":"HELLO"}';
            String responseBody = (String)new API_Test().patch('testpost', requestBody);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Correct request Body returned.');
    }

    @isTest
    private static void testFailureNoException() {

        System.Test.setMock(HttpCalloutMock.class, new MockFail());

        Test.startTest();

            API_Test api = new API_Test();
            api.setExceptionOnError(false);

            api.send('/testget?parm=HELLO', 'PATCH', '{}');
            api.send('/testget?parm=HELLO', 'POST', (Object)'{"parm":"HELLO"}');
       
            Integer statusCode = api.getStatusCode();

        Test.stopTest();
        Assert.areEqual(500, statusCode, 'Incorrect status code returned.');

    }

    @isTest
    private static void testFailureException() {

        System.Test.setMock(HttpCalloutMock.class, new MockFail());

        String errorMessage;
      
        Test.startTest();

            API_Test api = new API_Test();

            try {
                api.send('/testget?parm=HELLO', 'POST', (Object)'{"parm":"HELLO"}');
            }
            catch (Exception ex) {
                errorMessage = ex.getMessage();
            }
       
            Integer statusCode = api.getStatusCode();

        Test.stopTest();
        Assert.isTrue(errorMessage != null, 'No exception thrown.');
        Assert.areEqual(500, statusCode, 'Incorrect status code returned.');

    }


    
    @isTest
    private static void testInvalidBody() {

        System.Test.setMock(HttpCalloutMock.class, new MockFail());

        String errorMessage;

        Test.startTest();

            try {
                Integer invalidBodyType = 12345; // Invalid body type for API call
                API_Test api = new API_Test();
                api.send('/testget', 'PUT', invalidBodyType, null);
            }
            catch (Exception ex) {
                errorMessage = ex.getMessage();
            }
       
        Test.stopTest();

        Assert.isTrue(errorMessage != null, 'No exception thrown.');
        Assert.isTrue(errorMessage.contains('Unsupported request body type'), 'Expected exception not thrown.');
    }

    @isTest
    private static void prepareHttpRequestWithObjectStringBody() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            Object requestBody = (Object)'{"parm":"HELLO"}';
            HttpRequest httpRequest  = (HttpRequest)new API_Test().prepareHttpRequest('testpost', 'PUT' ,requestBody, 'application/json');

        Test.stopTest();

        Assert.areEqual(requestBody, httpRequest.getBody(), 'String Body populated based on Object.');
    }

    @isTest
    private static void prepareHttpRequestWithObjectBlobBody() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            Blob requestBody = Blob.valueOf('HELLO API!');
            HttpRequest httpRequest  = (HttpRequest)new API_Test().prepareHttpRequest('testpost', 'PUT' ,requestBody, null);

        Test.stopTest();

        Assert.areEqual(requestBody, httpRequest.getBodyAsBlob(), 'Blob Body populated based on Object.');
    }

    @isTest
    private static void prepareHttpRequestWithObjectDOMBody() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();
            String xmlString = '<note><to>Test</to><message>Hello!</message></note>';
            Dom.Document requestBody = new Dom.Document();
            requestBody.load(xmlString);
            HttpRequest httpRequest  = (HttpRequest)new API_Test().prepareHttpRequest('testpost', 'PUT', requestBody, ApiService.CONTENT_TYPE_TEXT_HTML);

        Test.stopTest();

        Assert.areEqual(requestBody, httpRequest.getBodyDocument(), 'DOM Body populated based on Object.');
    }

    /**
     * Need a concrete class to test the virtual class
     **/
    private class API_Test extends ApiService {

        API_Test() {
            super('NamedCredential');
        }

    }

    /**
     * Need a concrete class to test the virtual class
     **/
    private class API_Credential_Test extends ApiService {

        API_Credential_Test() {
            super('NamedCredential','CustomMetaDataType');
        }

    }
    
    /**
     * @description mocks a succesful response returned from the API call
     **/
    @testVisible
    private class MockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            String body = 'Hello World';
            response.setStatusCode(ApiService.HTTP_OK);
            response.setBody(body);
            return response;
        }
    }

    /**
     * @description mocks a failed API call
     **/
    @testVisible
    private class MockFail implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(ApiService.HTTP_INTERNAL_SERVER_ERROR);
            response.setBody('{"error":"Internal Server Error"}');
            return response;
        }
    }

    /**
     * @description mocks a blank response API call
     **/
    @testVisible
    private class MockBlank implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(ApiService.HTTP_OK);
            return response;
        }
    }
}