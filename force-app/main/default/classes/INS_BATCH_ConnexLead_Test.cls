/**
* @description       : Test for INS_BATCH_ConnexLead
* @author            : Raja Arsalan
* @group             : Smartenup
* @User Story        : SFP-44418
* @last modified on  : 28-01-2026
* @last modified by  : Raja Arsalan

* Change log
* 2026-01-28   Raja Arsalan    SFP-52529 - Added new method to the test class (testExtractErrorMessageWithDTO, testExtractFromErrorsArrayWithTitleFallback, testExtractFromErrorsArrayDirect, testParseNestedErrorWithErrorMessage, testParseNestedErrorWithErrorMessage, testParseNestedErrorWithErrorsArray)

*/


@isTest
private class INS_BATCH_ConnexLead_Test {
    
    /**
* @description Common test setup helper
*/
    private static TestSetup createTestSetup(String scenario) {
        TestSetup setup = new TestSetup();
        
        setup.testUser = Insurance_TestDataFactory.createTestUser();
        if (scenario == 'LeadQualify') {
            setup.testUser.EmployeeNumber = '123456';
        }
        insert setup.testUser;
        
        setup.campaigns = Insurance_TestDataFactory.createCampaigns();
        if (scenario == 'withoutDailLerQueueId') {
            for (Campaign cam : setup.campaigns) {
                cam.Dialler_System_Code__c = null;
            }
        }
        insert setup.campaigns;
        
        setup.expressedInterests = Insurance_TestDataFactory.createExpressInterest();
        insert setup.expressedInterests;
        
        setup.mockSettings = Insurance_TestDataFactory.createMockLeadSettings();
        
        setup.lead = createScenarioLead('General', scenario, setup);
        insert setup.lead;
        
        return setup;
    }
    
    
    
    /**
* @description Lead creation based on scenario
*/
    private static Lead createScenarioLead(String leadType, String scenario, TestSetup setup) {
        Lead lead = Insurance_TestDataFactory.createLead(leadType);
        lead.OwnerId = setup.testUser.Id;
        lead.Expressed_Interest_Product__c = setup.expressedInterests[0].Id;
        
        if (scenario == 'FuturePreferredTimeLead') {
            lead.Preferred_Contact_Date_Time__c = DateTime.now().addDays(1);
        } else if (scenario == 'PastPreferredTimeLead') {
            lead.Preferred_Contact_Date_Time_End__c = DateTime.now().addDays(-1);
        } else if (scenario == 'SuccessResponseOnUpdate' || scenario == 'UpdateSuccessResponse'|| scenario == 'Update502Response') {
            lead.Referred_System_Reference_Number__c = 'existing-ref';
        } else if (scenario == 'LeadQualify' || scenario == 'LeadExpiry') {
            lead.Referred_System_Reference_Number__c = '12345';
        } else if (scenario == 'IncorrectNumber') {
            lead.MobilePhone = '12';
            lead.Phone = '23';
        }
        
        return lead;
    }
    
    /**
* @description Batch execution helper
*/
    private static void executeBatch(TestSetup setup, String mockScenario) {
        INS_Leads_API.mockScenario = mockScenario;
        INS_Leads_API.testLeadId = setup.lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_LeadsAPI_Mock());
        
        INS_BATCH_ConnexLead batchJob = new INS_BATCH_ConnexLead(
            false,
            null,
            setup.mockSettings.INS_LeadType__c,
            setup.mockSettings.INS_ProductFamily__c,
            setup.mockSettings.INS_LeadDate__c != null ? setup.mockSettings.INS_LeadDate__c.date() : null,
            new List<String>{setup.lead.Id}
        );
        
