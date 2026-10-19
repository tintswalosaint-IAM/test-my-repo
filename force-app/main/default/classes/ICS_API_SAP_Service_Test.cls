/**
* @description       : Test class for ICS_API_SAP_Service
* @test              : ICS_API_SAP_Service_Test
* @author            : Ikyatha Naidu
* @group             : API
* @last modified on  : 08-10-2024
* @last modified by  : Ikyatha Naidu
**/
@isTest
public class ICS_API_SAP_Service_Test {
    private static final String TEST_REQUEST_BODY = '{"testKey":"TestValue"}';
    private static final String MOCK_RESPONSE_BODY = '{"Party":[{"PartyReference":{"PartyIdentification":[' +
        '{"PartyIdentificationType":"identificationNumber","PartyIdentification":{"IdentifierValue":{"Value":"0090170526"}}},' +
        '{"PartyIdentificationType":"Type","PartyIdentification":{"IdentifierValue":{"Value":"BusinessPartnerID"}}}]},' +
        '"AdditionalData":{"CategoryInformation":{"Category":[' +
        '{"CategoryItem":"header","CategoryDetails":[' +
        '{"CategoryType":"correlationID","CategoryIdentifierValue":"8044329e-331f-daab-3c52-5a4ebe826f15"},' +
        '{"CategoryType":"channelID","CategoryIdentifierValue":"SB678656760621A"},' +
        '{"CategoryType":"UserID","CategoryIdentifierValue":"MCA_USR"}]},' +
        '{"CategoryItem":"providerStatus","CategoryDetails":[' +
        '{"CategoryType":"statusMessage","CategoryIdentifierValue":"Your request was successfully processed"},' +
        '{"CategoryType":"statusCode","CategoryIdentifierValue":"S"},' +
        '{"CategoryType":"VerificationStatus","CategoryIdentifierValue":"057"}]}]}}}]}';

    private static final String SERVICE_CREATE_CUSTOMER = 'ICS_API_SAPCreateCustomer';
    private static final String SERVICE_CREATE_RELATION = 'ICS_API_SAPCreateRelation';
    private static final String SERVICE_CREATE_CYT = 'ICS_API_SAPCreateCYT';

    private static final String ERROR_CUSTOMER_CREATION = 'SAP Customer Creation API should return a valid response body - ICS_API_SAPCreateCustomer failed';
    private static final String ERROR_RELATION_CREATION = 'SAP Relation Creation API should return a valid response body - ICS_API_SAPCreateRelation failed';
    private static final String ERROR_CYT_CREATION = 'SAP CYT Creation API should return a valid response body - ICS_API_SAPCreateCYT failed';
    
    /**
     * @description Tests the SAP customer creation API call functionality
     * Verifies that the API returns a valid response when creating a new customer
     * Uses mock data to simulate the SAP system response
     * @return void
     */
    @isTest
    static void testPrepareHttpRequestSAPCreateCustomer() {
         object responseBody = testSAPServiceCall(SERVICE_CREATE_CUSTOMER);
         Assert.areEqual(true, responseBody != null, ERROR_CUSTOMER_CREATION);
    }
    
    /**
     * @description Tests the SAP relation creation API call functionality
     * Verifies that the API returns a valid response when creating a new relation
     * Uses mock data to simulate the SAP system response
     * @return void
     */
    @isTest
    static void testPrepareHttpRequestSAPCreateRelation() {
       object responseBody = testSAPServiceCall(SERVICE_CREATE_RELATION);
         Assert.areEqual(true, responseBody != null, ERROR_RELATION_CREATION);
    }
    
    /**
     * @description Tests the SAP CYT (Customer Type) creation API call functionality
     * Verifies that the API returns a valid response when creating a new CYT
     * Uses mock data to simulate the SAP system response
     * @return void
     */
    @isTest
    static void testPrepareHttpRequestSAPCreateCYT() {
        object responseBody = testSAPServiceCall(SERVICE_CREATE_CYT);
        Assert.areEqual(true, responseBody != null, ERROR_CYT_CREATION);
    }
    
    /**
     * @description Helper method to execute SAP service calls for testing
     * Reduces code duplication by centralizing common test logic
     * Sets up the mock response, executes the service call, and verifies the response
     * 
     * @param serviceName The name of the SAP service to be tested
     * @param errorMessage The error message to display if the test fails
     * @return void
     * @example
     * testSAPServiceCall('ICS_API_SAPCreateCustomer', 'Customer creation failed');
     */
    private static ICS_API_SAP_Service testSAPServiceCall(String serviceName) {
        CMN_WebserviceSetting__mdt settings = CMN_WebserviceSetting__mdt.getInstance(serviceName);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        
        Test.startTest();
        ICS_API_SAP_Service sapServicecall = new ICS_API_SAP_Service(settings.CMN_NamedCredential__c);
        sapServicecall.endPoint = settings.CMN_Path__c;
        sapServicecall.requestBody = TEST_REQUEST_BODY;
        sapServicecall.method = settings.AOB_Action__c;
        sapServicecall.serviceName = serviceName;
        sapServicecall.sendRequest();
                

        Test.stopTest();
        return sapServicecall;
    }
    
    /**
     * @description Mock class to simulate successful SAP API responses
     * Implements HttpCalloutMock interface to provide test responses
     * Returns a predefined successful response with HTTP 200 status code
     */
    public class CreateCustomerMockSuccess implements HttpCalloutMock {
        /**
         * @description Responds to HTTP requests with a mock response
         * @param req The HTTP request to respond to
         * @return HttpResponse A mock HTTP response with predefined successful data
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_Service.HTTP_OK);
            response.setBody(MOCK_RESPONSE_BODY);
            return response;
        }
    }
}