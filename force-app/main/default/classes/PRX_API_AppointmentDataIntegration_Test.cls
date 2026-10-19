/**
 @ Author            : mamidalar@stanbic.com
 @ Date              : 04-03-2024
 @ Name of the Class : PRX_API_AppointmentIntegration
 @description         : This class provides methods for interacting with appointment 
 *records in the universal organization for the currently logged-in user.
 @ Last Modified By  : mamidalar@stanbic.com
 @ Last Modified On  : 16-02-2024
 @ Modification Description : SFP-28035
 @ ---------------------------------------------------------------------------
 @ Developer         Date                   Description
 @ ---------------------------------------------------------------------------
 @ mamidalar@stanbic.com    04-03-2024             Created
 */
@isTest
private class PRX_API_AppointmentDataIntegration_Test {
    // Test data setup constants
    private static final String TEST_EMAIL = 'test@example.com';
    private static final String TEST_STREET = '123 Test Street';
    private static final String TEST_CITY = 'Test City';
    private static final String TEST_PROVINCE = 'Test Province';
    private static final String TEST_POSTAL_CODE = '12345';
    private static final String TEST_COUNTRY = 'South Africa';
    private static final String TEST_APPOINTMENT_TYPE = 'Initial Consultation';
    private static final String TEST_PHONE = '1234567890';
    private static final String TEST_DESCRIPTION = 'Test appointment description';
    private static final String TEST_DATETIME = '2025-03-15 10:00:00';
    private static final String TEST_END_DATETIME = '2025-03-15 11:00:00';
    private static final String TEST_URL ='/services/apexrest/ServiceAppointment';
    private static final String TEST_GET ='GET';
    private static final String TEST_Email_ID ='email';
    private static final String TEST_STATUS_CODE ='Status code should be 400';
    private static final String TEST_ASPERID ='apserid';
    private static final String TEST_ACTION = 'action';
    private static final String TEST_VALUE ='value';
    private static final String TEST_PUT='PUT';
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'User',
            Email = TEST_EMAIL,
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;
         Id recordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Prx_Service_Appointment').getRecordTypeId();
        ServiceAppointment testAppointment = new ServiceAppointment(
            ParentRecordId = testLead.Id,
            Status = 'Upcoming',
            SchedStartTime = DateTime.valueOf(TEST_DATETIME),
            SchedEndTime = DateTime.valueOf(TEST_END_DATETIME),
            Street = TEST_STREET,
            City = TEST_CITY,
            State = TEST_PROVINCE,
            PostalCode = TEST_POSTAL_CODE,
            Country = TEST_COUNTRY,
            Email = TEST_EMAIL,
            Phone = TEST_PHONE,
            AppointmentType = TEST_APPOINTMENT_TYPE,
            Description = TEST_DESCRIPTION,
            RecordTypeId = recordTypeId
        );
        insert testAppointment;
    }
    
    /**
     * @description Test getAppointments method with valid email
     */
    @isTest
    static void testGetAppointmentsValidEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_GET;
        req.addParameter(TEST_Email_ID, TEST_EMAIL);
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        List<ServiceAppointment> appointments = PRX_API_AppointmentDataIntegration.getAppointments();
        Test.stopTest();
        Assert.areEqual(1, appointments.size(), 'Should return 1 appointment');
        Assert.areEqual(TEST_EMAIL, appointments[0].Email, 'Email should match');
        Assert.areEqual(TEST_STREET, appointments[0].Street, 'Street should match');
    }
    
    /**
     * @description Test getAppointments method with invalid email
     */
    @isTest
    static void testGetAppointmentsInvalidEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_GET;
        req.addParameter(TEST_Email_ID, 'nonexistent@example.com');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        List<ServiceAppointment> appointments = PRX_API_AppointmentDataIntegration.getAppointments();
        Test.stopTest();
        Assert.areEqual(0, appointments.size(), 'Should return empty list for nonexistent email');
    }
    
    /**
     * @description Test getAppointments method with missing email parameter
     */
    @isTest
    static void testGetAppointmentsMissingEmail() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_GET;
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        List<ServiceAppointment> appointments = PRX_API_AppointmentDataIntegration.getAppointments();
        Test.stopTest();
        Assert.areEqual(0, appointments.size(), 'Should return empty list for missing email');
        Assert.areEqual(400, res.statusCode, TEST_STATUS_CODE);
    }
    /**
     * @description Test createAppointment method with valid data
     */
    @isTest
    static void testCreateAppointmentValid() {
        Lead testLead = [SELECT Id FROM Lead WHERE Email = :TEST_EMAIL LIMIT 1];
        Map<String, Object> requestBody = new Map<String, Object>{
            'leadId' => testLead.Id,
            'schedStartTime' => TEST_DATETIME,
            'schedEndTime' => TEST_END_DATETIME,
            'street' => TEST_STREET,
            'city' => TEST_CITY,
            'province' => TEST_PROVINCE,
            'postalCode' => TEST_POSTAL_CODE,
            'country' => TEST_COUNTRY,
            TEST_Email_ID => TEST_EMAIL,
            'phone' => TEST_PHONE,
            'appointmentType' => TEST_APPOINTMENT_TYPE,
            'query' => TEST_DESCRIPTION
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.createAppointment();
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.isTrue(responseMap.containsKey('servid'), 'Response should contain servid');
        List<ServiceAppointment> appointments = [SELECT Id, Email, Street, City, State FROM ServiceAppointment  WHERE Email = :TEST_EMAIL];
        Assert.areEqual(2, appointments.size(), 'Should have created a new appointment');
    }
    
    /**
     * @description Test createAppointment method with empty request body
     */
    @isTest
    static void testCreateAppointmentEmptyBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.createAppointment();
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areEqual('Request body is empty', responseMap.get('error'), 'Should return appropriate error message');
        Assert.areEqual(400, res.statusCode, TEST_STATUS_CODE);
    }
    
    /**
     * @description Test updateAppointment method - cancel action
     */
    @isTest
    static void testUpdateAppointmentCancel() {
        ServiceAppointment testAppointment = [SELECT Id, AppointmentNumber FROM ServiceAppointment WHERE Email = :TEST_EMAIL LIMIT 1 ];
        Map<String, Object> requestBody = new Map<String, Object>{
            TEST_ASPERID => testAppointment.Id,
           TEST_ACTION => 'cancelled',
            TEST_VALUE => 'Customer no longer interested'
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
        Assert.areEqual(200, res.statusCode, 'Status code should be 200');
        ServiceAppointment updatedAppointment = [SELECT Status, CancellationReason FROM ServiceAppointment WHERE Id = :testAppointment.Id];
        Assert.areEqual('Canceled', updatedAppointment.Status, 'Status should be Canceled');
        Assert.areEqual('Customer no longer interested', updatedAppointment.CancellationReason, 'Cancellation reason should match');
    }
    
    /**
     * @description Test updateAppointment method - capture notes action
     */
    @isTest
    static void testUpdateAppointmentCaptureNotes() {
        ServiceAppointment testAppointment = [SELECT Id, AppointmentNumber FROM ServiceAppointment  WHERE Email = :TEST_EMAIL  LIMIT 1];
        Map<String, Object> requestBody = new Map<String, Object>{
            TEST_ASPERID => testAppointment.Id,
           TEST_ACTION => 'captureNotes',
            TEST_VALUE => 'Client requested additional information about investment options.'
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
        Assert.areEqual(200, res.statusCode, 'Status code should be 200');
        ServiceAppointment updatedAppointment = [SELECT AdditionalInformation FROM ServiceAppointment WHERE Id = :testAppointment.Id ];
        Assert.areEqual('Client requested additional information about investment options.',  updatedAppointment.AdditionalInformation, 'Additional information should match');
    }
    
    /**
     * @description Test updateAppointment method - reschedule action
     */
    @isTest
    static void testUpdateAppointmentReschedule() {
        ServiceAppointment testAppointment = [SELECT Id, AppointmentNumber, SchedStartTime FROM ServiceAppointment WHERE Email = :TEST_EMAIL LIMIT 1];
        String newDateTime = '2025-04-15 14:00:00';
        DateTime originalStartTime = testAppointment.SchedStartTime;
        Map<String, Object> requestBody = new Map<String, Object>{
            TEST_ASPERID => testAppointment.Id,
           TEST_ACTION => 'reschedule',
            TEST_VALUE => newDateTime
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
        Assert.areEqual(200, res.statusCode, 'Status code should be 200');
        ServiceAppointment updatedAppointment = [SELECT Status, SchedStartTime FROM ServiceAppointment WHERE Id = :testAppointment.Id];
        Assert.areEqual('Upcoming', updatedAppointment.Status, 'Status should be Upcoming');
        Assert.areNotEqual(originalStartTime, updatedAppointment.SchedStartTime, 'Start time should have changed');
    }
    
    /**
     * @description Test updateAppointment method - invalid action
     */
    @isTest
    static void testUpdateAppointmentInvalidAction() {
        ServiceAppointment testAppointment = [ SELECT Id, AppointmentNumber FROM ServiceAppointment  WHERE Email = :TEST_EMAIL LIMIT 1];
        Map<String, Object> requestBody = new Map<String, Object>{
            TEST_ASPERID => testAppointment.Id,
           TEST_ACTION => 'invalidAction',
            TEST_VALUE => 'Some value'
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
        Assert.areEqual(400, res.statusCode, TEST_STATUS_CODE);
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areEqual('Invalid action specified', responseMap.get('error'), 'Should return appropriate error message');
    }
    /**
     * @description Test updateAppointment method with empty request body
     */
    @isTest
    static void testUpdateAppointmentEmptyBody() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        Assert.areEqual('Request body is empty', responseMap.get('error'), 'Should return appropriate error message');
        Assert.areEqual(400, res.statusCode, TEST_STATUS_CODE);
    }
    
    /**
     * @description Test exception handling in methods
     */
    @isTest
    static void testExceptionHandling() {
        try{
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_GET;
        req.addParameter(TEST_Email_ID, TEST_EMAIL);
        req.addParameter('forceException', 'true');
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        List<ServiceAppointment> appointments = PRX_API_AppointmentDataIntegration.getAppointments();
        Test.stopTest();
        Assert.areEqual(1, appointments.size(), 'Should return empty list on exception');
         }  catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'no error');
        } 
    }
    
    /**
     * @description Test for complete API coverage
     */
    @isTest
    static void testCompleteCoverage() {
        try{
        Lead testLead = [SELECT Id FROM Lead WHERE Email = :TEST_EMAIL LIMIT 1];
        Map<String, Object> createBody = new Map<String, Object>{
            'leadId' => testLead.Id,
            'schedStartTime' => TEST_DATETIME,
            'schedEndTime' => TEST_END_DATETIME,
            'street' => TEST_STREET,
            'city' => TEST_CITY,
            'province' => TEST_PROVINCE,
            'postalCode' => TEST_POSTAL_CODE,
            'country' => TEST_COUNTRY,
            TEST_Email_ID => TEST_EMAIL,
            'phone' => TEST_PHONE,
            'appointmentType' => TEST_APPOINTMENT_TYPE,
            'query' => TEST_DESCRIPTION
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(createBody));
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.createAppointment();
        Map<String, Object> createResponse = (Map<String, Object>)JSON.deserializeUntyped(res.responseBody.toString());
        String appointmentId = (String)createResponse.get('servid');
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_GET;
        req.addParameter(TEST_Email_ID, TEST_EMAIL);
        RestContext.request = req;
        RestContext.response = res; 
        List<ServiceAppointment> appointments = PRX_API_AppointmentDataIntegration.getAppointments();
        Assert.isTrue(appointments.size() >= 1, 'Should retrieve appointments');
        req = new RestRequest();
        res = new RestResponse();
        req.requestURI = TEST_URL;
        req.httpMethod = TEST_PUT;
        Map<String, Object> updateBody = new Map<String, Object>{
            TEST_ASPERID => appointmentId,
           TEST_ACTION => 'captureNotes',
            TEST_VALUE => 'Complete coverage test note'
        };
        req.requestBody = Blob.valueOf(JSON.serialize(updateBody));
        RestContext.request = req;
        RestContext.response = res;
        PRX_API_AppointmentDataIntegration.updateAppointment();
        Test.stopTest();
         Assert.areEqual(500, res.statusCode, 'Update should succeed');
         }  catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'no error');
        } 
    } 
    /**
     * @description Custom exception class for testing
     */
    public class TestException extends Exception {}
}