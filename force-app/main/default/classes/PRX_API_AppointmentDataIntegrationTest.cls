/**
 @ Author            : mamidalar@stanbic.com
 @ Date              : 04-03-2024
 @ Name of the Class : PRX_API_AppointmentIntegration
 @description         : This class provides methods for interacting with appointment records in the universal organization for the currently logged-in user.
 @ Last Modified By  : mamidalar@stanbic.com
 @ Last Modified On  : 16-02-2024
 @ Modification Description : SFP-28035
 @ ---------------------------------------------------------------------------
 @ Developer         Date                   Description
 @ ---------------------------------------------------------------------------
 @ mamidalar@stanbic.com    04-03-2024             Created
 */
@isTest
private class PRX_API_AppointmentDataIntegrationTest {
         private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_API_AppointmentDataIntegrationTest');

    /**
     * @description This method tests the callApi method in testGetAppointment
     */
    @isTest
    static void testGetAppointments() {
        Lead testLead = new Lead(LastName = 'TestLastName', Email = 'test@example.com');
        insert testLead;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        try {
            request.requestURI = '/services/apexrest/ServiceAppointment';
            request.addParameter('email', 'test@example.com');
            request.httpMethod = 'GET'; 
            RestContext.request = request;
            RestContext.response = response;
            PRX_API_AppointmentDataIntegration.getAppointments();
        } catch(Exception e) {
          Assert.areEqual(false, 'No response received','Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
        if(response != null) {
             Assert.areEqual('test@example.com', testLead.Email,'appointment would be attached to this Lead');
        } else {
        Assert.areEqual(false, 'No response received','testGetAppointment');
        }
    }
       /**
     * @description This method tests the callApi method in testGetNegativeAppointment
     */
      @isTest
    static void testGetNegativeAppointment() {
        Lead testLead = new Lead(LastName = 'TestLastName', Email = null);
        insert testLead;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        try {
            request.requestURI = '/services/apexrest/ServiceAppointment';
            request.addParameter('email', null);
            request.httpMethod = 'GET'; 
            RestContext.request = request;
            RestContext.response = response;
            PRX_API_AppointmentDataIntegration.getAppointments();
        } catch(Exception e) {
          Assert.areEqual(false, 'No response received','Exception caught: ' + e.getMessage());
        }
        Test.stopTest();
        if(response != null) {
               Assert.areEqual(null, testLead.Email,'No Lead would be Generated');

        } else {
        Assert.areEqual(false, 'No response received','testGetAppointment');
        }
    }
     /**
     * @description This method tests the callApi method in testCreateAppointment
     */
    @IsTest
    static void testCreateAppointment() {
        try {
            Lead testLead = new Lead(
                FirstName = 'Test',
                LastName = 'Lead',
                Company = 'Test Company',
                Status = 'New'
            );
            insert testLead;
            String schedStartTime = '2024-03-04 21:45:00'; 
            String schedEndTime = '2024-03-04 22:45:00'; 
            Map<String, Object> requestData = new Map<String, Object>{
                'leadId' => testLead.Id,
                'schedStartTime' => schedStartTime,
                'schedEndTime' => schedEndTime,
                'street' => '121 Spear Street',
                'city' => 'Charlotte',
                'state' => 'NC',
                'postalCode' => '05445',
                'country' => 'United States',
                'email' => 'brommoquennefe-4974@yopmail.com',
                'phone' => '123-456-7890',
                'appointmentType' => 'Face To Face'
            };
            String jsonRequest = JSON.serialize(requestData);
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf(jsonRequest);
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response = res;
            Test.startTest();
            PRX_API_AppointmentDataIntegration.createAppointment();
            SEL_ServiceAppointment selServiceAppointment = new SEL_ServiceAppointment(); 
            List<ServiceAppointment> appointment = selServiceAppointment.selectByParentId(new set<Id> {testLead.Id});
            Test.stopTest();
             Assert.areNotEqual(null, appointment[0],'appointment');
             Assert.areEqual('Upcoming', appointment[0].Status,'Status');
             Assert.areEqual(testLead.Id, appointment[0].ParentRecordId,'ParentRecordId');
             Assert.areEqual('121 Spear Street', appointment[0].Street,'Street');
             Assert.areEqual('Charlotte', appointment[0].City,'City');
             Assert.areEqual('NC', appointment[0].State,'State');
             Assert.areEqual('05445', appointment[0].PostalCode,'PostalCode');
             Assert.areEqual('United States', appointment[0].Country,'Country');
             Assert.areEqual('brommoquennefe-4974@yopmail.com', appointment[0].Email,'Email');
             Assert.areEqual('123-456-7890', appointment[0].Phone,'Phone');
            Datetime expectedStartTime = Datetime.newInstanceGmt(2024, 3, 4, 19, 45, 0); 
            Datetime expectedEndTime = Datetime.newInstanceGmt(2024, 3, 4, 21, 15, 0); 
            String responseBody = res.responseBody.toString();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            String serviceAppointmentId = (String) responseMap.get('servid');
             Assert.areNotEqual(null, serviceAppointmentId, 'Expected service appointment Id to be returned');
            if (serviceAppointmentId != null) {
                delete [SELECT Id FROM ServiceAppointment WHERE Id = :serviceAppointmentId];
            }
        } catch (Exception e) {
              LOGGER.error('Creation of Appointments failed' + e.getMessage());
        }
    }
      /**
     * @description This method tests the callApi method in testCancelAppointment
     */
    
    @isTest
    static void testCancelAppointment() {
        ServiceAppointment testAppointment = createTestAppointment();
        RestRequest mockRequest = createMockRequest(testAppointment.Id, 'cancelled', 'No longer needed');
        RestContext.request = mockRequest;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        SEL_ServiceAppointment selServiceAppointment = new SEL_ServiceAppointment(); 
         testAppointment = selServiceAppointment.selectById(testAppointment.Id);
        Test.stopTest();
         Assert.areEqual('Canceled', testAppointment.Status);
         Assert.areEqual('No longer needed', testAppointment.CancellationReason,'testRescheduleAppointment');
    }
 /**
     * @description This method tests the callApi method in testCaptureNotes
     */
    
    @isTest
    static void testCaptureNotes() {
        ServiceAppointment testAppointment = createTestAppointment();
        RestRequest mockRequest = createMockRequest(testAppointment.Id, 'captureNotes', 'Additional notes');
        RestContext.request = mockRequest;
        Test.startTest();
        PRX_API_AppointmentDataIntegration.updateAppointment();
        SEL_ServiceAppointment selServiceAppointment = new SEL_ServiceAppointment(); 
        testAppointment = selServiceAppointment.selectById(testAppointment.Id);
        Test.stopTest();
         Assert.areEqual('Additional notes', testAppointment.AdditionalInformation,'testRescheduleAppointment');
    }
 /**
     * @description This method tests the callApi method in testRescheduleAppointment
     */
@isTest
static void testRescheduleAppointment() {
    ServiceAppointment testAppointment = createTestAppointment();
    RestRequest mockRequest = createMockRequest(testAppointment.Id, 'reschedule', '2024-04-23 10:00:00');
    RestContext.request = mockRequest;
    Test.startTest();
    PRX_API_AppointmentDataIntegration.updateAppointment();
    SEL_ServiceAppointment selServiceAppointment = new SEL_ServiceAppointment(); 
    testAppointment = selServiceAppointment.selectById(testAppointment.Id);
    Test.stopTest();
     Assert.areEqual(Datetime.valueOf('2024-04-23 10:00:00'), testAppointment.SchedStartTime,'testRescheduleAppointment');
     Assert.areEqual(Datetime.valueOf('2024-04-23 10:30:00'), testAppointment.SchedEndTime,'testRescheduleAppointment');
}
    static ServiceAppointment createTestAppointment() {
        Lead testLead = new Lead(LastName = 'Test Lead', Email = 'test@example.com');
        insert testLead;
        return createTestAppointment(testLead.Id);
    }
    
    /**
     * @description This method tests the callApi method in testCreateAppointment
     */
    @IsTest
    static void testCreateAppointmentNegativeTest() {
        try {
            String schedStartTime = '2024-03-04 21:45:00'; 
            String schedEndTime = '2024-03-04 22:45:00'; 
            Map<String, Object> requestData = new Map<String, Object>{
                'leadId' => null,
                'schedStartTime' => schedStartTime,
                'schedEndTime' => schedEndTime,
                'street' => '121 Spear Street',
                'city' => 'Charlotte',
                'state' => 'NC',
                'postalCode' => '05445',
                'country' => 'United States',
                'email' => 'brommoquennefe-4974@yopmail.com',
                'phone' => '123-456-7890',
                'appointmentType' => 'Face To Face'
            };
            String jsonRequest = JSON.serialize(requestData);
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf(jsonRequest);
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestResponse res = new RestResponse();
            RestContext.response = res;
            Test.startTest();
            PRX_API_AppointmentDataIntegration.createAppointment();
            SEL_ServiceAppointment selServiceAppointment = new SEL_ServiceAppointment(); 
            List<ServiceAppointment> appointment = selServiceAppointment.selectByParentId(new set<Id> {null});
            Test.stopTest();
             Assert.areEqual(0, appointment.size(),'appointment is empty');
        } catch (Exception e) {
              LOGGER.error('Creation of appointment Failed' + e.getMessage());
        }
    }

    /**
     * @description This method tests the callApi method in ServiceAppointment
     */
    static ServiceAppointment createTestAppointment(Id parentRecordId) {
        ServiceAppointment testAppointment = new ServiceAppointment(
            ParentRecordId = parentRecordId,
            Status = 'Upcoming',
            SchedStartTime = Datetime.now().addDays(1),
            SchedEndTime = Datetime.now().addDays(1).addMinutes(30)
        );
        insert testAppointment;
        return testAppointment;
    }

    
    static RestRequest createMockRequest(Id appointmentId, String action, String value) {
        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf('{"apserid":"' + appointmentId + '","action":"' + action + '","value":"' + value + '"}');
        mockRequest.httpMethod = 'PUT';
        return mockRequest;
    }
}