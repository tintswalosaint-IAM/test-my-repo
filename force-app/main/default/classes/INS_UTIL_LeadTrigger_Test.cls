/**
* @description       : Test for INS_UTIL_LeadTrigger
* @author            : Raja Arsalan
* @group             : Lead
* @last modified on  : 10-06-2026
* @last modified by  : Raja Arsalan
* @UserStory         : SFP-58785
* @LastModifiedReason : Updated the test class to add a method
for testing bulk lead insertion.
**/
@isTest
public with sharing class INS_UTIL_LeadTrigger_Test {
    
    /**
* @description Test for testmaintainAccount
*/
    
    @isTest
    static void testmaintainAccount(){
        CMN_TRH_Lead.skipConnexCallout = true;
        INS_Insurance_Lead_Settings__mdt holidaySetting = Insurance_TestDataFactory.createMockPublicHolidaySettings();
        Set<String> holidays = new Set<String>();
        if (holidaySetting != null && String.isNotBlank(holidaySetting.INS_HolidayDates__c)) {
            holidays.addAll(holidaySetting.INS_HolidayDates__c.split(';'));
        }
        List<Campaign> camp = Insurance_TestDataFactory.createCampaigns();
        Insert camp;
        
        List<Leads_ProductQueueAllocation__c> expressedInterest = Insurance_TestDataFactory.createExpressInterest();
        insert expressedInterest; 
        Lead ld = Insurance_TestDataFactory.createLead('General');
        ld.Referred_System_Reference_Number__c = '12345';
        ld.Campaign_Source_ID__c = '907';
        ld.Expressed_Interest_Product__c = expressedInterest[0].Id;
        Insert ld;
        CMN_TRH_Lead.skipConnexCallout = false;
        INS_UTIL_LeadTrigger.cloneLeadForConnex(ld);
        SEL_Lead leadSelector = new SEL_Lead();
        List<lead> leadRecord = leadSelector.selectLeadByRecId(ld.Id);
        INS_UTIL_LeadTrigger.createCampaignMemberBasedOnBusinessHours(leadRecord[0],camp,holidays);
        CampaignMember campMember = [Select id,leadId from campaignMember where leadId =: leadRecord[0].Id limit 1];
        Assert.areEqual(leadRecord[0].Id,campMember.LeadId , 'Lead Id should Match');
        
    } 
    
    /**
* @description Test for DuplicateLeadDetection
*/
    @isTest
    static void testDuplicateLeadDetection() {
        List<Leads_ProductQueueAllocation__c> productQueues = Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        Lead existingLead = Insurance_TestDataFactory.createLead('General');
        existingLead.LastName = 'DuplicateTest';
        existingLead.MobilePhone = '+27821234567';
        existingLead.Campaign_Source_ID__c = 'TEST123';
        existingLead.Expressed_Interest_Product__c = productQueues[0].Id;
        existingLead.LeadSource = 'RETRO';
        existingLead.Status = 'New';
        existingLead.CreatedDate = System.now().addDays(-10); // Within 30 days
        insert existingLead;
        
        Test.startTest();
        
        CMN_TRH_Lead.skipConnexCallout = true;
        Lead newDuplicateLead = Insurance_TestDataFactory.createLead('General');
        newDuplicateLead.LastName = 'DuplicateTest';
        newDuplicateLead.MobilePhone = '+27821234567';
        newDuplicateLead.Campaign_Source_ID__c = 'TEST123';
        newDuplicateLead.Expressed_Interest_Product__c = productQueues[0].Id;
        newDuplicateLead.LeadSource = 'RETRO';
        insert newDuplicateLead;
        
        Test.stopTest();
        Lead verifiedNewLead = [SELECT Id, Referred_System_Reference_Number__c 
                                FROM Lead 
                                WHERE Id = :newDuplicateLead.Id];
        Assert.areEqual('Duplicate', verifiedNewLead.Referred_System_Reference_Number__c, 
                        'Lead should be marked as duplicate');
        
        List<Task> duplicateTasks = [SELECT Id, WhoId, Subject, Description 
                                     FROM Task 
                                     WHERE WhoId = :existingLead.Id];
        
        Assert.isFalse(duplicateTasks.isEmpty(), 'Duplicate task should be created');
        Assert.areEqual('Duplicate Lead Attempt', duplicateTasks[0].Subject, 
                        'Task subject should indicate duplicate attempt');
    }
    
    /**
* @description Test for NonDuplicateLeadScenario
*/
    
    @isTest
    static void testNonDuplicateLeadScenario() {
        
        List<Leads_ProductQueueAllocation__c> productQueues = Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        CMN_TRH_Lead.skipConnexCallout = true;
        Lead oldLead = Insurance_TestDataFactory.createLead('General');
        oldLead.LastName = 'OldTest';
        oldLead.MobilePhone = '27821112233';
        oldLead.Campaign_Source_ID__c = 'OLDTEST';
        oldLead.Expressed_Interest_Product__c = productQueues[0].Id;
        oldLead.LeadSource = 'Other';
        oldLead.Status = 'New';
        oldLead.CreatedDate = System.now().addDays(-40);
        insert oldLead;
        
        Test.startTest();
        
        CMN_TRH_Lead.skipConnexCallout = true;
        
        Lead newLead = Insurance_TestDataFactory.createLead('General');
        newLead.LastName = 'OldTest';
        newLead.MobilePhone = '27821112233';
        newLead.Campaign_Source_ID__c = 'OLDTEST';
        newLead.Expressed_Interest_Product__c = productQueues[0].Id;
        newLead.LeadSource = 'Other';
        
        insert newLead;
        
        Test.stopTest();
        
        Lead verifiedLead = [SELECT Referred_System_Reference_Number__c 
                             FROM Lead 
                             WHERE Id = :newLead.Id];
        
        Assert.areNotEqual('Duplicate', verifiedLead.Referred_System_Reference_Number__c, 
                           'Lead should not be duplicate when matching lead is expired');
    }
    
    /**
* @description Test for InactiveStatusNotDuplicate
*/    
    
    @isTest
    static void testInactiveStatusNotDuplicate() {
        List<Leads_ProductQueueAllocation__c> productQueues = Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        
        CMN_TRH_Lead.skipConnexCallout = true;
        Lead inactiveLead = Insurance_TestDataFactory.createLead('General');
        inactiveLead.LastName = 'InactiveTest';
        inactiveLead.MobilePhone = '0027825556677';
        inactiveLead.Campaign_Source_ID__c = 'INACTIVETEST';
        inactiveLead.Expressed_Interest_Product__c = productQueues[0].Id;
        inactiveLead.LeadSource = 'RETRO';
        inactiveLead.Status = 'Unqualified';
        inactiveLead.CreatedDate = System.now().addDays(-10);
        insert inactiveLead;
        
        Test.startTest();
        
        CMN_TRH_Lead.skipConnexCallout = true;
        
        Lead newLead = Insurance_TestDataFactory.createLead('General');
        newLead.LastName = 'InactiveTest';
        newLead.MobilePhone = '0027825556677';
        newLead.Campaign_Source_ID__c = 'INACTIVETEST';
        newLead.Expressed_Interest_Product__c = productQueues[0].Id;
        newLead.LeadSource = 'RETRO';
        
        
        insert newLead;
        
        Test.stopTest();
        
        Lead verifiedLead = [SELECT Referred_System_Reference_Number__c 
                             FROM Lead 
                             WHERE Id = :newLead.Id];
        
        Assert.areNotEqual('Duplicate', verifiedLead.Referred_System_Reference_Number__c, 
                           'Lead should not be duplicate when matching lead is inactive');
    }
    
    /**
* @description Test for DifferentLeadSourcesNotDuplicate
*/
    @isTest
    static void testDifferentLeadSourcesNotDuplicate() {
        List<Leads_ProductQueueAllocation__c> productQueues = Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        
        CMN_TRH_Lead.skipConnexCallout = true;
        Lead nonRetroLead = Insurance_TestDataFactory.createLead('General');
        nonRetroLead.LastName = 'SourceTest';
        nonRetroLead.MobilePhone = '+27823334455';
        nonRetroLead.Campaign_Source_ID__c = 'SOURCETEST';
        nonRetroLead.Expressed_Interest_Product__c = productQueues[0].Id;
        nonRetroLead.LeadSource = 'NON-RETRO';
        nonRetroLead.Status = 'New';
        nonRetroLead.CreatedDate = System.now().addDays(-10);
        insert nonRetroLead;
        
        Test.startTest();
        
        
        Lead retroLead = Insurance_TestDataFactory.createLead('General');
        retroLead.LastName = 'SourceTest';
        retroLead.MobilePhone = '+27823334455';
        retroLead.Campaign_Source_ID__c = 'SOURCETEST';
        retroLead.Expressed_Interest_Product__c = productQueues[0].Id;
        retroLead.LeadSource = 'RETRO';
        
        insert retroLead;
        
        Test.stopTest();
        
        Lead verifiedLead = [SELECT Referred_System_Reference_Number__c 
                             FROM Lead 
                             WHERE Id = :retroLead.Id];
        
        Assert.areNotEqual('Duplicate', verifiedLead.Referred_System_Reference_Number__c, 
                           'Leads with different sources should not be duplicates');
        
        List<Task> duplicateTasks = [SELECT Id FROM Task WHERE WhoId = :nonRetroLead.Id];
        Assert.isTrue(duplicateTasks.isEmpty(), 'No duplicate task should be created for different lead sources');
    }
    
    /**
* @description Test for NonRetroOver30DaysStatusSpecific
*/
    @isTest
    static void testNonRetroOver30DaysStatusSpecific() {
        List<Leads_ProductQueueAllocation__c> productQueues = Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        CMN_TRH_Lead.skipConnexCallout = true;
        
        // Create existing leads with unique last names
        List<Lead> existingLeads = new List<Lead>();
        
        Lead existingNew = Insurance_TestDataFactory.createLead('General');
        existingNew.LastName = 'TestNew'; existingNew.MobilePhone = '27821111111'; existingNew.Campaign_Source_ID__c = 'TESTNEW';
        existingNew.Expressed_Interest_Product__c = productQueues[0].Id; existingNew.LeadSource = 'NON-RETRO'; existingNew.Status = 'New'; existingNew.CreatedDate = System.now().addDays(-40);
        
        Lead existingWorking = Insurance_TestDataFactory.createLead('General'); 
        existingWorking.LastName = 'TestWorking'; existingWorking.MobilePhone = '27822222222'; existingWorking.Campaign_Source_ID__c = 'TESTWORKING';
        existingWorking.Expressed_Interest_Product__c = productQueues[0].Id; existingWorking.LeadSource = 'NON-RETRO'; existingWorking.Status = 'Working'; existingWorking.CreatedDate = System.now().addDays(-40);
        
        Lead existingWaiting = Insurance_TestDataFactory.createLead('General');
        existingWaiting.LastName = 'TestWaiting'; existingWaiting.MobilePhone = '27823333333'; existingWaiting.Campaign_Source_ID__c = 'TESTWAITING';
        existingWaiting.Expressed_Interest_Product__c = productQueues[0].Id; existingWaiting.LeadSource = 'NON-RETRO'; existingWaiting.Status = 'Waiting for Customer'; existingWaiting.CreatedDate = System.now().addDays(-40);
        
        insert new List<Lead>{existingNew, existingWorking, existingWaiting};
            
            Test.startTest();
        
        // Create new leads using factory directly
        List<Lead> newLeads = new List<Lead>();
        
        Lead new1 = Insurance_TestDataFactory.createLead('General');
        new1.LastName = 'TestNew'; new1.MobilePhone = '27821111111'; new1.Campaign_Source_ID__c = 'TESTNEW';
        new1.Expressed_Interest_Product__c = productQueues[0].Id; new1.LeadSource = 'NON-RETRO';
        
        Lead new2 = Insurance_TestDataFactory.createLead('General');
        new2.LastName = 'TestWorking'; new2.MobilePhone = '27822222222'; new2.Campaign_Source_ID__c = 'TESTWORKING';
        new2.Expressed_Interest_Product__c = productQueues[0].Id; new2.LeadSource = 'NON-RETRO';
        
        Lead new3 = Insurance_TestDataFactory.createLead('General');
        new3.LastName = 'TestWaiting'; new3.MobilePhone = '27823333333'; new3.Campaign_Source_ID__c = 'TESTWAITING';
        new3.Expressed_Interest_Product__c = productQueues[0].Id; new3.LeadSource = 'NON-RETRO';
        
        
        insert new List<Lead>{new1, new2, new3};
            
            Test.stopTest();
        
        // Verify by specific last names
        Map<String, Lead> resultMap = new Map<String, Lead>();
        for(Lead ld : [SELECT LastName, Referred_System_Reference_Number__c FROM Lead WHERE LastName IN ('TestNew','TestWorking','TestWaiting')]) {
            resultMap.put(ld.LastName, ld);
        }
        
        Assert.areNotEqual('Duplicate', resultMap.get('TestNew').Referred_System_Reference_Number__c, 'Status=New >30 days: NOT duplicate');
        Assert.areEqual('Duplicate', resultMap.get('TestWorking').Referred_System_Reference_Number__c, 'Status=Working >30 days: DUPLICATE');
        Assert.areEqual('Duplicate', resultMap.get('TestWaiting').Referred_System_Reference_Number__c, 'Status=Waiting >30 days: DUPLICATE');
    }
    
    
    /**
* @description Test for Bulk leads insertion.
*/
    @isTest
    static void testBulkDuplicateLeadScenario() {
        
        List<Leads_ProductQueueAllocation__c> productQueues =
            Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        
        CMN_TRH_Lead.skipConnexCallout = true;
        
        
        List<Lead> sameLeads = new List<Lead>();
        
        for (Integer i = 0; i < 5; i++) {
            
            Lead ld = Insurance_TestDataFactory.createLead('General');
            
            ld.LastName = 'BulkSame';
            ld.MobilePhone = '7700111122';
            ld.Campaign_Source_ID__c = 'TESTBULK';
            ld.Expressed_Interest_Product__c = productQueues[0].Id;
            ld.LeadSource = 'RETRO';
            ld.Status = 'New';
            
            sameLeads.add(ld);
        }
        
        insert sameLeads;
        
        
        List<Lead> uniqueLeads = new List<Lead>();
        
        for (Integer i = 0; i < 5; i++) {
            
            Lead ld = Insurance_TestDataFactory.createLead('General');
            
            ld.LastName = 'BulkUnique';
            ld.MobilePhone = '77002222' + String.valueOf(10 + i);
            ld.Campaign_Source_ID__c = 'TESTBULK';
            ld.Expressed_Interest_Product__c = productQueues[0].Id;
            ld.LeadSource = 'RETRO';
            ld.Status = 'New';
            
            uniqueLeads.add(ld);
        }
        
        insert uniqueLeads;
        
        Test.startTest();
        
        Test.stopTest();
        
        
        List<Task> duplicateTasks = [
            SELECT Id, WhoId, Subject
            FROM Task
            WHERE Subject = 'Duplicate Lead Attempt'
        ];
        
        Assert.isTrue(
            duplicateTasks.size() > 0,
            'Duplicate tasks should be created for same leads'
        );
    }
    
    
    
    
    
    /**
* @description Test for leadInfoChanged
*/
    @isTest
    static void testLeadInfoChanged() {
        
        List<Leads_ProductQueueAllocation__c> productQueues =
            Insurance_TestDataFactory.createExpressInterest();
        insert productQueues;
        
        CMN_TRH_Lead.skipConnexCallout = true;
        
        Lead oldLead = Insurance_TestDataFactory.createLead('General');
        oldLead.FirstName = 'John';
        oldLead.LastName = 'LeadInfo';
        oldLead.MobilePhone = '27821110000';
        oldLead.Phone = '0111111111';
        oldLead.Email = 'old@test.com';
        oldLead.Title = 'Mr';
        oldLead.Description = 'Old Description';
        oldLead.Status = 'New';
        oldLead.LeadSource = 'RETRO';
        oldLead.Campaign_Source_ID__c = 'LEADINFO';
        oldLead.Referred_System_Reference_Number__c = 'REF001';
        oldLead.Loan_Account_Number__c = 'LN001';
        oldLead.SA_ID_or_Passport__c = '8001015009087';
        oldLead.Expressed_Interest_Product__c = productQueues[0].Id;
        
        insert oldLead;
        
        // ===== SAME DATA =====
        Lead sameLead = oldLead.clone(false, true, false, false);
        
        Boolean noChanges =
            INS_UTIL_LeadTrigger.leadInfoChanged(sameLead, oldLead);
        
        Assert.areEqual(
            false,
            noChanges,
            'Should return false when nothing changed'
        );
        
        Lead changedLead = oldLead.clone(false, true, false, false);
        changedLead.Email = 'new@test.com';
        
        Boolean hasChanges =
            INS_UTIL_LeadTrigger.leadInfoChanged(changedLead, oldLead);
        
        Assert.areEqual(
            true,
            hasChanges,
            'Should return true when fields are changed'
        );
        
    }
    
    
    
}