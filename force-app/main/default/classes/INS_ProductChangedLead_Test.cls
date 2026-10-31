@IsTest
private class INS_ProductChangedLead_Test {

    private class TestSetupData {
        public User testUser;
        public List<Campaign> campaigns;
        public List<Leads_ProductQueueAllocation__c> expressedInterests;
        public Lead lead;
    }

    private static TestSetupData createTestSetup() {

        TestSetupData setup = new TestSetupData();

        setup.testUser = Insurance_TestDataFactory.createTestUser();
        insert setup.testUser;

        setup.campaigns = Insurance_TestDataFactory.createCampaigns();
        insert setup.campaigns;

        setup.expressedInterests =
            Insurance_TestDataFactory.createExpressInterest();
        insert setup.expressedInterests;

        setup.lead = Insurance_TestDataFactory.createLead('General');

        setup.lead.OwnerId = setup.testUser.Id;
        setup.lead.Expressed_Interest_Product__c =
            setup.expressedInterests[0].Id;

        // Existing Dialler Lead
        setup.lead.Referred_System_Reference_Number__c =
            'existing-ref';

        insert setup.lead;

        return setup;
    }

    @IsTest
    static void testProductChangedLeadHappyPath() {

        TestSetupData setup = createTestSetup();

        // Simulate Product Change
       CMN_TRH_Lead.skipConnexCallout = true;

Lead leadToUpdate = new Lead(
    Id = setup.lead.Id,
    Expressed_Interest_Product__c =
        setup.expressedInterests[1].Id
);

update leadToUpdate;

CMN_TRH_Lead.skipConnexCallout = false;
        // Mock
        INS_Leads_API.mockScenario = 'success';
        INS_Leads_API.testLeadId = setup.lead.Id;

        Test.setMock(
            HttpCalloutMock.class,
            new INS_LeadsAPI_Mock()
        );

        Lead leadToProcess = [
            SELECT Id,
                   OwnerId,
                   MobilePhone,
                   Phone,
                   Campaign_Name__c,
                   Dialler_Queue_ID__c,
                   Referred_System_Reference_Number__c,
                   Expressed_Interest_Product__c,
                   Status
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        Test.startTest();

        INS_UTIL_ConnexLeads.processProductChangedLeads(
            new List<Lead>{ leadToProcess }
        );

        Test.stopTest();

        Lead updatedLead = [
            SELECT Id,
                   Expressed_Interest_Product__c,
                   Referred_System_Reference_Number__c,
                   Dialer_Failure_Reason__c
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        Assert.areEqual(
            setup.expressedInterests[1].Id,
            updatedLead.Expressed_Interest_Product__c,
            'Product should be updated'
        );

        Assert.areEqual(
            null,
            updatedLead.Dialer_Failure_Reason__c,
            'Failure reason should be blank'
        );
    }
}