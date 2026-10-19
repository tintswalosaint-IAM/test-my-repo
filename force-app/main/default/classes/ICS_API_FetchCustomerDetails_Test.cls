/***************************************************************************************
* @name of the Class : ICS_API_FetchCustomerDetails_Test.cls
* @description class used as test class for ICS_API_FetchCustomerDetails
* @Story:SFP-32986
* @date 10/03/2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/

@isTest
public class ICS_API_FetchCustomerDetails_Test {
    
    @isTest
    static void testGetBody() {
        Test.startTest();
        
        ICS_API_FetchCustomerDetails fetchCustomerDetails = new ICS_API_FetchCustomerDetails();
        fetchCustomerDetails.accountId = '001XXXXXXXXXXXX'; 

        String requestBody = fetchCustomerDetails.getBody();
        
        Assert.areNotEqual(null, requestBody, 'Request body should not be null.');
        Assert.areEqual('{"customerId":"001XXXXXXXXXXXX"}', requestBody, 'Request body should contain correct JSON.');

        Test.stopTest();
    }

    @isTest
    static void testGetServiceName() {
        Test.startTest();
        
        ICS_API_FetchCustomerDetails fetchCustomerDetails = new ICS_API_FetchCustomerDetails();
        String serviceName = fetchCustomerDetails.getServiceName();

        Assert.areNotEqual(null, serviceName, 'Service name should not be null.');
        Assert.areEqual(ICS_API_FetchCustomerDetails.SERVICE_NAME, serviceName, 'Service name should match expected value.');

        Test.stopTest();
    }

    @isTest
    static void testGetVerb() {
        Test.startTest();

        ICS_API_FetchCustomerDetails fetchCustomerDetails = new ICS_API_FetchCustomerDetails();
        String verb = fetchCustomerDetails.getVerb();

        Assert.areNotEqual(null, verb, 'HTTP verb should not be null.');
        Assert.areEqual('POST', verb, 'HTTP verb should be POST.');

        Test.stopTest();
    }

    @isTest
    static void testSetHeaders() {
        Test.startTest();

        ICS_API_FetchCustomerDetails fetchCustomerDetails = new ICS_API_FetchCustomerDetails();
        fetchCustomerDetails.setHeaders();

        Assert.areNotEqual(null, fetchCustomerDetails.request, 'Request object should not be null.');
        Assert.areEqual('POST', fetchCustomerDetails.request.getMethod(), 'HTTP method should be POST.');
        Assert.areEqual('application/json', fetchCustomerDetails.request.getHeader('Content-Type'), 'Content-Type should be application/json.');

        Test.stopTest();
    }

    @isTest
    static void testGetWebServiceEndPoint() {
        Test.startTest();

        ICS_API_FetchCustomerDetails fetchCustomerDetails = new ICS_API_FetchCustomerDetails();

        String endPoint = fetchCustomerDetails.getWebServiceEndPoint();

        Assert.areNotEqual(null, endPoint, 'Endpoint URL should not be null.');
        Assert.areNotEqual('callout:My_Named_Credential/fetchCustomer', endPoint, 'Endpoint URL should be constructed correctly.');

        Test.stopTest();
    }

    @isTest
    static void testMockSuccessResponse() {
        Test.startTest();

        ICS_API_FetchCustomerDetails.ICS_API_FetchCustomerDetailsMock mock = 
            new ICS_API_FetchCustomerDetails.ICS_API_FetchCustomerDetailsMock(ICS_API_FetchCustomerDetails.SERVICE_NAME, 'SUCCESS');

        HttpResponse response = new HttpResponse();
        mock.setResponse(new HttpRequest(), response);
        
        Assert.areNotEqual(null, response.getBody(), 'Response body should not be null.');
        Assert.areEqual('{"statusCode":200,"statusMessage":"OK","data":"Your response data here"}', 
                            response.getBody(), 'Response body should match expected success JSON.');

        Test.stopTest();
    }

    @isTest
    static void testMockFailureResponse() {
        Test.startTest();

        ICS_API_FetchCustomerDetails.ICS_API_FetchCustomerDetailsMock mock = 
            new ICS_API_FetchCustomerDetails.ICS_API_FetchCustomerDetailsMock(ICS_API_FetchCustomerDetails.SERVICE_NAME, 'FAILURE');

        HttpResponse response = new HttpResponse();
        mock.setResponse(new HttpRequest(), response);
        
        Assert.areNotEqual(null, response.getBody(), 'Response body should not be null.');
        Assert.areEqual('{"statusCode":400,"statusMessage":"Bad Request","data":"Error message here"}', 
                            response.getBody(), 'Response body should match expected failure JSON.');

        Test.stopTest();
    }

  
}