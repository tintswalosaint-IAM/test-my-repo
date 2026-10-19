/**
 * @description       : 
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 10-03-2024
 * @last modified by  : Derek Hughes
**/
@IsTest(seeAllData=false)
public with sharing class CMN_API_Gateway_Service_Test {

    @isTest
    private static void testGet() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            API_test api = new API_Test();
            String responseBody = (String)api.get('/testget?parm=HELLO');

            api.setDtoType(String.class);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect response returned');
    }


    @isTest
    private static void testPost() {

        System.Test.setMock(HttpCalloutMock.class, new MockSuccess());

        Test.startTest();

            String requestBody = '{"parm":"HELLO"}';
            String responseBody = (String)new API_Test().post('testpost', requestBody);

        Test.stopTest();

        Assert.areEqual('Hello World', responseBody, 'Incorrect response returned');
    }


    @isTest
    private static void testFailure() {

        System.Test.setMock(HttpCalloutMock.class, new MockFail());
        String errorMessage;

        Test.startTest();

            try {
                String responseBody = (String)new API_Test().get('/testget?parm=HELLO');
            }
            catch (Exception ex) {
                errorMessage = ex.getMessage();
            }

        Test.stopTest();

        Assert.areEqual('API call failed: 500 - null', errorMessage, 'Exception message not correct');
    }

    /**
     * Need a concrete class to test the abstract class
     **/
    private class API_Test extends CMN_API_Gateway_Service {

        API_Test() {
            super('NamedCredential');
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
            response.setStatusCode(CMN_API_Service.HTTP_OK);
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
            response.setStatusCode(CMN_API_Service.HTTP_INTERNAL_SERVER_ERROR);
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
            response.setStatusCode(CMN_API_Service.HTTP_OK);
            return response;
        }
    }
}