        Database.executeBatch(batchJob, 15);
    }
    
    /**
* @description Test setup wrapper class (inner class)
*/
    private class TestSetup {
        public User testUser;
        public List<Campaign> campaigns;
        public List<Leads_ProductQueueAllocation__c> expressedInterests;
        public INS_Insurance_Lead_Settings__mdt mockSettings;
        public Lead lead;
    }
    
    /**
* @description Test for SuccessResponse
*/ 
    @isTest static void testSuccessResponse() {
        TestSetup setup = createTestSetup('SuccessResponse');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should not be empty on success');
    }
    
    /**
* @description Test for FuturePreferredTimeLead
*/ 
    @isTest static void testFuturePreferredTimeLead() {
        TestSetup setup = createTestSetup('FuturePreferredTimeLead');
        
        // No batch execution for future preferred time
        Test.startTest();
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual(NULL, updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should be NULL');
    }
    
    /**
* @description Test for PastPreferredTimeLead
*/ 
    @isTest static void testPastPreferredTimeLead() {
        TestSetup setup = createTestSetup('PastPreferredTimeLead');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should not be empty on success');
    }
    
    /**
* @description Test for SuccessResponseOnUpdate
*/ 
    @isTest static void testSuccessResponseOnUpdate() {
        TestSetup setup = createTestSetup('SuccessResponseOnUpdate');
        
        // Update lead
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Expressed_Interest_Product__c = setup.expressedInterests[1].Id;
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Expressed_Interest_Product__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areNotEqual(setup.expressedInterests[0].Id, updated.Expressed_Interest_Product__c,'Expressed_Interest_Product__c should not match');
    }
    
    /**
* @description Test for LeadQualify scenario
*/  
    @isTest static void testLeadQualify() {
        TestSetup setup = createTestSetup('LeadQualify');
        
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Status = 'Qualified';
        leadRecord[0].Dialer_Agent_Id__c = '123456';
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT OwnerId FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual(setup.testUser.Id, updated.OwnerId,' OwnerId should not match');
    }
    
    /**
* @description Test for LeadExpiry scenario
*/ 
    @isTest static void testLeadExpiry() {
        TestSetup setup = createTestSetup('LeadExpiry');
        
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Status = 'Unqualified';
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Stage__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Closed Lost', updated.Stage__c,'Lead has been expired in salesforce');
    }
    
    /**
* @description Test for withoutDailLerQueueId
*/ 
    @isTest static void testwithoutDailLerQueueId() {
        TestSetup setup = createTestSetup('withoutDailLerQueueId');
        
        Test.startTest();
        executeBatch(setup, 'Queuefailure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Dialler Queue ID is missing on the lead record.', updated.Dialer_Failure_Reason__c,'Lead failed because it does not have queue Id');
    }
    
    /**
* @description Test for IncorrectNumber
*/ 
    @isTest static void testIncorrectNumber() {
        TestSetup setup = createTestSetup('IncorrectNumber');
        
        Test.startTest();
        executeBatch(setup, 'Queuefailure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Invalid format detected for Mobile Phone or Phone.', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    }
    
    /**
* @description Test for FailureResponse
*/ 
    @isTest static void testFailureResponse() {
        TestSetup setup = createTestSetup('FailureResponse');
        
        Test.startTest();
        executeBatch(setup, 'failure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Invalid phone', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    } 
    
    /**
* @description Test for ServerFailure
*/ 
    @isTest static void testServerFailure() {
        TestSetup setup = createTestSetup('ServerFailure');
        
        Test.startTest();
        executeBatch(setup, 'ServerError');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex POST API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    } 
    
    /**
* @description Test for ScheduleMe
*/ 
    @isTest static void testScheduleMe() {
        Test.startTest();
        INS_BATCH_ConnexLead.scheduleMe();
        Test.stopTest(); 
    }
    
    /**
* @description Test for UpdateSuccessResponse
*/ 
    @isTest static void testUpdateSuccessResponse() {
        TestSetup setup = createTestSetup('UpdateSuccessResponse');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Reference Number matches');
        Assert.areEqual(null, updated.Dialer_Failure_Reason__c, 'Update Successful, failure Reason Should be Null');
    }
    
    /**
* @description Test for BuildErrorLeadFailure
*/ 
    @isTest static void testBuildErrorLeadFailure() {
        TestSetup setup = createTestSetup('BuildErrorLeadFailure');
        
        Test.startTest();
        
        executeBatch(setup, '502Error');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex POST API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should match the failure message');
    }
    
    /**
* @description Test for Update502Response
*/ 
    @isTest static void testUpdate502Response() {
        TestSetup setup = createTestSetup('Update502Response');
        
        Test.startTest();
        executeBatch(setup, '502Error');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex PUT API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should match the failure message');
    } 
    
    
    /**
* @description Test for GetObjectType
*/ 
    @isTest static void testGetObjectType() {
        INS_DTO_UpdateConnexLeadResponse dto = new INS_DTO_UpdateConnexLeadResponse();
        Type result = dto.getObjectType();
        Assert.areEqual(INS_DTO_UpdateConnexLeadResponse.class, result, 'The returned type should be INS_DTO_UpdateConnexLeadResponse');
    }
    
    
    /**
* @description Test parseNestedError with valid nested JSON containing 'errors' array
*/
    @isTest static void testParseNestedErrorWithErrorsArray() {
        String nestedJson = '{"errors":[{"detail":"This is an error detail","title":"Error Title"}]}';
        String result = INS_UTIL_ConnexLeads.parseNestedError(nestedJson);
        
        Assert.areEqual('This is an error detail', result, 'Should extract the detail from errors array');
    }
    
    /**
* @description Test parseNestedError with nested JSON containing 'errorMessage'
*/
    @isTest static void testParseNestedErrorWithErrorMessage() {
        String nestedJson = '{"error":{"errorMessage":"Nested error message here"}}';
        String result = INS_UTIL_ConnexLeads.parseNestedError(nestedJson);
        
        Assert.areEqual('Nested error message here', result, 'Should extract the errorMessage from nested error');
    }
    
    /**
* @description Test extractFromErrorsArray directly
*/
    @isTest static void testExtractFromErrorsArrayDirect() {
        List<Object> errorsList = new List<Object>{
            new Map<String, Object>{ 'detail' => 'First detail', 'title' => 'First title' },
                new Map<String, Object>{ 'detail' => 'Second detail', 'title' => 'Second title' }
        };
            
            String result = INS_UTIL_ConnexLeads.extractFromErrorsArray(errorsList);
        Assert.areEqual('First detail', result, 'Should return the detail of the first error object');
    }
    
    /**
* @description Test extractFromErrorsArray with title fallback
*/
    @isTest static void testExtractFromErrorsArrayWithTitleFallback() {
        List<Object> errorsList = new List<Object>{
            new Map<String, Object>{ 'title' => 'Only title here' }
        };
            
            String result = INS_UTIL_ConnexLeads.extractFromErrorsArray(errorsList);
        Assert.areEqual('Only title here', result, 'Should fallback to title when detail is missing');
    }
    
    /**
* @description Test extractErrorMessage using actual DTO structure
*/
    @isTest static void testExtractErrorMessageWithDTO() {
        INS_DTO_ConnexLeadsResponse dto1 = new INS_DTO_ConnexLeadsResponse();
        dto1.error = new INS_DTO_ConnexLeadsResponse.ConnexError();
        dto1.error.errorDescription = '{"error":[{"detail":"Provided credentials are invalid","title":"Unauthorized"}]}';
        
        String result1 = INS_UTIL_ConnexLeads.extractErrorMessage(dto1, 'Default error');
        Assert.areEqual('Provided credentials are invalid', result1, 'Should extract detail from nested errorDescription');
    }
    
    
    
    
    
    
}