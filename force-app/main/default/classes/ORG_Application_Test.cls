/**
* @description      : SFP-53562: Test class to test the functionality of ORG_Application_Test.cls
* @last Modified 	: Jaco de Lange - 22-10-2025
* @modification		: SFP-53279 - create additional test data to cover code coverage
* 
*@description : SFP-54443 - Added testSetup Data to increase the code coverage
* @last Modified : Amlendu Bajpai - 10-07-2026

*@description : SFP-55625 - Added CaseMilestoneMetrics test data to cover the code coverage.
* @last Modified : Given Khupai - 04-08-2026

*@description : SFP-55625 - Removed the mockHasAccessResult guard in
*  testUnitOfWorkCanCommitCaseMilestoneMetricPositiveOutcome - that field no longer
*  exists on INS_UTIL_BusinessHoursCalcHelper (hasAccessToCaseTaT() was removed), and
*  the guard was unnecessary anyway since a bare Case insert with no TAT dates set
*  never satisfies INS_SRV_CaseMilestoneMetrics.createNewMetric()'s create conditions.
* @last Modified : Given Khupai - 20-08-2026

*@description : SFP-55625 - testUnitOfWorkCanCommitCaseMilestoneMetricPositiveOutcome was
*  flaky: real org automation on Case insert can non-deterministically create its own
*  CMN_CaseMilestoneMetric__c (depending on business-hours/routing automation), which made
*  the "Expected: 1" count assertion fail intermittently. Now deletes any such
*  automation-created metric before the explicit UnitOfWork commit under test.
* @last Modified : Given Khupai - 26-08-2026
**/
@IsTest
public class ORG_Application_Test { 
    
