/**
* @description       : Test class for Sell_Lead
* @LastModified       : Raja Arsalan
* @author            : Raja Arsalan
* @LastModifiedReason : Modified the class to add test for
*						testSelectLeadsForManualExpiry_MatchingLead
*						testSelectLeadsByRecIds_ValidIds
*
* Change log
* 2024-04-30   Derek Hughes    Added test for selectByIdWithNoRelatedAccount
* 2024-05-22                   Added code coverage only for existing methods without tests
* 2025-10-15   Raja Arsalan    Added tests for:
*                                  - testSelectByBulkDuplicateCriteria
*                                  - testSelectLeadsByDtoSearchCriteria
*                                  - testSelectLeadsEligibleForCourtesySMS
*                                  - testSelectLeadsToExpire
* 2026-01-28   Raja Arsalan    SFP-52529 - Renamed the test method and
*                                  updated the test logic accordingly.
* 2026-07-16.  Raja Arsalan    SFP-59422 - Updated the testSelectLeadsEligibleForCourtesySMS
*							   to execute under system admin and have lead admin permission.	
*=====================================================
 * @Last Modified By   : Anuja Alli
 * @Last Modified On   : Aug 8, 2026
 * @Modified Description : Added new method test coverage selectMostRecentlyCreatedLead
 * @ User Story : SFP-53980 
    
**/
@isTest
private class SEL_Lead_Test {
    
    private static final String LEAD_RT_GENERAL = 'General';
    private static final String PRODUCT_FAMILY_INSURANCE = 'Insurance';
    private static final String LEAD_TYPE_SBIB_DIALLER = 'SBIB DIALLER';
    private static final String LEAD_FIRST_NAME = 'Test';
    private static final String LEAD_LAST_NAME = 'Lead';
    private static final String TEST_COMPANY = 'Test Lead';
    private static final String LEAD_STATUS = 'New';
    private static final String LEAD_SOURCE = 'Retro';
    private static final String GENERAL_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(LEAD_RT_GENERAL).getRecordTypeId();
    
    /**
* @description Create basic test data for all test methods
* @author Derek Hughes | 04-04-2024 
**/
    @TestSetup
    public static void testSetUp() {
        
        final Lead testLeadForCampaign = new Lead(
            RecordTypeId = GENERAL_LEAD_RT_ID,
            Status = LEAD_STATUS,
            FirstName = 'Campaign',
            LastName = LEAD_LAST_NAME,
            Email = 'dummy@gmail.com',
            Campaign_Code__c = 'ABC123'
        );
        
        insert testLeadForCampaign;
        
        final Lead testLead = new Lead(
            RecordTypeId = GENERAL_LEAD_RT_ID,
            Status = LEAD_STATUS,
            FirstName = 'Web',
            LastName = LEAD_LAST_NAME
        );
        
        insert testLead;
        
        // Create a working Lead for an existing client - synched to org
        final Lead testLeadForClient = new Lead(
            RecordTypeId = GENERAL_LEAD_RT_ID,
            Status = 'Working',
            FirstName = 'Client',
            LastName = LEAD_LAST_NAME,
            Loan_Income_Amount__c = 500000,
            External_Client_Identifier__c = 'ZA010111111'
        );
        
        insert testLeadForClient;
        
        WI_DAL_DataFactory.createTestAccountAndLead();
        
    }
    
    /**
* @description       : Test method for Sell_Lead
* @author            : Raja Arsalan
**/    
    @isTest
    static void testSelectLeadByRecId() {
        // Create test data
        Lead testLead = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = TEST_COMPANY
        );
        insert testLead;
        
        SEL_Lead leadSelector = new SEL_Lead();
        
