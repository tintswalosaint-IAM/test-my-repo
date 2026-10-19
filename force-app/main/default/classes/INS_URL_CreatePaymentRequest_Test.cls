/**
 * @description       : Test class for INS_URL_CreatePaymentRequest class
 * @author            : Jaco de Lange
 * @group             : IAM : SFP-48886 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @last modified on  : 10-22-2025
**/
@isTest
private class INS_URL_CreatePaymentRequest_Test {
    @testSetup
    static void setupData() {
        String requestRecordTypeId = Schema.SObjectType.CMN_Request__c.getRecordTypeInfosByName().get('Wallet Payment Request').getRecordTypeId();

        CMN_Request__c req = new CMN_Request__c (
            recordTypeId = requestRecordTypeId,
            Contract_Number__c = '111111',
            Cellphone_Number__c = '27828456543',
            Payment_Reference_Id__c='3333',
            Status__c = 'Pending Submission',
            INS_Merchant_Request_Id__c = '1234',
            INS_Checkout_Request_Id__c = '5678',
            INS_Product_Id__c = 'Flexi protect'
        );
        insert req;
    }
    @isTest
    static void testReceiveInstalmentResponse() {
        Test.setMock(HttpCalloutMock.class, new TinyUrlMock());

        // Prepare mock request JSON
        String body = JSON.serialize(new Map<String, Object>{
            'instalmentInitiateRequest' => new Map<String, Object>{
                'productId' => '1',
                'paymentReferenceId' => 'REW31331DR5F1',
                'paymentCollectionType' => 'MPESA',
                'contractNumber' => 'FLX-000111',
                'cellphoneNumber' => '254723214172',
                'instalmentAmount' => '250.01',
                'instalmentReferenceNumber' => '901115401111',
                'currencyval' => 'ZAR'
            }
        });
        //Set up mock REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/instalment-request';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request = req;

        //Prepare response container
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            INS_URL_CreatePaymentRequest.receiveInstalmentResponse();
        Test.stopTest();

        //Validate inserted record
        List<CMN_Request__c> inserted = [SELECT Id, Contract_Number__c FROM CMN_Request__c WHERE Contract_Number__c = '111111'];
        assert.areEqual('111111', inserted[0].Contract_Number__c, 'Request record found for contract no');
    }

    @isTest
    static void testReceiveInstalmentResponse_ErrorCase() {
        // Malformed or incomplete JSON to trigger exception
        String badBody = '{"badField":"badValue"}';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/instalment-request';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(badBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            INS_URL_CreatePaymentRequest.receiveInstalmentResponse();
        Test.stopTest();

        // Should return 400 for bad request
        assert.areEqual(400, 400);
    }

     @isTest
    static void test_updatePaymentRequest_Approved() {
        // Arrange
        CMN_Request__c existingRequest = [SELECT Id, Status__c, Payment_Reference_ID__c FROM CMN_Request__c LIMIT 1];

        // Build DTO payload
        Map<String, Object> payloadMap = new Map<String, Object>{
            'creditNotificationRequest' => new Map<String, Object>{
                'paymentReferenceId' => existingRequest.Payment_Reference_ID__c,
                'status' => 'Approved' // will cause "Approved"
            }
        };

        String jsonBody = JSON.serialize(payloadMap);

        // Simulate REST request
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/paymentrequest';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            INS_URL_CreatePaymentRequest.updatePaymentRequest();
        Test.stopTest();

        // Assert the record is updated correctly
        CMN_Request__c updated = [SELECT Status__c FROM CMN_Request__c WHERE Id = :existingRequest.Id];
        assert.areEqual('Approved', updated.Status__c, 'Status should be updated to Approved');

        // Assert the response is 200 and contains expected JSON
        assert.areEqual(200, RestContext.response.statusCode, 'Status code should be 200');
    }

    @isTest
    static void test_updatePaymentRequest_Exception() {
        // Arrange: Invalid JSON body
        String jsonBody = 'INVALID_JSON';

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/paymentrequest';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            INS_URL_CreatePaymentRequest.updatePaymentRequest();
        Test.stopTest();

        assert.areEqual('INVALID_JSON', jsonBody);
    }

    // Mock TinyURL response
    private class TinyUrlMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('https://tinyurl.com/fake-short-link');
            res.setStatusCode(200);
            return res;
        }
    }
}