    @TestSetup
    static void setupTestData() {
        
        Contact con = new Contact (
        	LastName = 'Test LastName'
        );
        insert con;
        Schema.RecordTypeInfo rtInfo =
            Schema.SObjectType.Lead
                .getRecordTypeInfosByDeveloperName()
                .get('SBFC_Lead');
        
        // Create test records that might be needed for selector tests
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Lead',
            Status = 'Nurturing',
            Stage__c = 'In Progress – Awaiting Signed Disclosure',
            RecordTypeId = rtInfo.getRecordTypeId(),
            FinServ__ReferredByContact__c = con.Id
        );
        insert testLead;
        
       
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        PartyProfile testPartyProfile = new PartyProfile(
            Name = 'Test Party Profile',
            AccountId = testAccount.Id
            // Add other required fields
        );
        insert testPartyProfile;
    }
    
    @IsTest
    static void testSelectorFactory() {
        Test.startTest();
        
        // Test Lead selector
        Object leadSelector = ORG_Application.selector.newInstance(Lead.SObjectType);
        Assert.isTrue(leadSelector instanceof sbgplatform.fflib_SObjectSelector, 'Lead selector should be an instance of fflib_SObjectSelector');
        
        // Test Application__c selector
        Object applicationSelector = ORG_Application.selector.newInstance(Application__c.SObjectType);
        Assert.isTrue(applicationSelector instanceof sbgplatform.fflib_SObjectSelector, 'Application__c selector should be an instance of fflib_SObjectSelector');
        
        // Test User selector
        Object userSelector = ORG_Application.selector.newInstance(User.SObjectType);
        Assert.isTrue(userSelector instanceof sbgplatform.fflib_SObjectSelector, 'User selector should be an instance of fflib_SObjectSelector');
        
        // Test Case selector
        Object caseSelector = ORG_Application.selector.newInstance(Case.SObjectType);
        Assert.isTrue(caseSelector instanceof sbgplatform.fflib_SObjectSelector, 'Case selector should be an instance of fflib_SObjectSelector');
         
        Test.stopTest();
        
        // Additional assertions to verify selector functionality
        if (leadSelector instanceof sbgplatform.fflib_SObjectSelector) {
            sbgplatform.fflib_SObjectSelector typedLeadSelector = (sbgplatform.fflib_SObjectSelector)leadSelector;
            Assert.areEqual(Lead.SObjectType, typedLeadSelector.getSObjectType(), 'Lead selector should return Lead SObjectType');
        }
        
        if (applicationSelector instanceof sbgplatform.fflib_SObjectSelector) {
            sbgplatform.fflib_SObjectSelector typedApplicationSelector = (sbgplatform.fflib_SObjectSelector)applicationSelector;
            Assert.areEqual(Application__c.SObjectType, typedApplicationSelector.getSObjectType(), 'Application__c selector should return Application__c SObjectType');
        }  
    }
    
    @IsTest
    static void testServiceFactory() {
        Test.startTest();
        Assert.isNotNull(ORG_Application.service, 'Service factory should be initialized');
        Test.stopTest();
    }
    
    @IsTest
    static void testUnitOfWorkFactory() {
        Test.startTest();
        Assert.isNotNull(ORG_Application.unitOfWork, 'UnitOfWork factory should be initialized');
        Assert.isNotNull(ORG_Application.unitOfWorkRegisteredTypes, 'UnitOfWork types should be initialized');
        Assert.isTrue(ORG_Application.unitOfWorkRegisteredTypes.size() > 0, 'UnitOfWork types should not be empty');
        Test.stopTest();
    }

    /**
    * @description : SFP-55625 Regression guard - CMN_CaseMilestoneMetric__c must stay registered
    *                with the UnitOfWork factory. When it was missing, INS_SRV_CaseMilestoneMetrics
    *                silently failed to insert/update metric records: unitOfWork.registerNew() threw
    *                an unsupported-SObjectType exception that was caught and only logged by the
    *                calling service, so Case updates kept succeeding while no metric was ever created.
    **/
    @IsTest
    static void testUnitOfWorkRegisteredTypesIncludesCaseMilestoneMetricPositiveOutcome() {
        Test.startTest();
        Boolean isRegistered = ORG_Application.unitOfWorkRegisteredTypes.contains(CMN_CaseMilestoneMetric__c.SObjectType);
        Test.stopTest();

        Assert.isTrue(
            isRegistered,
            'CMN_CaseMilestoneMetric__c must be registered with the UnitOfWork factory, otherwise Case Milestone Metrics silently fail to save'
        );
    }

    /**
    * @description : SFP-55625 Functional companion to the check above - proves the UnitOfWork can
    *                actually commit a CMN_CaseMilestoneMetric__c record, not just that the type is
    *                present in the list.
    **/
    @IsTest
    static void testUnitOfWorkCanCommitCaseMilestoneMetricPositiveOutcome() {
        Account testAccount = new Account(Name = 'Test Account UoW Metric');
        insert testAccount;

        Case testCase = new Case(
            Subject = 'Test Case UoW Metric',
            Status = 'New',
            Origin = 'Email',
            AccountId = testAccount.Id
        );
        insert testCase;

        // SFP-55625: Case insert can trigger real org automation (e.g. Case
        // allocation flows) that non-deterministically creates its own
        // CMN_CaseMilestoneMetric__c for this Case, depending on business-hours
        // / routing automation outside this test's control. Clear it so the
        // count assertion below reflects only the explicit UnitOfWork commit
        // this test is verifying.
        delete [
            SELECT Id
            FROM CMN_CaseMilestoneMetric__c
            WHERE CMN_Case__c = :testCase.Id
        ];

        sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c(
            CMN_Case__c = testCase.Id
        );

        Test.startTest();
        unitOfWork.registerNew(metric);
        unitOfWork.commitWork();
        Test.stopTest();

        List<CMN_CaseMilestoneMetric__c> insertedMetrics = [
            SELECT Id, CMN_Case__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE CMN_Case__c = :testCase.Id
        ];

        Assert.areEqual(
            1,
            insertedMetrics.size(),
            'UnitOfWork should successfully insert CMN_CaseMilestoneMetric__c when the type is registered in ORG_Application'
        );
    }
}