        List<Lead> selectedLeads = leadSelector.selectLeadByRecId(testLead.Id);
        Assert.areEqual(testLead.Id, selectedLeads[0].Id,'Lead Ids are same');
    }
    
    /**
* @description Test for selectByEmail  
* @author Krishna Ranjan| 22-05-2024 
**/
    @isTest
    static void selectByEmailTest() {
        
        Test.startTest();
        
        // Instantiate the selector class
        SEL_Lead leadSelector = new SEL_Lead(false, false, false);
        // Test the selectListOfLeadByEmail method
        List<Lead> selectedLeads = leadSelector.selectByEmail('dummy@gmail.com');
        Test.stopTest();
        
        Assert.areEqual(1, selectedLeads.size(), 'Lead Does not Exist');
        
    }
    
    /**
* @description Test for selectById
* @author Krishna Ranjan| 22-05-2024 
**/
    @isTest
    static void selectByIdTest() {
        Test.startTest();
        Lead testLeadRecord = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = TEST_COMPANY
        );
        insert testLeadRecord;
        SEL_Lead leadSelector = new SEL_Lead();
        Lead selectedLeads = leadSelector.selectById(testLeadRecord.Id);
        Test.stopTest();
        Assert.areEqual(testLeadRecord.Id, selectedLeads.Id,'Lead Ids are same');
        
    }
    
    /**
* @description Test for selectByIdHavingSystemReference
* @author Krishna Ranjan| 22-05-2024 
**/
    @isTest
    static void selectByIdHavingSystemReferenceTest() {
        Test.startTest();
        Lead testLeadRecord = new Lead(
            FirstName = LEAD_FIRST_NAME,
            LastName = LEAD_LAST_NAME,
            Company = TEST_COMPANY,
            Source_System_Reference__c = 'WhatMatters'
        );
        insert testLeadRecord;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> selectedLeads = leadSelector.selectByIdHavingSystemReference(testLeadRecord.Id);
        Test.stopTest();
        Assert.areEqual(1, selectedLeads.size(),'Lead Record has Source System Reference Value');
        
    }
    
    /**
* @description Test for selectUnlinkedLeads
* @author Derek Hughes | 22-05-2024 
**/
    @isTest
    static void selectByIdWithNoRelatedAccount() {
        
        Test.startTest();
        // Instantiate the selector class default constructor
        SEL_Lead leadSelector = new SEL_Lead();
        
        leadSelector.getSObjectFieldList();
        
        // Instantiate the selector class with other constructor
        leadSelector = new SEL_Lead(false, false, false);
        
        // Test the selectLeadByRecId method
        List<Lead> selectedLeads = leadSelector.selectByIdWithNoRelatedAccount(new Set<String>{'ZA010111111'});
        
        Test.stopTest();
        
        Assert.areEqual(1, selectedLeads.size(), 'Incorrect number of unlinked leads for client');
        
    }
    
    @isTest
    static void testSelectLeadByAccountId() {
        Lead testLead = [SELECT ID, FinServ__RelatedAccount__c FROM LEAD WHERE LastName = 'Test Lead X'];
        Account testAccount = [SELECT Id FROM Account WHERE Id = :testLead.FinServ__RelatedAccount__c LIMIT 1];
        
        SEL_Lead selector = new SEL_Lead();
        List<Lead> retrievedLead = selector.selectLeadByAccountId(testAccount.Id);
        Lead getlead = selector.selectLeadByLeadId(retrievedLead[0].Id);
        
        Assert.areEqual(testLead.Id, retrievedLead[0].Id, 'Expected to retrieve the correct Lead record.');
        Assert.IsNotNull(getLead.Id);
    }
    
    /**
* @description Test for SelectLeadsEligibleForCourtesySMS
* @author Raja Arsalan | 15-10-2025 
**/    
    @isTest
    static void testSelectLeadsEligibleForCourtesySMS() {
        
        User u = Insurance_TestDataFactory.createTestUser();
        u.FirstName = 'SBG';
        u.LastName = 'DATA User';
        u.Username = 'sbg.data.user@example.com.test';
        u.Email = 'sbg.data.user@example.com';
        insert u;
        
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Lead_Administrator'
            LIMIT 1
        ];
        
        System.runAs(u) {
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = ps.Id
            );
        }
        
        List<Leads_ProductQueueAllocation__c> expressedInterest = Insurance_TestDataFactory.createExpressInterest();
        expressedInterest[0].Leads_Jurisdiction__c = 'South Africa';
        insert expressedInterest;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'General' LIMIT 1];
        
        Lead lead;
        
        
        System.runAs(u) {
            lead = new Lead(
                FirstName = LEAD_FIRST_NAME,
                LastName = LEAD_LAST_NAME,
                Company = 'Test Company',
                LeadSource = 'Website',
                Status = 'Open',
                RecordTypeId = rt.Id,
                Expressed_Interest_Product__c = expressedInterest[0].Id
            );
            insert lead;
        }
        
        Set<Id> leadSet = new Set<Id>{ lead.Id };
            SEL_Lead selector = new SEL_Lead();
        Map<Id, Lead> retrievedLeads = selector.selectLeadsEligibleForCourtesySMS(leadSet);
        Assert.areEqual(1, retrievedLeads.size(), 'Lead should be retrieved as it meets all criteria');
        Assert.areEqual(lead.Id, retrievedLeads.keySet().iterator().next(), 'Lead Id should match');
    }
    
    /**
* @description Test for SelectLeadsToExpire
* @author Raja Arsalan | 15-10-2025 
**/    
    @isTest
    static void testSelectLeadsToExpire() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;
        
        Leads_ProductQueueAllocation__c expressedInterest = Insurance_TestDataFactory.createExpressInterest()[0];
        expressedInterest.Lead_Type__c = LEAD_TYPE_SBIB_DIALLER;
        expressedInterest.Leads_Product_Family__c = PRODUCT_FAMILY_INSURANCE;
        insert expressedInterest;
        
        Lead lead = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        lead.Expressed_Interest_Product__c = expressedInterest.Id;
        lead.Referred_System_Reference_Number__c = 'REF-123';
        lead.OwnerId = u.Id;
        lead.LeadSource = LEAD_SOURCE;
        insert lead;
        
        List<string> statuses = new List<string>{LEAD_STATUS};
            SEL_Lead selector = new SEL_Lead();
        List<Lead> results = selector.selectLeadsToExpire(statuses, LEAD_SOURCE, LEAD_TYPE_SBIB_DIALLER, PRODUCT_FAMILY_INSURANCE);
        
        Assert.areEqual(0, results.size(), 'Expected 0 lead to expire because lead is created within last 30 days');
    }
    
    /**
* @description Test for SelectLeadsByTypeAndDateFilters
* @author Raja Arsalan | 15-10-2025 
**/        
    
    @isTest
    static void testSelectLeadsByDtoSearchCriteria() {
        
        // Test User
        User testUser = Insurance_TestDataFactory.createTestUser();
        insert testUser;
        
        
        List<Leads_ProductQueueAllocation__c> expressedInterest =
            Insurance_TestDataFactory.createExpressInterest();
        expressedInterest[0].Lead_Type__c = LEAD_TYPE_SBIB_DIALLER;
        expressedInterest[0].Leads_Product_Family__c = PRODUCT_FAMILY_INSURANCE;
        insert expressedInterest;
        
        
        Lead validLead = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        validLead.Expressed_Interest_Product__c = expressedInterest[0].Id;
        validLead.Preferred_Contact_Date_Time__c = System.now().addMinutes(-10);
        validLead.Preferred_Contact_Date_Time_End__c = System.now().addMinutes(10);
        validLead.Email = 'ali.test@example.com';
        validLead.Phone = '123456789';
        validLead.IsConverted = false;
        validLead.OwnerId = testUser.Id;
        insert validLead;
        
        
        INS_DTO_LeadSearchCriteria criteria = new INS_DTO_LeadSearchCriteria();
        criteria.leadType = LEAD_TYPE_SBIB_DIALLER;
        criteria.connexDate = System.now().addDays(-1);
        criteria.productFamily = PRODUCT_FAMILY_INSURANCE;
        criteria.searchKey = 'ali';
        criteria.startDate = System.now().addDays(-2);
        criteria.endDate = System.now().addDays(2);
        criteria.isReport = false;
        
       
        SEL_Lead selector = new SEL_Lead();
        List<Lead> results =
            selector.selectLeadsByDtoSearchCriteria(criteria);
        
        
        Assert.areEqual(1, results.size(), 'Expected one lead to be returned');
    }
    
    /**
* @description Test for selectByBulkDuplicateCriteria
* @author Raja Arsalan | 15-10-2025 
**/    
    
    @isTest
    static void testselectByBulkDuplicateCriteria() {
        
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;
        
        Leads_ProductQueueAllocation__c expressedInterest = Insurance_TestDataFactory.createExpressInterest()[0];
        expressedInterest.Lead_Type__c = LEAD_TYPE_SBIB_DIALLER;
        expressedInterest.Leads_Product_Family__c = PRODUCT_FAMILY_INSURANCE;
        insert expressedInterest;
        
        Lead lead1 = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        lead1.Expressed_Interest_Product__c = expressedInterest.Id;
        lead1.Referred_System_Reference_Number__c = 'Duplicate';
        lead1.OwnerId = u.Id;
        lead1.LeadSource = LEAD_SOURCE;
        insert lead1;
        
        
        Lead lead2 = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        lead2.LastName = lead1.LastName;
        lead2.MobilePhone = lead1.MobilePhone;
        lead2.Campaign_Source_ID__c = lead1.Campaign_Source_ID__c;
        lead2.OwnerId = u.Id;
        insert lead2;
        
        
        Set<String> lastNames = new Set<String>{lead1.LastName};
            Set<String> campaignSourceIds = new Set<String>{lead1.Campaign_Source_ID__c};
                Set<String> mobilePhones = new Set<String>{lead1.MobilePhone};
                    SEL_Lead selector = new SEL_Lead();
        List<Lead> results = selector.selectByBulkDuplicateCriteria(
            lastNames,
            campaignSourceIds,
            mobilePhones
        );
        
        Assert.areEqual(1, results.size(),'Expected lead to be returned by duplicate criteria');
    }
    
    @isTest
    static void testSelectLeadsByRecIds_ValidIds() {
        Lead lead1 = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        lead1.FirstName = LEAD_FIRST_NAME;
        lead1.LastName = LEAD_LAST_NAME;
    
        Lead lead2 = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        lead2.FirstName = LEAD_FIRST_NAME;
        lead2.LastName = 'Lead Two';
        
        insert new List<Lead>{ lead1, lead2 };
            
            SEL_Lead selector = new SEL_Lead();
        
        Test.startTest();
        List<Lead> results = selector.selectLeadsByRecIds(new List<Id>{ lead1.Id, lead2.Id });
        Test.stopTest();
        
        Assert.areEqual(2, results.size(), 'Expected 2 leads to be returned');
        
    }
    
    @isTest
    static void testSelectLeadsForManualExpiry_MatchingLead() {
        
        Leads_ProductQueueAllocation__c expressedInterest = new Leads_ProductQueueAllocation__c(
            Lead_Type__c = LEAD_TYPE_SBIB_DIALLER,
            Leads_Product_Family__c = PRODUCT_FAMILY_INSURANCE
        );
        insert expressedInterest;
        
        
        Lead testLead = Insurance_TestDataFactory.createLead(LEAD_RT_GENERAL);
        testLead.FirstName = LEAD_FIRST_NAME;
        testLead.LastName = LEAD_LAST_NAME;
        testLead.Status = LEAD_STATUS;
        testLead.Campaign_Name__c = 'Retro Campaign';
        testLead.Email = 'testlead@example.com';
        testLead.Phone = '1234567890';
        testLead.Expressed_Interest_Product__c = expressedInterest.Id;
        insert testLead;
        
        
        
        INS_DTO_LeadSearchCriteria criteria = new INS_DTO_LeadSearchCriteria();
        criteria.connexDate = System.now().addDays(-1);
        criteria.startDate = System.now().addDays(-1);
        criteria.endDate = System.now().addDays(1);
        criteria.leadType = LEAD_TYPE_SBIB_DIALLER;
        criteria.productFamily = PRODUCT_FAMILY_INSURANCE;
        criteria.status = LEAD_STATUS;
        criteria.campaignName = LEAD_SOURCE;
        criteria.searchKey = 'testlead@example.com';
        
        SEL_Lead selector = new SEL_Lead();
        
        Test.startTest();
        List<Lead> results = selector.selectLeadsForManualExpiry(criteria);
        Test.stopTest();
        
        Assert.areEqual(testLead.Id, results[0].Id, 'Expected created lead to be returned');
    }
     /**
    * @description Test method for selectMostRecentlyCreatedLead
    */
    @isTest
    static void testSelectMostRecentlyCreatedLead() {
        Lead latestLead = new Lead(
            FirstName = 'Latest',
            LastName = 'Test Lead',
            Company = 'Latest Test Company'
        );
        insert latestLead;

        SEL_Lead selector = new SEL_Lead();

        Test.startTest();
        List<Lead> results = selector.selectMostRecentlyCreatedLead();
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Expected only one Lead to be returned');
        Assert.areEqual(
            latestLead.Id,
            results[0].Id,
            'Expected the most recently created Lead to be returned'
        );
    }
    
    
}