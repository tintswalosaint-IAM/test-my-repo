/**
 * @description       : 
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 18-04-2024
 * @last modified by  : Derek Hughes
 * 
**/
@IsTest(seeAllData=false)
public with sharing class ApiGatewayServiceTest {

    @isTest
    private static void testGet() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            API_test api = new API_Test();
            String responseBody = (String)api.get('/testget?parm=HELLO');

            api.setResponseDtoType(String.class);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect response returned');
    }


    @isTest
    private static void testPost() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            String requestBody = '{"parm":"HELLO"}';
            String responseBody = (String)new API_Test('testCredentials').post('testpost', requestBody);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect response returned');
    }


    @isTest
    private static void testFailure() {

        System.Test.setMock(HttpCalloutMock.class, new MockFail());

        Test.startTest();

            API_Test api = new API_Test();

            api.prepareHttpRequest('/test', 'POST', '{"parm":"HELLO"}');
            api
                .setExceptionOnError(false)    
                .get('/testget?parm=HELLO');

            Integer statusCode = api.getStatusCode();

        Test.stopTest();
        Assert.areEqual(500, statusCode, 'Incorrect status code returned.');
    }

    /**
     * Need a concrete class to test the virtual class
     **/
    private class API_Test extends ApiGatewayService {

        API_Test() {
            super('NamedCredential');
        }

        API_Test(String apiCredential) {
            super('NamedCredential', apiCredential);
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