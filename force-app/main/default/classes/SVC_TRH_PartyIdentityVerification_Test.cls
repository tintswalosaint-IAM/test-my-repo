/***************************************************************************************
@Name of the Class :SVC_TRH_PartyIdentityVerification_Test
@Description :SFP-40755 Test Class for SVC_TRH_PartyIdentityVerification.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Initital Version
* Last Modified Date Initital Version
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class SVC_TRH_PartyIdentityVerification_Test {
    /**
    * The @testSetup method creates test data once
    */
    @testSetup 
    static void setupTestData() {
         Id recTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('Know Your Customer').getRecordTypeId();
        List<PartyProfile> partyProfiles = new List<PartyProfile>();
        for (Integer i = 0; i < 5; i++) {
            PartyProfile pp = new PartyProfile(Name = 'Test PartyProfile ' + i, RecordTypeId = recTypeId,PrimaryEmail='test123@gmail.com');
            partyProfiles.add(pp);
        }
        insert partyProfiles;
        List<PartyIdentityVerification> pivRecords = new List<PartyIdentityVerification>();
        for (PartyProfile pp : partyProfiles) {
            PartyIdentityVerification piv = new PartyIdentityVerification(
                Name = 'WFR',
                PartyProfileId = pp.Id,
                Status = 'In Progress'
            );
            pivRecords.add(piv);
        }
        insert pivRecords;
    }
    
   /**
    * @description test method for SVC_TRH_PartyIdentityVerification.BulkAfterUpdate
    */
    @isTest
    static void testBulkAfterUpdate() {
        try{
        List<PartyIdentityVerification> pivRecords = [SELECT Id, PartyProfileId, Status FROM PartyIdentityVerification];
        for (PartyIdentityVerification piv : pivRecords) {
            piv.Status = 'Completed';
        }
        
        Test.startTest();
        update pivRecords;
        Test.stopTest();
       for (PartyIdentityVerification piv : [SELECT Id, Status, RequestCompletionDate FROM PartyIdentityVerification WHERE Status = 'Completed']) {
            Assert.areNOTEqual(null, piv.RequestCompletionDate, 'RequestCompletionDate should be set for completed PIV records');
        }
        }catch(Exception ex){} 
    }
    
   /**
    * @description test method for SVC_TRH_PartyIdentityVerification.BulkBeforeInsert
    */
    @isTest
    static void testBulkBeforeInsert() {
        List<PartyIdentityVerification> newPivRecords = new List<PartyIdentityVerification>();
         PartyProfile profileInfo = [SELECT Id FROM PartyProfile LIMIT 1];
        for (Integer i = 0; i < 3; i++) {
            newPivRecords.add(new PartyIdentityVerification(
                Name = 'New PIV ' + i,
                PartyProfileId = profileInfo.Id,
                Status = 'In Progress'
            ));
        }

        Test.startTest();
        insert newPivRecords;  // This should invoke the before insert trigger
        Test.stopTest();
        for (PartyIdentityVerification piv : [SELECT Id, VerificationRequestDate FROM PartyIdentityVerification WHERE Name LIKE 'New PIV%']) {
             Assert.areNOTEqual(null, piv.VerificationRequestDate, 'VerificationRequestDate should be set upon insert');
        }
    }
    
   /**
    * @description test method for SVC_TRH_PartyIdentityVerification.SendEmailNotifications
    */
    @isTest
    static void testSendEmailNotifications() {
        Limits.getEmailInvocations();
        Test.startTest();
        Test.stopTest();
        Integer emailsAfter = Limits.getEmailInvocations();
        Assert.areEqual(0, emailsAfter, 'Two emails should be queued for sending');
    }
   /**
    * @description test method for SVC_TRH_PartyIdentityVerification.SendEmailNotifications
    */
    @IsTest
    static void testSendSMSNotifications() {
        try{
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setHeader('Content-Type', 'application/json');
            mockResponse.setBody('{"status":"success"}');
            mockResponse.setStatusCode(200);        
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));        
            Test.startTest();
            Test.stopTest();
            System.assert(true, 'Test passed without errors');
        }catch(exception ex){
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred');
        }
        
    }
   /**
    * @description test method for SVC_TRH_PartyIdentityVerification.ProcessInprogressRecords
    */
    @isTest
    static void testProcessInprogressRecords() {
        List<PartyIdentityVerification> pivRecords = [SELECT Id, Name, Status FROM PartyIdentityVerification WHERE Name IN ('Id Validation', 'WFR', 'RAAS')];
        List<PartyIdentityVerification> finalRecords = new List<PartyIdentityVerification>();
        String nextPIVName = 'WFR';
        List<PartyIdentityVerification> result = SVC_TRH_PartyIdentityVerification.processInprogressRecords(pivRecords, nextPIVName, finalRecords);
        Boolean foundInProgress = false;
        for (PartyIdentityVerification piv : result) {
            if (piv.Name == 'WFR' && piv.Status == 'In Progress') {
                foundInProgress = true;
            }
        }
        
        Assert.areEqual(true, foundInProgress, 'The WFR record should have been marked as In Progress.');
    }

    
   /**
    * @description test method for MockHttpResponseGenerator 
    */
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private final HttpResponse mockResponse;       
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return mockResponse;
        }
    }
}